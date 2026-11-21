import 'package:material_ui/material_ui.dart';

import '../controller.dart';
import '../models.dart';
import '../place_utils.dart';

const categoryIcons = {
  'cafe': Icons.restaurant_outlined,
  'coffee_shop': Icons.local_cafe_outlined,
  'library': Icons.menu_book_outlined,
  'coworking': Icons.business_outlined,
  'anticafe': Icons.chair_outlined,
};

class Spot4uLogo extends StatelessWidget {
  const Spot4uLogo({super.key, this.light = false});
  final bool light;

  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Text(
        'Spot4u',
        style: TextStyle(
          color: light ? Colors.white : AppColors.ink,
          fontSize: 22,
          fontWeight: FontWeight.w800,
          letterSpacing: -0.6,
        ),
      ),
      const SizedBox(width: 6),
      Container(
        width: 10,
        height: 10,
        decoration: const BoxDecoration(
          color: AppColors.lime,
          shape: BoxShape.circle,
        ),
      ),
    ],
  );
}

class AppHeader extends StatelessWidget {
  const AppHeader({super.key, required this.onBack});
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) => SizedBox(
    height: 52,
    child: Row(
      children: [
        IconButton.filledTonal(
          key: const Key('back-button'),
          onPressed: onBack,
          icon: const Icon(Icons.arrow_back),
          tooltip: 'На главную',
        ),
        const Expanded(child: Center(child: Spot4uLogo())),
        const SizedBox(width: 48),
      ],
    ),
  );
}

class OriginCard extends StatelessWidget {
  const OriginCard({super.key, required this.campus});
  final Campus campus;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      boxShadow: const [
        BoxShadow(
          color: Color(0x0D304CC9),
          blurRadius: 20,
          offset: Offset(0, 8),
        ),
      ],
    ),
    child: Row(
      children: [
        Container(
          width: 42,
          height: 42,
          decoration: const BoxDecoration(
            color: AppColors.lime,
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.near_me, size: 21, color: AppColors.ink),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'СТАРТОВАЯ ТОЧКА',
                style: TextStyle(
                  color: AppColors.muted,
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.7,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                campus.address,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

class CategorySelector extends StatelessWidget {
  const CategorySelector({
    super.key,
    required this.selected,
    required this.onToggle,
  });

  final Set<String> selected;
  final ValueChanged<String> onToggle;

  @override
  Widget build(BuildContext context) => Wrap(
    spacing: 8,
    runSpacing: 8,
    children: categoryNames.entries.map((entry) {
      final isSelected = selected.contains(entry.key);
      return FilterChip(
        key: Key('category-${entry.key}'),
        label: Text(entry.value),
        avatar: Icon(categoryIcons[entry.key], size: 18),
        selected: isSelected,
        showCheckmark: true,
        checkmarkColor: Colors.white,
        selectedColor: AppColors.cobalt,
        backgroundColor: AppColors.soft,
        side: BorderSide.none,
        labelStyle: TextStyle(
          color: isSelected ? Colors.white : AppColors.ink,
          fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
        ),
        onSelected: (_) => onToggle(entry.key),
      );
    }).toList(),
  );
}

class AppFilterButton extends StatelessWidget {
  const AppFilterButton({
    super.key,
    required this.count,
    required this.onPressed,
  });

  final int count;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) => Align(
    alignment: Alignment.centerLeft,
    child: FilledButton.icon(
      key: const Key('filters-button'),
      onPressed: onPressed,
      style: FilledButton.styleFrom(
        backgroundColor: AppColors.ink,
        foregroundColor: Colors.white,
        disabledBackgroundColor: AppColors.ink,
        disabledForegroundColor: Colors.white70,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      ),
      icon: const Icon(Icons.tune, size: 17),
      label: Text(count == 0 ? 'Фильтры' : 'Фильтры • $count'),
    ),
  );
}

class ViewSwitcher extends StatelessWidget {
  const ViewSwitcher({super.key, required this.view, required this.onChanged});
  final ResultView view;
  final ValueChanged<ResultView> onChanged;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(4),
    decoration: BoxDecoration(
      color: const Color(0xFFEAE7E7),
      borderRadius: BorderRadius.circular(30),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _tab(ResultView.list, Icons.format_list_bulleted, 'Список'),
        _tab(ResultView.map, Icons.map_outlined, 'Карта'),
      ],
    ),
  );

  Widget _tab(ResultView value, IconData icon, String label) {
    final selected = view == value;
    return InkWell(
      key: Key('${value.name}-tab'),
      onTap: () => onChanged(value),
      borderRadius: BorderRadius.circular(24),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? AppColors.cobalt : Colors.transparent,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 14,
              color: selected ? Colors.white : AppColors.muted,
            ),
            const SizedBox(width: 3),
            Text(
              label,
              style: TextStyle(
                color: selected ? Colors.white : AppColors.muted,
                fontSize: 11,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class PrimaryButton extends StatelessWidget {
  const PrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon = Icons.arrow_forward,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData icon;

  @override
  Widget build(BuildContext context) => SizedBox(
    width: double.infinity,
    height: 56,
    child: ElevatedButton.icon(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.lime,
        foregroundColor: AppColors.ink,
        disabledBackgroundColor: const Color(0xFFE5E2E1),
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        textStyle: const TextStyle(
          fontFamily: 'Onest',
          fontSize: 16,
          fontWeight: FontWeight.w700,
        ),
      ),
      icon: Icon(icon),
      label: FittedBox(fit: BoxFit.scaleDown, child: Text(label, maxLines: 1)),
    ),
  );
}
