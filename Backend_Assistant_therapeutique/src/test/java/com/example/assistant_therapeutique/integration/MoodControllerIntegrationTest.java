package com.example.assistant_therapeutique.integration;

import com.example.assistant_therapeutique.model.Mood;
import com.example.assistant_therapeutique.model.User;
import com.example.assistant_therapeutique.repository.MoodRepository;
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

import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.*;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.*;

@SpringBootTest
@AutoConfigureMockMvc
@ActiveProfiles("test")
@DirtiesContext(classMode = DirtiesContext.ClassMode.BEFORE_CLASS)
@Epic("Mood Tracking")
@Feature("Mood Controller Integration Tests")
public class MoodControllerIntegrationTest {

    @Autowired
    private MockMvc mockMvc;

    @Autowired
    private MoodRepository moodRepository;

    @Autowired
    private UserRepository userRepository;

    @Autowired
    private ObjectMapper objectMapper;

    private User testUser;

    @BeforeEach
    void setUp() {
        moodRepository.deleteAll();
        userRepository.deleteAll();

        // Create a test user
        testUser = new User();
        testUser.setUsername("mooduser");
        testUser.setPassword("password123");
        testUser = userRepository.save(testUser);
    }

    @Test
    @DisplayName("Save Mood - Success")
    @Story("Mood CRUD")
    @Description("Test successful mood entry creation")
    @Severity(SeverityLevel.CRITICAL)
    void saveMood_Success() throws Exception {
        Mood mood = new Mood();
        mood.setMood("happy");
        mood.setCreatedAt(LocalDateTime.now());
        mood.setUser(testUser);

        mockMvc.perform(post("/api/moods")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(mood)))
                .andExpect(status().isCreated())
                .andExpect(jsonPath("$.mood").value("happy"))
                .andExpect(jsonPath("$.id").exists());
    }

    @Test
    @DisplayName("Get Moods by User - Success")
    @Story("Mood CRUD")
    @Description("Test retrieving all mood entries for a user")
    @Severity(SeverityLevel.NORMAL)
    void getMoodsByUser_Success() throws Exception {
        // Create a mood entry
        Mood mood = new Mood();
        mood.setMood("anxious");
        mood.setCreatedAt(LocalDateTime.now());
        mood.setUser(testUser);
        moodRepository.save(mood);

        mockMvc.perform(get("/api/moods/user/" + testUser.getId()))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$").isArray())
                .andExpect(jsonPath("$[0].mood").value("anxious"));
    }

    @Test
    @DisplayName("Get Mood by ID - Success")
    @Story("Mood CRUD")
    @Description("Test retrieving a specific mood entry by ID")
    @Severity(SeverityLevel.NORMAL)
    void getMoodById_Success() throws Exception {
        Mood mood = new Mood();
        mood.setMood("calm");
        mood.setCreatedAt(LocalDateTime.now());
        mood.setUser(testUser);
        mood = moodRepository.save(mood);

        mockMvc.perform(get("/api/moods/" + mood.getId()))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.mood").value("calm"));
    }

    @Test
    @DisplayName("Get Mood by ID - Not Found")
    @Story("Mood CRUD")
    @Description("Test 404 response when mood entry does not exist")
    @Severity(SeverityLevel.MINOR)
    void getMoodById_NotFound() throws Exception {
        mockMvc.perform(get("/api/moods/99999"))
                .andExpect(status().isNotFound());
    }

    @Test
    @DisplayName("Update Mood - Success")
    @Story("Mood CRUD")
    @Description("Test successful mood entry update")
    @Severity(SeverityLevel.NORMAL)
    void updateMood_Success() throws Exception {
        Mood mood = new Mood();
        mood.setMood("sad");
        mood.setCreatedAt(LocalDateTime.now());
        mood.setUser(testUser);
        mood = moodRepository.save(mood);

        Mood updateRequest = new Mood();
        updateRequest.setMood("happy");

        mockMvc.perform(put("/api/moods/" + mood.getId())
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(updateRequest)))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.mood").value("happy"));
    }

    @Test
    @DisplayName("Delete Mood - Success")
    @Story("Mood CRUD")
    @Description("Test successful mood entry deletion")
    @Severity(SeverityLevel.NORMAL)
    void deleteMood_Success() throws Exception {
        Mood mood = new Mood();
        mood.setMood("neutral");
        mood.setCreatedAt(LocalDateTime.now());
        mood.setUser(testUser);
        mood = moodRepository.save(mood);

        mockMvc.perform(delete("/api/moods/" + mood.getId()))
                .andExpect(status().isNoContent());
    }
}
