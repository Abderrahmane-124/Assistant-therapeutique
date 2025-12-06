package com.example.assistant_therapeutique.controller;

import com.example.assistant_therapeutique.model.Mood;
import com.example.assistant_therapeutique.service.MoodService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Optional;

@RestController
@RequestMapping("/api/moods")
public class MoodController {

    @Autowired
    private MoodService moodService;

    @PostMapping
    public ResponseEntity<Mood> saveMood(@RequestBody Mood mood) {
        Mood savedMood = moodService.saveMood(mood);
        return new ResponseEntity<>(savedMood, HttpStatus.CREATED);
    }

    @GetMapping("/user/{userId}")
    public List<Mood> getMoodsByUserId(@PathVariable Long userId) {
        return moodService.getMoodsByUserId(userId);
    }

    @GetMapping("/{id}")
    public ResponseEntity<Mood> getMoodById(@PathVariable Long id) {
        Optional<Mood> mood = moodService.getMoodById(id);
        return mood.map(ResponseEntity::ok)
                .orElseGet(() -> ResponseEntity.notFound().build());
    }

    @PutMapping("/{id}")
    public ResponseEntity<Mood> updateMood(@PathVariable Long id, @RequestBody Mood moodDetails) {
        Optional<Mood> optionalMood = moodService.getMoodById(id);
        if (optionalMood.isPresent()) {
            Mood mood = optionalMood.get();
            mood.setMood(moodDetails.getMood());
            Mood updatedMood = moodService.saveMood(mood);
            return ResponseEntity.ok(updatedMood);
        } else {
            return ResponseEntity.notFound().build();
        }
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<Void> deleteMood(@PathVariable Long id) {
        moodService.deleteMood(id);
        return ResponseEntity.noContent().build();
    }
}
