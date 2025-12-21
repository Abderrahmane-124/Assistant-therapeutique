package com.example.assistant_therapeutique.controller;

import com.example.assistant_therapeutique.dto.JournalRequestDTO;
import com.example.assistant_therapeutique.model.Journal;
import com.example.assistant_therapeutique.model.User;
import com.example.assistant_therapeutique.service.JournalService;
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
import java.util.Optional;

import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.*;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.*;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.*;

/**
 * Tests pour JournalController
 * Couvre : CRUD + logique update avec condition exists/not exists
 */
@WebMvcTest(JournalController.class)
class JournalControllerTest {

    @Autowired
    private MockMvc mockMvc;

    @MockBean
    private JournalService journalService;

    @Autowired
    private ObjectMapper objectMapper;

    private User testUser;
    private Journal testJournal;

    @BeforeEach
    void setUp() {
        testUser = new User();
        testUser.setId(1L);

        testJournal = new Journal();
        testJournal.setId(1L);
        testJournal.setTitle("Mon journal");
        testJournal.setContent("Contenu test");
        testJournal.setCreatedAt(LocalDateTime.now());
        testJournal.setUser(testUser);
    }

    @Test
    @DisplayName("POST /journals - doit créer un journal")
    void createJournal_ShouldReturnCreated() throws Exception {
        JournalRequestDTO dto = new JournalRequestDTO();
        dto.setUserId(1L);
        dto.setContent("Contenu test");

        when(journalService.createJournalEntry(any(JournalRequestDTO.class))).thenReturn(testJournal);

        mockMvc.perform(post("/api/journals")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(dto)))
                .andExpect(status().isCreated())
                .andExpect(jsonPath("$.content").value("Contenu test"));
    }

    @Test
    @DisplayName("GET /journals/user/{userId} - doit retourner les journaux")
    void getJournalsByUserId_ShouldReturnJournals() throws Exception {
        when(journalService.getJournalsByUserId(1L)).thenReturn(Arrays.asList(testJournal));

        mockMvc.perform(get("/api/journals/user/1"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$[0].title").value("Mon journal"));
    }

    @Test
    @DisplayName("GET /journals/{id} - existant -> 200")
    void getJournalById_WhenExists_ShouldReturnJournal() throws Exception {
        when(journalService.getJournalById(1L)).thenReturn(Optional.of(testJournal));

        mockMvc.perform(get("/api/journals/1"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.title").value("Mon journal"));
    }

    @Test
    @DisplayName("GET /journals/{id} - inexistant -> 404")
    void getJournalById_WhenNotExists_ShouldReturn404() throws Exception {
        when(journalService.getJournalById(999L)).thenReturn(Optional.empty());

        mockMvc.perform(get("/api/journals/999"))
                .andExpect(status().isNotFound());
    }

    @Test
    @DisplayName("PUT /journals/{id} - existant -> mise à jour")
    void updateJournal_WhenExists_ShouldUpdate() throws Exception {
        Journal updatedJournal = new Journal();
        updatedJournal.setId(1L);
        updatedJournal.setTitle("Nouveau titre");
        updatedJournal.setContent("Nouveau contenu");

        when(journalService.getJournalById(1L)).thenReturn(Optional.of(testJournal));
        when(journalService.saveJournal(any(Journal.class))).thenReturn(updatedJournal);

        mockMvc.perform(put("/api/journals/1")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(updatedJournal)))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.title").value("Nouveau titre"));
    }

    @Test
    @DisplayName("PUT /journals/{id} - inexistant -> 404")
    void updateJournal_WhenNotExists_ShouldReturn404() throws Exception {
        when(journalService.getJournalById(999L)).thenReturn(Optional.empty());

        mockMvc.perform(put("/api/journals/999")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(testJournal)))
                .andExpect(status().isNotFound());
    }

    @Test
    @DisplayName("DELETE /journals/{id} - doit supprimer")
    void deleteJournal_ShouldReturn204() throws Exception {
        doNothing().when(journalService).deleteJournal(1L);

        mockMvc.perform(delete("/api/journals/1"))
                .andExpect(status().isNoContent());
    }
}
