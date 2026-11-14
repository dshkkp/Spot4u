import 'package:material_ui/material_ui.dart';

import 'models.dart';

abstract final class AppColors {
  static const cobalt = Color(0xFF304CC9);
  static const cobaltDark = Color(0xFF1E369B);
  static const lime = Color(0xFFD5F477);
  static const ink = Color(0xFF171717);
  static const canvas = Color(0xFFFCF9F8);
  static const muted = Color(0xFF64748B);
  static const soft = Color(0xFFF0EDED);
}

const categoryNames = {
  'cafe': 'Кафе',
  'coffee_shop': 'Кофейни',
  'library': 'Библиотеки',
  'coworking': 'Коворкинги',
  'anticafe': 'Антикафе',
};

const categorySingularNames = {
  'cafe': 'Кафе',
  'coffee_shop': 'Кофейня',
  'library': 'Библиотека',
  'coworking': 'Коворкинг',
  'anticafe': 'Антикафе',
};

String singularCategoryName(String category) =>
    categorySingularNames[category] ?? category;

String flagLabel(String? value) => switch (value) {
  'yes' => 'Есть',
  'no' => 'Нет',
  _ => 'Нет данных',
};

String costLabel(int? value) {
  if (value == null) return 'Средний чек: Нет данных';
  if (value == 0) return 'Бесплатно';
  return 'Средний чек $value ₽';
}

String travelLabel(Place place) {
  final mode = switch (place.travelMode) {
    'walking' => 'пешком',
    'metro' => 'на метро',
    _ => null,
  };
  final minutes = place.travelTimeMin;
  if (minutes == null) {
    return mode == null
        ? 'Время в пути: нет данных'
        : 'Время в пути: нет данных · $mode';
  }
  return '$minutes мин · ${mode ?? 'Способ не указан'}';
}

String openingStatusLabel(String status) => switch (status) {
  'open' => 'Открыто сейчас',
  'closed' => 'Сейчас закрыто',
  _ => 'Нет данных',
};

Uri yandexRouteUri(Campus origin, Place place) => Uri(
  scheme: 'https',
  host: 'yandex.ru',
  path: '/maps/',
  queryParameters: {
    'rtext':
        '${origin.latitude},${origin.longitude}~${place.latitude},${place.longitude}',
    if (place.travelMode == 'walking') 'rtt': 'pd',
    if (place.travelMode == 'metro') 'rtt': 'mt',
  },
);
