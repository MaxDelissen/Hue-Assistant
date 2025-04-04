import 'dart:convert';
import 'dart:io';

import 'package:dart_openai/dart_openai.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:path_provider/path_provider.dart';

/// Class to interact with the OpenAI API
/// Make sure to have the API key in the .env file
/// Keep in mind that using functions from this class will consume the API credits.
class OpenAiApi {
  /// Initialization message for the chat completion when no custom message is provided
  final String defaultInitMessage =
      "You are a helpful assistant. You will help the user to categorize their complaints. "
      "The user will provide you with a complaint, and you will suggest a category for it. "
      "If the complaint is not clear, ask the user for more information.";
  OpenAiApi() {
    initialize();
  }

  /// Initialize the OpenAI API with the API key from the .env file
  /// Throws an exception if the API key is missing or empty
  Future<void> initialize() async {
    await dotenv.load(fileName: ".env");
    final apiKey = dotenv.env['API_KEY'];
    if (apiKey == null || apiKey.isEmpty) {
      throw Exception('API key is missing or empty');
    }
    OpenAI.apiKey = apiKey;
  }

  /// Mainly for development purposes, prints the available models
  Future<void> printModels() async {
    final models = await OpenAI.instance.model.list();
    models.forEach(print);
  }

  /// Transcribe the audio from the given path into text.
  /// Returns the transcribed text
  Future<String> audioTranscribe(String audioPath) async {
    // Check if the audio file exists
    final file = File(audioPath);
    if (!file.existsSync()) {
      throw Exception('Audio file does not exist: $audioPath');
    }

    // Transcribe the audio using the whisper-1 model from OpenAI
    try {
      final transcription = await OpenAI.instance.audio.createTranscription(
        file: file,
        model: "whisper-1",
      );
      return transcription.text;
    } catch (e) {
      throw Exception('Error during transcription: $e');
    }
  }

  /// Retrieve existing categories from the local complaints file
  Future<List<String>> getExistingCategories() async {
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/complaints.json');

    if (!file.existsSync()) return [];

    final complaints = jsonDecode(await file.readAsString()) as List;
    return complaints.map((c) => c['category'] as String).toList();
  }

  Future<String> chatComplete(
    String userMessageText, {
    int maxToken = 200,
    String? useCustomInitMessage,
    String model = "gpt-4o",
    List<String> existingCategories = const [],
  }) async {
    // Create the system and user messages
    final systemMessage = OpenAIChatCompletionChoiceMessageModel(
      role: OpenAIChatMessageRole.system,
      content: [
        OpenAIChatCompletionChoiceMessageContentItemModel.text(
          useCustomInitMessage ?? defaultInitMessage,
        ),
      ],
    );

    final systemExistingCategories = OpenAIChatCompletionChoiceMessageModel(
      role: OpenAIChatMessageRole.system,
      content: [
        OpenAIChatCompletionChoiceMessageContentItemModel.text(
          existingCategories.join("\n"),
        ),
      ],
    );

    final userMessage = OpenAIChatCompletionChoiceMessageModel(
      role: OpenAIChatMessageRole.user,
      content: [
        OpenAIChatCompletionChoiceMessageContentItemModel.text(userMessageText),
      ],
    );

    // Send request for chat completion
    try {
      final response = await OpenAI.instance.chat.create(
        model: model,
        messages: [systemMessage, systemExistingCategories, userMessage],
        maxTokens: maxToken,
        responseFormat: {"type": "json_object"},
      );

      // Get the response content
      final content = response.choices.first.message.content!.first.text;
      return content ?? '';
    } catch (e) {
      throw Exception('Error during chat completion: $e');
    }
  }
}
