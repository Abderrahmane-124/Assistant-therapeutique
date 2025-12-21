package com.example.assistant_therapeutique.service;

import com.example.assistant_therapeutique.model.Mood;
import com.example.assistant_therapeutique.model.User;
import com.example.assistant_therapeutique.repository.MoodRepository;
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
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.*;

/**
 * Tests unitaires pour MoodService
 * Couvre : sauvegarde avec date auto, récupération, suppression
 */
@ExtendWith(MockitoExtension.class)
class MoodServiceTest {

    @Mock
    private MoodRepository moodRepository;

    @InjectMocks
    private MoodService moodService;

    private User testUser;
    private Mood testMood;

    @BeforeEach
    void setUp() {
        testUser = new User();
        testUser.setId(1L);
        testUser.setUsername("testuser");

        testMood = new Mood();
        testMood.setId(1L);
        testMood.setMood("happy");
        testMood.setUser(testUser);
    }

    @Test
    @DisplayName("saveMood - doit définir createdAt automatiquement")
    void saveMood_ShouldSetCreatedAtAutomatically() {
        when(moodRepository.save(any(Mood.class))).thenAnswer(inv -> inv.getArgument(0));

        LocalDateTime before = LocalDateTime.now();
        Mood saved = moodService.saveMood(testMood);
        LocalDateTime after = LocalDateTime.now();

        assertThat(saved.getCreatedAt()).isNotNull();
        assertThat(saved.getCreatedAt()).isBetween(before, after);
    }

    @Test
    @DisplayName("getMoodsByUserId - doit retourner les humeurs")
    void getMoodsByUserId_ShouldReturnMoods() {
        Mood mood1 = new Mood();
        mood1.setMood("happy");
        Mood mood2 = new Mood();
        mood2.setMood("sad");
        
        when(moodRepository.findByUserId(1L)).thenReturn(Arrays.asList(mood1, mood2));

        List<Mood> moods = moodService.getMoodsByUserId(1L);

        assertThat(moods).hasSize(2);
    }

    @Test
    @DisplayName("getMoodById - humeur existante")
    void getMoodById_WhenExists_ShouldReturnMood() {
        when(moodRepository.findById(1L)).thenReturn(Optional.of(testMood));

        Optional<Mood> found = moodService.getMoodById(1L);

        assertThat(found).isPresent();
        assertThat(found.get().getMood()).isEqualTo("happy");
    }

    @Test
    @DisplayName("deleteMood - doit appeler le repository")
    void deleteMood_ShouldCallRepository() {
        doNothing().when(moodRepository).deleteById(1L);

        moodService.deleteMood(1L);

        verify(moodRepository).deleteById(1L);
    }
}
