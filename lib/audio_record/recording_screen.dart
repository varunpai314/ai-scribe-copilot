// File: lib/screens/recording_screen.dart
import 'package:flutter/material.dart';

class RecordingScreen extends StatelessWidget {
  const RecordingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Audio Recorder"), centerTitle: true),
      body: SafeArea(child: Center(child: Container())),
    );
  }
}
