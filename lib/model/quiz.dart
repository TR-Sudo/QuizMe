class Quiz {
  String name;
  String topic;
  List<Question> questions;

  Quiz(this.name, this.topic, this.questions);
}

class Question {
  String question;
  int correctOptionIndex;
  List<String> options;

  Question(this.question, this.correctOptionIndex, this.options);
}
