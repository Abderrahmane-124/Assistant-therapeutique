package com.example.assistant_therapeutique.controller;

import com.example.assistant_therapeutique.model.User;
import com.example.assistant_therapeutique.service.UserService;
import com.fasterxml.jackson.databind.ObjectMapper;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.WebMvcTest;
import org.springframework.boot.test.mock.mockito.MockBean;
import org.springframework.http.MediaType;
import org.springframework.test.web.servlet.MockMvc;

import java.util.Optional;

import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.when;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.*;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.*;

/**
 * Tests pour AuthController
 * Couvre : registration, login réussi, login échoué (logique conditionnelle importante)
 */
@WebMvcTest(AuthController.class)
class AuthControllerTest {

    @Autowired
    private MockMvc mockMvc;

    @MockBean
    private UserService userService;

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
    @DisplayName("POST /register - doit créer un utilisateur")
    void registerUser_ShouldReturnCreated() throws Exception {
        when(userService.saveUser(any(User.class))).thenReturn(testUser);

        mockMvc.perform(post("/api/auth/register")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(testUser)))
                .andExpect(status().isCreated())
                .andExpect(jsonPath("$.username").value("testuser"));
    }

    @Test
    @DisplayName("POST /login - identifiants valides -> succès")
    void loginUser_WithValidCredentials_ShouldReturnSuccess() throws Exception {
        when(userService.findByUsername("testuser")).thenReturn(Optional.of(testUser));

        User loginRequest = new User();
        loginRequest.setUsername("testuser");
        loginRequest.setPassword("password123");

        mockMvc.perform(post("/api/auth/login")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(loginRequest)))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.success").value(true))
                .andExpect(jsonPath("$.userId").value(1));
    }

    @Test
    @DisplayName("POST /login - identifiants invalides -> 401")
    void loginUser_WithInvalidCredentials_ShouldReturnUnauthorized() throws Exception {
        when(userService.findByUsername("testuser")).thenReturn(Optional.of(testUser));

        User loginRequest = new User();
        loginRequest.setUsername("testuser");
        loginRequest.setPassword("wrongpassword");

        mockMvc.perform(post("/api/auth/login")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(loginRequest)))
                .andExpect(status().isUnauthorized())
                .andExpect(jsonPath("$.success").value(false));
    }

    @Test
    @DisplayName("POST /login - utilisateur inexistant -> 401")
    void loginUser_WithUnknownUser_ShouldReturnUnauthorized() throws Exception {
        when(userService.findByUsername("unknown")).thenReturn(Optional.empty());

        User loginRequest = new User();
        loginRequest.setUsername("unknown");
        loginRequest.setPassword("password");

        mockMvc.perform(post("/api/auth/login")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(loginRequest)))
                .andExpect(status().isUnauthorized());
    }
}
