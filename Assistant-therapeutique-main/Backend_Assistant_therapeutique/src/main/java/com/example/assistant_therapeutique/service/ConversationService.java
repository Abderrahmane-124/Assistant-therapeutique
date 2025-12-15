package com.example.assistant_therapeutique.service;

import com.example.assistant_therapeutique.model.Conversation;
import com.example.assistant_therapeutique.model.User;
import com.example.assistant_therapeutique.repository.ConversationRepository;
import com.example.assistant_therapeutique.repository.UserRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;

@Service
public class ConversationService {

    @Autowired
    private ConversationRepository conversationRepository;

    @Autowired
    private UserRepository userRepository;

    public List<Conversation> getConversationsByUserId(Long userId) {
        return conversationRepository.findByUserId(userId);
    }

    public Optional<Conversation> getConversationById(Long id) {
        return conversationRepository.findById(id);
    }

    public Conversation createConversation(Long userId, String titre) {
        Optional<User> userOptional = userRepository.findById(userId);
        if (userOptional.isEmpty()) {
            throw new RuntimeException("User not found with ID: " + userId);
        }
        User user = userOptional.get();

        Conversation conversation = new Conversation();
        conversation.setTitre(titre);
        conversation.setUser(user);
        conversation.setCreatedAt(LocalDateTime.now());

        return conversationRepository.save(conversation);
    }
    
    public Conversation saveConversation(Conversation conversation) {
        return conversationRepository.save(conversation);
    }

    public void deleteConversation(Long id) {
        conversationRepository.deleteById(id);
    }
    
    public Conversation updateTitle(Long id, String newTitle) {
        Conversation conversation = conversationRepository.findById(id)
            .orElseThrow(() -> new RuntimeException("Conversation not found with ID: " + id));
        conversation.setTitre(newTitle);
        return conversationRepository.save(conversation);
    }
}