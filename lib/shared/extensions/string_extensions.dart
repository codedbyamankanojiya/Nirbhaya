extension StringExtensions on String {
  String get initials {
    final parts = trim().split(' ');
    if (parts.length >= 2) return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    return isNotEmpty ? this[0].toUpperCase() : '?';
  }

  String get capitalizeFirst {
    if (isEmpty) return this;
    return '${this[0].toUpperCase()}${substring(1)}';
  }

  bool get isValidEmail => RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$').hasMatch(this);
  bool get isValidPhone => RegExp(r'^[\+]?[0-9\s\-\(\)]{7,15}$').hasMatch(this);
}
