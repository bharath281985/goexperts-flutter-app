import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../app/constants/app_sizes.dart';
import '../extensions/context_extensions.dart';

/// Standard labeled text field used across all forms.
class AppTextField extends StatefulWidget {
  const AppTextField({
    super.key,
    this.controller,
    this.label,
    this.hint,
    this.prefixIcon,
    this.suffixIcon,
    this.obscure = false,
    this.keyboardType,
    this.validator,
    this.onChanged,
    this.maxLines = 1,
    this.maxLength,
    this.inputFormatters,
    this.enabled = true,
    this.textInputAction,
    this.initialValue,
    this.onSubmitted,
    this.readOnly = false,
    this.onTap,
  });

  final TextEditingController? controller;
  final String? label;
  final String? hint;
  final IconData? prefixIcon;
  final Widget? suffixIcon;
  final bool obscure;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final int maxLines;
  final int? maxLength;
  final List<TextInputFormatter>? inputFormatters;
  final bool enabled;
  final TextInputAction? textInputAction;
  final String? initialValue;
  final bool readOnly;
  final VoidCallback? onTap;

  @override
  State<AppTextField> createState() => _AppTextFieldState();
}

class _AppTextFieldState extends State<AppTextField> {
  late bool _obscured = widget.obscure;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.label != null) ...[
          Text(context.tr(widget.label!), style: context.text.titleSmall),
          AppSizes.vGapSm,
        ],
        TextFormField(
          controller: widget.controller,
          initialValue: widget.initialValue,
          obscureText: _obscured,
          keyboardType: widget.keyboardType,
          validator: widget.validator,
          onChanged: widget.onChanged,
          onFieldSubmitted: widget.onSubmitted,
          maxLines: widget.obscure ? 1 : widget.maxLines,
          maxLength: widget.maxLength,
          inputFormatters: widget.inputFormatters,
          enabled: widget.enabled,
          textInputAction: widget.textInputAction,
          readOnly: widget.readOnly,
          onTap: widget.onTap,
          decoration: InputDecoration(
            hintText: widget.hint == null ? null : context.tr(widget.hint!),
            prefixIcon: widget.prefixIcon != null
                ? Icon(widget.prefixIcon, size: AppSizes.iconMd)
                : null,
            suffixIcon: widget.obscure
                ? IconButton(
                    icon: Icon(
                      _obscured
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                      size: AppSizes.iconMd,
                    ),
                    onPressed: () => setState(() => _obscured = !_obscured),
                  )
                : widget.suffixIcon,
          ),
        ),
      ],
    );
  }
}
