import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:uuid/uuid.dart';
import 'dart:developer' as developer;
import '../../domain/entities/chat_message_entity.dart';
import '../../domain/repositories/chat_repository.dart';

part 'chat_event.dart';
part 'chat_state.dart';

class ChatBloc extends Bloc<ChatEvent, ChatState> {
  final ChatRepository repository;
  final String userId; // Inyectado desde el AuthBloc

  ChatBloc({required this.repository, required this.userId}) : super(const ChatState()) {
    on<ChatHistoryLoaded>(_onHistoryLoaded);
    on<ChatMessageSent>(_onMessageSent);
  }

  Future<void> _onMessageSent(ChatMessageSent event, Emitter<ChatState> emit) async {
    final userMsg = ChatMessageEntity(
      id: const Uuid().v4(),
      text: event.text,
      role: MessageRole.user,
      timestamp: DateTime.now(),
    );

    // 1. Mostrar mensaje del usuario inmediatamente
    final updatedMessages = List<ChatMessageEntity>.from(state.messages)..add(userMsg);
    emit(state.copyWith(messages: updatedMessages, isTyping: true));
    await repository.saveMessage(userId, userMsg);

    // 2. Preparar el mensaje "placeholder" de la IA
    final aiMsgId = const Uuid().v4();
    var aiMsg = ChatMessageEntity(
      id: aiMsgId,
      text: "",
      role: MessageRole.ai,
      timestamp: DateTime.now(),
    );

    updatedMessages.add(aiMsg);
    emit(state.copyWith(messages: updatedMessages));

    // 3. Escuchar el stream de la IA
    try {
      final responseStream = repository.getChatResponseStream(state.messages);
      String fullText = "";

      await for (final chunk in responseStream) {
        fullText += chunk;
        // Actualizamos el último mensaje con el nuevo texto acumulado
        final lastIdx = state.messages.length - 1;
        final newMessages = List<ChatMessageEntity>.from(state.messages);
        newMessages[lastIdx] = aiMsg.copyWith(text: fullText);

        emit(state.copyWith(messages: newMessages));
      }

      // Guardar mensaje final de la IA en Firestore
      await repository.saveMessage(userId, state.messages.last);
    } catch (e) {
      print("Error ($e)");

      final lastIdx = state.messages.length - 1;
      final newMessages = List<ChatMessageEntity>.from(state.messages);
      newMessages[lastIdx] = aiMsg.copyWith(text: "⚠️ Error de conexión con la IA. Revisa tu API Key o conexión.");

      emit(state.copyWith(messages: newMessages, isTyping: false));
    } finally {
      emit(state.copyWith(isTyping: false));
    }
  }

  Future<void> _onHistoryLoaded(ChatHistoryLoaded event, Emitter<ChatState> emit) async {
    final history = await repository.getChatHistory(userId);
    emit(state.copyWith(messages: history));
  }
}