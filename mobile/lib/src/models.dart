class Campus {
  const Campus({
    required this.id,
    required this.name,
    required this.address,
    required this.latitude,
    required this.longitude,
  });

  final String id;
  final String name;
  final String address;
  final double latitude;
  final double longitude;

  factory Campus.fromJson(Map<String, dynamic> json) => Campus(
    id: json['id'] as String,
    name: json['name'] as String,
    address: json['address'] as String,
    latitude: (json['latitude'] as num).toDouble(),
    longitude: (json['longitude'] as num).toDouble(),
  );

  static const leningradsky = Campus(
    id: 'leningradsky',
    name: 'Ленинградский проспект',
    address: 'Москва, Ленинградский проспект, 49/2',
    latitude: 55.8003496,
    longitude: 37.5288590,
  );

  static const veshnyakovsky = Campus(
    id: 'veshnyakovsky',
    name: 'Вешняковский проезд',
    address: 'Москва, 4-й Вешняковский проезд, 4, стр. 3',
    latitude: 55.7183211,
    longitude: 37.7956473,
  );

  static const defaults = [leningradsky, veshnyakovsky];
}

class Place {
  const Place({
    required this.placeId,
    required this.name,
    required this.category,
    required this.address,
    required this.latitude,
    required this.longitude,
    required this.openingHours,
    required this.rating,
    required this.reviewCount,
    required this.avgCheckRub,
    required this.wifi,
    required this.sockets,
    required this.laptopFriendly,
    required this.studentDiscount,
    required this.website,
    required this.phone,
    required this.travelTimeMin,
    required this.travelMode,
    required this.openStatus,
    required this.studyScore,
  });

  final String placeId;
  final String name;
  final String category;
  final String address;
  final double latitude;
  final double longitude;
  final String? openingHours;
  final double? rating;
  final int? reviewCount;
  final int? avgCheckRub;
  final String? wifi;
  final String? sockets;
  final String? laptopFriendly;
  final String? studentDiscount;
  final String? website;
  final String? phone;
  final int? travelTimeMin;
  final String? travelMode;
  final String openStatus;
  final double studyScore;

  factory Place.fromJson(Map<String, dynamic> json) => Place(
    placeId: json['place_id'] as String,
    name: json['name'] as String,
    category: json['category'] as String,
    address: json['address'] as String,
    latitude: (json['latitude'] as num).toDouble(),
    longitude: (json['longitude'] as num).toDouble(),
    openingHours: json['opening_hours'] as String?,
    rating: (json['rating'] as num?)?.toDouble(),
    reviewCount: json['review_count'] as int?,
    avgCheckRub: json['avg_check_rub'] as int?,
    wifi: json['wifi'] as String?,
    sockets: json['sockets'] as String?,
    laptopFriendly: json['laptop_friendly'] as String?,
    studentDiscount: json['student_discount'] as String?,
    website: json['website'] as String?,
    phone: json['phone'] as String?,
    travelTimeMin: json['travel_time_min'] as int?,
    travelMode: json['travel_mode'] as String?,
    openStatus: json['open_status'] as String,
    studyScore: (json['study_score'] as num).toDouble(),
  );
}

class SearchFilters {
  const SearchFilters({
    this.wifi = false,
    this.sockets = false,
    this.laptopFriendly = false,
    this.studentDiscount = false,
    this.openNow = false,
    this.maxAvgCheckRub,
    this.maxTravelTimeMin,
  });

  final bool wifi;
  final bool sockets;
  final bool laptopFriendly;
  final bool studentDiscount;
  final bool openNow;
  final int? maxAvgCheckRub;
  final int? maxTravelTimeMin;

  static const _unset = Object();

  SearchFilters copyWith({
    bool? wifi,
    bool? sockets,
    bool? laptopFriendly,
    bool? studentDiscount,
    bool? openNow,
    Object? maxAvgCheckRub = _unset,
    Object? maxTravelTimeMin = _unset,
  }) => SearchFilters(
    wifi: wifi ?? this.wifi,
    sockets: sockets ?? this.sockets,
    laptopFriendly: laptopFriendly ?? this.laptopFriendly,
    studentDiscount: studentDiscount ?? this.studentDiscount,
    openNow: openNow ?? this.openNow,
    maxAvgCheckRub: identical(maxAvgCheckRub, _unset)
        ? this.maxAvgCheckRub
        : maxAvgCheckRub as int?,
    maxTravelTimeMin: identical(maxTravelTimeMin, _unset)
        ? this.maxTravelTimeMin
        : maxTravelTimeMin as int?,
  );

  int get activeCount =>
      [wifi, sockets, laptopFriendly, studentDiscount, openNow].where((v) => v).length +
      (maxAvgCheckRub != null ? 1 : 0) +
      (maxTravelTimeMin != null ? 1 : 0);

  Map<String, dynamic> toJson() => {
    'wifi': wifi,
    'sockets': sockets,
    'laptop_friendly': laptopFriendly,
    'student_discount': studentDiscount,
    'open_now': openNow,
    'max_avg_check_rub': maxAvgCheckRub,
    'max_travel_time_min': maxTravelTimeMin,
  };
}

class SearchCriteria {
  const SearchCriteria({
    required this.origin,
    required this.categories,
    required this.priority,
    required this.filters,
  });

  final Campus origin;
  final Set<String> categories;
  final String priority;
  final SearchFilters filters;

  factory SearchCriteria.initial() => const SearchCriteria(
    origin: Campus.leningradsky,
    categories: <String>{},
    priority: 'balanced',
    filters: SearchFilters(),
  );

  SearchCriteria copyWith({
    Campus? origin,
    Set<String>? categories,
    String? priority,
    SearchFilters? filters,
  }) => SearchCriteria(
    origin: origin ?? this.origin,
    categories: Set.unmodifiable(categories ?? this.categories),
    priority: priority ?? this.priority,
    filters: filters ?? this.filters,
  );

  Map<String, dynamic> toJson() => {
    'origin_id': origin.id,
    'categories': categories.toList()..sort(),
    'priority': priority,
    'filters': filters.toJson(),
  };
}

class SearchResult {
  const SearchResult({
    required this.origin,
    required this.priority,
    required this.places,
  });

  final Campus origin;
  final String priority;
  final List<Place> places;

  int get count => places.length;

  factory SearchResult.fromJson(Map<String, dynamic> json) => SearchResult(
    origin: Campus.fromJson(json['origin'] as Map<String, dynamic>),
    priority: json['priority'] as String,
    places: (json['places'] as List<dynamic>)
        .map((value) => Place.fromJson(value as Map<String, dynamic>))
        .toList(growable: false),
  );
}
