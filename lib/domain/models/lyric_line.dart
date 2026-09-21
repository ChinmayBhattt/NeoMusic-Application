/// Single lyric line with timestamp
class LyricLine {
  final Duration time;
  final String text;

  const LyricLine({
    required this.time,
    required this.text,
  });

  Map<String, dynamic> toJson() => {
        'timeMs': time.inMilliseconds,
        'text': text,
      };

  factory LyricLine.fromJson(Map<String, dynamic> json) => LyricLine(
        time: Duration(milliseconds: json['timeMs'] as int? ?? 0),
        text: json['text'] as String? ?? '',
      );
}
