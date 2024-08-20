import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:intl/intl.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
        designSize: const Size(390, 844),
        minTextAdapt: true,
        splitScreenMode: true,
        builder: (context, snapshot) {
          return MaterialApp(
            title: 'Flutter Demo',
            debugShowCheckedModeBanner: false,
            theme: ThemeData(
              colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
              useMaterial3: true,
            ),
            home: const ChatScreen(),
          );
        });
  }
}

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _userInput = TextEditingController();
  static const apiKey = "YOUR API KEY";
  late final GenerativeModel model;
  final List<Message> _messages = [];
  String _lastWords = '';
  final SpeechToText _speechToText = SpeechToText();
  bool _speechEnabled = false;

  @override
  void initState() {
    super.initState();
    _initSpeech();

    _initializeModel();
  }

  void _initSpeech() async {
    _speechEnabled = await _speechToText.initialize();
    setState(() {});
  }

  void _startListening() async {
    await _speechToText.listen(onResult: _onSpeechResult);
    setState(() {});
  }

  void _onSpeechResult(SpeechRecognitionResult result) {
    setState(() {
      _lastWords = result.recognizedWords;
    });
  }

  void _stopListening() async {
    await _speechToText.stop();
    setState(() {});
  }

  void _initializeModel() {
    model = GenerativeModel(
      model: 'gemini-1.5-pro-latest',
      apiKey: apiKey,
      generationConfig: GenerationConfig(
        temperature: 0.9,
        topK: 1,
        topP: 1,
        maxOutputTokens: 2048,
        stopSequences: [],
      ),
    );
  }

  void sendVoiceMessage() async {
    if (_lastWords.isEmpty) {
      return;
    }

    final messageToSend = _lastWords;

    setState(() {
      _messages.add(
          Message(isUser: true, message: messageToSend, date: DateTime.now()));
    });

    try {
      final prompt = [
        Content.text(
            "You are a therapist chat bot designed to help depression patients cope with their symptoms. Comfort them and make them feel heard. Remind them, you are not a licensed therapist so make sure to recommend them to further medical resources if needed."),
        Content.text(messageToSend)
      ];
      final response = await model.generateContent(prompt);

      setState(() {
        _messages.add(Message(
          isUser: false,
          message: response.text ?? "Sorry, I couldn't generate a response.",
          date: DateTime.now(),
        ));
      });
      _lastWords = '';
    } catch (e) {
      setState(() {
        _messages.add(Message(
          isUser: false,
          message: "An error occurred while processing your request.",
          date: DateTime.now(),
        ));
      });
      _lastWords = '';
    }
  }

  Future<void> sendMessage() async {
    final message = _userInput.text;
    if (message.isEmpty) return;

    setState(() {
      _messages
          .add(Message(isUser: true, message: message, date: DateTime.now()));
      _userInput.clear();
    });

    try {
      final prompt = [
        Content.text(
            "You are a therapist chat bot designed to help depression patients cope with their symptoms. Comfort them and make them feel heard. Remind them, you are not a licensed therapist so make sure to recommend them to further medical resources if needed."),
        Content.text(message)
      ];
      final response = await model.generateContent(
        prompt,
      );

      setState(() {
        _messages.add(Message(
          isUser: false,
          message: response.text ?? "Sorry, I couldn't generate a response.",
          date: DateTime.now(),
        ));
      });
    } catch (e) {
      setState(() {
        _messages.add(Message(
          isUser: false,
          message: "An error occurred while processing your request.",
          date: DateTime.now(),
        ));
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
            color: Colors.red,
            gradient: LinearGradient(
              begin: Alignment.bottomLeft,
              end: Alignment.topRight,
              colors: [
                Color.fromARGB(255, 51, 13, 93),
                Color.fromARGB(255, 70, 36, 107),
                Color.fromARGB(255, 70, 28, 114),
                Color.fromARGB(255, 111, 33, 27),
              ],
            )),
        child: Column(
          children: [
            Expanded(
              child: _messages.isEmpty
                  ? SingleChildScrollView(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          140.verticalSpace,
                          const Text(
                            "Welcome to Therapy Bot",
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 30,
                                fontWeight: FontWeight.bold),
                          ),
                          40.verticalSpace,
                          Text(
                            "Frequently Asked Questions",
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 24.sp,
                                fontWeight: FontWeight.bold),
                          ),
                          20.verticalSpace,
                          ExpansionTile(
                            shape: const RoundedRectangleBorder(),
                            iconColor: Colors.white,
                            collapsedIconColor: Colors.white,
                            title: Text(
                              "Can this replace the need of a therapist?",
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18.sp,
                                  fontWeight: FontWeight.w600),
                            ),
                            children: [
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 12),
                                child: Text(
                                  "No, while our AI Therapist can be a helpful tool, it cannot replace a lincensed mental health professional",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 18.sp,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          ExpansionTile(
                            shape: const RoundedRectangleBorder(),
                            iconColor: Colors.white,
                            collapsedIconColor: Colors.white,
                            title: Text(
                              "Is my data safe and confidential?",
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18.sp,
                                  fontWeight: FontWeight.w600),
                            ),
                            children: [
                              Padding(
                                padding: EdgeInsets.symmetric(horizontal: 12.h),
                                child: Text(
                                  "No, while our AI Therapist does not track any responses. It relies on Google Gemini's API, which does track responses. Be weary of any personal or confidential information you share.",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 18.sp,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          ExpansionTile(
                            shape: const RoundedRectangleBorder(),
                            iconColor: Colors.white,
                            collapsedIconColor: Colors.white,
                            title: Text(
                              "What are the limitations of the AI Therapist?",
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18.sp,
                                  fontWeight: FontWeight.w600),
                            ),
                            children: [
                              Padding(
                                padding: EdgeInsets.symmetric(horizontal: 12.h),
                                child: Text(
                                  "The AI Therapist cannot diagnosis conditions or replace actual therapists. If you have a concern with your mental health reach out to a trained medical professional.",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 18.sp,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      itemCount: _messages.length,
                      itemBuilder: (context, index) {
                        final message = _messages[index];
                        return Messages(
                          isUser: message.isUser,
                          message: message.message,
                          date: DateFormat('HH:mm').format(message.date),
                        );
                      },
                    ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  Expanded(
                    flex: 15,
                    child: TextFormField(
                      style: const TextStyle(color: Colors.white),
                      controller: _userInput,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        labelText: 'Enter Your Message',
                        labelStyle: const TextStyle(color: Colors.white70),
                      ),
                    ),
                  ),
                  10.horizontalSpace,
                  IconButton(
                    padding: EdgeInsets.all(12.h),
                    iconSize: 30,
                    style: ButtonStyle(
                      backgroundColor: WidgetStateProperty.all(Colors.black),
                      foregroundColor: WidgetStateProperty.all(Colors.white),
                      shape: WidgetStateProperty.all(const CircleBorder()),
                    ),
                    onPressed: sendMessage,
                    icon: const Icon(Icons.send),
                  ),
                  8.horizontalSpace,
                  GestureDetector(
                      onLongPress: _startListening,
                      onLongPressUp: () {
                        _stopListening();
                        sendVoiceMessage();
                      },
                      child: Container(
                          height: 50.h,
                          width: 50.h,
                          decoration: const BoxDecoration(
                              color: Colors.green, shape: BoxShape.circle),
                          child: Icon(
                            Icons.mic,
                            size: 30.h,
                            color: Colors.white,
                          ))),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class Message {
  final bool isUser;
  final String message;
  final DateTime date;

  Message({required this.isUser, required this.message, required this.date});
}

class Messages extends StatelessWidget {
  final bool isUser;
  final String message;
  final String date;

  const Messages({
    super.key,
    required this.isUser,
    required this.message,
    required this.date,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(15.h),
      margin: EdgeInsets.symmetric(vertical: 15.h)
          .copyWith(left: isUser ? 100.h : 10.h, right: isUser ? 10.h : 100),
      decoration: BoxDecoration(
        color: isUser ? Colors.blueAccent : Colors.grey.shade400,
        borderRadius: BorderRadius.only(
          topLeft: const Radius.circular(10),
          bottomLeft: isUser ? const Radius.circular(10) : Radius.zero,
          topRight: const Radius.circular(10),
          bottomRight: isUser ? Radius.zero : const Radius.circular(10),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (isUser)
            Text(
              message,
              style: TextStyle(fontSize: 16.sp, color: Colors.white),
            )
          else
            AnimatedTextKit(
              repeatForever: false,
              isRepeatingAnimation: false,
              animatedTexts: [
                TypewriterAnimatedText(message,
                    textStyle: TextStyle(fontSize: 16.sp, color: Colors.black),
                    speed: const Duration(milliseconds: 50),
                    cursor: '_'),
              ],
              totalRepeatCount: 1,
              displayFullTextOnTap: true,
              stopPauseOnTap: true,
            ),
          const SizedBox(height: 5),
          Text(
            date,
            style: TextStyle(
              fontSize: 10.sp,
              color: isUser ? Colors.white70 : Colors.black54,
            ),
          ),
        ],
      ),
    );
  }
}
