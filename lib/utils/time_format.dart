class TimeFormat {
  TimeFormat._();

  static String clock(Duration value) {
    String two(int n) => n.toString().padLeft(2, '0');
    final hours = value.inHours;
    final minutes = value.inMinutes.remainder(60);
    final seconds = value.inSeconds.remainder(60);
    if (hours > 0) return '${two(hours)}:${two(minutes)}:${two(seconds)}';
    return '${two(minutes)}:${two(seconds)}';
  }

  static String compact(Duration value) {
    if (value.inHours >= 1) {
      final minutes = value.inMinutes.remainder(60);
      return '${value.inHours}h ${minutes}m';
    }
    if (value.inMinutes >= 1) return '${value.inMinutes} min';
    return '${value.inSeconds}s';
  }
}
