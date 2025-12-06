package com.example.assistant_therapeutique.controller;

import com.example.assistant_therapeutique.dto.ConversationRequestDTO;
import com.example.assistant_therapeutique.model.Conversation;
import com.example.assistant_therapeutique.model.ChatMessage;
import com.example.assistant_therapeutique.service.ConversationService;
import com.example.assistant_therapeutique.service.ChatMessageService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;
import java.util.Optional;

@RestController
@RequestMapping("/api/conversations")
public class ConversationController {

    @Autowired
    private ConversationService conversationService;
    
    @Autowired
    private ChatMessageService chatMessageService;

    @PostMapping
    public ResponseEntity<Conversation> createConversation(@RequestBody ConversationRequestDTO conversationRequestDTO) {
        Conversation savedConversation = conversationService.createConversation(
                conversationRequestDTO.getUserId(),
                conversationRequestDTO.getTitre()
        );
        return new ResponseEntity<>(savedConversation, HttpStatus.CREATED);
    }

    @GetMapping("/user/{userId}")
    public List<Conversation> getConversationsByUserId(@PathVariable Long userId) {
        return conversationService.getConversationsByUserId(userId);
    }

    @GetMapping("/{id}")
    public ResponseEntity<Conversation> getConversationById(@PathVariable Long id) {
        Optional<Conversation> conversation = conversationService.getConversationById(id);
        return conversation.map(ResponseEntity::ok)
                .orElseGet(() -> ResponseEntity.notFound().build());
    }
    
    @PostMapping("/send")
    public ResponseEntity<?> sendMessage(@RequestBody Map<String, Object> request) {
        try {
            Long userId = ((Number) request.get("userId")).longValue();
            Long conversationId = request.get("conversationId") != null 
                ? ((Number) request.get("conversationId")).longValue() 
                : null;
            String message = (String) request.get("message");
            String conversationTitle = (String) request.get("conversationTitle");
            
            // If no conversationId, create new conversation
            Conversation conversation;
            if (conversationId == null) {
                String title = conversationTitle != null ? conversationTitle : "Nouvelle conversation";
                conversation = conversationService.createConversation(userId, title);
                conversationId = conversation.getId();
            } else {
                conversation = conversationService.getConversationById(conversationId)
                    .orElseThrow(() -> new RuntimeException("Conversation not found"));
            }
            
            // Save user message
            ChatMessage userMessage = chatMessageService.saveMessage(
                userId,
                conversationId,
                message
            );
            
            // TODO: Generate AI response here
            // For now, send a mock response
            String aiResponseText = "Merci pour votre message. Je suis là pour vous aider.";
            ChatMessage aiMessage = chatMessageService.saveMessage(
                1L, // AI user ID
                conversationId,
                aiResponseText
            );
            
            // Reload conversation with updated messages
            conversation = conversationService.getConversationById(conversationId)
                .orElseThrow(() -> new RuntimeException("Conversation not found"));
            
            return ResponseEntity.ok(conversation);
            
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                .body(Map.of("error", e.getMessage()));
        }
    }
    
    @DeleteMapping("/{id}")
    public ResponseEntity<?> deleteConversation(@PathVariable Long id) {
        try {
            conversationService.deleteConversation(id);
            return ResponseEntity.ok(Map.of("message", "Conversation supprimée"));
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                .body(Map.of("error", e.getMessage()));
        }
    }
    
    @PutMapping("/{id}/title")
    public ResponseEntity<?> updateConversationTitle(
            @PathVariable Long id, 
            @RequestBody Map<String, String> request) {
        try {
            String newTitle = request.get("title");
            Conversation updatedConversation = conversationService.updateTitle(id, newTitle);
            return ResponseEntity.ok(updatedConversation);
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                .body(Map.of("error", e.getMessage()));
        }
    }
}