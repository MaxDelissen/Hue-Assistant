import 'package:flutter_sound/flutter_sound.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:io';

import 'open_ai_api.dart';

class AudioService {
  final FlutterSoundRecorder _recorder = FlutterSoundRecorder();
  bool isRecording = false;
  String? _filePath;

  /// Request microphone permission
  /// Returns true if permission is granted
  static Future<bool> requestMicPermission() async {
    PermissionStatus status = await Permission.microphone.status;
    if (!status.isGranted) {
      status = await Permission.microphone.request();
    }
    return status.isGranted;
  }

  /// Get the path to the audio file
  /// Returns the application's internal storage path
  Future<String> getAudioFilePath() async {
    final directory =
        await getApplicationDocumentsDirectory(); // App's internal storage
    return '${directory.path}/audio_recording.wav';
  }

  /// Start recording audio, and save it to the internal storage
  Future<void> startRecording() async {
    if (await requestMicPermission()) {
      _filePath = await getAudioFilePath();
      await _recorder.openRecorder();
      await _recorder.startRecorder(toFile: _filePath, codec: Codec.pcm16WAV);
      isRecording = true;
    }
  }

  /// Stop recording audio
  Future<void> stopRecording() async {
    if (isRecording) {
      await _recorder.stopRecorder();
      isRecording = false;
    }
  }

  /// Transcribe the audio from the given path into text.
  /// Returns the transcribed text
  Future<String> audioTranscribe(String audioPath) async {
    final openAiApi = OpenAiApi();
    await openAiApi.initialize();
    return await openAiApi.audioTranscribe(audioPath);
  }

  Future<bool> audioFileExists() async {
    final path = await getAudioFilePath();
    return File(path).existsSync();
  }
}
