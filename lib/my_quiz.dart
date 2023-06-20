import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';


import 'answer.dart';
import 'question.dart';
import 'quiz_brain.dart';

QuizBrain quizBrain = QuizBrain();

class MyQuiz extends StatelessWidget {
  // accept the langname as a parameter

  String quizId;

  MyQuiz(this.quizId);

  @override
  Widget build(BuildContext context) {
    // TODO: loading screen for loading json from file!!
    // and now we return the FutureBuilder to load and decode JSON
    return FutureBuilder(
      future:
        DefaultAssetBundle.of(context).loadString('assets/jsons/test'+quizId+'.json', cache: false),
      builder: (context, snapshot) {
        var questions = json.decode(snapshot.data.toString());

        List<Question> questionList = [];

        for (int i = 0; i < questions.length; i++) {
          Question question =
          Question(questions[i]['quest'], questions[i]['quest_zh'], questions[i]['type'], [], questions[i]['id'] );
          for (int x = 0; x < questions[i]['answers'].length; x++) {
            question.list.add(Answer(
                questions[i]['answers'][x]['answer'],
                questions[i]['answers'][x]['answer_zh'],
                questions[i]['answers'][x]['correct']
              )
            );
          }
          question.list.shuffle();
          questionList.add(question);
        }
        print(questionList);

        if (questionList.isEmpty) {
          return Scaffold(
            body: Center(
              child: Text(
                "Loading",
              ),
            ),
          );
        } else {
          return QuizPage(mydata: questionList);
        }
      },
    );
  }

}


class QuizPage extends StatefulWidget {
  final List<Question> mydata;
  const QuizPage({Key? key, required this.mydata}) : super(key: key);

  @override
  _QuizPageState createState() => _QuizPageState(mydata);
}

class _QuizPageState extends State<QuizPage> {
  final List<Question> mydata;
  _QuizPageState(this.mydata);

  List<Icon> scoreKeeper = [];

  int correctScore = 0;

  @override
  void initState() {
    quizBrain.assignQuestion(this.mydata);
    super.initState();
  }

  void previousQuestion(Question question) {
    setState(() {
      quizBrain.previousQuestion();
    });
  }

  void nextQuestion(Question question) {
    setState(() {
      quizBrain.nextQuestion();
    });
  }

  void checkAndNextAnswer(Question question) {
    setState(() {
      // calc the mark:
      bool correct = true;
      for (var answer in question.list) {
        if (answer.correct != answer.selected) {
          correct = false;
        }
      }
      question.isCorrect = correct;
      if (correct) {
        scoreKeeper.add(
          Icon(Icons.check, color: Colors.green),
        );
        correctScore++;
      } else {
        scoreKeeper.add(
          Icon(Icons.close, color: Colors.red),
        );
      }

      Future.delayed(const Duration(milliseconds: 500), () {
        nextQuestion(quizBrain.getQuestion());
      });
    });
  }

