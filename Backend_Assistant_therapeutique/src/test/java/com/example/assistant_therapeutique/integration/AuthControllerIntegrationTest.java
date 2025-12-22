package com.example.assistant_therapeutique.integration;

import com.example.assistant_therapeutique.model.User;
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

import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.*;

@SpringBootTest
@AutoConfigureMockMvc
@ActiveProfiles("test")
@DirtiesContext(classMode = DirtiesContext.ClassMode.BEFORE_CLASS)
@Epic("Authentification")
@Feature("Auth Controller Integration Tests")
public class AuthControllerIntegrationTest {

    @Autowired
    private MockMvc mockMvc;

    @Autowired
    private UserRepository userRepository;

    @Autowired
    private ObjectMapper objectMapper;

    @BeforeEach
    void setUp() {
        userRepository.deleteAll();
    }

    @Test
    @DisplayName("Register - Success")
    @Story("User Registration")
    @Description("Test successful user registration with valid credentials")
    @Severity(SeverityLevel.CRITICAL)
    void registerUser_Success() throws Exception {
        User user = new User();
        user.setUsername("testuser");
        user.setPassword("password123");

        mockMvc.perform(post("/api/auth/register")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(user)))
                .andExpect(status().isCreated())
                .andExpect(jsonPath("$.username").value("testuser"))
                .andExpect(jsonPath("$.id").exists());
    }

    @Test
    @DisplayName("Login - Success")
    @Story("User Login")
    @Description("Test successful login with valid credentials")
    @Severity(SeverityLevel.CRITICAL)
    void loginUser_Success() throws Exception {
        // First, create a user
        User user = new User();
        user.setUsername("loginuser");
        user.setPassword("password123");
        userRepository.save(user);

        // Then, try to login
        User loginRequest = new User();
        loginRequest.setUsername("loginuser");
        loginRequest.setPassword("password123");

        mockMvc.perform(post("/api/auth/login")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(loginRequest)))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.success").value(true))
                .andExpect(jsonPath("$.message").value("Login successful"))
                .andExpect(jsonPath("$.userId").exists());
    }

    @Test
    @DisplayName("Login - Invalid Credentials")
    @Story("User Login")
    @Description("Test login with invalid credentials returns 401")
    @Severity(SeverityLevel.NORMAL)
    void loginUser_InvalidCredentials() throws Exception {
        User loginRequest = new User();
        loginRequest.setUsername("nonexistent");
        loginRequest.setPassword("wrongpassword");

        mockMvc.perform(post("/api/auth/login")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(loginRequest)))
                .andExpect(status().isUnauthorized())
                .andExpect(jsonPath("$.success").value(false))
                .andExpect(jsonPath("$.message").value("Invalid credentials"));
    }
}
