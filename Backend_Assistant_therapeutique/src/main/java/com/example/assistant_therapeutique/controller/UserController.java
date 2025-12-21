package com.example.assistant_therapeutique.controller;

import com.example.assistant_therapeutique.model.User;
import com.example.assistant_therapeutique.service.UserService;
import com.example.assistant_therapeutique.repository.ConversationRepository;
import com.example.assistant_therapeutique.repository.JournalRepository;
import com.example.assistant_therapeutique.repository.MoodRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.HashMap;
import java.util.Map;
import java.util.Optional;

@RestController
@RequestMapping("/api/users")
public class UserController {

    @Autowired
    private UserService userService;

    @Autowired
    private ConversationRepository conversationRepository;

    @Autowired
    private JournalRepository journalRepository;

    @Autowired
    private MoodRepository moodRepository;

    @GetMapping("/{id}")
    public ResponseEntity<?> getUserById(@PathVariable Long id) {
        Optional<User> user = userService.findById(id);
        if (user.isPresent()) {
            // Return user without password for security
            User foundUser = user.get();
            Map<String, Object> response = new HashMap<>();
            response.put("id", foundUser.getId());
            response.put("username", foundUser.getUsername());
            return new ResponseEntity<>(response, HttpStatus.OK);
        } else {
            Map<String, String> error = new HashMap<>();
            error.put("message", "User not found");
            return new ResponseEntity<>(error, HttpStatus.NOT_FOUND);
        }
    }

    @PutMapping("/{id}")
    public ResponseEntity<?> updateUser(@PathVariable Long id, @RequestBody Map<String, String> updates) {
        Optional<User> existingUser = userService.findById(id);
        if (existingUser.isPresent()) {
            User user = existingUser.get();
            
            // Update username if provided
            if (updates.containsKey("username")) {
                user.setUsername(updates.get("username"));
            }
            
            // Update password if provided
            if (updates.containsKey("password") && !updates.get("password").isEmpty()) {
                user.setPassword(updates.get("password"));
            }
            
            User savedUser = userService.saveUser(user);
            Map<String, Object> response = new HashMap<>();
            response.put("id", savedUser.getId());
            response.put("username", savedUser.getUsername());
            return new ResponseEntity<>(response, HttpStatus.OK);
        } else {
            Map<String, String> error = new HashMap<>();
            error.put("message", "User not found");
            return new ResponseEntity<>(error, HttpStatus.NOT_FOUND);
        }
    }

    @GetMapping("/{id}/stats")
    public ResponseEntity<?> getUserStats(@PathVariable Long id) {
        Optional<User> user = userService.findById(id);
        if (user.isPresent()) {
            // Calculate real statistics from database
            int conversationsCount = conversationRepository.findByUserId(id).size();
            int journalEntriesCount = journalRepository.findByUserId(id).size();
            int moodEntriesCount = moodRepository.findByUserId(id).size();

            Map<String, Object> stats = new HashMap<>();
            stats.put("userId", id);
            stats.put("conversationsCount", conversationsCount);
            stats.put("journalEntriesCount", journalEntriesCount);
            stats.put("moodEntriesCount", moodEntriesCount);
            return new ResponseEntity<>(stats, HttpStatus.OK);
        } else {
            Map<String, String> error = new HashMap<>();
            error.put("message", "User not found");
            return new ResponseEntity<>(error, HttpStatus.NOT_FOUND);
        }
    }
}
