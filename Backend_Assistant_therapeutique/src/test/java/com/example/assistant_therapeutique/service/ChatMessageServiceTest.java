package com.example.assistant_therapeutique.service;

import com.example.assistant_therapeutique.model.ChatMessage;
import com.example.assistant_therapeutique.model.Conversation;
import com.example.assistant_therapeutique.model.User;
import com.example.assistant_therapeutique.repository.ChatMessageRepository;
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
 * Tests unitaires pour ChatMessageService
 * Couvre : envoi message, gestion erreurs (sender/conversation), récupération
 */
@ExtendWith(MockitoExtension.class)
class ChatMessageServiceTest {

    @Mock
    private ChatMessageRepository chatMessageRepository;

    @Mock
    private UserRepository userRepository;

    @Mock
    private ConversationRepository conversationRepository;

    @InjectMocks
    private ChatMessageService chatMessageService;

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
    }

    @Test
    @DisplayName("saveMessage - doit créer un message avec date auto")
    void saveMessage_ShouldCreateMessageWithAutoDate() {
        when(userRepository.findById(1L)).thenReturn(Optional.of(testUser));
        when(conversationRepository.findById(1L)).thenReturn(Optional.of(testConversation));
        when(chatMessageRepository.save(any(ChatMessage.class))).thenAnswer(inv -> inv.getArgument(0));

        LocalDateTime before = LocalDateTime.now();
        ChatMessage saved = chatMessageService.saveMessage(1L, 1L, "Hello!");

        assertThat(saved.getContent()).isEqualTo("Hello!");
        assertThat(saved.getSender()).isEqualTo(testUser);
        assertThat(saved.getConversation()).isEqualTo(testConversation);
        assertThat(saved.getCreatedAt()).isAfterOrEqualTo(before);
    }

    @Test
    @DisplayName("saveMessage - sender inexistant -> exception")
    void saveMessage_WhenSenderNotFound_ShouldThrowException() {
        when(userRepository.findById(999L)).thenReturn(Optional.empty());

        assertThatThrownBy(() -> chatMessageService.saveMessage(999L, 1L, "Hello!"))
                .isInstanceOf(RuntimeException.class)
                .hasMessageContaining("Sender user not found");
    }

    @Test
    @DisplayName("saveMessage - conversation inexistante -> exception")
    void saveMessage_WhenConversationNotFound_ShouldThrowException() {
        when(userRepository.findById(1L)).thenReturn(Optional.of(testUser));
        when(conversationRepository.findById(999L)).thenReturn(Optional.empty());

        assertThatThrownBy(() -> chatMessageService.saveMessage(1L, 999L, "Hello!"))
                .isInstanceOf(RuntimeException.class)
                .hasMessageContaining("Conversation not found");
    }

    @Test
    @DisplayName("getMessagesByConversationId - doit retourner les messages")
    void getMessagesByConversationId_ShouldReturnMessages() {
        ChatMessage msg = new ChatMessage();
        msg.setContent("Test message");
        
        when(chatMessageRepository.findByConversationId(1L)).thenReturn(Arrays.asList(msg));

        List<ChatMessage> messages = chatMessageService.getMessagesByConversationId(1L);

        assertThat(messages).hasSize(1);
    }
}
