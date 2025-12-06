package com.example.assistant_therapeutique.dto;

public class ConversationRequestDTO {
    private String titre;
    private Long userId;

    // Constructors
    public ConversationRequestDTO() {
    }

    public ConversationRequestDTO(String titre, Long userId) {
        this.titre = titre;
        this.userId = userId;
    }

    // Getters and Setters
    public String getTitre() {
        return titre;
    }

    public void setTitre(String titre) {
        this.titre = titre;
    }

    public Long getUserId() {
        return userId;
    }

    public void setUserId(Long userId) {
        this.userId = userId;
    }
}
