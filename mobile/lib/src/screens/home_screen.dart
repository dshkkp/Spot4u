import 'package:material_ui/material_ui.dart';

import '../controller.dart';
import '../place_utils.dart';
import '../widgets/common.dart';
import '../widgets/filters.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key, required this.controller});
  final Spot4uController controller;

  @override
  Widget build(BuildContext context) => Scaffold(
    body: SingleChildScrollView(
      child: Stack(
        children: [
          const Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 260,
            child: _Hero(),
          ),
          Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 600),
              child: Padding(
                padding: const EdgeInsets.only(top: 236, bottom: 32),
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(28),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x18304CC9),
                        blurRadius: 28,
                        offset: Offset(0, 12),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const _SectionTitle('Выберите стартовую точку'),
                      const SizedBox(height: 10),
                      DropdownButtonFormField<String>(
                        key: ValueKey(controller.criteria.origin.id),
                        initialValue: controller.criteria.origin.id,
                        isExpanded: true,
                        dropdownColor: Colors.white,
                        borderRadius: BorderRadius.circular(18),
                        elevation: 4,
                        menuMaxHeight: 320,
                        itemHeight: 52,
                        icon: const Icon(Icons.keyboard_arrow_down_rounded),
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppColors.ink,
                        ),
                        decoration: InputDecoration(
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 14,
                          ),
                          filled: true,
                          fillColor: const Color(0xFFF6F3F2),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(18),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        items: controller.campuses
                            .map(
                              (campus) => DropdownMenuItem(
                                value: campus.id,
                                child: Text(
                                  campus.name,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            )
                            .toList(),
                        onChanged: (id) {
                          if (id == null) return;
                          controller.setOrigin(
                            controller.campuses.firstWhere(
                              (campus) => campus.id == id,
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 22),
                      Row(
                        children: [
                          const Expanded(
                            child: _SectionTitle('Какие места ищем?'),
                          ),
                          FilledButton.icon(
                            onPressed: controller.toggleHomeFilters,
                            style: FilledButton.styleFrom(
                              backgroundColor: AppColors.cobalt,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 13,
                              ),
                            ),
                            icon: const Icon(Icons.tune, size: 17),
                            label: const Text('Фильтры'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      CategorySelector(
                        selected: controller.criteria.categories,
                        onToggle: controller.toggleCategory,
                      ),
                      if (controller.homeFiltersExpanded) ...[
                        const SizedBox(height: 18),
                        Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF6F3F2),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  const Expanded(
                                    child: Text(
                                      'Дополнительные фильтры',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                  TextButton(
                                    key: const Key('reset-home-filters'),
                                    onPressed: controller.resetHomeFilters,
                                    child: const Text('Сбросить'),
                                  ),
                                ],
                              ),
                              FilterControls(
                                filters: controller.criteria.filters,
                                onChanged: controller.updateFilters,
                              ),
                            ],
                          ),
                        ),
                      ],
                      const SizedBox(height: 24),
                      const _SectionTitle('Что важнее?'),
                      const SizedBox(height: 10),
                      PrioritySelector(
                        value: controller.criteria.priority,
                        onChanged: controller.setPriority,
                      ),
                      const SizedBox(height: 20),
                      if (controller.criteria.categories.isEmpty)
                        const Padding(
                          padding: EdgeInsets.only(bottom: 10),
                          child: Text(
                            'Выберите хотя бы одну категорию',
                            style: TextStyle(
                              color: AppColors.muted,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      PrimaryButton(
                        key: const Key('search-submit'),
                        label: 'Показать места',
                        onPressed: controller.criteria.categories.isEmpty
                            ? null
                            : () => controller.startSearch(),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

class _Hero extends StatelessWidget {
  const _Hero();

  @override
  Widget build(BuildContext context) => Container(
    decoration: const BoxDecoration(
      borderRadius: BorderRadius.vertical(bottom: Radius.circular(36)),
      gradient: RadialGradient(
        center: Alignment(0.85, -0.8),
        radius: 1.8,
        colors: [
          Color(0xFF91A667),
          Color(0xFFB16D83),
          AppColors.cobalt,
          Color(0xFF1B35AB),
        ],
        stops: [0, 0.32, 0.7, 1],
      ),
    ),
    child: SafeArea(
      bottom: false,
      child: Padding(
        padding: EdgeInsets.fromLTRB(20, 12, 20, 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Spot4uLogo(light: true),
            Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
              decoration: BoxDecoration(
                color: AppColors.lime,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.bolt, size: 17),
                  SizedBox(width: 4),
                  Text(
                    'ДЛЯ УЧЁБЫ И РАБОТЫ',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
                  ),
                ],
              ),
            ),
            SizedBox(height: 12),
            Text(
              'Найди своё место',
              style: TextStyle(
                color: Colors.white,
                fontSize: 32,
                height: 1.15,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.8,
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);
  final String text;

  @override
  Widget build(BuildContext context) => Text(
    text,
    style: const TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.w800,
      letterSpacing: -0.3,
    ),
  );
}
