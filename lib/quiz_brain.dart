import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'question.dart';
import 'answer.dart';

class QuizBrain {

  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

  List<TextEditingController> listNoteTextEditingController = [];

  int _questionNumber = 0;

  List<Question> _questions = [];

  assignQuestion(List<Question> list)  {
//    final SharedPreferences prefs = await _prefs;
    _questions = list;
    for (var element in list) {
      //var note = prefs.getString('id_'+ element.id) ?? '';
      var note = '';
      listNoteTextEditingController.add(TextEditingController(text: note));
      //print(">>>>>inserted:" + 'id_'+ element.id +" is "+ note );
    }
    reset();
  }

  int getTotalQuestions() {
    return _questions.length ;
  }


  void nextQuestion() {
    if (_questionNumber < _questions.length - 1) {
      _questionNumber++;
    }
  }

  void previousQuestion() {
    if (_questionNumber > 0) {
      _questionNumber--;
    }
  }

  TextEditingController getNoteTextEditingController() {
    return listNoteTextEditingController[_questionNumber];
  }

  String getQuestionText() {
    print(">>>>>getQuestionText");
    return
        (_questionNumber + 1).toString() +
        " / "+
        getTotalQuestions().toString() +
        " [" +
        _questions[_questionNumber].type +
        "] "+
        _questions[_questionNumber].questionText.toString() + " { " + _questions[_questionNumber].questionTextZh.toString() + "}";
  }

  Future<String> getNote() async {
    final SharedPreferences prefs = await _prefs;
    return prefs.getString('id_'+ _questions[_questionNumber].id) ?? '';
  }

  setNote(String note) async {
    final SharedPreferences prefs = await _prefs;
    prefs.setString('id_'+ _questions[_questionNumber].id, note);
    print(">>>>>>save:" + note);
  }

  bool? getIsCorrect() {
    return  _questions[_questionNumber].isCorrect;
  }

  Question getQuestion(){
    return _questions[_questionNumber];
  }

  List<Answer> getQuestionAnswer() {
    //return _questions[_questionNumber].list.where((element) => element.correct ).toList();
    return _questions[_questionNumber].list;
  }

  bool isFinished() {
    if (_questionNumber == _questions.length - 1) {
      return true;
    } else {
      return false;
    }
  }

  void printFinish() {
    if (isFinished()) {
      print('the quiz is finished');
    }
  }

  void reset() {
    _questionNumber = 0;
  }
}
