import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'dart:io';
import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';
import 'package:google_fonts/google_fonts.dart';

void main() => runApp(const ProSoundTextApp());

class ProSoundTextApp extends StatelessWidget {
  const ProSoundTextApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        primaryColor: const Color(0xFF002366),
        scaffoldBackgroundColor: const Color(0xFFF8FAFC),
        textTheme: GoogleFonts.notoKufiArabicTextTheme(),
      ),
      home: const LoginScreen(),
    );
  }
}

// --- شاشة الدخول (Login) ---
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _passController = TextEditingController();

  void _checkLogin() {
    if (_passController.text == "1998") {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const MainAppScreen()));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("كلمة المرور خاطئة!")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Container(
          width: 350,
          padding: const EdgeInsets.all(30),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20)],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.keyboard_voice_rounded, size: 60, color: Color(0xFF002366)),
              const SizedBox(height: 10),
              Text("Sound Text", style: GoogleFonts.poppins(fontSize: 24, fontWeight: FontWeight.bold, color: const Color(0xFF002366))),
              const SizedBox(height: 30),
              TextField(
                controller: _passController,
                obscureText: true,
                textAlign: TextAlign.center,
                decoration: InputDecoration(
                  hintText: "Password",
                  filled: true,
                  fillColor: Colors.grey[50],
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _checkLogin,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF002366),
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                ),
                child: const Text("دخول", style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// --- الشاشة الرئيسية (Main) ---
class MainAppScreen extends StatefulWidget {
  const MainAppScreen({super.key});

  @override
  State<MainAppScreen> createState() => _MainAppScreenState();
}

class _MainAppScreenState extends State<MainAppScreen> {
  final SpeechToText _speech = SpeechToText();
  final TextEditingController _textController = TextEditingController();
  bool _isListening = false;

  void _toggleListening() async {
    if (!_isListening) {
      bool available = await _speech.initialize();
      if (available) {
        setState(() => _isListening = true);
        _speech.listen(
          onResult: (result) => setState(() => _textController.text = result.recognizedWords),
          localeId: "ar_SA",
        );
      }
    } else {
      setState(() => _isListening = false);
      _speech.stop();
    }
  }

  // دالة التصدير المبسطة لتعمل على ويندوز مباشرة
  Future<void> _exportAsTextFile() async {
    if (_textController.text.isEmpty) return;

    // ملاحظة: لإنشاء DOCX حقيقي، المكتبة تحتاج ملف قالب. 
    // للتبسيط ولضمان العمل 100%، سنقوم بتصديره كملف نصي يمكن فتحه بالـ Word بكل سهولة.
    String? path = await FilePicker.platform.saveFile(
      dialogTitle: 'حفظ الملف',
      fileName: 'my_speech.doc', // نحفظه بصيغة .doc لفتحه مباشرة بالورد
    );

    if (path != null) {
      final file = File(path);
      await file.writeAsString(_textController.text);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("تم التصدير بنجاح!")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Sound Text Pro", style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
        centerTitle: true,
        actions: [
          IconButton(onPressed: _exportAsTextFile, icon: const Icon(Icons.save_alt_rounded)),
          const SizedBox(width: 15),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
        child: Column(
          children: [
            // منطقة الورقة
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10)],
                ),
                child: TextField(
                  controller: _textController,
                  maxLines: null,
                  textAlign: TextAlign.right,
                  style: const TextStyle(fontSize: 18, height: 1.8),
                  decoration: const InputDecoration(
                    hintText: "سأكتب ما تقوله هنا...",
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.all(30),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 30),
            
            // منطقة التحكم
            if (_isListening) const SpinKitThreeBounce(color: Color(0xFF002366), size: 30),
            const SizedBox(height: 20),
            
            GestureDetector(
              onTap: _toggleListening,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                decoration: BoxDecoration(
                  color: _isListening ? Colors.redAccent : const Color(0xFF002366),
                  borderRadius: BorderRadius.circular(40),
                  boxShadow: [BoxShadow(color: (_isListening ? Colors.redAccent : const Color(0xFF002366)).withOpacity(0.3), blurRadius: 15)],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(_isListening ? Icons.stop_rounded : Icons.mic_rounded, color: Colors.white),
                    const SizedBox(width: 15),
                    Text(
                      _isListening ? "إيقاف التسجيل" : "Start Talk",
                      style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}