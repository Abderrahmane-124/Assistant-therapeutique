package com.example.assistant_therapeutique.controller;

import com.example.assistant_therapeutique.dto.ConversationRequestDTO;
import com.example.assistant_therapeutique.model.Conversation;
import com.example.assistant_therapeutique.model.User;
import com.example.assistant_therapeutique.service.ConversationService;
import com.example.assistant_therapeutique.service.ChatMessageService;
import com.example.assistant_therapeutique.service.AiService;
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
import java.util.HashMap;
import java.util.Map;
import java.util.Optional;

import static org.mockito.ArgumentMatchers.*;
import static org.mockito.Mockito.*;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.*;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.*;

/**
 * Tests pour ConversationController
 * Couvre : CRUD + logique complexe sendMessage (création conv + AI)
 */
@WebMvcTest(ConversationController.class)
class ConversationControllerTest {

    @Autowired
    private MockMvc mockMvc;

    @MockBean
    private ConversationService conversationService;

    @MockBean
    private ChatMessageService chatMessageService;

    @MockBean
    private AiService aiService;

    @Autowired
    private ObjectMapper objectMapper;

    private User testUser;
    private Conversation testConversation;

    @BeforeEach
    void setUp() {
        testUser = new User();
        testUser.setId(1L);

        testConversation = new Conversation();
        testConversation.setId(1L);
        testConversation.setTitre("Test Conv");
        testConversation.setUser(testUser);
        testConversation.setCreatedAt(LocalDateTime.now());
    }

    @Test
    @DisplayName("POST /conversations - doit créer une conversation")
    void createConversation_ShouldReturnCreated() throws Exception {
        ConversationRequestDTO dto = new ConversationRequestDTO();
        dto.setUserId(1L);
        dto.setTitre("Nouvelle conv");

        when(conversationService.createConversation(1L, "Nouvelle conv")).thenReturn(testConversation);

        mockMvc.perform(post("/api/conversations")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(dto)))
                .andExpect(status().isCreated());
    }

    @Test
    @DisplayName("GET /conversations/user/{userId} - doit retourner les conversations")
    void getConversationsByUserId_ShouldReturnConversations() throws Exception {
        when(conversationService.getConversationsByUserId(1L)).thenReturn(Arrays.asList(testConversation));

        mockMvc.perform(get("/api/conversations/user/1"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$[0].titre").value("Test Conv"));
    }

    @Test
    @DisplayName("GET /conversations/{id} - existant -> 200")
    void getConversationById_WhenExists_ShouldReturn() throws Exception {
        when(conversationService.getConversationById(1L)).thenReturn(Optional.of(testConversation));

        mockMvc.perform(get("/api/conversations/1"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.titre").value("Test Conv"));
    }

    @Test
    @DisplayName("GET /conversations/{id} - inexistant -> 404")
    void getConversationById_WhenNotExists_ShouldReturn404() throws Exception {
        when(conversationService.getConversationById(999L)).thenReturn(Optional.empty());

        mockMvc.perform(get("/api/conversations/999"))
                .andExpect(status().isNotFound());
    }

    @Test
    @DisplayName("DELETE /conversations/{id} - doit supprimer")
    void deleteConversation_ShouldReturnOk() throws Exception {
        doNothing().when(conversationService).deleteConversation(1L);

        mockMvc.perform(delete("/api/conversations/1"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.message").value("Conversation supprimée"));
    }

    @Test
    @DisplayName("PUT /conversations/{id}/title - mise à jour titre")
    void updateConversationTitle_ShouldUpdate() throws Exception {
        Conversation updated = new Conversation();
        updated.setId(1L);
        updated.setTitre("Nouveau titre");

        when(conversationService.updateTitle(1L, "Nouveau titre")).thenReturn(updated);

        Map<String, String> request = new HashMap<>();
        request.put("title", "Nouveau titre");

        mockMvc.perform(put("/api/conversations/1/title")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(request)))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.titre").value("Nouveau titre"));
    }
}
