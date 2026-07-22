import 'package:flutter/material.dart';

import '../../app/constants/app_sizes.dart';
import '../extensions/context_extensions.dart';
import '../services/google_places_service.dart';
import 'location_search_sheet.dart';

/// Location field with Google Places search and selection.
class AppLocationField extends StatelessWidget {
  const AppLocationField({
    super.key,
    required this.controller,
    this.label,
    this.hint,
    this.validator,
    this.onPlaceSelected,
    this.placesService,
  });

  final TextEditingController controller;
  final String? label;
  final String? hint;
  final String? Function(String?)? validator;
  final ValueChanged<SelectedPlace>? onPlaceSelected;
  final GooglePlacesService? placesService;

  Future<void> _openSearch(BuildContext context) async {
    final selected = await LocationSearchSheet.show(
      context,
      initialQuery: controller.text,
      placesService: placesService,
    );
    if (selected == null) return;

    controller.text = selected.formattedAddress;
    onPlaceSelected?.call(selected);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null) ...[
          Text(label!, style: context.text.titleSmall),
          AppSizes.vGapSm,
        ],
        TextFormField(
          controller: controller,
          readOnly: true,
          onTap: () => _openSearch(context),
          validator: validator,
          decoration: InputDecoration(
            hintText: hint ?? 'Search and select location',
            prefixIcon: const Icon(
              Icons.location_on_outlined,
              size: AppSizes.iconMd,
            ),
            suffixIcon: IconButton(
              tooltip: 'Search location',
              onPressed: () => _openSearch(context),
              icon: const Icon(Icons.search),
            ),
          ),
        ),
      ],
    );
  }
}
