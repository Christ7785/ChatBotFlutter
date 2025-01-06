import 'widgets/chat_input_box.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gemini/flutter_gemini.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

class SectionChat extends StatefulWidget {
  const SectionChat({super.key});

  @override
  State<SectionChat> createState() => _SectionChatState();
}

class _SectionChatState extends State<SectionChat> {
  final controller = TextEditingController();
  final gemini = Gemini.instance;
  bool _loading = false;
  bool isHistoryVisible = false;

  bool get loading => _loading;

  set loading(bool set) => setState(() => _loading = set);
  final List<Content> chats = [];

  final List<String> predefinedQuestions = [
    "Qu'est-ce que l'intelligence artificielle ?",
    "Comment l'IA peut-elle améliorer la vie quotidienne ?",
    "Quels sont les principaux types d'IA ?",
    "Peux-tu expliquer ce qu'est le deep learning ?",
    "Comment l'IA est-elle utilisée dans la médecine ?",
  ];

  late List<bool> questionVisibility;

  @override
  void initState() {
    super.initState();
    questionVisibility = List<bool>.filled(predefinedQuestions.length, true);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          color: Theme.of(context).colorScheme.primary,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Chat',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onPrimary,
                  fontWeight: FontWeight.bold,
                  fontSize: 24,
                ),
              ),
              Row(
                children: [
                  IconButton(
                    icon: Icon(Icons.chat_bubble_outline,
                        color: isHistoryVisible
                            ? Theme.of(context).colorScheme.onPrimary
                            : Colors.yellowAccent),
                    onPressed: () {
                      setState(() {
                        isHistoryVisible = false;
                      });
                    },
                  ),
                  TextButton(
                    onPressed: () {
                      setState(() {
                        isHistoryVisible = true;
                      });
                    },
                    child: Row(
                      children: [
                        Icon(Icons.history,
                            color: isHistoryVisible
                                ? Colors.yellowAccent
                                : Theme.of(context).colorScheme.onPrimary),
                        const SizedBox(width: 5),
                        Text(
                          'Historique',
                          style: TextStyle(
                            color: isHistoryVisible
                                ? Colors.yellowAccent
                                : Theme.of(context).colorScheme.onPrimary,
                            fontSize: 18,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        Expanded(
          child: isHistoryVisible ? _buildHistory() : _buildChat(),
        ),
        if (loading) const CircularProgressIndicator(),
        if (!isHistoryVisible)
          ChatInputBox(
            controller: controller,
            onSend: () {
              if (controller.text.isNotEmpty) {
                _sendMessage(controller.text);
                controller.clear();
              }
            },
          ),
      ],
    );
  }

  // Build Chat Widget
  Widget _buildChat() {
    return chats.isNotEmpty
        ? Align(
            alignment: Alignment.bottomCenter,
            child: ListView.builder(
              itemBuilder: chatItem,
              shrinkWrap: true,
              physics: const ClampingScrollPhysics(),
              itemCount: chats.length,
            ),
          )
        : Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Wrap(
                  spacing: 8.0,
                  children: predefinedQuestions.map((question) {
                    return Container(
                      margin: const EdgeInsets.symmetric(vertical: 5),
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blueAccent,
                          foregroundColor: Colors.white,
                          elevation: 5,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: () {
                          _sendMessage(question);
                          _hideAllQuestions();
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16.0, vertical: 10.0),
                          child: Text(
                            question,
                            style: const TextStyle(fontSize: 16),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          );
  }

  // Build History Widget
  Widget _buildHistory() {
    if (chats.isEmpty) {
      return Center(child: Text("Aucun historique disponible."));
    }

    return ListView.builder(
      itemCount: chats.length,
      itemBuilder: (context, index) {
        final Content content = chats[index];
        final isUser = content.role == 'user';

        final color = isUser
            ? Color.fromARGB(255, 240, 240, 240)
            : Color.fromARGB(255, 34, 150, 243);
        final textColor = isUser ? Colors.black : Colors.white;

        return Align(
          alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.7),
            child: Card(
              elevation: 3,
              color: color,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      content.role ?? 'role',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: textColor,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Markdown(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      data: content.parts?.lastOrNull?.text ??
                          'Aucun contenu de message.',
                      styleSheet: MarkdownStyleSheet(
                        p: TextStyle(
                          color: textColor,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  void _hideAllQuestions() {
    setState(() {
      questionVisibility = List<bool>.filled(predefinedQuestions.length, false);
    });
  }

  void _sendMessage(String message) {
    chats.add(Content(role: 'user', parts: [Parts(text: message)]));
    loading = true;

    // Call to the API
    gemini.chat(chats).then((value) {
      if (value != null && value.output != null) {
        chats.add(Content(role: 'model', parts: [Parts(text: value.output)]));
      } else {
        chats.add(Content(role: 'model', parts: [
          Parts(text: 'Error: Unable to generate a valid response.')
        ]));
      }
      loading = false;
      setState(() {});
    }).catchError((error) {
      chats.add(Content(role: 'model', parts: [Parts(text: 'Error: $error')]));
      loading = false;
      setState(() {});
    });
  }

  Widget chatItem(BuildContext context, int index) {
    final Content content = chats[index];
    final isUser = content.role == 'user';

    final color = isUser
        ? Color.fromARGB(255, 240, 240, 240)
        : Color.fromARGB(255, 34, 150, 243);
    final textColor = isUser ? Colors.black : Colors.white;

    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints:
            BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.7),
        child: Card(
          elevation: 3,
          color: color,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  content.role ?? 'role',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
                const SizedBox(height: 5),
                Markdown(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  data: content.parts?.lastOrNull?.text ??
                      'cannot generate data!',
                  styleSheet: MarkdownStyleSheet(
                    p: TextStyle(
                      color: textColor,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
