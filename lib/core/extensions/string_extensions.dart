extension StringX on String {
  String get capitalize =>
      isEmpty ? this : '${this[0].toUpperCase()}${substring(1)}';

  String get titleCase => split(' ').map((w) => w.capitalize).join(' ');

  bool get isValidEmail =>
      RegExp(r'^[\w.\-+]+@([\w\-]+\.)+[\w\-]{2,}$').hasMatch(trim());

  bool get isValidPhone => RegExp(r'^[+]?[0-9]{7,15}$').hasMatch(replaceAll(' ', ''));

  bool get isValidUrl =>
      RegExp(r'^(https?:\/\/)?([\w\-]+\.)+[\w\-]{2,}(\/\S*)?$').hasMatch(trim());

  String truncate(int max) => length <= max ? this : '${substring(0, max)}…';
}

extension NullableStringX on String? {
  bool get isNullOrEmpty => this == null || this!.trim().isEmpty;
  String orEmpty() => this ?? '';
}
