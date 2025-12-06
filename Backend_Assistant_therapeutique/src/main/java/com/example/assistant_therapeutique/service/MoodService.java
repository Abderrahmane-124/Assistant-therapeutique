package com.example.assistant_therapeutique.service;

import com.example.assistant_therapeutique.model.Mood;
import com.example.assistant_therapeutique.repository.MoodRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;

@Service
public class MoodService {

    @Autowired
    private MoodRepository moodRepository;

    public Mood saveMood(Mood mood) {
        mood.setCreatedAt(LocalDateTime.now());
        return moodRepository.save(mood);
    }

    public List<Mood> getMoodsByUserId(Long userId) {
        return moodRepository.findByUserId(userId);
    }

    public Optional<Mood> getMoodById(Long id) {
        return moodRepository.findById(id);
    }

    public void deleteMood(Long id) {
        moodRepository.deleteById(id);
    }
}
