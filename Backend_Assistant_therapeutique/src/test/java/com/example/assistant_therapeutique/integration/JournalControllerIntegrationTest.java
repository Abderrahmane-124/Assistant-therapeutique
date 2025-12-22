package com.example.assistant_therapeutique.integration;

import com.example.assistant_therapeutique.dto.JournalRequestDTO;
import com.example.assistant_therapeutique.model.Journal;
import com.example.assistant_therapeutique.model.User;
import com.example.assistant_therapeutique.repository.JournalRepository;
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
@Epic("Journal")
@Feature("Journal Controller Integration Tests")
public class JournalControllerIntegrationTest {

    @Autowired
    private MockMvc mockMvc;

    @Autowired
    private JournalRepository journalRepository;

    @Autowired
    private UserRepository userRepository;

    @Autowired
    private ObjectMapper objectMapper;

    private User testUser;

    @BeforeEach
    void setUp() {
        journalRepository.deleteAll();
        userRepository.deleteAll();

        // Create a test user
        testUser = new User();
        testUser.setUsername("journaluser");
        testUser.setPassword("password123");
        testUser = userRepository.save(testUser);
    }

    @Test
    @DisplayName("Create Journal - Success")
    @Story("Journal CRUD")
    @Description("Test successful journal entry creation")
    @Severity(SeverityLevel.CRITICAL)
    void createJournal_Success() throws Exception {
        JournalRequestDTO request = new JournalRequestDTO("Mon journal du jour", testUser.getId());

        mockMvc.perform(post("/api/journals")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(request)))
                .andExpect(status().isCreated())
                .andExpect(jsonPath("$.content").value("Mon journal du jour"))
                .andExpect(jsonPath("$.id").exists());
    }

    @Test
    @DisplayName("Get Journals by User - Success")
    @Story("Journal CRUD")
    @Description("Test retrieving all journal entries for a user")
    @Severity(SeverityLevel.NORMAL)
    void getJournalsByUser_Success() throws Exception {
        // Create a journal entry
        Journal journal = new Journal();
        journal.setTitle("Test Title");
        journal.setContent("Test Content");
        journal.setCreatedAt(LocalDateTime.now());
        journal.setUser(testUser);
        journalRepository.save(journal);

        mockMvc.perform(get("/api/journals/user/" + testUser.getId()))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$").isArray())
                .andExpect(jsonPath("$[0].content").value("Test Content"));
    }

    @Test
    @DisplayName("Get Journal by ID - Success")
    @Story("Journal CRUD")
    @Description("Test retrieving a specific journal entry by ID")
    @Severity(SeverityLevel.NORMAL)
    void getJournalById_Success() throws Exception {
        Journal journal = new Journal();
        journal.setTitle("Specific Journal");
        journal.setContent("Specific Content");
        journal.setCreatedAt(LocalDateTime.now());
        journal.setUser(testUser);
        journal = journalRepository.save(journal);

        mockMvc.perform(get("/api/journals/" + journal.getId()))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.title").value("Specific Journal"));
    }

    @Test
    @DisplayName("Get Journal by ID - Not Found")
    @Story("Journal CRUD")
    @Description("Test 404 response when journal entry does not exist")
    @Severity(SeverityLevel.MINOR)
    void getJournalById_NotFound() throws Exception {
        mockMvc.perform(get("/api/journals/99999"))
                .andExpect(status().isNotFound());
    }

    @Test
    @DisplayName("Update Journal - Success")
    @Story("Journal CRUD")
    @Description("Test successful journal entry update")
    @Severity(SeverityLevel.NORMAL)
    void updateJournal_Success() throws Exception {
        Journal journal = new Journal();
        journal.setTitle("Original Title");
        journal.setContent("Original Content");
        journal.setCreatedAt(LocalDateTime.now());
        journal.setUser(testUser);
        journal = journalRepository.save(journal);

        Journal updateRequest = new Journal();
        updateRequest.setTitle("Updated Title");
        updateRequest.setContent("Updated Content");

        mockMvc.perform(put("/api/journals/" + journal.getId())
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(updateRequest)))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.title").value("Updated Title"))
                .andExpect(jsonPath("$.content").value("Updated Content"));
    }

    @Test
    @DisplayName("Delete Journal - Success")
    @Story("Journal CRUD")
    @Description("Test successful journal entry deletion")
    @Severity(SeverityLevel.NORMAL)
    void deleteJournal_Success() throws Exception {
        Journal journal = new Journal();
        journal.setTitle("To Delete");
        journal.setContent("Delete me");
        journal.setCreatedAt(LocalDateTime.now());
        journal.setUser(testUser);
        journal = journalRepository.save(journal);

        mockMvc.perform(delete("/api/journals/" + journal.getId()))
                .andExpect(status().isNoContent());
    }
}
