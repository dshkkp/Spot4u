import 'package:material_ui/material_ui.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models.dart';
import '../place_utils.dart';

class PlaceCard extends StatelessWidget {
  const PlaceCard({
    super.key,
    required this.place,
    required this.origin,
    this.expanded = false,
    this.onToggle,
  });

  final Place place;
  final Campus origin;
  final bool expanded;
  final VoidCallback? onToggle;

  @override
  Widget build(BuildContext context) => Container(
    key: Key('place-card-${place.placeId}'),
    padding: const EdgeInsets.all(18),
    decoration: BoxDecoration(
      gradient: placeCardGradient(place.category),
      borderRadius: BorderRadius.circular(26),
      boxShadow: const [
        BoxShadow(
          color: Color(0x14171717),
          blurRadius: 16,
          offset: Offset(0, 6),
        ),
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Wrap(
                spacing: 8,
                runSpacing: 6,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xDFFFFFFF),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      singularCategoryName(place.category).toUpperCase(),
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.4,
                      ),
                    ),
                  ),
                  Text(
                    travelLabel(place),
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            _ScoreBadge(score: place.studyScore),
          ],
        ),
        const SizedBox(height: 12),
        Text(
          place.name,
          style: const TextStyle(
            color: AppColors.ink,
            fontSize: 19,
            height: 1.2,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 5),
        Text(
          place.address,
          style: const TextStyle(color: Color(0xCC171717), fontSize: 13),
        ),
        const SizedBox(height: 13),
        Wrap(
          spacing: 6,
          runSpacing: 6,
          children: [
            if (place.wifi == 'yes')
              const _FeatureChip(icon: Icons.wifi, label: 'Wi-Fi'),
            if (place.sockets == 'yes')
              const _FeatureChip(icon: Icons.power_outlined, label: 'Розетки'),
            if (place.avgCheckRub != null)
              _FeatureChip(
                icon: Icons.payments_outlined,
                label: costLabel(place.avgCheckRub),
              ),
            if (place.studentDiscount == 'yes')
              const _FeatureChip(icon: Icons.school_outlined, label: 'Скидка'),
            if (place.laptopFriendly == 'yes')
              const _FeatureChip(
                icon: Icons.laptop_mac_outlined,
                label: 'Ноутбук',
              ),
          ],
        ),
        const SizedBox(height: 14),
        if (!expanded)
          SizedBox(
            width: double.infinity,
            height: 44,
            child: FilledButton.icon(
              onPressed: onToggle,
              style: _detailsButtonStyle(),
              icon: const Icon(Icons.arrow_forward, size: 17),
              label: const Text('Подробнее'),
            ),
          )
        else
          _ExpandedDetails(place: place, origin: origin, onToggle: onToggle!),
      ],
    ),
  );
}

class _ExpandedDetails extends StatelessWidget {
  const _ExpandedDetails({
    required this.place,
    required this.origin,
    required this.onToggle,
  });

