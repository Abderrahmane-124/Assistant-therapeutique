package com.example.assistant_therapeutique.controller;

import com.example.assistant_therapeutique.dto.ChatMessageRequestDTO;
import com.example.assistant_therapeutique.model.ChatMessage;
import com.example.assistant_therapeutique.model.User;
import com.example.assistant_therapeutique.model.Conversation;
import com.example.assistant_therapeutique.service.ChatMessageService;
import com.fasterxml.jackson.databind.ObjectMapper;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.WebMvcTest;
import org.springframework.boot.test.mock.mockito.MockBean;
import org.springframework.http.MediaType;
import org.springframework.test.web.servlet.MockMvc;

import java.time.LocalDateTime;
import java.util.Arrays;

import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.anyLong;
import static org.mockito.Mockito.when;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.*;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.*;

/**
 * Tests pour ChatMessageController
 * Couvre : envoi et récupération de messages
 */
@WebMvcTest(ChatMessageController.class)
class ChatMessageControllerTest {

    @Autowired
    private MockMvc mockMvc;

    @MockBean
    private ChatMessageService chatMessageService;

    @Autowired
    private ObjectMapper objectMapper;

    private ChatMessage testMessage;

    @BeforeEach
    void setUp() {
        User user = new User();
        user.setId(1L);

        Conversation conv = new Conversation();
        conv.setId(1L);

        testMessage = new ChatMessage();
        testMessage.setId(1L);
        testMessage.setContent("Hello!");
        testMessage.setSender(user);
        testMessage.setConversation(conv);
        testMessage.setCreatedAt(LocalDateTime.now());
    }

    @Test
    @DisplayName("POST /chat/send - doit envoyer un message")
    void sendMessage_ShouldReturnCreated() throws Exception {
        ChatMessageRequestDTO dto = new ChatMessageRequestDTO();
        dto.setSenderId(1L);
        dto.setConversationId(1L);
        dto.setContent("Hello!");

        when(chatMessageService.saveMessage(anyLong(), anyLong(), any(String.class)))
                .thenReturn(testMessage);

        mockMvc.perform(post("/api/chat/send")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(dto)))
                .andExpect(status().isCreated())
                .andExpect(jsonPath("$.content").value("Hello!"));
    }

    @Test
    @DisplayName("GET /chat/conversations/{id}/messages - doit retourner les messages")
    void getMessagesByConversationId_ShouldReturnMessages() throws Exception {
        when(chatMessageService.getMessagesByConversationId(1L))
                .thenReturn(Arrays.asList(testMessage));

        mockMvc.perform(get("/api/chat/conversations/1/messages"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$[0].content").value("Hello!"));
    }
}
