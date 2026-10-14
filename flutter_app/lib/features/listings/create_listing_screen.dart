import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import '../../core/constants/app_constants.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/utils/validators.dart';
import '../../models/equipment_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/equipment_provider.dart';
import '../../services/upload_service.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_text_field.dart';
import '../../widgets/network_image_with_fallback.dart';

class CreateListingScreen extends ConsumerStatefulWidget {
  final String? editEquipmentId;

  const CreateListingScreen({
    super.key,
    this.editEquipmentId,
  });

  @override
  ConsumerState<CreateListingScreen> createState() => _CreateListingScreenState();
}

class _CreateListingScreenState extends ConsumerState<CreateListingScreen> {
  final _formKey = GlobalKey<FormState>();

  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _rentalPriceController = TextEditingController();
  final _purchasePriceController = TextEditingController();
  final _buildingController = TextEditingController();
  final _roomController = TextEditingController();
  final _cityController = TextEditingController();
  final _stateController = TextEditingController();

  String _category = 'microscopy';
  String _condition = 'excellent';
  String _listingType = 'rent';
  String _rentalPricingUnit = 'day';

  final List<EquipmentImage> _images = [];
  final List<Map<String, String>> _specs = [];

  bool _isLoading = false;
  bool _isUploadingImage = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    final user = ref.read(currentUserProvider);
    if (user != null) {
      _cityController.text = user.institution?.city ?? '';
      _stateController.text = user.institution?.state ?? '';
    }

