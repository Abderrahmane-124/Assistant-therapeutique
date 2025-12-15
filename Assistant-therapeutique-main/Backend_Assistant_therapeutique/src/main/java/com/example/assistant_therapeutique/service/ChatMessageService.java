package com.example.assistant_therapeutique.service;

import com.example.assistant_therapeutique.model.ChatMessage;
import com.example.assistant_therapeutique.model.Conversation;
import com.example.assistant_therapeutique.model.User;
import com.example.assistant_therapeutique.repository.ChatMessageRepository;
import com.example.assistant_therapeutique.repository.ConversationRepository;
import com.example.assistant_therapeutique.repository.UserRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;

@Service
public class ChatMessageService {

    @Autowired
    private ChatMessageRepository chatMessageRepository;

    @Autowired
    private UserRepository userRepository;

    @Autowired
    private ConversationRepository conversationRepository;

    public ChatMessage saveMessage(Long senderId, Long conversationId, String content) {
        Optional<User> senderOptional = userRepository.findById(senderId);
        if (senderOptional.isEmpty()) {
            throw new RuntimeException("Sender user not found with ID: " + senderId);
        }
        User sender = senderOptional.get();

        Optional<Conversation> conversationOptional = conversationRepository.findById(conversationId);
        if (conversationOptional.isEmpty()) {
            throw new RuntimeException("Conversation not found with ID: " + conversationId);
        }
        Conversation conversation = conversationOptional.get();

        ChatMessage message = new ChatMessage();
        message.setSender(sender);
        message.setConversation(conversation);
        message.setContent(content);
        message.setCreatedAt(LocalDateTime.now());

        return chatMessageRepository.save(message);
    }

    public List<ChatMessage> getMessagesByConversationId(Long conversationId) {
        return chatMessageRepository.findByConversationId(conversationId);
    }
}
