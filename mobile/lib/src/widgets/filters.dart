import 'package:material_ui/material_ui.dart';

import '../controller.dart';
import '../models.dart';
import '../place_utils.dart';
import 'common.dart';

class FilterControls extends StatefulWidget {
  const FilterControls({
    super.key,
    required this.filters,
    required this.onChanged,
  });

  final SearchFilters filters;
  final ValueChanged<SearchFilters> onChanged;

  @override
  State<FilterControls> createState() => _FilterControlsState();
}

class _FilterControlsState extends State<FilterControls> {
  late int price = widget.filters.maxAvgCheckRub ?? 2000;
  late int minutes = widget.filters.maxTravelTimeMin ?? 60;

  @override
  void didUpdateWidget(covariant FilterControls oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.filters.maxAvgCheckRub != widget.filters.maxAvgCheckRub) {
      price = widget.filters.maxAvgCheckRub ?? 2000;
    }
    if (oldWidget.filters.maxTravelTimeMin != widget.filters.maxTravelTimeMin) {
      minutes = widget.filters.maxTravelTimeMin ?? 60;
    }
  }

  @override
  Widget build(BuildContext context) {
    final filters = widget.filters;
    return Column(
      children: [
        _buildSwitch(
          'Wi-Fi',
          Icons.wifi,
          filters.wifi,
          (value) => widget.onChanged(filters.copyWith(wifi: value)),
        ),
        _buildSwitch(
          'Наличие розеток',
          Icons.power_outlined,
          filters.sockets,
          (value) => widget.onChanged(filters.copyWith(sockets: value)),
        ),
        _buildSwitch(
          'Студенческая скидка',
          Icons.school_outlined,
          filters.studentDiscount,
          (value) => widget.onChanged(filters.copyWith(studentDiscount: value)),
        ),
        _buildSwitch(
          'Подходит для ноутбука',
          Icons.laptop_mac_outlined,
          filters.laptopFriendly,
          (value) => widget.onChanged(filters.copyWith(laptopFriendly: value)),
        ),
        _buildSwitch(
          'Открыто прямо сейчас',
          Icons.schedule,
          filters.openNow,
          (value) => widget.onChanged(filters.copyWith(openNow: value)),
        ),
        const SizedBox(height: 12),
        LimitSlider(
          title: 'Средний чек',
          value: price,
          min: 0,
          max: 2000,
          divisions: 40,
          valueLabel: 'До $price ₽',
          rangeLabels: const ['0 ₽', '2 000 ₽'],
          onChanged: (value) => setState(() => price = value),
          onChangeEnd: (value) => widget.onChanged(
            filters.copyWith(maxAvgCheckRub: value == 2000 ? null : value),
          ),
        ),
        const SizedBox(height: 16),
        LimitSlider(
          title: 'Время в пути',
          value: minutes,
          min: 5,
          max: 60,
          divisions: 11,
          valueLabel: 'До $minutes мин',
          rangeLabels: const ['5 мин', '60 мин'],
          onChanged: (value) => setState(() => minutes = value),
          onChangeEnd: (value) => widget.onChanged(
            filters.copyWith(maxTravelTimeMin: value == 60 ? null : value),
          ),
        ),
      ],
    );
  }

  Widget _buildSwitch(
    String title,
    IconData icon,
    bool value,
    ValueChanged<bool> onChanged,
  ) => SizedBox(
    height: 42,
    child: Row(
      children: [
        Icon(icon, size: 20, color: AppColors.muted),
        const SizedBox(width: 10),
        Expanded(child: Text(title, style: const TextStyle(fontSize: 14))),
        Switch(value: value, onChanged: onChanged),
      ],
    ),
  );
}

class LimitSlider extends StatelessWidget {
  const LimitSlider({
    super.key,
    required this.title,
    required this.value,
    required this.min,
    required this.max,
    required this.divisions,
    required this.valueLabel,
    required this.rangeLabels,
    required this.onChanged,
    required this.onChangeEnd,
  });

