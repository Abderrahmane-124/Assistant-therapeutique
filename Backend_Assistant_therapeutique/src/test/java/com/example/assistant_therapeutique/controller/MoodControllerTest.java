package com.example.assistant_therapeutique.controller;

import com.example.assistant_therapeutique.model.Mood;
import com.example.assistant_therapeutique.model.User;
import com.example.assistant_therapeutique.service.MoodService;
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
import java.util.Optional;

import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.*;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.*;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.*;

/**
 * Tests pour MoodController
 * Couvre : CRUD + logique update avec condition exists/not exists
 */
@WebMvcTest(MoodController.class)
class MoodControllerTest {

    @Autowired
    private MockMvc mockMvc;

    @MockBean
    private MoodService moodService;

    @Autowired
    private ObjectMapper objectMapper;

    private User testUser;
    private Mood testMood;

    @BeforeEach
    void setUp() {
        testUser = new User();
        testUser.setId(1L);

        testMood = new Mood();
        testMood.setId(1L);
        testMood.setMood("happy");
        testMood.setUser(testUser);
    }

    @Test
    @DisplayName("POST /moods - doit créer une humeur")
    void saveMood_ShouldReturnCreated() throws Exception {
        when(moodService.saveMood(any(Mood.class))).thenReturn(testMood);

        mockMvc.perform(post("/api/moods")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(testMood)))
                .andExpect(status().isCreated())
                .andExpect(jsonPath("$.mood").value("happy"));
    }

    @Test
    @DisplayName("GET /moods/user/{userId} - doit retourner les humeurs")
    void getMoodsByUserId_ShouldReturnMoods() throws Exception {
        when(moodService.getMoodsByUserId(1L)).thenReturn(Arrays.asList(testMood));

        mockMvc.perform(get("/api/moods/user/1"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$[0].mood").value("happy"));
    }

    @Test
    @DisplayName("GET /moods/{id} - existant -> 200")
    void getMoodById_WhenExists_ShouldReturnMood() throws Exception {
        when(moodService.getMoodById(1L)).thenReturn(Optional.of(testMood));

        mockMvc.perform(get("/api/moods/1"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.mood").value("happy"));
    }

    @Test
    @DisplayName("GET /moods/{id} - inexistant -> 404")
    void getMoodById_WhenNotExists_ShouldReturn404() throws Exception {
        when(moodService.getMoodById(999L)).thenReturn(Optional.empty());

        mockMvc.perform(get("/api/moods/999"))
                .andExpect(status().isNotFound());
    }

    @Test
    @DisplayName("PUT /moods/{id} - existant -> mise à jour")
    void updateMood_WhenExists_ShouldUpdate() throws Exception {
        Mood updatedMood = new Mood();
        updatedMood.setId(1L);
        updatedMood.setMood("sad");

        when(moodService.getMoodById(1L)).thenReturn(Optional.of(testMood));
        when(moodService.saveMood(any(Mood.class))).thenReturn(updatedMood);

        mockMvc.perform(put("/api/moods/1")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(updatedMood)))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.mood").value("sad"));
    }

    @Test
    @DisplayName("PUT /moods/{id} - inexistant -> 404")
    void updateMood_WhenNotExists_ShouldReturn404() throws Exception {
        when(moodService.getMoodById(999L)).thenReturn(Optional.empty());

        mockMvc.perform(put("/api/moods/999")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(testMood)))
                .andExpect(status().isNotFound());
    }

    @Test
    @DisplayName("DELETE /moods/{id} - doit supprimer")
    void deleteMood_ShouldReturn204() throws Exception {
        doNothing().when(moodService).deleteMood(1L);

        mockMvc.perform(delete("/api/moods/1"))
                .andExpect(status().isNoContent());
    }
}
