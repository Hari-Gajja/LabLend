import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/utils/formatters.dart';
import '../../core/utils/validators.dart';
import '../../models/equipment_model.dart';
import '../../providers/request_provider.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_text_field.dart';

class BookingRequestSheet extends ConsumerStatefulWidget {
  final EquipmentModel equipment;
  final String requestType; // 'rental' | 'purchase'

  const BookingRequestSheet({
    super.key,
    required this.equipment,
    required this.requestType,
  });

  @override
  ConsumerState<BookingRequestSheet> createState() => _BookingRequestSheetState();
}

class _BookingRequestSheetState extends ConsumerState<BookingRequestSheet> {
  final _formKey = GlobalKey<FormState>();
  final _intendedUseController = TextEditingController();
  final _messageController = TextEditingController();
  final _quantityController = TextEditingController(text: '1');

  DateTime? _startDate;
  DateTime? _endDate;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    if (widget.requestType == 'rental') {
      _startDate = DateTime.now().add(const Duration(days: 1));
      _endDate = DateTime.now().add(const Duration(days: 4));
    }
  }

  @override
  void dispose() {
    _intendedUseController.dispose();
    _messageController.dispose();
    _quantityController.dispose();
    super.dispose();
  }

  Future<void> _pickDateRange() async {
    final now = DateTime.now();
    final picked = await showDateRangePicker(
      context: context,
      firstDate: now,
      lastDate: now.add(const Duration(days: 365)),
      initialDateRange: _startDate != null && _endDate != null
          ? DateTimeRange(start: _startDate!, end: _endDate!)
          : null,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.deepForest,
              onPrimary: AppColors.pureWhite,
              onSurface: AppColors.primaryInk,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _startDate = picked.start;
        _endDate = picked.end;
      });
    }
  }

  Future<void> _submitRequest() async {
    if (!_formKey.currentState!.validate()) return;

    if (widget.requestType == 'rental') {
      if (_startDate == null || _endDate == null) {
        setState(() => _errorMessage = 'Please select a valid rental date range');
        return;
      }
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final service = ref.read(requestServiceProvider);
      await service.createRequest(
        equipmentId: widget.equipment.id,
        requestType: widget.requestType,
        requestedQuantity: int.tryParse(_quantityController.text) ?? 1,
        rentalStartDate: _startDate,
        rentalEndDate: _endDate,
        intendedUse: _intendedUseController.text.trim(),
        message: _messageController.text.trim(),
      );

      // Refresh requests provider
      ref.read(requestsNotifierProvider.notifier).fetchAll();

      if (!mounted) return;
      Navigator.of(context).pop(true);
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = e.toString().replaceAll('Exception: ', '');
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isRental = widget.requestType == 'rental';

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.pureWhite,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.border,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Title
              Text(
                isRental ? 'Request Equipment Rental' : 'Submit Purchase Inquiry',
                style: AppTypography.headlineMedium,
              ),
              const SizedBox(height: 4),
              Text(
                widget.equipment.title,
                style: AppTypography.bodySmall.copyWith(color: AppColors.secondaryText),
              ),
              const Divider(height: 24),

              if (_errorMessage != null) ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.errorBg,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.error.withOpacity(0.3)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.error_outline, size: 18, color: AppColors.error),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _errorMessage!,
                          style: AppTypography.bodySmall.copyWith(color: AppColors.error),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // Rental Dates Picker
              if (isRental) ...[
                Text('Scheduled Reservation Window', style: AppTypography.titleSmall),
                const SizedBox(height: 8),
                InkWell(
                  onTap: _pickDateRange,
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppColors.warmOffWhite,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.calendar_month, color: AppColors.deepForest, size: 20),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            _startDate != null && _endDate != null
                                ? Formatters.formatDateRange(_startDate!, _endDate!)
                                : 'Select rental start and return dates',
                            style: AppTypography.bodyMedium.copyWith(
                              fontWeight: FontWeight.w600,
                              color: AppColors.primaryInk,
                            ),
                          ),
                        ),
                        Text(
                          'Change',
                          style: AppTypography.labelSmall.copyWith(color: AppColors.deepForest),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // Intended Research / Clinical Use
              AppTextField(
                label: 'Research / Intended Use',
                hint: 'Describe your study, protocol, or intended application (min 10 characters)...',
                controller: _intendedUseController,
                validator: (val) => Validators.minLength(val, 10, 'Please provide at least 10 characters describing intended use'),
                maxLines: 3,
              ),
              const SizedBox(height: 16),

              // Message to Facility
              AppTextField(
                label: 'Message to Lab Director (Optional)',
                hint: 'Specify calibration requirements, sample constraints, or lab technician access needs...',
                controller: _messageController,
                maxLines: 2,
              ),
              const SizedBox(height: 24),

              // Rate Summary Box
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.paleSand.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.warmStone),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Rate / Pricing', style: AppTypography.bodyMedium),
                    Text(
                      isRental
                          ? '${Formatters.formatCurrency(widget.equipment.rentalPrice)} / ${widget.equipment.rentalPricingUnit}'
                          : Formatters.formatCurrency(widget.equipment.purchasePrice),
                      style: AppTypography.priceMedium,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Submit Button
              AppButton(
                text: isRental ? 'Submit Rental Request' : 'Submit Purchase Offer',
                width: double.infinity,
                isLoading: _isLoading,
                onPressed: _submitRequest,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
