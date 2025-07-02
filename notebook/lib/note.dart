class Note {
  String title;
  String tag;
  String content;
  DateTime date;

  Note({
    required this.title,
    required this.tag,
    required this.content,
    required this.date,
  });

  Map<String, dynamic> toJson() => {
    'title': title,
    'tag': tag,
    'content': content,
    'date': date.toIso8601String(),
  };

  static Note fromJson(Map<String, dynamic> json) => Note(
    title: json['title'],
    tag: json['tag'],
    content: json['content'],
    date: DateTime.parse(json['date']),
  );
}