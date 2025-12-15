package com.example.assistant_therapeutique.controller;

import com.example.assistant_therapeutique.dto.JournalRequestDTO;
import com.example.assistant_therapeutique.model.Journal;
import com.example.assistant_therapeutique.service.JournalService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Optional;

@RestController
@RequestMapping("/api/journals")
public class JournalController {

    @Autowired
    private JournalService journalService;

    @GetMapping("/user/{userId}")
    public List<Journal> getJournalsByUserId(@PathVariable Long userId) {
        return journalService.getJournalsByUserId(userId);
    }

    @GetMapping("/{id}")
    public ResponseEntity<Journal> getJournalById(@PathVariable Long id) {
        Optional<Journal> journal = journalService.getJournalById(id);
        return journal.map(ResponseEntity::ok)
                .orElseGet(() -> ResponseEntity.notFound().build());
    }

    @PostMapping
    public ResponseEntity<Journal> createJournal(@RequestBody JournalRequestDTO journalRequestDTO) {
        Journal savedJournal = journalService.createJournalEntry(journalRequestDTO);
        return new ResponseEntity<>(savedJournal, HttpStatus.CREATED);
    }

    @PutMapping("/{id}")
    public ResponseEntity<Journal> updateJournal(@PathVariable Long id, @RequestBody Journal journalDetails) {
        Optional<Journal> optionalJournal = journalService.getJournalById(id);
        if (optionalJournal.isPresent()) {
            Journal journal = optionalJournal.get();
            journal.setTitle(journalDetails.getTitle());
            journal.setContent(journalDetails.getContent());
            Journal updatedJournal = journalService.saveJournal(journal);
            return ResponseEntity.ok(updatedJournal);
        } else {
            return ResponseEntity.notFound().build();
        }
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<Void> deleteJournal(@PathVariable Long id) {
        journalService.deleteJournal(id);
        return ResponseEntity.noContent().build();
    }
}