  final String title;
  final int value;
  final double min;
  final double max;
  final int divisions;
  final String valueLabel;
  final List<String> rangeLabels;
  final ValueChanged<int> onChanged;
  final ValueChanged<int> onChangeEnd;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 4),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
            ),
            const SizedBox(width: 4),
            Flexible(
              child: Container(
                width: 128,
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: value == max
                      ? AppColors.soft
                      : const Color(0xFFDEE1FF),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    value == max ? 'Без ограничения' : valueLabel,
                    maxLines: 1,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: AppColors.cobaltDark,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: value == max ? AppColors.muted : AppColors.cobalt,
            thumbColor: value == max ? AppColors.muted : AppColors.cobalt,
          ),
          child: Stack(
            alignment: Alignment.centerLeft,
            children: [
              // Extend the track to the label edge while keeping the thumb inside.
              Container(
                width: 12,
                height: 4,
                decoration: BoxDecoration(
                  color: value == max ? AppColors.muted : AppColors.cobalt,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Slider(
                padding: const EdgeInsets.symmetric(horizontal: 9),
                value: value.toDouble(),
                min: min,
                max: max,
                divisions: divisions,
                onChanged: (value) => onChanged(value.round()),
                onChangeEnd: (value) => onChangeEnd(value.round()),
              ),
            ],
          ),
        ),
        Padding(
          padding: EdgeInsets.zero,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: rangeLabels
                .map(
                  (label) => Text(
                    label,
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.muted,
                    ),
                  ),
                )
                .toList(),
          ),
        ),
      ],
    ),
  );
}

class PrioritySelector extends StatelessWidget {
  const PrioritySelector({
    super.key,
    required this.value,
    required this.onChanged,
  });
  final String value;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) => Column(
    children: [
      for (final option in const [
        ('balanced', 'Сбалансированно'),
        ('nearest', 'Поближе'),
        ('cheapest', 'Подешевле'),
      ])
        Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: InkWell(
            onTap: () => onChanged(option.$1),
            borderRadius: BorderRadius.circular(16),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              padding: const EdgeInsets.all(13),
              decoration: BoxDecoration(
                color: value == option.$1
                    ? const Color(0xFFEDF0FF)
                    : const Color(0xFFF6F3F2),
                border: Border.all(
                  color: value == option.$1
                      ? AppColors.cobalt
                      : Colors.transparent,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  Icon(
                    value == option.$1
                        ? Icons.radio_button_checked
                        : Icons.radio_button_unchecked,
                    color: value == option.$1
                        ? AppColors.cobalt
                        : AppColors.muted,
                    size: 21,
                  ),
                  const SizedBox(width: 10),
                  Text(
                    option.$2,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
    ],
  );
}

class SearchFilterSheet extends StatelessWidget {
  const SearchFilterSheet({super.key, required this.controller});
  final Spot4uController controller;

  @override
  Widget build(BuildContext context) {
    final draft = controller.draftCriteria!;
    return Scaffold(
      backgroundColor: Colors.black54,
      body: SafeArea(
        top: false,
        child: Align(
          alignment: Alignment.bottomCenter,
          child: GestureDetector(
            onTap: () {},
            child: Container(
              height: MediaQuery.sizeOf(context).height * 0.9,
              constraints: const BoxConstraints(maxWidth: 600),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
              ),
              child: Column(
                children: [
                  const SizedBox(height: 10),
                  Container(
                    width: 42,
                    height: 5,
                    decoration: BoxDecoration(
                      color: const Color(0xFFD4D4D4),
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 4, 12, 8),
                    child: Row(
                      children: [
                        const Text(
                          'Фильтры',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(width: 7),
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: AppColors.cobalt,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const Spacer(),
                        IconButton(
                          key: const Key('close-filters'),
                          onPressed: controller.closeFilters,
                          icon: const Icon(Icons.close),
                          tooltip: 'Закрыть без применения',
                        ),
                      ],
                    ),
                  ),
                  const Divider(height: 1),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Тип заведения',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 12),
                          CategorySelector(
                            selected: draft.categories,
                            onToggle: controller.toggleDraftCategory,
                          ),
                          if (draft.categories.isEmpty)
                            const Padding(
                              padding: EdgeInsets.only(top: 8),
                              child: Text(
                                'Выберите хотя бы одну категорию',
                                style: TextStyle(
                                  color: AppColors.muted,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          const SizedBox(height: 24),
                          const Text(
                            'Удобства и условия',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 8),
                          FilterControls(
                            filters: draft.filters,
                            onChanged: controller.updateDraftFilters,
                          ),
                          const SizedBox(height: 24),
                          const Text(
                            'Что важнее?',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 10),
                          PrioritySelector(
                            value: draft.priority,
                            onChanged: controller.updateDraftPriority,
                          ),
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 10, 20, 16),
                    child: Row(
                      children: [
                        Expanded(
                          child: SizedBox(
                            height: 56,
                            child: OutlinedButton(
                              key: const Key('reset-draft-filters'),
                              onPressed: controller.resetDraftFilters,
                              style: OutlinedButton.styleFrom(
                                padding: EdgeInsets.zero,
                              ),
                              child: const Text('Сбросить'),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          flex: 2,
                          child: PrimaryButton(
                            key: const Key('apply-filters'),
                            label: 'Показать места',
                            onPressed: draft.categories.isEmpty
                                ? null
                                : controller.applyDraftFilters,
                          ),
                        ),
                      ],
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
}
