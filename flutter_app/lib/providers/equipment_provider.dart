import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/equipment_model.dart';
import '../services/equipment_service.dart';

class EquipmentFilterState {
  final String? search;
  final String? category;
  final String? condition;
  final String? listingType;
  final String? availability;
  final num? minPrice;
  final num? maxPrice;
  final String sort;

  const EquipmentFilterState({
    this.search,
    this.category,
    this.condition,
    this.listingType,
    this.availability,
    this.minPrice,
    this.maxPrice,
    this.sort = 'newest',
  });

  EquipmentFilterState copyWith({
    String? search,
    String? category,
    String? condition,
    String? listingType,
    String? availability,
    num? minPrice,
    num? maxPrice,
    String? sort,
    bool clearCategory = false,
    bool clearFilters = false,
  }) {
    if (clearFilters) {
      return const EquipmentFilterState();
    }
    return EquipmentFilterState(
      search: search ?? this.search,
      category: clearCategory ? null : (category ?? this.category),
      condition: condition ?? this.condition,
      listingType: listingType ?? this.listingType,
      availability: availability ?? this.availability,
      minPrice: minPrice ?? this.minPrice,
      maxPrice: maxPrice ?? this.maxPrice,
      sort: sort ?? this.sort,
    );
  }
}

class EquipmentListState {
  final List<EquipmentModel> items;
  final bool isLoading;
  final bool isMoreLoading;
  final bool hasMore;
  final int page;
  final int total;
  final String? errorMessage;

  const EquipmentListState({
    this.items = const [],
    this.isLoading = false,
    this.isMoreLoading = false,
    this.hasMore = true,
    this.page = 1,
    this.total = 0,
    this.errorMessage,
  });

  EquipmentListState copyWith({
    List<EquipmentModel>? items,
    bool? isLoading,
    bool? isMoreLoading,
    bool? hasMore,
    int? page,
    int? total,
    String? errorMessage,
  }) {
    return EquipmentListState(
      items: items ?? this.items,
      isLoading: isLoading ?? this.isLoading,
      isMoreLoading: isMoreLoading ?? this.isMoreLoading,
      hasMore: hasMore ?? this.hasMore,
      page: page ?? this.page,
      total: total ?? this.total,
      errorMessage: errorMessage,
    );
  }
}

class EquipmentNotifier extends StateNotifier<EquipmentListState> {
  final EquipmentService _service;
  EquipmentFilterState _filter = const EquipmentFilterState();

  EquipmentNotifier(this._service) : super(const EquipmentListState()) {
    fetchEquipment();
  }

  EquipmentFilterState get filter => _filter;

  Future<void> fetchEquipment({bool isRefresh = false}) async {
    if (isRefresh) {
      state = state.copyWith(isLoading: true, page: 1, errorMessage: null);
    } else {
      state = state.copyWith(isLoading: true, errorMessage: null);
    }

    try {
      final result = await _service.listEquipment(
        search: _filter.search,
        category: _filter.category,
        condition: _filter.condition,
        listingType: _filter.listingType,
        availability: _filter.availability,
        minPrice: _filter.minPrice,
        maxPrice: _filter.maxPrice,
        sort: _filter.sort,
        page: 1,
        limit: 12,
      );

      state = state.copyWith(
        items: result.items,
        isLoading: false,
        page: 1,
        total: result.total,
        hasMore: result.page < result.totalPages,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString().replaceAll('Exception: ', ''),
      );
    }
  }

  Future<void> loadMore() async {
    if (state.isLoading || state.isMoreLoading || !state.hasMore) return;

    state = state.copyWith(isMoreLoading: true);
    final nextPage = state.page + 1;

    try {
      final result = await _service.listEquipment(
        search: _filter.search,
        category: _filter.category,
        condition: _filter.condition,
        listingType: _filter.listingType,
        availability: _filter.availability,
        minPrice: _filter.minPrice,
        maxPrice: _filter.maxPrice,
        sort: _filter.sort,
        page: nextPage,
        limit: 12,
      );

      state = state.copyWith(
        items: [...state.items, ...result.items],
        isMoreLoading: false,
        page: nextPage,
        total: result.total,
        hasMore: result.page < result.totalPages,
      );
    } catch (_) {
      state = state.copyWith(isMoreLoading: false);
    }
  }

  void setSearch(String query) {
    _filter = _filter.copyWith(search: query);
    fetchEquipment(isRefresh: true);
  }

  void setCategory(String? categoryId) {
    if (categoryId == null || _filter.category == categoryId) {
      _filter = _filter.copyWith(clearCategory: true);
    } else {
      _filter = _filter.copyWith(category: categoryId);
    }
    fetchEquipment(isRefresh: true);
  }

  void setFilters(EquipmentFilterState newFilter) {
    _filter = newFilter;
    fetchEquipment(isRefresh: true);
  }

  void resetFilters() {
    _filter = const EquipmentFilterState();
    fetchEquipment(isRefresh: true);
  }
}

// Providers
final equipmentServiceProvider = Provider<EquipmentService>((ref) => EquipmentService());

final equipmentNotifierProvider =
    StateNotifierProvider<EquipmentNotifier, EquipmentListState>((ref) {
  return EquipmentNotifier(ref.watch(equipmentServiceProvider));
});

final featuredEquipmentProvider = FutureProvider<List<EquipmentModel>>((ref) async {
  final service = ref.watch(equipmentServiceProvider);
  final result = await service.listEquipment(featured: true, limit: 4);
  return result.items;
});

final recentEquipmentProvider = FutureProvider<List<EquipmentModel>>((ref) async {
  final service = ref.watch(equipmentServiceProvider);
  final result = await service.listEquipment(sort: 'newest', limit: 6);
  return result.items;
});

final myListingsProvider =
    StateNotifierProvider<MyListingsNotifier, AsyncValue<List<EquipmentModel>>>((ref) {
  return MyListingsNotifier(ref.watch(equipmentServiceProvider));
});

class MyListingsNotifier extends StateNotifier<AsyncValue<List<EquipmentModel>>> {
  final EquipmentService _service;

  MyListingsNotifier(this._service) : super(const AsyncValue.loading()) {
    loadListings();
  }

  Future<void> loadListings() async {
    try {
      state = const AsyncValue.loading();
      final items = await _service.getMyEquipment();
      state = AsyncValue.data(items);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> deleteListing(String id) async {
    try {
      await _service.deleteEquipment(id);
      state.whenData((items) {
        state = AsyncValue.data(items.where((item) => item.id != id).toList());
      });
    } catch (_) {}
  }

  Future<void> toggleAvailability(String id, String currentStatus) async {
    final newStatus = currentStatus == 'available' ? 'maintenance' : 'available';
    try {
      final updated = await _service.updateAvailability(id, newStatus);
      state.whenData((items) {
        state = AsyncValue.data(
          items.map((item) => item.id == id ? updated : item).toList(),
        );
      });
    } catch (_) {}
  }
}

final equipmentDetailProvider =
    FutureProvider.family<EquipmentModel, String>((ref, id) async {
  final service = ref.watch(equipmentServiceProvider);
  return await service.getEquipmentById(id);
});
