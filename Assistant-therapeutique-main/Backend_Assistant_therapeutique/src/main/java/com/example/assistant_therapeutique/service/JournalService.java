package com.example.assistant_therapeutique.service;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import com.example.assistant_therapeutique.dto.JournalRequestDTO;
import com.example.assistant_therapeutique.model.Journal;
import com.example.assistant_therapeutique.model.User;
import com.example.assistant_therapeutique.repository.JournalRepository;
import com.example.assistant_therapeutique.repository.UserRepository;

@Service
public class JournalService {

    @Autowired
    private JournalRepository journalRepository;

    @Autowired
    private UserRepository userRepository;

    public List<Journal> getJournalsByUserId(Long userId) {
        return journalRepository.findByUserId(userId);
    }

    public Optional<Journal> getJournalById(Long id) {
        return journalRepository.findById(id);
    }

    public Journal createJournalEntry(JournalRequestDTO journalRequestDTO) {
        Optional<User> userOptional = userRepository.findById(journalRequestDTO.getUserId());
        if (userOptional.isEmpty()) {
            throw new RuntimeException("User not found with ID: " + journalRequestDTO.getUserId());
        }
        User user = userOptional.get();

        Journal journal = new Journal();
        journal.setContent(journalRequestDTO.getContent());
        journal.setUser(user);
        journal.setTitle("Journal Entry - " + LocalDate.now()); // Default title
        journal.setCreatedAt(LocalDateTime.now());

        return journalRepository.save(journal);
    }
    
    public Journal saveJournal(Journal journal) {
        return journalRepository.save(journal);
    }

    public void deleteJournal(Long id) {
        journalRepository.deleteById(id);
    }
}
