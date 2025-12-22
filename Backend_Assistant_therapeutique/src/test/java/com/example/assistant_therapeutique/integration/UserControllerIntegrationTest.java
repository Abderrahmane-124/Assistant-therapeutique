package com.example.assistant_therapeutique.integration;

import com.example.assistant_therapeutique.model.User;
import com.example.assistant_therapeutique.model.Journal;
import com.example.assistant_therapeutique.model.Mood;
import com.example.assistant_therapeutique.repository.UserRepository;
import com.example.assistant_therapeutique.repository.JournalRepository;
import com.example.assistant_therapeutique.repository.MoodRepository;
import com.example.assistant_therapeutique.repository.ConversationRepository;
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
@Epic("User Management")
@Feature("User Controller Integration Tests")
public class UserControllerIntegrationTest {

    @Autowired
    private MockMvc mockMvc;

    @Autowired
    private UserRepository userRepository;

    @Autowired
    private JournalRepository journalRepository;

    @Autowired
    private MoodRepository moodRepository;

    @Autowired
    private ConversationRepository conversationRepository;

    @Autowired
    private ObjectMapper objectMapper;

    private User testUser;

    @BeforeEach
    void setUp() {
        conversationRepository.deleteAll();
        journalRepository.deleteAll();
        moodRepository.deleteAll();
        userRepository.deleteAll();

        // Create a test user
        testUser = new User();
        testUser.setUsername("usercontroller_test");
        testUser.setPassword("password123");
        testUser = userRepository.save(testUser);
    }

    @Test
    @DisplayName("Get User by ID - Success")
    @Story("User Profile")
    @Description("Test retrieving user information by ID")
    @Severity(SeverityLevel.CRITICAL)
    void getUserById_Success() throws Exception {
        mockMvc.perform(get("/api/users/" + testUser.getId()))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.id").value(testUser.getId()))
                .andExpect(jsonPath("$.username").value("usercontroller_test"));
    }

    @Test
    @DisplayName("Get User by ID - Not Found")
    @Story("User Profile")
    @Description("Test 404 response when user does not exist")
    @Severity(SeverityLevel.NORMAL)
    void getUserById_NotFound() throws Exception {
        mockMvc.perform(get("/api/users/99999"))
                .andExpect(status().isNotFound())
                .andExpect(jsonPath("$.message").value("User not found"));
    }

    @Test
    @DisplayName("Update User - Success")
    @Story("User Profile")
    @Description("Test successful user profile update")
    @Severity(SeverityLevel.CRITICAL)
    void updateUser_Success() throws Exception {
        Map<String, String> updates = new HashMap<>();
        updates.put("username", "updated_username");

        mockMvc.perform(put("/api/users/" + testUser.getId())
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(updates)))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.username").value("updated_username"));
    }

    @Test
    @DisplayName("Update User Password - Success")
    @Story("User Profile")
    @Description("Test successful user password update")
    @Severity(SeverityLevel.CRITICAL)
    void updateUserPassword_Success() throws Exception {
        Map<String, String> updates = new HashMap<>();
        updates.put("password", "newpassword123");

        mockMvc.perform(put("/api/users/" + testUser.getId())
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(updates)))
                .andExpect(status().isOk());
    }

    @Test
    @DisplayName("Update User - Not Found")
    @Story("User Profile")
    @Description("Test 404 response when updating non-existent user")
    @Severity(SeverityLevel.NORMAL)
    void updateUser_NotFound() throws Exception {
        Map<String, String> updates = new HashMap<>();
        updates.put("username", "new_username");

        mockMvc.perform(put("/api/users/99999")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(updates)))
                .andExpect(status().isNotFound())
                .andExpect(jsonPath("$.message").value("User not found"));
    }

    @Test
    @DisplayName("Get User Stats - Success")
    @Story("User Statistics")
    @Description("Test retrieving user statistics (conversations, journals, moods)")
    @Severity(SeverityLevel.NORMAL)
    void getUserStats_Success() throws Exception {
        // Create some data for statistics
        Journal journal = new Journal();
        journal.setTitle("Test Journal");
        journal.setContent("Test content");
        journal.setCreatedAt(LocalDateTime.now());
        journal.setUser(testUser);
        journalRepository.save(journal);

        Mood mood = new Mood();
        mood.setMood("happy");
        mood.setCreatedAt(LocalDateTime.now());
        mood.setUser(testUser);
        moodRepository.save(mood);

        mockMvc.perform(get("/api/users/" + testUser.getId() + "/stats"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.userId").value(testUser.getId()))
                .andExpect(jsonPath("$.journalEntriesCount").value(1))
                .andExpect(jsonPath("$.moodEntriesCount").value(1))
                .andExpect(jsonPath("$.conversationsCount").value(0));
    }

    @Test
    @DisplayName("Get User Stats - Not Found")
    @Story("User Statistics")
    @Description("Test 404 response when getting stats for non-existent user")
    @Severity(SeverityLevel.MINOR)
    void getUserStats_NotFound() throws Exception {
        mockMvc.perform(get("/api/users/99999/stats"))
                .andExpect(status().isNotFound())
                .andExpect(jsonPath("$.message").value("User not found"));
    }
}
