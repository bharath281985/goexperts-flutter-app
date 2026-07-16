import 'dart:async';

import 'package:flutter/material.dart';

import '../../app/constants/app_colors.dart';
import '../../app/constants/app_sizes.dart';
import '../extensions/context_extensions.dart';
import '../services/google_places_service.dart';

class LocationSearchSheet extends StatefulWidget {
  const LocationSearchSheet({
    super.key,
    this.initialQuery = '',
    this.placesService,
  });

  final String initialQuery;
  final GooglePlacesService? placesService;

  static Future<SelectedPlace?> show(
    BuildContext context, {
    String initialQuery = '',
    GooglePlacesService? placesService,
  }) {
    return showModalBottomSheet<SelectedPlace>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.viewInsetsOf(context).bottom,
        ),
        child: LocationSearchSheet(
          initialQuery: initialQuery,
          placesService: placesService,
        ),
      ),
    );
  }

  @override
  State<LocationSearchSheet> createState() => _LocationSearchSheetState();
}

class _LocationSearchSheetState extends State<LocationSearchSheet> {
  late final TextEditingController _searchController = TextEditingController(
    text: widget.initialQuery,
  );
  late final GooglePlacesService _placesService =
      widget.placesService ?? GooglePlacesService();

  Timer? _debounce;
  bool _loading = false;
  bool _resolving = false;
  String? _error;
  List<PlacePrediction> _predictions = [];

  @override
  void initState() {
    super.initState();
    if (widget.initialQuery.trim().isNotEmpty) {
      _search(widget.initialQuery);
    }
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  void _onQueryChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 350), () => _search(value));
  }

  Future<void> _search(String query) async {
    if (query.trim().length < 2) {
      setState(() {
        _predictions = [];
        _error = null;
        _loading = false;
      });
      return;
    }

    setState(() {
      _loading = true;
      _error = null;
    });

    final results = await _placesService.searchPlaces(query);
    if (!mounted) return;

    setState(() {
      _loading = false;
      _predictions = results;
      if (results.isEmpty) _error = 'No locations found';
    });
  }

  Future<void> _selectPrediction(PlacePrediction prediction) async {
    setState(() {
      _resolving = true;
      _error = null;
    });

    final place = await _placesService.getPlaceDetails(prediction.placeId);
    if (!mounted) return;

    if (place == null || place.formattedAddress.isEmpty) {
      setState(() {
        _resolving = false;
        _error = 'Could not load location details';
      });
      return;
    }

    Navigator.of(context).pop(place);
  }

  @override
  Widget build(BuildContext context) {
    final sheetHeight = MediaQuery.sizeOf(context).height * 0.75;

    return SizedBox(
      height: sheetHeight,
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.xl),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Search location', style: context.text.titleMedium),
            AppSizes.vGapMd,
            TextField(
              controller: _searchController,
              autofocus: true,
              textInputAction: TextInputAction.search,
              decoration: InputDecoration(
                hintText: 'Search city, area, or address',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        onPressed: () {
                          _searchController.clear();
                          setState(() {
                            _predictions = [];
                            _error = null;
                          });
                        },
                        icon: const Icon(Icons.clear),
                      )
                    : null,
              ),
              onChanged: (value) {
                setState(() {});
                _onQueryChanged(value);
              },
              onSubmitted: _search,
            ),
            AppSizes.vGapMd,
            if (_loading || _resolving)
              const LinearProgressIndicator(minHeight: 2),
            if (_error != null) ...[
              AppSizes.vGapSm,
              Text(
                _error!,
                style: context.text.bodySmall?.copyWith(color: AppColors.danger),
              ),
            ],
            AppSizes.vGapSm,
            Expanded(
              child: ListView.separated(
                itemCount: _predictions.length,
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final prediction = _predictions[index];
                  return ListTile(
                    leading: const Icon(Icons.location_on_outlined),
                    title: Text(prediction.description),
                    onTap: _resolving
                        ? null
                        : () => _selectPrediction(prediction),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
