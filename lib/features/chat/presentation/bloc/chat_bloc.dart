import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';
import '../../domain/entities/chat_message_entity.dart';
import '../../domain/repositories/chat_repository.dart';
import 'chat_event.dart';
import 'chat_state.dart';

class ChatBloc extends Bloc<ChatEvent, ChatState> {
  final ChatRepository repository;
  final String userId;

  ChatBloc({required this.repository, required this.userId}) : super(const ChatState()) {
    on<ChatHistoryLoaded>(_onHistoryLoaded);
    on<ChatMessageSent>(_onMessageSent);
  }

  Future<void> _onHistoryLoaded(ChatHistoryLoaded event, Emitter<ChatState> emit) async {
    try {
      final history = await repository.getChatHistory(userId);
      emit(state.copyWith(messages: history));
    } catch (e) {
      emit(state.copyWith(error: "Error al cargar historial"));
    }
  }

  Future<void> _onMessageSent(ChatMessageSent event, Emitter<ChatState> emit) async {
    if (event.text.isEmpty) return;

    // 1. Crear y mostrar mensaje del usuario
    final userMsg = ChatMessageEntity(
      id: const Uuid().v4(),
      text: event.text,
      role: MessageRole.user,
      timestamp: DateTime.now(),
    );

    final updatedWithUser = List<ChatMessageEntity>.from(state.messages)..add(userMsg);
    emit(state.copyWith(messages: updatedWithUser, isTyping: true));
    await repository.saveMessage(userId, userMsg);

    // 2. Crear placeholder para la IA
    final aiMsgId = const Uuid().v4();
    var aiMsg = ChatMessageEntity(
      id: aiMsgId,
      text: "",
      role: MessageRole.ai,
      timestamp: DateTime.now(),
    );

    final updatedWithAI = List<ChatMessageEntity>.from(state.messages)..add(aiMsg);
    emit(state.copyWith(messages: updatedWithAI));

    // 3. Procesar Stream
    try {
      final stream = repository.getChatResponseStream(state.messages);
      String fullResponse = "";

      await for (final chunk in stream) {
        fullResponse += chunk;
        final lastIdx = state.messages.length - 1;
        final newMessages = List<ChatMessageEntity>.from(state.messages);
        newMessages[lastIdx] = aiMsg.copyWith(text: fullResponse);
        emit(state.copyWith(messages: newMessages));
      }

      // 4. Guardar respuesta final en Firestore
      await repository.saveMessage(userId, state.messages.last);
    } catch (e) {
      emit(state.copyWith(error: "Error de conexión con la IA", isTyping: false));
    } finally {
      emit(state.copyWith(isTyping: false));
    }
  }
}