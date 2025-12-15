package com.example.assistant_therapeutique.controller;

import com.example.assistant_therapeutique.dto.ChatMessageRequestDTO;
import com.example.assistant_therapeutique.model.ChatMessage;
import com.example.assistant_therapeutique.service.ChatMessageService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/chat")
public class ChatMessageController {

    @Autowired
    private ChatMessageService chatMessageService;

    @PostMapping("/send")
    public ResponseEntity<ChatMessage> sendMessage(@RequestBody ChatMessageRequestDTO chatMessageRequestDTO) {
        ChatMessage savedMessage = chatMessageService.saveMessage(
                chatMessageRequestDTO.getSenderId(),
                chatMessageRequestDTO.getConversationId(),
                chatMessageRequestDTO.getContent()
        );
        return new ResponseEntity<>(savedMessage, HttpStatus.CREATED);
    }

    @GetMapping("/conversations/{conversationId}/messages")
    public List<ChatMessage> getMessagesByConversationId(@PathVariable Long conversationId) {
        return chatMessageService.getMessagesByConversationId(conversationId);
    }
}
