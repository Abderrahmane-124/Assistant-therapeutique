package com.example.assistant_therapeutique.service;

import com.example.assistant_therapeutique.model.User;
import com.example.assistant_therapeutique.repository.UserRepository;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

import java.util.Optional;

import static org.assertj.core.api.Assertions.assertThat;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.*;

/**
 * Tests unitaires pour UserService
 * Couvre les fonctionnalités essentielles : CRUD utilisateur
 */
@ExtendWith(MockitoExtension.class)
class UserServiceTest {

    @Mock
    private UserRepository userRepository;

    @InjectMocks
    private UserService userService;

    private User testUser;

    @BeforeEach
    void setUp() {
        testUser = new User();
        testUser.setId(1L);
        testUser.setUsername("testuser");
        testUser.setPassword("password123");
    }

    @Test
    @DisplayName("saveUser - doit sauvegarder un utilisateur")
    void saveUser_ShouldReturnSavedUser() {
        when(userRepository.save(any(User.class))).thenReturn(testUser);

        User saved = userService.saveUser(testUser);

        assertThat(saved).isNotNull();
        assertThat(saved.getUsername()).isEqualTo("testuser");
    }

    @Test
    @DisplayName("findByUsername - utilisateur existant")
    void findByUsername_WhenExists_ShouldReturnUser() {
        when(userRepository.findByUsername("testuser")).thenReturn(Optional.of(testUser));

        Optional<User> found = userService.findByUsername("testuser");

        assertThat(found).isPresent();
        assertThat(found.get().getUsername()).isEqualTo("testuser");
    }

    @Test
    @DisplayName("findByUsername - utilisateur inexistant")
    void findByUsername_WhenNotExists_ShouldReturnEmpty() {
        when(userRepository.findByUsername("unknown")).thenReturn(Optional.empty());

        Optional<User> found = userService.findByUsername("unknown");

        assertThat(found).isEmpty();
    }

    @Test
    @DisplayName("findById - utilisateur existant")
    void findById_WhenExists_ShouldReturnUser() {
        when(userRepository.findById(1L)).thenReturn(Optional.of(testUser));

        Optional<User> found = userService.findById(1L);

        assertThat(found).isPresent();
        assertThat(found.get().getId()).isEqualTo(1L);
    }
}