  @override
  Widget build(BuildContext context){
    return Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.of(context).pop(),
          ),
          title: Text("Quiz"),
          centerTitle: true,
        ),
        floatingActionButton: Visibility(
          visible: false,
          child: Padding(
              padding: const EdgeInsets.only(bottom: 50.0),
              child: FloatingActionButton(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.black,
                onPressed: () async {
                  var note = await _showTextInputDialog(context);
                  if (note != null){
                    quizBrain.setNote(note);
                  }
                },
                child: Icon(Icons.note),
              )
          )
        ),

        body: Column(
            children: <Widget>[
              //title
              Expanded(
                flex: 3,
                child: Container(
                  padding: EdgeInsets.all(15.0),
                  alignment: Alignment.bottomLeft,
                  child: Text(
                    quizBrain.getQuestionText(),
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 25.0, color: Colors.black),
                  ),
                ),
              ),
              //result
              Expanded(
                flex: 0,
                child: Padding(
                  padding: EdgeInsets.all(10.0),
                  child: Center(
                      child: (quizBrain.getIsCorrect() == null
                          ? Icon(Icons.check, color: Colors.transparent)
                          : (quizBrain.getIsCorrect() == true
                          ? Icon(Icons.check, color: Colors.green)
                          : Icon(Icons.close, color: Colors.red)))),
                ),
              ),
              //choose
              Expanded(
                  flex: 3,
                  child: Container(
                    child: Column(
                      children: quizBrain
                          .getQuestionAnswer()
                          .map((t) => CheckboxListTile(
                        title: Text(t.answerText + "[中文:"+t.answerTextZh+"]'",
                            style: TextStyle(
                                fontSize: 18.0, color: Colors.black)),
                        value: t.selected,
                        onChanged: (value) {
                          setState(() {
                            t.selected = !t.selected;
                          });
                        },
                      ))
                          .toList(),
                    ),
                  )),


            ]
        ),

        bottomNavigationBar: BottomAppBar(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Expanded(
                  child: TextButton(
                      onPressed: () {
                        previousQuestion(quizBrain.getQuestion());
                      },
                      child: Text("previous",
                          style: TextStyle(
                              color: Colors.white, fontSize: 20.0)),
                      style: TextButton.styleFrom(
                          backgroundColor: Colors.blueGrey))),
              Expanded(
                  child: Padding(
                      padding: EdgeInsets.only(left: 5, right: 5),
                      child: TextButton(
                          onPressed: () {
                            checkAndNextAnswer(
                                quizBrain.getQuestion());
                          },
                          child: Text("Check & Next",
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 20.0)),
                          style: TextButton.styleFrom(
                              backgroundColor:
                              Colors.purpleAccent)))
              ),
            ],
          )
        )
    );
  }

  Future<String?> _showTextInputDialog(BuildContext context) async {
    return showDialog(
        context: context,
        builder: (context) {

          return FutureBuilder(
              future: quizBrain.getNote(),
              builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
                if (snapshot.hasData){
                  quizBrain.getNoteTextEditingController().text = snapshot.data.toString();
                }
                return AlertDialog(
                  title: const Text('Note'),
                  content: Container(
                    child: new ConstrainedBox(
                      constraints: BoxConstraints(
                        maxHeight: 300.0,
                      ),
                      child: TextField(
                        controller: quizBrain.getNoteTextEditingController(),
                        maxLines: null,
                      ),
                    ),
                  ),
                  actions: <Widget>[
                    ElevatedButton(
                      child: const Text("Cancel"),
                      onPressed: () => Navigator.pop(context),
                    ),
                    ElevatedButton(
                        child: const Text('OK'),
                        onPressed: () => {
                          Navigator.pop(context, quizBrain.getNoteTextEditingController().text)
                        }

                    ),
                  ],
                );
              },
          );


        });
  }
}


class DecoratedTextField extends StatelessWidget {

  late TextEditingController noteController;

  DecoratedTextField(TextEditingController noteController){
    this.noteController = noteController;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: quizBrain.getNote(),
      builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
        if (snapshot.hasData){
          noteController.text = snapshot.data.toString();
        }
        return Container(
            height: 200,
            alignment: Alignment.center,
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            decoration: BoxDecoration(
                color: Colors.grey[300], borderRadius: BorderRadius.circular(10)),
            child: TextField(
              //scrollController: textFieldScrollController,
              controller: noteController,
              keyboardType: TextInputType.multiline,
              minLines: null,
              maxLines: null,
              onChanged: (value) {
                //noteController.jumpTo(textFieldScrollController.position.maxScrollExtent);
                //quizBrain.setNote(value);
                //noteController.text = value;
              },
            )
        );
      },

    );

  }
}

class SheetButton extends StatefulWidget {
  late TextEditingController noteController;

  SheetButton(TextEditingController noteController){
    this.noteController = noteController;
  }

  _SheetButtonState createState() => _SheetButtonState(noteController);
}
class _SheetButtonState extends State<SheetButton> {

  late TextEditingController noteController;

  _SheetButtonState(TextEditingController noteController){
    this.noteController = noteController;
  }

  bool checkingFlight = false;
  bool success = false;
  @override
  Widget build(BuildContext context) {
    return !checkingFlight
        ? MaterialButton(
      color: Colors.grey[800],
      onPressed: () {
        quizBrain.setNote(noteController.text);
      },
      child: Text(
        'Save',
        style: TextStyle(color: Colors.white),
      ),
    )
        : !success
        ? CircularProgressIndicator()
        : Icon(
      Icons.check,
      color: Colors.green,
    );
  }
}

