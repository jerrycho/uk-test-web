import 'answer.dart';

class Question {

  String questionText;
  String questionTextZh;

  String type;
  List<Answer> list;

  bool? isCorrect;

  String id;

  Question(this.questionText, this.questionTextZh, this.type, this.list, this.id);
}
