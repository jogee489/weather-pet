import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/models/weather_theme.dart';
import '../../core/providers/location_provider.dart';
import '../../core/providers/pet_state_provider.dart';
import '../../core/services/weather_api.dart';

// ─── Search state ─────────────────────────────────────────────────────────────

class _SearchState {
  const _SearchState({
    this.results = const [],
    this.isLoading = false,
    this.error,
  });

  final List<GeocodingResult> results;
  final bool isLoading;
  final String? error;

  _SearchState copyWith({
    List<GeocodingResult>? results,
    bool? isLoading,
    String? error,
  }) =>
      _SearchState(
        results: results ?? this.results,
        isLoading: isLoading ?? this.isLoading,
        error: error,
      );
}

class _SearchNotifier extends StateNotifier<_SearchState> {
  _SearchNotifier() : super(const _SearchState());

  final _api = const WeatherApi();

  Future<void> search(String query) async {
    if (query.trim().isEmpty) {
      state = const _SearchState();
      return;
    }
    state = state.copyWith(isLoading: true, error: null, results: []);
    try {
      final results = await _api.searchCity(query);
      state = _SearchState(results: results);
    } catch (e) {
      state = const _SearchState(error: 'Search failed. Check your connection.');
    }
  }

  void clear() => state = const _SearchState();
}

final _searchProvider =
    StateNotifierProvider.autoDispose<_SearchNotifier, _SearchState>(
  (_) => _SearchNotifier(),
);

// ─── Screen ───────────────────────────────────────────────────────────────────

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final petState = ref.watch(petStateProvider);
    final theme = WeatherTheme.forState(petState);
    final searchState = ref.watch(_searchProvider);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 600),
      decoration: BoxDecoration(gradient: theme.gradient),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Header ──────────────────────────────────────────────
                Text(
                  'Search',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        color: theme.textPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 16),

                // ── Search field ─────────────────────────────────────────
                TextField(
                  controller: _controller,
                  focusNode: _focusNode,
                  onChanged: (v) =>
                      ref.read(_searchProvider.notifier).search(v),
                  style: TextStyle(color: theme.textPrimary),
                  decoration: InputDecoration(
                    hintText: 'Search for a city…',
                    hintStyle:
                        TextStyle(color: theme.textPrimary.withOpacity(0.5)),
                    prefixIcon: Icon(Icons.search,
                        color: theme.textPrimary.withOpacity(0.7)),
                    suffixIcon: _controller.text.isNotEmpty
                        ? IconButton(
                            icon: Icon(Icons.clear,
                                color: theme.textPrimary.withOpacity(0.7)),
                            onPressed: () {
                              _controller.clear();
                              ref.read(_searchProvider.notifier).clear();
                            },
                          )
                        : null,
                    filled: true,
                    fillColor: theme.cardColor,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // ── Results area ─────────────────────────────────────────
                Expanded(child: _ResultsArea(state: searchState, theme: theme)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Results area ─────────────────────────────────────────────────────────────

class _ResultsArea extends ConsumerWidget {
  const _ResultsArea({required this.state, required this.theme});
  final _SearchState state;
  final WeatherTheme theme;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (state.isLoading) {
      return Center(
        child: CircularProgressIndicator(
          color: theme.textPrimary.withOpacity(0.6),
          strokeWidth: 2,
        ),
      );
    }

    if (state.error != null) {
      return Center(
        child: Text(
          state.error!,
          style: TextStyle(color: theme.textPrimary.withOpacity(0.8)),
          textAlign: TextAlign.center,
        ),
      );
    }

    if (state.results.isEmpty) {
      return Center(
        child: Text(
          'Type a city name to search',
          style: TextStyle(color: theme.textPrimary.withOpacity(0.5)),
        ),
      );
    }

    return ListView.separated(
      itemCount: state.results.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (_, i) => _ResultTile(
        result: state.results[i],
        theme: theme,
        onTap: () async {
          final r = state.results[i];
          await ref.read(locationProvider.notifier).setManual(
                (lat: r.lat, lon: r.lon),
              );
          if (context.mounted) context.go('/home');
        },
      ),
    );
  }
}

// ─── Result tile ──────────────────────────────────────────────────────────────

class _ResultTile extends StatelessWidget {
  const _ResultTile({
    required this.result,
    required this.theme,
    required this.onTap,
  });
  final GeocodingResult result;
  final WeatherTheme theme;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: theme.cardColor,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(
            children: [
              Icon(Icons.location_on_outlined,
                  color: theme.textPrimary.withOpacity(0.7), size: 20),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  result.displayName,
                  style: TextStyle(
                    color: theme.textPrimary,
                    fontSize: 15,
                  ),
                ),
              ),
              Icon(Icons.chevron_right,
                  color: theme.textPrimary.withOpacity(0.4), size: 20),
            ],
          ),
        ),
      ),
    );
  }
}
