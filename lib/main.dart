import 'sections/chat.dart';
import 'sections/chat_stream.dart';
import 'sections/embed_batch_contents.dart';
import 'sections/embed_content.dart';
import 'sections/response_widget_stream.dart';
import 'sections/stream.dart';
import 'sections/text_and_image.dart';
import 'sections/text_only.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gemini/flutter_gemini.dart';
import 'package:google_fonts/google_fonts.dart';

void main() async {
  const apiKey = 'AIzaSyCcyjEWDmn6F5EnYxqyicHEvJFQtmKRhFA';
  Gemini.init(apiKey: apiKey, enableDebugging: true);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Gemini',
      themeMode: ThemeMode.dark,
      debugShowCheckedModeBanner: false,
      darkTheme: ThemeData.dark().copyWith(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        cardTheme: CardTheme(color: const Color.fromARGB(255, 25, 25, 25)),
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        title: const Text(
          'Bienvenue sur Flutter Gemini',
          style: TextStyle(
            color: Colors.white,
            fontSize: 22,
          ),
        ),
        centerTitle: true,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF1A237E), Color(0xFF00ACC1)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              const Color(0xFF121212),
              const Color(0xFF1C1C1C),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.flutter_dash,
                size: 100,
                color: Colors.blueAccent[100],
              ),
              const SizedBox(height: 30),
              Text(
                'Explorez les capacités de Gemini AI !',
                style: GoogleFonts.roboto(
                  textStyle: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 15),
              Text(
                'Découvrez les fonctionnalités d\'IA avancées en quelques clics.',
                style: GoogleFonts.roboto(
                  textStyle: const TextStyle(
                    fontSize: 16,
                    color: Colors.white70,
                  ),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),
              AnimatedButton(
                text: 'Commencer',
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => const MyHomePage()),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class AnimatedButton extends StatefulWidget {
  final String text;
  final VoidCallback onPressed;

  const AnimatedButton({Key? key, required this.text, required this.onPressed})
      : super(key: key);

  @override
  _AnimatedButtonState createState() => _AnimatedButtonState();
}

class _AnimatedButtonState extends State<AnimatedButton> {
  bool _isHovering = false;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: widget.onPressed,
      onHover: (hovering) {
        setState(() {
          _isHovering = hovering;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        width: 200,
        height: 50,
        decoration: BoxDecoration(
          gradient: _isHovering
              ? const LinearGradient(
                  colors: [Color(0xFF00ACC1), Color(0xFF1A237E)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : const LinearGradient(
                  colors: [Color(0xFF1A237E), Color(0xFF00ACC1)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
          borderRadius: BorderRadius.circular(30),
          boxShadow: _isHovering
              ? [
                  BoxShadow(
                    color: Colors.blueAccent.withOpacity(0.6),
                    spreadRadius: 2,
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  )
                ]
              : [],
        ),
        child: Center(
          child: Text(
            widget.text,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
        ),
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _selectedItem = 0;

  final _sections = <SectionItem>[
    SectionItem(
        0, 'Stream Text', Icons.text_fields, const SectionTextStreamInput()),
    SectionItem(
        1, 'Text and Image', Icons.image, const SectionTextAndImageInput()),
    SectionItem(2, 'Catbot', Icons.chat_bubble_outline, const SectionChat()),
    SectionItem(3, 'Stream Chat', Icons.live_tv, const SectionStreamChat()),
    SectionItem(4, 'Text', Icons.text_snippet, const SectionTextInput()),
    SectionItem(
        5, 'Embed Content', Icons.content_copy, const SectionEmbedContent()),
    SectionItem(6, 'Batch Embed', Icons.batch_prediction,
        const SectionBatchEmbedContents()),
    SectionItem(
        7, 'Response Widget', Icons.widgets, const ResponseWidgetSection()),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedItem = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(80.0),
        child: AppBar(
          flexibleSpace: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF1A237E), Color(0xFF00ACC1)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          title: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.star, color: Colors.yellowAccent),
              const SizedBox(width: 10),
              Text(
                _sections[_selectedItem].title,
                style: const TextStyle(
                  fontFamily: 'Roboto',
                  fontWeight: FontWeight.bold,
                  fontSize: 26,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          centerTitle: true,
          elevation: 10,
          shadowColor: Colors.black.withOpacity(0.5),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              const Color(0xFF121212),
              const Color(0xFF1C1C1C),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(15.0),
            child: Container(
              color: Colors.white.withOpacity(0.1),
              child: _sections[_selectedItem].widget,
            ),
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedItem,
        onTap: _onItemTapped,
        backgroundColor: Colors.blueGrey[900],
        selectedItemColor: const Color(0xFF00ACC1),
        unselectedItemColor: Colors.grey[400],
        items: _sections.map((section) {
          return BottomNavigationBarItem(
            icon: Icon(section.icon),
            label: section.title,
          );
        }).toList(),
      ),
    );
  }
}

class SectionItem {
  final int index;
  final String title;
  final IconData icon;
  final Widget widget;

  SectionItem(this.index, this.title, this.icon, this.widget);
}
