import 'package:material_ui/material_ui.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../models.dart';
import '../place_utils.dart';
import 'common.dart';
import 'place_card.dart';

class PlacesMap extends StatefulWidget {
  const PlacesMap({
    super.key,
    required this.result,
    required this.selectedPlaceId,
    required this.onSelected,
  });

  final SearchResult result;
  final String? selectedPlaceId;
  final ValueChanged<String> onSelected;

  @override
  State<PlacesMap> createState() => _PlacesMapState();
}

class _PlacesMapState extends State<PlacesMap> {
  static const cardPeekSize = 0.48;
  final mapController = MapController();
  final cardController = DraggableScrollableController();
  bool ready = false;
  bool cardExpanded = false;

  @override
  void initState() {
    super.initState();
    cardController.addListener(_updateCardExpansion);
  }

  @override
  void dispose() {
    cardController.dispose();
    super.dispose();
  }

  void _updateCardExpansion() {
    final expanded = cardController.size > 0.7;
    if (mounted && expanded != cardExpanded) {
      setState(() => cardExpanded = expanded);
    }
  }

  void _toggleCard() {
    setState(() => cardExpanded = !cardExpanded);
    if (cardController.isAttached) {
      cardController.animateTo(
        cardExpanded ? 0.95 : cardPeekSize,
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutCubic,
      );
    }
  }

  List<LatLng> get points => [
    LatLng(widget.result.origin.latitude, widget.result.origin.longitude),
    for (final place in widget.result.places)
      LatLng(place.latitude, place.longitude),
  ];

  @override
  void didUpdateWidget(covariant PlacesMap oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedPlaceId != widget.selectedPlaceId) {
      cardExpanded = false;
      if (cardController.isAttached) cardController.jumpTo(cardPeekSize);
    }
    if (oldWidget.result.places.map((p) => p.placeId).join() !=
        widget.result.places.map((p) => p.placeId).join()) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _fitMapToResults());
    }
  }

  void _fitMapToResults() {
    if (!ready || !mounted) return;
    mapController.fitCamera(
      CameraFit.coordinates(
        coordinates: points,
        padding: const EdgeInsets.fromLTRB(40, 48, 40, 100),
        maxZoom: 16,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final selected = widget.result.places
        .where((place) => place.placeId == widget.selectedPlaceId)
        .firstOrNull;
    return ClipRRect(
      borderRadius: BorderRadius.circular(26),
      child: Stack(
        children: [
          FlutterMap(
            mapController: mapController,
            options: MapOptions(
              initialCenter: points.first,
              initialZoom: 13,
              maxZoom: 19,
              onMapReady: () {
                ready = true;
                WidgetsBinding.instance.addPostFrameCallback(
                  (_) => _fitMapToResults(),
                );
              },
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'ru.spot4u.app',
                maxZoom: 19,
              ),
              MarkerLayer(
                markers: [
                  Marker(
                    point: points.first,
                    width: 58,
                    height: 58,
                    child: Tooltip(
                      message:
                          'Стартовая точка: ${widget.result.origin.address}',
                      child: Container(
                        decoration: BoxDecoration(
                          color: AppColors.lime,
                          shape: BoxShape.circle,
                          border: Border.all(color: AppColors.ink, width: 2),
                          boxShadow: const [
                            BoxShadow(color: Color(0x33171717), blurRadius: 8),
                          ],
                        ),
                        child: const Icon(Icons.school, color: AppColors.ink),
                      ),
                    ),
                  ),
                  for (final place in widget.result.places)
                    Marker(
                      point: LatLng(place.latitude, place.longitude),
                      width: 68,
                      height: 44,
                      child: GestureDetector(
                        key: Key('place-marker-${place.placeId}'),
                        behavior: HitTestBehavior.opaque,
                        onTap: () => widget.onSelected(place.placeId),
                        child: _PlaceMarker(
                          place: place,
                          selected: place.placeId == widget.selectedPlaceId,
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
          Positioned(
            right: 10,
            top: 12,
            child: Column(
              children: [
                _MapButton(
                  icon: Icons.add,
                  tooltip: 'Приблизить',
                  onPressed: () => mapController.move(
                    mapController.camera.center,
                    mapController.camera.zoom + 1,
                  ),
                ),
                const SizedBox(height: 6),
                _MapButton(
                  icon: Icons.remove,
                  tooltip: 'Отдалить',
                  onPressed: () => mapController.move(
                    mapController.camera.center,
                    mapController.camera.zoom - 1,
                  ),
                ),
              ],
            ),
          ),
          const Positioned(
            left: 5,
            top: 4,
            child: DecoratedBox(
              decoration: BoxDecoration(color: Color(0xCCFFFFFF)),
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                child: Text(
                  '© OpenStreetMap contributors',
                  style: TextStyle(fontSize: 9, color: AppColors.ink),
                ),
              ),
            ),
          ),
          if (selected != null)
            Positioned.fill(
              child: DraggableScrollableSheet(
                key: const Key('map-place-sheet'),
                controller: cardController,
                initialChildSize: cardPeekSize,
                minChildSize: 0.28,
                maxChildSize: 0.95,
                snap: true,
                snapSizes: const [cardPeekSize],
                builder: (context, scrollController) => ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(26),
                  ),
                  child: SingleChildScrollView(
                    controller: scrollController,
                    child: Column(
                      children: [
                        Center(
                          child: Container(
                            width: 42,
                            height: 5,
                            margin: const EdgeInsets.only(bottom: 6),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(3),
                            ),
                          ),
                        ),
                        PlaceCard(
                          place: selected,
                          origin: widget.result.origin,
                          expanded: cardExpanded,
                          onToggle: _toggleCard,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _PlaceMarker extends StatelessWidget {
  const _PlaceMarker({required this.place, required this.selected});
  final Place place;
  final bool selected;

  @override
  Widget build(BuildContext context) => Center(
    child: AnimatedContainer(
      duration: const Duration(milliseconds: 160),
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 7),
      decoration: BoxDecoration(
        color: placeMarkerColor(place.category),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: selected ? AppColors.cobalt : Colors.white,
          width: selected ? 3 : 2,
        ),
        boxShadow: const [BoxShadow(color: Color(0x33171717), blurRadius: 7)],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(categoryIcons[place.category], size: 14, color: AppColors.ink),
          const SizedBox(width: 3),
          Text(
            place.studyScore.round().toString(),
            style: const TextStyle(
              color: AppColors.ink,
              fontSize: 12,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    ),
  );
}

Color placeMarkerColor(String category) => switch (category) {
  'coworking' => const Color(0xFF72D3FE),
  'library' => const Color(0xFFD6E0FF),
  'anticafe' => const Color(0xFFE8D5FF),
  'cafe' => const Color(0xFFF1A0DF),
  _ => const Color(0xFFFED7AA),
};

class _MapButton extends StatelessWidget {
  const _MapButton({
    required this.icon,
    required this.tooltip,
    required this.onPressed,
  });
  final IconData icon;
  final String tooltip;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) => Material(
    color: Colors.white,
    borderRadius: BorderRadius.circular(14),
    elevation: 2,
    child: IconButton(onPressed: onPressed, icon: Icon(icon), tooltip: tooltip),
  );
}
