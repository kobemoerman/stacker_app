class FlashCard {
  int key;
  int isSwipped;
  String theme;
  final String question;
  final String answer;

  FlashCard({this.key, this.isSwipped, this.theme, this.question, this.answer})
      : assert(question != null),
        assert(answer != null);

  Map<String, dynamic> toMap() => {
        'key': this.key,
        'isSwipped': this.isSwipped,
        'theme': this.theme,
        'question': this.question,
        'answer': this.answer
      };

  factory FlashCard.fromMap(Map<String, dynamic> map) => FlashCard(
        key: map['key'],
        isSwipped: map['isSwipped'],
        theme: map['theme'],
        question: map['question'],
        answer: map['answer'],
      );

  set setKey(int k) => this.key = k;
  set setSwipped(int s) => this.isSwipped = s;
  set setTable(String string) => this.theme = string;
}
