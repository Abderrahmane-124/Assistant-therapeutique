package com.example.assistant_therapeutique.model;

import javax.persistence.*;
import java.time.LocalDateTime;
import java.util.List; // Import List

@Entity
public class Conversation {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    private String titre; // Title of the conversation

    @ManyToOne
    @JoinColumn(name = "user_id", nullable = false)
    private User user; // The user who owns this conversation

    private LocalDateTime createdAt;

    @OneToMany(mappedBy = "conversation", cascade = CascadeType.ALL, orphanRemoval = true)
    private List<ChatMessage> messages; // List of messages in this conversation

    // Constructors
    public Conversation() {
    }

    public Conversation(String titre, User user, LocalDateTime createdAt) {
        this.titre = titre;
        this.user = user;
        this.createdAt = createdAt;
    }

    // Getters and Setters
    public Long getId() {
        return id;
    }

    public void setId(Long id) {
        this.id = id;
    }

    public String getTitre() {
        return titre;
    }

    public void setTitre(String titre) {
        this.titre = titre;
    }

    public User getUser() {
        return user;
    }

    public void setUser(User user) {
        this.user = user;
    }

    public LocalDateTime getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(LocalDateTime createdAt) {
        this.createdAt = createdAt;
    }

    public List<ChatMessage> getMessages() {
        return messages;
    }

    public void setMessages(List<ChatMessage> messages) {
        this.messages = messages;
    }
}
