import 'package:dialog_flowtter/dialog_flowtter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bot/Messages.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'YSBot',
      theme: ThemeData(brightness: Brightness.dark),
      home: Home(),
    );
  }
}

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  DialogFlowtter? dialogFlowtter; // nullable so we can check if loaded
  final TextEditingController _controller = TextEditingController();
  List<Map<String, dynamic>> messages = [];

  @override
  void initState() {
    super.initState();
    DialogFlowtter.fromFile().then((instance) {
      setState(() {
        dialogFlowtter = instance;
      });
    }).catchError((e) {
      debugPrint('Failed to load DialogFlowtter: $e');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('YSBot'),
      ),
      body: Column(
        children: [
          Expanded(child: MessagesScreen(messages: messages)),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            color: Colors.deepPurple,
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    style: TextStyle(color: Colors.white),
                  ),
                ),
                IconButton(
                  onPressed: dialogFlowtter == null
                      ? null // disable button until loaded
                      : () {
                          sendMessage(_controller.text);
                          _controller.clear();
                        },
                  icon: Icon(Icons.send),
                )
              ],
            ),
          )
        ],
      ),
    );
  }

  sendMessage(String text) async {
    if (text.isEmpty) return;
    if (dialogFlowtter == null) return;

    setState(() {
      addMessage(Message(text: DialogText(text: [text])), true);
    });

    try {
      DetectIntentResponse response = await dialogFlowtter!.detectIntent(
          queryInput: QueryInput(text: TextInput(text: text)));

      if (response.message == null) {
        // Bot had no response — show a fallback message
        setState(() {
          addMessage(Message(text: DialogText(text: ["Sorry, I didn't understand that."])));
        });
        return;
      }

      setState(() {
        addMessage(response.message!);
      });
    } catch (e) {
      debugPrint('Dialogflow error: $e');
      setState(() {
        addMessage(Message(text: DialogText(text: ["Error connecting to bot. Check your internet."])));
      });
    }
  }

  addMessage(Message message, [bool isUserMessage = false]) {
    messages.add({'message': message, 'isUserMessage': isUserMessage});
  }
}
