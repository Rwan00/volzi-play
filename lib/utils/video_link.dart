class VideoLink {
  VideoLink._();

  static String normalize(String raw) => raw.trim();

  static Uri? tryParse(String raw) {
    final value = normalize(raw);
    if (value.isEmpty) return null;
    final uri = Uri.tryParse(value);
    if (uri == null || !uri.hasScheme || uri.host.isEmpty) return null;
    if (uri.scheme != 'http' && uri.scheme != 'https') return null;
    return uri;
  }

  static String? validationMessage(String raw) {
    final value = normalize(raw);
    if (value.isEmpty) return 'Enter a video link first.';
    if (tryParse(value) == null) {
      return 'That link is not valid. Use an address that starts with http or https.';
    }
    return null;
  }

  static String formatLabel(String raw) {
    final uri = tryParse(raw);
    final path = (uri?.path ?? raw).toLowerCase();
    if (path.contains('.m3u8') || path.endsWith('.m3u')) return 'HLS / M3U8';
    if (path.endsWith('.mp4')) return 'MP4';
    if (path.endsWith('.mov')) return 'MOV';
    if (path.endsWith('.m4v')) return 'M4V';
    if (path.endsWith('.mp3')) return 'MP3';
    if (path.endsWith('.m4a') || path.endsWith('.aac')) return 'Audio';
    return 'Network video';
  }
}
