import 'package:material_ui/material_ui.dart';

import '../controller.dart';
import '../place_utils.dart';
import '../widgets/common.dart';
import '../widgets/place_card.dart';
import '../widgets/places_map.dart';

class SearchResultsScreen extends StatelessWidget {
  const SearchResultsScreen({super.key, required this.controller});
  final Spot4uController controller;

  @override
  Widget build(BuildContext context) {
    final result = controller.result!;
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 700),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(18, 4, 18, 12),
              child: Column(
                children: [
                  AppHeader(onBack: controller.goHome),
                  const SizedBox(height: 8),
                  OriginCard(campus: result.origin),
                  const SizedBox(height: 16),
                  SearchResultsSummary(controller: controller),
                  const SizedBox(height: 10),
                  AppFilterButton(
                    count: controller.criteria.filters.activeCount,
                    onPressed: controller.openFilters,
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    child: switch (controller.view) {
                      ResultView.list => _ResultsList(controller: controller),
                      ResultView.map => PlacesMap(
                        key: ValueKey(
                          result.places.map((place) => place.placeId).join('|'),
                        ),
                        result: result,
                        selectedPlaceId: controller.selectedPlaceId,
                        onSelected: controller.selectPlace,
                      ),
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class SearchResultsSummary extends StatelessWidget {
  const SearchResultsSummary({super.key, required this.controller});
  final Spot4uController controller;

  @override
  Widget build(BuildContext context) => Row(
    crossAxisAlignment: CrossAxisAlignment.end,
    children: [
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Подходящие места',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              'Найдено: ${controller.result!.count}',
              key: const Key('results-count'),
              style: const TextStyle(color: AppColors.muted, fontSize: 13),
            ),
          ],
        ),
      ),
      ViewSwitcher(view: controller.view, onChanged: controller.setView),
    ],
  );
}

class _ResultsList extends StatelessWidget {
  const _ResultsList({required this.controller});
  final Spot4uController controller;

  @override
  Widget build(BuildContext context) {
    final result = controller.result!;
    return ListView.separated(
      key: const Key('results-list'),
      padding: const EdgeInsets.only(bottom: 24),
      itemCount: result.places.length + 1,
      separatorBuilder: (_, _) => const SizedBox(height: 14),
      itemBuilder: (context, index) {
        if (index == 0) {
          return const Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.info_outline, size: 16, color: AppColors.muted),
              SizedBox(width: 6),
              Expanded(
                child: Text(
                  'StudyScore — оценка от 0 до 100. Чем выше балл, тем лучше место подходит под твои критерии.',
                  style: TextStyle(
                    color: AppColors.muted,
                    fontSize: 12,
                    height: 1.35,
                  ),
                ),
              ),
            ],
          );
        }
        final place = result.places[index - 1];
        return PlaceCard(
          place: place,
          origin: result.origin,
          expanded: controller.expandedPlaceId == place.placeId,
          onToggle: () => controller.toggleExpanded(place.placeId),
        );
      },
    );
  }
}

class SearchLoadingScreen extends StatelessWidget {
  const SearchLoadingScreen({super.key, required this.controller});
  final Spot4uController controller;

  @override
  Widget build(BuildContext context) => Scaffold(
    body: SafeArea(
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 700),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(18, 4, 18, 12),
            child: Column(
              children: [
                AppHeader(onBack: controller.goHome),
                const SizedBox(height: 8),
                OriginCard(campus: controller.origin),
                const SizedBox(height: 16),
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Подходящие места',
                    style: TextStyle(fontSize: 23, fontWeight: FontWeight.w800),
                  ),
                ),
                const SizedBox(height: 4),
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text('Ищем…', key: Key('loading-state')),
                ),
                const SizedBox(height: 12),
                AppFilterButton(
                  count: controller.criteria.filters.activeCount,
                  onPressed: null,
                ),
                const SizedBox(height: 16),
                const LinearProgressIndicator(color: AppColors.cobalt),
                const SizedBox(height: 16),
                Expanded(
                  child: ListView.separated(
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: 3,
                    separatorBuilder: (_, _) => const SizedBox(height: 14),
                    itemBuilder: (_, _) => const _SkeletonCard(),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}

class SearchStatusScreen extends StatelessWidget {
  const SearchStatusScreen({
    super.key,
    required this.controller,
    required this.error,
  });
  final Spot4uController controller;
  final bool error;

  @override
  Widget build(BuildContext context) => Scaffold(
    body: SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(18, 4, 18, 20),
        child: Column(
          children: [
            AppHeader(onBack: controller.goHome),
            const SizedBox(height: 8),
            OriginCard(campus: controller.origin),
            Expanded(
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 340),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Image.asset(
                        'assets/images/empty-cat.png',
                        key: const Key('empty-cat-image'),
                        width: 140,
                        height: 96,
                        fit: BoxFit.contain,
                        semanticLabel: 'Кот в лужице',
                      ),
                      const SizedBox(height: 24),
                      Text(
                        error
                            ? 'Не удалось загрузить результаты'
                            : 'Ничего не найдено',
                        key: Key(error ? 'error-state' : 'empty-state'),
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        error
                            ? controller.errorMessage ?? 'Попробуйте ещё раз'
                            : 'Попробуйте изменить параметры поиска',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: AppColors.muted,
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 24),
                      PrimaryButton(
                        key: Key(
                          error ? 'retry-search' : 'empty-change-filters',
                        ),
                        label: error ? 'Обновить' : 'Изменить фильтры',
                        icon: error ? Icons.refresh : Icons.tune,
                        onPressed: error
                            ? controller.retry
                            : controller.openFilters,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

class _SkeletonCard extends StatelessWidget {
  const _SkeletonCard();

  @override
  Widget build(BuildContext context) => Container(
    height: 200,
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      color: const Color(0xFFF1F1F3),
      borderRadius: BorderRadius.circular(26),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        skeletonBar(90, 26),
        const SizedBox(height: 20),
        skeletonBar(240, 18),
        const SizedBox(height: 12),
        skeletonBar(160, 13),
        const Spacer(),
        skeletonBar(double.infinity, 44),
      ],
    ),
  );

  Widget skeletonBar(double width, double height) => Container(
    width: width,
    height: height,
    decoration: BoxDecoration(
      color: const Color(0xFFE1E2E6),
      borderRadius: BorderRadius.circular(height / 2),
    ),
  );
}
