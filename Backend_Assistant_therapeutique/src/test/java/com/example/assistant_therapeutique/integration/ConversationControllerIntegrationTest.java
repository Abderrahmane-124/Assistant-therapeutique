package com.example.assistant_therapeutique.integration;

import com.example.assistant_therapeutique.dto.ConversationRequestDTO;
import com.example.assistant_therapeutique.model.Conversation;
import com.example.assistant_therapeutique.model.User;
import com.example.assistant_therapeutique.repository.ConversationRepository;
import com.example.assistant_therapeutique.repository.ChatMessageRepository;
import com.example.assistant_therapeutique.repository.UserRepository;
import com.fasterxml.jackson.databind.ObjectMapper;
import io.qameta.allure.*;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureMockMvc;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.http.MediaType;
import org.springframework.test.annotation.DirtiesContext;
import org.springframework.test.context.ActiveProfiles;
import org.springframework.test.web.servlet.MockMvc;

import java.time.LocalDateTime;
import java.util.HashMap;
import java.util.Map;

import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.*;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.*;

@SpringBootTest
@AutoConfigureMockMvc
@ActiveProfiles("test")
@DirtiesContext(classMode = DirtiesContext.ClassMode.BEFORE_CLASS)
@Epic("Conversations")
@Feature("Conversation Controller Integration Tests")
public class ConversationControllerIntegrationTest {

    @Autowired
    private MockMvc mockMvc;

    @Autowired
    private ConversationRepository conversationRepository;

    @Autowired
    private ChatMessageRepository chatMessageRepository;

    @Autowired
    private UserRepository userRepository;

    @Autowired
    private ObjectMapper objectMapper;

    private User testUser;

    @BeforeEach
    void setUp() {
        chatMessageRepository.deleteAll();
        conversationRepository.deleteAll();
        userRepository.deleteAll();

        // Create a test user
        testUser = new User();
        testUser.setUsername("conversation_user");
        testUser.setPassword("password123");
        testUser = userRepository.save(testUser);
    }

    @Test
    @DisplayName("Create Conversation - Success")
    @Story("Conversation CRUD")
    @Description("Test successful conversation creation")
    @Severity(SeverityLevel.CRITICAL)
    void createConversation_Success() throws Exception {
        ConversationRequestDTO request = new ConversationRequestDTO("Ma première conversation", testUser.getId());

        mockMvc.perform(post("/api/conversations")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(request)))
                .andExpect(status().isCreated())
                .andExpect(jsonPath("$.titre").value("Ma première conversation"))
                .andExpect(jsonPath("$.id").exists());
    }

    @Test
    @DisplayName("Get Conversations by User - Success")
    @Story("Conversation CRUD")
    @Description("Test retrieving all conversations for a user")
    @Severity(SeverityLevel.NORMAL)
    void getConversationsByUser_Success() throws Exception {
        // Create a conversation
        Conversation conversation = new Conversation();
        conversation.setTitre("Test Conversation");
        conversation.setUser(testUser);
        conversation.setCreatedAt(LocalDateTime.now());
        conversationRepository.save(conversation);

        mockMvc.perform(get("/api/conversations/user/" + testUser.getId()))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$").isArray())
                .andExpect(jsonPath("$[0].titre").value("Test Conversation"));
    }

    @Test
    @DisplayName("Get Conversations by User - Empty List")
    @Story("Conversation CRUD")
    @Description("Test retrieving conversations when user has none")
    @Severity(SeverityLevel.MINOR)
    void getConversationsByUser_EmptyList() throws Exception {
        mockMvc.perform(get("/api/conversations/user/" + testUser.getId()))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$").isArray())
                .andExpect(jsonPath("$.length()").value(0));
    }

    @Test
    @DisplayName("Get Conversation by ID - Success")
    @Story("Conversation CRUD")
    @Description("Test retrieving a specific conversation by ID")
    @Severity(SeverityLevel.NORMAL)
    void getConversationById_Success() throws Exception {
        Conversation conversation = new Conversation();
        conversation.setTitre("Specific Conversation");
        conversation.setUser(testUser);
        conversation.setCreatedAt(LocalDateTime.now());
        conversation = conversationRepository.save(conversation);

        mockMvc.perform(get("/api/conversations/" + conversation.getId()))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.titre").value("Specific Conversation"));
    }

    @Test
    @DisplayName("Get Conversation by ID - Not Found")
    @Story("Conversation CRUD")
    @Description("Test 404 response when conversation does not exist")
    @Severity(SeverityLevel.MINOR)
    void getConversationById_NotFound() throws Exception {
        mockMvc.perform(get("/api/conversations/99999"))
                .andExpect(status().isNotFound());
    }

    @Test
    @DisplayName("Delete Conversation - Success")
    @Story("Conversation CRUD")
    @Description("Test successful conversation deletion")
    @Severity(SeverityLevel.NORMAL)
    void deleteConversation_Success() throws Exception {
        Conversation conversation = new Conversation();
        conversation.setTitre("To Delete");
        conversation.setUser(testUser);
        conversation.setCreatedAt(LocalDateTime.now());
        conversation = conversationRepository.save(conversation);

        mockMvc.perform(delete("/api/conversations/" + conversation.getId()))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.message").value("Conversation supprimée"));
    }

    @Test
    @DisplayName("Update Conversation Title - Success")
    @Story("Conversation CRUD")
    @Description("Test successful conversation title update")
    @Severity(SeverityLevel.NORMAL)
    void updateConversationTitle_Success() throws Exception {
        Conversation conversation = new Conversation();
        conversation.setTitre("Original Title");
        conversation.setUser(testUser);
        conversation.setCreatedAt(LocalDateTime.now());
        conversation = conversationRepository.save(conversation);

        Map<String, String> request = new HashMap<>();
        request.put("title", "Updated Title");

        mockMvc.perform(put("/api/conversations/" + conversation.getId() + "/title")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(request)))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.titre").value("Updated Title"));
    }
}
