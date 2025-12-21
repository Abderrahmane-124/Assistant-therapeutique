package com.example.assistant_therapeutique.service;

import com.example.assistant_therapeutique.dto.JournalRequestDTO;
import com.example.assistant_therapeutique.model.Journal;
import com.example.assistant_therapeutique.model.User;
import com.example.assistant_therapeutique.repository.JournalRepository;
import com.example.assistant_therapeutique.repository.UserRepository;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

import java.time.LocalDateTime;
import java.util.Arrays;
import java.util.List;
import java.util.Optional;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.*;

/**
 * Tests unitaires pour JournalService
 * Couvre : création avec DTO, gestion erreur utilisateur, CRUD
 */
@ExtendWith(MockitoExtension.class)
class JournalServiceTest {

    @Mock
    private JournalRepository journalRepository;

    @Mock
    private UserRepository userRepository;

    @InjectMocks
    private JournalService journalService;

    private User testUser;
    private Journal testJournal;

    @BeforeEach
    void setUp() {
        testUser = new User();
        testUser.setId(1L);
        testUser.setUsername("testuser");

        testJournal = new Journal();
        testJournal.setId(1L);
        testJournal.setTitle("Mon Journal");
        testJournal.setContent("Contenu du journal");
        testJournal.setCreatedAt(LocalDateTime.now());
        testJournal.setUser(testUser);
    }

    @Test
    @DisplayName("createJournalEntry - doit créer avec titre et date auto")
    void createJournalEntry_ShouldCreateWithAutoTitleAndDate() {
        JournalRequestDTO dto = new JournalRequestDTO();
        dto.setUserId(1L);
        dto.setContent("Mon contenu");

        when(userRepository.findById(1L)).thenReturn(Optional.of(testUser));
        when(journalRepository.save(any(Journal.class))).thenAnswer(inv -> inv.getArgument(0));

        LocalDateTime before = LocalDateTime.now();
        Journal created = journalService.createJournalEntry(dto);

        assertThat(created.getContent()).isEqualTo("Mon contenu");
        assertThat(created.getUser()).isEqualTo(testUser);
        assertThat(created.getTitle()).startsWith("Journal Entry -");
        assertThat(created.getCreatedAt()).isAfterOrEqualTo(before);
    }

    @Test
    @DisplayName("createJournalEntry - utilisateur inexistant -> exception")
    void createJournalEntry_WhenUserNotFound_ShouldThrowException() {
        JournalRequestDTO dto = new JournalRequestDTO();
        dto.setUserId(999L);
        dto.setContent("Contenu");

        when(userRepository.findById(999L)).thenReturn(Optional.empty());

        assertThatThrownBy(() -> journalService.createJournalEntry(dto))
                .isInstanceOf(RuntimeException.class)
                .hasMessageContaining("User not found");
        
        verify(journalRepository, never()).save(any());
    }

    @Test
    @DisplayName("getJournalsByUserId - doit retourner les journaux")
    void getJournalsByUserId_ShouldReturnJournals() {
        when(journalRepository.findByUserId(1L)).thenReturn(Arrays.asList(testJournal));

        List<Journal> journals = journalService.getJournalsByUserId(1L);

        assertThat(journals).hasSize(1);
    }

    @Test
    @DisplayName("getJournalById - journal existant")
    void getJournalById_WhenExists_ShouldReturnJournal() {
        when(journalRepository.findById(1L)).thenReturn(Optional.of(testJournal));

        Optional<Journal> found = journalService.getJournalById(1L);

        assertThat(found).isPresent();
    }

    @Test
    @DisplayName("saveJournal - sauvegarde directe")
    void saveJournal_ShouldSave() {
        when(journalRepository.save(testJournal)).thenReturn(testJournal);

        Journal saved = journalService.saveJournal(testJournal);

        assertThat(saved).isNotNull();
    }

    @Test
    @DisplayName("deleteJournal - doit appeler le repository")
    void deleteJournal_ShouldCallRepository() {
        doNothing().when(journalRepository).deleteById(1L);

        journalService.deleteJournal(1L);

        verify(journalRepository).deleteById(1L);
    }
}