  final Place place;
  final Campus origin;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const Divider(color: Color(0x33171717)),
      _DetailRow(label: 'Время в пути', value: travelLabel(place)),
      _DetailRow(label: 'Wi-Fi', value: flagLabel(place.wifi)),
      _DetailRow(label: 'Розетки', value: flagLabel(place.sockets)),
      _DetailRow(label: 'Для ноутбука', value: flagLabel(place.laptopFriendly)),
      _DetailRow(
        label: 'Средний чек',
        value: place.avgCheckRub == null
            ? 'Нет данных'
            : place.avgCheckRub == 0
            ? '0 ₽ · бесплатно'
            : '${place.avgCheckRub} ₽',
      ),
      _DetailRow(
        label: 'Студенческая скидка',
        value: flagLabel(place.studentDiscount),
      ),
      _DetailRow(label: 'Статус', value: openingStatusLabel(place.openStatus)),
      _DetailRow(
        label: 'Рейтинг',
        value: place.rating == null
            ? 'Нет данных'
            : '${place.rating!.toStringAsFixed(1)}${place.reviewCount == null ? '' : ' · ${place.reviewCount} отзывов'}',
      ),
      _DetailRow(
        label: 'StudyScore',
        value: '${place.studyScore.toStringAsFixed(2)} / 100',
      ),
      const SizedBox(height: 8),
      const Text(
        'Часы работы',
        style: TextStyle(fontSize: 12, color: Color(0xAA171717)),
      ),
      const SizedBox(height: 3),
      Text(
        (place.openingHours ?? 'Нет данных')
            .split(';')
            .map((day) => day.trim())
            .where((day) => day.isNotEmpty)
            .join('\n'),
        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
      ),
      if (place.website != null) ...[
        const SizedBox(height: 8),
        TextButton.icon(
          onPressed: () => _openPlaceLink(context, Uri.parse(place.website!)),
          style: TextButton.styleFrom(padding: EdgeInsets.zero),
          icon: const Icon(Icons.open_in_new, size: 17),
          label: const Flexible(child: Text('Открыть сайт')),
        ),
      ],
      if (place.phone != null) ...[
        const SizedBox(height: 4),
        TextButton.icon(
          onPressed: () => _openPlaceLink(
            context,
            Uri(
              scheme: 'tel',
              path: place.phone!.replaceAll(RegExp(r'[^+0-9]'), ''),
            ),
          ),
          style: TextButton.styleFrom(padding: EdgeInsets.zero),
          icon: const Icon(Icons.phone_outlined, size: 17),
          label: Text(place.phone!),
        ),
      ],
      const SizedBox(height: 12),
      SizedBox(
        width: double.infinity,
        height: 46,
        child: FilledButton.icon(
          key: Key('route-${place.placeId}'),
          onPressed: () =>
              _openPlaceLink(context, yandexRouteUri(origin, place)),
          style: _detailsButtonStyle(),
          icon: const Icon(Icons.open_in_new, size: 17),
          label: const Text('Построить маршрут'),
        ),
      ),
      TextButton.icon(
        onPressed: onToggle,
        style: TextButton.styleFrom(
          foregroundColor: AppColors.ink,
          minimumSize: const Size.fromHeight(40),
        ),
        icon: const Icon(Icons.keyboard_arrow_up),
        label: const Text('Свернуть'),
      ),
    ],
  );
}

Future<void> _openPlaceLink(BuildContext context, Uri uri) async {
  var opened = false;
  try {
    opened = await launchUrl(uri, mode: LaunchMode.externalApplication);
  } on Object {
    opened = false;
  }
  if (!opened && context.mounted) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Не удалось открыть внешнее приложение')),
    );
  }
}

ButtonStyle _detailsButtonStyle() => FilledButton.styleFrom(
  backgroundColor: AppColors.ink,
  foregroundColor: Colors.white,
  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
);

LinearGradient placeCardGradient(String category) => switch (category) {
  'coworking' => const LinearGradient(
    colors: [Color(0xFF50C8F4), Color(0xFF79E5F3), Color(0xFFA5B6FF)],
  ),
  'library' => const LinearGradient(
    colors: [Color(0xFF879FFC), Color(0xFFA6BAFF), Color(0xFFCFBCFF)],
  ),
  'anticafe' => const LinearGradient(
    colors: [Color(0xFFC38CF7), Color(0xFFE0A9FB), Color(0xFFF4B9DD)],
  ),
  'cafe' => const LinearGradient(
    colors: [Color(0xFFF1A0DF), Color(0xFFFFB5C8), Color(0xFFFFC98E)],
  ),
  _ => const LinearGradient(
    colors: [Color(0xFFFF9388), Color(0xFFFFB18F), Color(0xFFFFD28E)],
  ),
};

class _ScoreBadge extends StatelessWidget {
  const _ScoreBadge({required this.score});
  final double score;

  @override
  Widget build(BuildContext context) {
    final color = score >= 75
        ? const Color(0xFF59DC8D)
        : score >= 50
        ? const Color(0xFFFFD34E)
        : const Color(0xFFFF7885);
    return Container(
      padding: const EdgeInsets.fromLTRB(4, 4, 11, 4),
      decoration: BoxDecoration(
        color: const Color(0xEFFFFFFF),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            child: Icon(
              score >= 75
                  ? Icons.sentiment_satisfied_alt
                  : score >= 50
                  ? Icons.sentiment_neutral
                  : Icons.sentiment_dissatisfied,
              size: 21,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            score.round().toString(),
            style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800),
          ),
        ],
      ),
    );
  }
}

class _FeatureChip extends StatelessWidget {
  const _FeatureChip({required this.icon, required this.label});
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
    decoration: BoxDecoration(
      color: const Color(0xEFFFFFFF),
      borderRadius: BorderRadius.circular(10),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14),
        const SizedBox(width: 4),
        Flexible(
          child: Text(
            label,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500),
          ),
        ),
      ],
    ),
  );
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 4),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: Text(label, style: const TextStyle(fontSize: 13))),
        const SizedBox(width: 12),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
          ),
        ),
      ],
    ),
  );
}
