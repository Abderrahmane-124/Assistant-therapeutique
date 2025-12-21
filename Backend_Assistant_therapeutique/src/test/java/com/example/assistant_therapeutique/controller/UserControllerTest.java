package com.example.assistant_therapeutique.controller;

import com.example.assistant_therapeutique.model.User;
import com.example.assistant_therapeutique.service.UserService;
import com.example.assistant_therapeutique.repository.ConversationRepository;
import com.example.assistant_therapeutique.repository.JournalRepository;
import com.example.assistant_therapeutique.repository.MoodRepository;
import com.fasterxml.jackson.databind.ObjectMapper;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.WebMvcTest;
import org.springframework.boot.test.mock.mockito.MockBean;
import org.springframework.http.MediaType;
import org.springframework.test.web.servlet.MockMvc;

import java.util.Arrays;
import java.util.HashMap;
import java.util.Map;
import java.util.Optional;

import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.when;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.*;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.*;

/**
 * Tests pour UserController
 * Couvre : getUser, updateUser (username+password), getStats
 */
@WebMvcTest(UserController.class)
class UserControllerTest {

    @Autowired
    private MockMvc mockMvc;

    @MockBean
    private UserService userService;

    @MockBean
    private ConversationRepository conversationRepository;

    @MockBean
    private JournalRepository journalRepository;

    @MockBean
    private MoodRepository moodRepository;

    @Autowired
    private ObjectMapper objectMapper;

    private User testUser;

    @BeforeEach
    void setUp() {
        testUser = new User();
        testUser.setId(1L);
        testUser.setUsername("testuser");
        testUser.setPassword("password123");
    }

    @Test
    @DisplayName("GET /users/{id} - existant -> 200 sans password")
    void getUserById_WhenExists_ShouldReturnUserWithoutPassword() throws Exception {
        when(userService.findById(1L)).thenReturn(Optional.of(testUser));

        mockMvc.perform(get("/api/users/1"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.id").value(1))
                .andExpect(jsonPath("$.username").value("testuser"))
                .andExpect(jsonPath("$.password").doesNotExist());
    }

    @Test
    @DisplayName("GET /users/{id} - inexistant -> 404")
    void getUserById_WhenNotExists_ShouldReturn404() throws Exception {
        when(userService.findById(999L)).thenReturn(Optional.empty());

        mockMvc.perform(get("/api/users/999"))
                .andExpect(status().isNotFound())
                .andExpect(jsonPath("$.message").value("User not found"));
    }

    @Test
    @DisplayName("PUT /users/{id} - mise à jour username")
    void updateUser_ShouldUpdateUsername() throws Exception {
        User updatedUser = new User();
        updatedUser.setId(1L);
        updatedUser.setUsername("newusername");

        when(userService.findById(1L)).thenReturn(Optional.of(testUser));
        when(userService.saveUser(any(User.class))).thenReturn(updatedUser);

        Map<String, String> updates = new HashMap<>();
        updates.put("username", "newusername");

        mockMvc.perform(put("/api/users/1")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(updates)))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.username").value("newusername"));
    }

    @Test
    @DisplayName("PUT /users/{id} - inexistant -> 404")
    void updateUser_WhenNotExists_ShouldReturn404() throws Exception {
        when(userService.findById(999L)).thenReturn(Optional.empty());

        Map<String, String> updates = new HashMap<>();
        updates.put("username", "test");

        mockMvc.perform(put("/api/users/999")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(updates)))
                .andExpect(status().isNotFound());
    }

    @Test
    @DisplayName("GET /users/{id}/stats - doit retourner les statistiques")
    void getUserStats_WhenExists_ShouldReturnStats() throws Exception {
        when(userService.findById(1L)).thenReturn(Optional.of(testUser));
        when(conversationRepository.findByUserId(1L)).thenReturn(Arrays.asList());
        when(journalRepository.findByUserId(1L)).thenReturn(Arrays.asList());
        when(moodRepository.findByUserId(1L)).thenReturn(Arrays.asList());

        mockMvc.perform(get("/api/users/1/stats"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.userId").value(1))
                .andExpect(jsonPath("$.conversationsCount").value(0))
                .andExpect(jsonPath("$.journalEntriesCount").value(0))
                .andExpect(jsonPath("$.moodEntriesCount").value(0));
    }

    @Test
    @DisplayName("GET /users/{id}/stats - inexistant -> 404")
    void getUserStats_WhenNotExists_ShouldReturn404() throws Exception {
        when(userService.findById(999L)).thenReturn(Optional.empty());

        mockMvc.perform(get("/api/users/999/stats"))
                .andExpect(status().isNotFound());
    }
}
