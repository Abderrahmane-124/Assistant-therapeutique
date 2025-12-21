package com.example.assistant_therapeutique.service;

import com.example.assistant_therapeutique.model.Conversation;
import com.example.assistant_therapeutique.model.User;
import com.example.assistant_therapeutique.repository.ConversationRepository;
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
 * Tests unitaires pour ConversationService
 * Couvre : création, mise à jour titre, CRUD, gestion erreurs
 */
@ExtendWith(MockitoExtension.class)
class ConversationServiceTest {

    @Mock
    private ConversationRepository conversationRepository;

    @Mock
    private UserRepository userRepository;

    @InjectMocks
    private ConversationService conversationService;

    private User testUser;
    private Conversation testConversation;

    @BeforeEach
    void setUp() {
        testUser = new User();
        testUser.setId(1L);
        testUser.setUsername("testuser");

        testConversation = new Conversation();
        testConversation.setId(1L);
        testConversation.setTitre("Test Conversation");
        testConversation.setUser(testUser);
        testConversation.setCreatedAt(LocalDateTime.now());
    }

    @Test
    @DisplayName("createConversation - doit créer avec date auto")
    void createConversation_ShouldCreateWithAutoDate() {
        when(userRepository.findById(1L)).thenReturn(Optional.of(testUser));
        when(conversationRepository.save(any(Conversation.class))).thenAnswer(inv -> inv.getArgument(0));

        LocalDateTime before = LocalDateTime.now();
        Conversation created = conversationService.createConversation(1L, "Nouvelle conv");

        assertThat(created.getTitre()).isEqualTo("Nouvelle conv");
        assertThat(created.getUser()).isEqualTo(testUser);
        assertThat(created.getCreatedAt()).isAfterOrEqualTo(before);
    }

    @Test
    @DisplayName("createConversation - utilisateur inexistant -> exception")
    void createConversation_WhenUserNotFound_ShouldThrowException() {
        when(userRepository.findById(999L)).thenReturn(Optional.empty());

        assertThatThrownBy(() -> conversationService.createConversation(999L, "Test"))
                .isInstanceOf(RuntimeException.class)
                .hasMessageContaining("User not found");
    }

    @Test
    @DisplayName("getConversationsByUserId - doit retourner les conversations")
    void getConversationsByUserId_ShouldReturnConversations() {
        when(conversationRepository.findByUserId(1L)).thenReturn(Arrays.asList(testConversation));

        List<Conversation> convs = conversationService.getConversationsByUserId(1L);

        assertThat(convs).hasSize(1);
    }

    @Test
    @DisplayName("getConversationById - conversation existante")
    void getConversationById_WhenExists_ShouldReturnConversation() {
        when(conversationRepository.findById(1L)).thenReturn(Optional.of(testConversation));

        Optional<Conversation> found = conversationService.getConversationById(1L);

        assertThat(found).isPresent();
    }

    @Test
    @DisplayName("updateTitle - doit mettre à jour le titre")
    void updateTitle_ShouldUpdateTitle() {
        when(conversationRepository.findById(1L)).thenReturn(Optional.of(testConversation));
        when(conversationRepository.save(any(Conversation.class))).thenAnswer(inv -> inv.getArgument(0));

        Conversation updated = conversationService.updateTitle(1L, "Nouveau titre");

        assertThat(updated.getTitre()).isEqualTo("Nouveau titre");
    }

    @Test
    @DisplayName("updateTitle - conversation inexistante -> exception")
    void updateTitle_WhenNotFound_ShouldThrowException() {
        when(conversationRepository.findById(999L)).thenReturn(Optional.empty());

        assertThatThrownBy(() -> conversationService.updateTitle(999L, "Test"))
                .isInstanceOf(RuntimeException.class)
                .hasMessageContaining("Conversation not found");
    }

    @Test
    @DisplayName("deleteConversation - doit appeler le repository")
    void deleteConversation_ShouldCallRepository() {
        doNothing().when(conversationRepository).deleteById(1L);

        conversationService.deleteConversation(1L);

        verify(conversationRepository).deleteById(1L);
    }
}