    if (widget.editEquipmentId != null) {
      _loadExistingEquipment();
    }
  }

  Future<void> _loadExistingEquipment() async {
    setState(() => _isLoading = true);
    try {
      final service = ref.read(equipmentServiceProvider);
      final item = await service.getEquipmentById(widget.editEquipmentId!);

      _titleController.text = item.title;
      _descriptionController.text = item.description;
      _category = item.category;
      _condition = item.condition;
      _listingType = item.listingType;
      _rentalPricingUnit = item.rentalPricingUnit;
      if (item.rentalPrice != null) _rentalPriceController.text = item.rentalPrice.toString();
      if (item.purchasePrice != null) _purchasePriceController.text = item.purchasePrice.toString();
      _buildingController.text = item.location.building;
      _roomController.text = item.location.room;
      _cityController.text = item.location.city;
      _stateController.text = item.location.state;

      _images.addAll(item.images);
      for (final s in item.technicalSpecs) {
        _specs.add({'key': s.key, 'value': s.value});
      }
    } catch (_) {
      _errorMessage = 'Failed to load listing for editing';
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _rentalPriceController.dispose();
    _purchasePriceController.dispose();
    _buildingController.dispose();
    _roomController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    super.dispose();
  }

  Future<void> _pickAndUploadImages() async {
    final picker = ImagePicker();
    final pickedFiles = await picker.pickMultiImage();
    if (pickedFiles.isEmpty) return;

    setState(() => _isUploadingImage = true);

    final uploadService = UploadService();
    try {
      for (int i = 0; i < pickedFiles.length; i++) {
        final file = pickedFiles[i];
        final uploaded = await uploadService.uploadImage(
          file,
          isCover: _images.isEmpty && i == 0,
        );
        if (mounted) {
          setState(() {
            _images.add(uploaded);
          });
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Image upload warning: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isUploadingImage = false);
    }
  }

  void _addSpecRow() {
    setState(() {
      _specs.add({'key': '', 'value': ''});
    });
  }

  void _removeSpecRow(int index) {
    setState(() {
      _specs.removeAt(index);
    });
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    if (_images.isEmpty) {
      _images.add(
        EquipmentImage(
          url: 'https://images.unsplash.com/photo-1582719478250-c89cae4dc85b?q=80&w=1200&auto=format&fit=crop',
          publicId: 'default_equipment_${DateTime.now().millisecondsSinceEpoch}',
          isCover: true,
        ),
      );
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final payload = <String, dynamic>{
      'title': _titleController.text.trim(),
      'description': _descriptionController.text.trim(),
      'category': _category,
      'condition': _condition,
      'listingType': _listingType,
      'rentalPricingUnit': _rentalPricingUnit,
      'location': {
        'building': _buildingController.text.trim(),
        'room': _roomController.text.trim(),
        'city': _cityController.text.trim(),
        'state': _stateController.text.trim(),
      },
      'images': _images.map((i) => i.toJson()).toList(),
      'technicalSpecs': _specs.where((s) => s['key']!.isNotEmpty).toList(),
    };

    if (_listingType == 'rent' || _listingType == 'both') {
      payload['rentalPrice'] = num.tryParse(_rentalPriceController.text.trim()) ?? 0;
    }
    if (_listingType == 'buy' || _listingType == 'both') {
      payload['purchasePrice'] = num.tryParse(_purchasePriceController.text.trim()) ?? 0;
    }

    try {
      final service = ref.read(equipmentServiceProvider);
      if (widget.editEquipmentId != null) {
        await service.updateEquipment(widget.editEquipmentId!, payload);
      } else {
        await service.createEquipment(payload);
      }

      ref.read(myListingsProvider.notifier).loadListings();
      ref.read(equipmentNotifierProvider.notifier).fetchEquipment(isRefresh: true);

      if (!mounted) return;
      context.pop();
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = e.toString().replaceAll('Exception: ', '');
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.editEquipmentId != null;

    return Scaffold(
      backgroundColor: AppColors.warmOffWhite,
      appBar: AppBar(
        title: Text(
          isEditing ? 'Edit Listing' : 'List Equipment',
          style: AppTypography.headlineLarge,
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: _isLoading && isEditing
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (_errorMessage != null) ...[
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.errorBg,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: AppColors.error.withValues(alpha: 0.3)),
                        ),
                        child: Text(_errorMessage!, style: const TextStyle(color: AppColors.error)),
                      ),
                      const SizedBox(height: 16),
                    ],

                    Text('Equipment Photos', style: AppTypography.titleMedium),
                    const SizedBox(height: 6),
                    Text(
                      'Upload high-resolution photographs of the instrument and control interface.',
                      style: AppTypography.bodySmall,
                    ),
                    const SizedBox(height: 12),

                    _buildImagePickerRow(),
                    const SizedBox(height: 24),

                    AppTextField(
                      label: 'Equipment Title',
                      hint: 'e.g. Olympus IX83 Inverted Fluorescence Microscope',
                      controller: _titleController,
                      validator: Validators.required,
                    ),
                    const SizedBox(height: 16),

                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Domain Category', style: AppTypography.titleSmall),
                              const SizedBox(height: 6),
                              DropdownButtonFormField<String>(
                                initialValue: _category,
                                decoration: const InputDecoration(),
                                items: AppConstants.categories
                                    .map((c) => DropdownMenuItem(
                                          value: c['id'],
                                          child: Text(c['label']!),
                                        ))
                                    .toList(),
                                onChanged: (val) {
                                  if (val != null) setState(() => _category = val);
                                },
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Condition', style: AppTypography.titleSmall),
                              const SizedBox(height: 6),
                              DropdownButtonFormField<String>(
                                initialValue: _condition,
                                decoration: const InputDecoration(),
                                items: AppConstants.conditions
                                    .map((c) => DropdownMenuItem(
                                          value: c['id'],
                                          child: Text(c['label']!),
                                        ))
                                    .toList(),
                                onChanged: (val) {
                                  if (val != null) setState(() => _condition = val);
                                },
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    AppTextField(
                      label: 'Description',
                      hint: 'Detail optical configuration, detector type, calibration history, and usage guidelines...',
                      controller: _descriptionController,
                      validator: Validators.required,
                      maxLines: 4,
                    ),
                    const SizedBox(height: 24),

                    Text('Listing Type & Rates', style: AppTypography.titleMedium),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: ChoiceChip(
                            label: const Center(child: Text('For Rent')),
                            selected: _listingType == 'rent',
                            selectedColor: AppColors.softSage,
                            onSelected: (_) => setState(() => _listingType = 'rent'),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: ChoiceChip(
                            label: const Center(child: Text('For Sale')),
                            selected: _listingType == 'buy',
                            selectedColor: AppColors.softSage,
                            onSelected: (_) => setState(() => _listingType = 'buy'),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: ChoiceChip(
                            label: const Center(child: Text('Both')),
                            selected: _listingType == 'both',
                            selectedColor: AppColors.softSage,
                            onSelected: (_) => setState(() => _listingType = 'both'),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    if (_listingType == 'rent' || _listingType == 'both') ...[
                      Row(
                        children: [
                          Expanded(
                            child: AppTextField(
                              label: 'Rental Rate (\$ USD)',
                              hint: 'e.g. 75',
                              controller: _rentalPriceController,
                              keyboardType: TextInputType.number,
                              validator: (val) => Validators.positiveNumber(val, 'Please enter a valid rental price'),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Pricing Unit', style: AppTypography.titleSmall),
                                const SizedBox(height: 6),
                                DropdownButtonFormField<String>(
                                  initialValue: _rentalPricingUnit,
                                  decoration: const InputDecoration(),
                                  items: AppConstants.pricingUnits
                                      .map((u) => DropdownMenuItem(
                                            value: u['id'],
                                            child: Text(u['label']!),
                                          ))
                                      .toList(),
                                  onChanged: (val) {
                                    if (val != null) setState(() => _rentalPricingUnit = val);
                                  },
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                    ],

                    if (_listingType == 'buy' || _listingType == 'both') ...[
                      AppTextField(
                        label: 'Purchase Price (\$ USD)',
                        hint: 'e.g. 42000',
                        controller: _purchasePriceController,
                        keyboardType: TextInputType.number,
                        validator: (val) => Validators.positiveNumber(val, 'Please enter a valid purchase price'),
                      ),
                      const SizedBox(height: 24),
                    ],

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Technical Specifications', style: AppTypography.titleMedium),
                        TextButton.icon(
                          icon: const Icon(Icons.add, size: 16, color: AppColors.deepForest),
                          label: Text(
                            'Add Spec',
                            style: AppTypography.labelSmall.copyWith(color: AppColors.deepForest),
                          ),
                          onPressed: _addSpecRow,
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    _buildSpecsInputs(),
                    const SizedBox(height: 24),

                    Text('Location Details', style: AppTypography.titleMedium),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: AppTextField(
                            label: 'Building / Center',
                            hint: 'Shriram Center',
                            controller: _buildingController,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: AppTextField(
                            label: 'Room / Suite',
                            hint: 'B-104',
                            controller: _roomController,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: AppTextField(
                            label: 'City',
                            hint: 'Stanford',
                            controller: _cityController,
                            validator: Validators.required,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: AppTextField(
                            label: 'State',
                            hint: 'CA',
                            controller: _stateController,
                            validator: Validators.required,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 36),

                    AppButton(
                      text: isEditing ? 'Update Listing' : 'Publish Equipment Listing',
                      width: double.infinity,
                      isLoading: _isLoading,
                      onPressed: _handleSubmit,
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildImagePickerRow() {
    return SizedBox(
      height: 100,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          GestureDetector(
            onTap: _isUploadingImage ? null : _pickAndUploadImages,
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: AppColors.warmOffWhite,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.border, style: BorderStyle.solid),
              ),
              child: Center(
                child: _isUploadingImage
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.add_a_photo_outlined, color: AppColors.deepForest),
                          const SizedBox(height: 4),
                          Text('Add Photo', style: AppTypography.labelSmall.copyWith(fontSize: 10)),
                        ],
                      ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          ..._images.asMap().entries.map((entry) {
            final index = entry.key;
            final img = entry.value;
            return Container(
              margin: const EdgeInsets.only(right: 10),
              width: 100,
              height: 100,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(14),
                    child: NetworkImageWithFallback(imageUrl: img.url),
                  ),
                  Positioned(
                    top: 4,
                    right: 4,
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          _images.removeAt(index);
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: AppColors.primaryInk,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.close, color: AppColors.pureWhite, size: 12),
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildSpecsInputs() {
    if (_specs.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.pureWhite,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.border),
        ),
        child: Text(
          'No custom specifications added. Click "Add Spec" to add optical, electrical, or thermal parameters.',
          style: AppTypography.bodySmall,
        ),
      );
    }

    return Column(
      children: _specs.asMap().entries.map((entry) {
        final index = entry.key;
        final spec = entry.value;
        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Row(
            children: [
              Expanded(
                flex: 4,
                child: TextFormField(
                  initialValue: spec['key'],
                  decoration: const InputDecoration(hintText: 'Parameter (e.g. Max RPM)'),
                  onChanged: (val) => _specs[index]['key'] = val,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                flex: 5,
                child: TextFormField(
                  initialValue: spec['value'],
                  decoration: const InputDecoration(hintText: 'Value (e.g. 100,000 RPM)'),
                  onChanged: (val) => _specs[index]['value'] = val,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.remove_circle_outline, color: AppColors.error),
                onPressed: () => _removeSpecRow(index),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}
