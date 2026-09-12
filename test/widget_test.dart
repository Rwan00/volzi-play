import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:volzi_play/main.dart';
import 'package:volzi_play/utils/video_link.dart';

void main() {
  testWidgets('Volzi Play splash shows the brand', (tester) async {
    await tester.pumpWidget(const VolziApp());
    expect(find.textContaining('VOLZI PLAY'), findsWidgets);
    await tester.pumpWidget(const SizedBox.shrink());
  });

  test('accepts https video links', () {
    expect(VideoLink.tryParse('https://cdn.example.com/live.m3u8'), isNotNull);
    expect(VideoLink.formatLabel('https://cdn.example.com/film.mp4'), 'MP4');
    expect(VideoLink.validationMessage(''), isNotNull);
  });
}
