import 'package:flutter/foundation.dart';

import 'api.dart';
import 'models.dart';

enum SearchStatus { home, loading, success, empty, error }

enum ResultView { list, map }

enum FilterReturnState { results, empty }

class Spot4uController extends ChangeNotifier {
  Spot4uController(this._api);

  final Spot4uApi _api;
  List<Campus> campuses = Campus.defaults;
  SearchCriteria criteria = SearchCriteria.initial();
  SearchCriteria? draftCriteria;
  SearchResult? result;
  SearchStatus status = SearchStatus.home;
  ResultView view = ResultView.list;
  ResultView requestedView = ResultView.list;
  FilterReturnState filterReturnState = FilterReturnState.results;
  bool filtersOpen = false;
  bool homeFiltersExpanded = false;
  String? selectedPlaceId;
  String? expandedPlaceId;
  String? errorMessage;
  int _latestRequestId = 0;

  bool get isLoading => status == SearchStatus.loading;
  Campus get origin => criteria.origin;

  Future<void> loadCampuses() async {
    try {
      final loaded = await _api.campuses();
      if (loaded.isEmpty) return;
      campuses = loaded;
      criteria = criteria.copyWith(
        origin: loaded.firstWhere(
          (campus) => campus.id == criteria.origin.id,
          orElse: () => loaded.first,
        ),
      );
      notifyListeners();
    } on Object {
      return;
    }
  }

  void setOrigin(Campus campus) {
    criteria = criteria.copyWith(origin: campus);
    notifyListeners();
  }

  void toggleCategory(String category) {
    final categories = Set<String>.of(criteria.categories);
    if (!categories.remove(category)) categories.add(category);
    criteria = criteria.copyWith(categories: categories);
    notifyListeners();
  }

  void setPriority(String priority) {
    criteria = criteria.copyWith(priority: priority);
    notifyListeners();
  }

  void updateFilters(SearchFilters filters) {
    criteria = criteria.copyWith(filters: filters);
    notifyListeners();
  }

  void toggleHomeFilters() {
    homeFiltersExpanded = !homeFiltersExpanded;
    notifyListeners();
  }

  void resetHomeFilters() {
    criteria = criteria.copyWith(filters: const SearchFilters());
    notifyListeners();
  }

  Future<void> startSearch({ResultView? preferredView}) async {
    if (isLoading || criteria.categories.isEmpty) return;
    requestedView = preferredView ?? ResultView.list;
    await _performSearch();
  }

  Future<void> retry() async {
    if (!isLoading) await _performSearch();
  }

  Future<void> _performSearch() async {
    final requestId = ++_latestRequestId;
    status = SearchStatus.loading;
    filtersOpen = false;
    draftCriteria = null;
    selectedPlaceId = null;
    expandedPlaceId = null;
    errorMessage = null;
    notifyListeners();
    try {
      final response = await _api.search(criteria);
      if (requestId != _latestRequestId) return;
      result = response;
      if (response.places.isEmpty) {
        status = SearchStatus.empty;
        view = ResultView.list;
      } else {
        status = SearchStatus.success;
        view = requestedView;
      }
    } on Object catch (error) {
      if (requestId != _latestRequestId) return;
      status = SearchStatus.error;
      errorMessage = error is ApiException
          ? error.message
          : 'Не удалось загрузить результаты.';
    }
    notifyListeners();
  }

  void setView(ResultView value) {
    if (status != SearchStatus.success || view == value) return;
    view = value;
    requestedView = value;
    selectedPlaceId = null;
    expandedPlaceId = null;
    notifyListeners();
  }

  void openFilters() {
    if (status != SearchStatus.success && status != SearchStatus.empty) return;
    filterReturnState = status == SearchStatus.empty
        ? FilterReturnState.empty
        : FilterReturnState.results;
    draftCriteria = criteria.copyWith();
    filtersOpen = true;
    notifyListeners();
  }

  void closeFilters() {
    filtersOpen = false;
    draftCriteria = null;
    notifyListeners();
  }

  void toggleDraftCategory(String category) {
    final draft = draftCriteria;
    if (draft == null) return;
    final categories = Set<String>.of(draft.categories);
    if (!categories.remove(category)) categories.add(category);
    draftCriteria = draft.copyWith(categories: categories);
    notifyListeners();
  }

  void updateDraftFilters(SearchFilters filters) {
    final draft = draftCriteria;
    if (draft == null) return;
    draftCriteria = draft.copyWith(filters: filters);
    notifyListeners();
  }

  void updateDraftPriority(String priority) {
    final draft = draftCriteria;
    if (draft == null) return;
    draftCriteria = draft.copyWith(priority: priority);
    notifyListeners();
  }

  void resetDraftFilters() {
    updateDraftFilters(const SearchFilters());
  }

  Future<void> applyDraftFilters() async {
    final draft = draftCriteria;
    if (draft == null || draft.categories.isEmpty || isLoading) return;
    final returnToMap =
        filterReturnState == FilterReturnState.results &&
        view == ResultView.map;
    criteria = draft;
    await startSearch(
      preferredView: returnToMap ? ResultView.map : ResultView.list,
    );
  }

  void selectPlace(String placeId) {
    if (selectedPlaceId == placeId) return;
    selectedPlaceId = placeId;
    notifyListeners();
  }

  void toggleExpanded(String placeId) {
    expandedPlaceId = expandedPlaceId == placeId ? null : placeId;
    notifyListeners();
  }

  void goHome() {
    _latestRequestId++;
    status = SearchStatus.home;
    filtersOpen = false;
    draftCriteria = null;
    selectedPlaceId = null;
    expandedPlaceId = null;
    notifyListeners();
  }
}
