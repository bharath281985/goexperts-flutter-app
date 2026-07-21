import 'package:country_code_picker/country_code_picker.dart';
import 'package:flutter/material.dart';

import '../../app/constants/app_sizes.dart';
import '../extensions/context_extensions.dart';

class CountryCodeField extends StatelessWidget {
  const CountryCodeField({
    super.key,
    required this.initialSelection,
    required this.onChanged,
    this.onInit,
    this.label = 'Country',
  });

  final String initialSelection;
  final ValueChanged<CountryCode> onChanged;
  final ValueChanged<CountryCode>? onInit;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(context.tr(label), style: context.text.titleSmall),
        AppSizes.vGapSm,
        InputDecorator(
          decoration: const InputDecoration(
            constraints: BoxConstraints(minHeight: 56),
            contentPadding: EdgeInsets.symmetric(
              horizontal: AppSizes.sm,
              vertical: AppSizes.md,
            ),
          ),
          child: CountryCodePicker(
            initialSelection: initialSelection,
            onInit: (countryCode) {
              if (countryCode != null) onInit?.call(countryCode);
            },
            onChanged: onChanged,
            showCountryOnly: false,
            showOnlyCountryWhenClosed: false,
            showDropDownButton: false,
            alignLeft: true,
            padding: EdgeInsets.zero,
            flagWidth: 24,
            textStyle: context.text.bodyMedium,
            dialogTextStyle: context.text.bodyMedium,
            searchDecoration: InputDecoration(
              hintText: context.tr('Search country'),
            ),
            builder: (countryCode) =>
                _CountryCodeButton(countryCode: countryCode),
          ),
        ),
      ],
    );
  }
}

class _CountryCodeButton extends StatelessWidget {
  const _CountryCodeButton({required this.countryCode});

  final CountryCode? countryCode;

  @override
  Widget build(BuildContext context) {
    final code = countryCode;
    return SizedBox(
      height: 25,
      child: Row(
        children: [
          if (code?.flagUri != null) ...[
            Image.asset(
              code!.flagUri!,
              package: 'country_code_picker',
              width: 24,
            ),
            AppSizes.hGapS,
          ],
          Expanded(
            child: Text(
              code?.dialCode ?? '+91',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: context.text.bodyMedium,
            ),
          ),
          const Icon(Icons.arrow_drop_down, size: AppSizes.iconSm),
        ],
      ),
    );
  }
}
