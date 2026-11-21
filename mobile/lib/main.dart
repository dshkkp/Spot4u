import 'package:material_ui/material_ui.dart';

import 'src/api.dart';
import 'src/controller.dart';
import 'src/place_utils.dart';
import 'src/screens/home_screen.dart';
import 'src/screens/search_results_screen.dart';
import 'src/widgets/filters.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const Spot4uApp());
}

final _appTheme = ThemeData(
  useMaterial3: true,
  colorScheme: ColorScheme.fromSeed(
    seedColor: AppColors.cobalt,
    primary: AppColors.cobalt,
    surface: AppColors.canvas,
    error: const Color(0xFFBA1A1A),
  ),
  scaffoldBackgroundColor: AppColors.canvas,
  fontFamily: 'Onest',
  splashFactory: InkSparkle.splashFactory,
  appBarTheme: const AppBarTheme(
    backgroundColor: AppColors.canvas,
    foregroundColor: AppColors.ink,
    elevation: 0,
  ),
  sliderTheme: const SliderThemeData(
    activeTrackColor: AppColors.cobalt,
    thumbColor: AppColors.cobalt,
    inactiveTrackColor: Color(0xFFE5E2E1),
    trackHeight: 4,
    padding: EdgeInsets.zero,
    activeTickMarkColor: Colors.transparent,
    inactiveTickMarkColor: Colors.transparent,
    disabledActiveTickMarkColor: Colors.transparent,
    disabledInactiveTickMarkColor: Colors.transparent,
    thumbShape: RoundSliderThumbShape(enabledThumbRadius: 9),
    overlayShape: RoundSliderOverlayShape(overlayRadius: 18),
  ),
  switchTheme: SwitchThemeData(
    thumbColor: const WidgetStatePropertyAll(Colors.white),
    trackColor: WidgetStateProperty.resolveWith(
      (states) => states.contains(WidgetState.selected)
          ? AppColors.cobalt
          : const Color(0xFFD4D4D4),
    ),
    trackOutlineColor: const WidgetStatePropertyAll(Colors.transparent),
  ),
);

class Spot4uApp extends StatefulWidget {
  const Spot4uApp({super.key, this.api});

  final Spot4uApi? api;

  @override
  State<Spot4uApp> createState() => _Spot4uAppState();
}

class _Spot4uAppState extends State<Spot4uApp> {
  late final Spot4uController controller;

  @override
  void initState() {
    super.initState();
    controller = Spot4uController(widget.api ?? HttpSpot4uApi());
    controller.loadCampuses();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'Spot4u',
    debugShowCheckedModeBanner: false,
    theme: _appTheme,
    home: AnimatedBuilder(
      animation: controller,
      builder: (context, _) => PopScope(
        canPop:
            controller.status == SearchStatus.home && !controller.filtersOpen,
        onPopInvokedWithResult: (didPop, result) {
          if (didPop) return;
          if (controller.filtersOpen) {
            controller.closeFilters();
          } else {
            controller.goHome();
          }
        },
        child: Stack(
          children: [
            Positioned.fill(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 180),
                child: KeyedSubtree(
                  key: ValueKey(controller.status),
                  child: switch (controller.status) {
                    SearchStatus.home => HomeScreen(controller: controller),
                    SearchStatus.loading => SearchLoadingScreen(
                      controller: controller,
                    ),
                    SearchStatus.success => SearchResultsScreen(
                      controller: controller,
                    ),
                    SearchStatus.empty => SearchStatusScreen(
                      controller: controller,
                      error: false,
                    ),
                    SearchStatus.error => SearchStatusScreen(
                      controller: controller,
                      error: true,
                    ),
                  },
                ),
              ),
            ),
            if (controller.filtersOpen)
              Positioned.fill(child: SearchFilterSheet(controller: controller)),
          ],
        ),
      ),
    ),
  );
}
