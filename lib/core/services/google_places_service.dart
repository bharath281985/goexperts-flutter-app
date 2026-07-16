import 'package:dio/dio.dart';

import '../../app/config/app_config.dart';
import '../../app/config/google_maps_config.dart';

class PlacePrediction {
  const PlacePrediction({
    required this.placeId,
    required this.description,
  });

  final String placeId;
  final String description;
}

class SelectedPlace {
  const SelectedPlace({
    required this.formattedAddress,
    required this.placeId,
    this.latitude,
    this.longitude,
  });

  final String formattedAddress;
  final String placeId;
  final double? latitude;
  final double? longitude;
}

class GooglePlacesService {
  GooglePlacesService({Dio? dio}) : _dio = dio ?? Dio();

  final Dio _dio;

  Future<List<PlacePrediction>> searchPlaces(String input) async {
    final query = input.trim();
    if (query.length < 2) return [];

    try {
      final response = await _dio.get<Map<String, dynamic>>(
        GoogleMapsConfig.placesAutocompleteUrl,
        queryParameters: {
          'input': query,
          'key': GoogleMapsConfig.apiKey,
          'types': 'geocode',
        },
        options: Options(
          receiveTimeout: AppConfig.connectTimeout,
          sendTimeout: AppConfig.connectTimeout,
        ),
      );

      final data = response.data;
      if (data == null || data['status'] != 'OK') return [];

      final predictions = data['predictions'] as List? ?? [];
      return predictions
          .whereType<Map>()
          .map(
            (item) => PlacePrediction(
              placeId: item['place_id']?.toString() ?? '',
              description: item['description']?.toString() ?? '',
            ),
          )
          .where((item) => item.placeId.isNotEmpty && item.description.isNotEmpty)
          .toList();
    } catch (_) {
      return [];
    }
  }

  Future<SelectedPlace?> getPlaceDetails(String placeId) async {
    if (placeId.isEmpty) return null;

    try {
      final response = await _dio.get<Map<String, dynamic>>(
        GoogleMapsConfig.placeDetailsUrl,
        queryParameters: {
          'place_id': placeId,
          'key': GoogleMapsConfig.apiKey,
          'fields': 'formatted_address,geometry',
        },
        options: Options(
          receiveTimeout: AppConfig.connectTimeout,
          sendTimeout: AppConfig.connectTimeout,
        ),
      );

      final data = response.data;
      if (data == null || data['status'] != 'OK') return null;

      final result = data['result'];
      if (result is! Map) return null;

      final geometry = result['geometry'];
      final location = geometry is Map ? geometry['location'] : null;
      final lat = location is Map ? location['lat'] : null;
      final lng = location is Map ? location['lng'] : null;

      return SelectedPlace(
        placeId: placeId,
        formattedAddress:
            result['formatted_address']?.toString() ?? '',
        latitude: lat is num ? lat.toDouble() : double.tryParse('$lat'),
        longitude: lng is num ? lng.toDouble() : double.tryParse('$lng'),
      );
    } catch (_) {
      return null;
    }
  }
}
