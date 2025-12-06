package com.example.assistant_therapeutique.dto;

public class JournalRequestDTO {
    private String content;
    private Long userId;

    // Constructors
    public JournalRequestDTO() {
    }

    public JournalRequestDTO(String content, Long userId) {
        this.content = content;
        this.userId = userId;
    }

    // Getters and Setters
    public String getContent() {
        return content;
    }

    public void setContent(String content) {
        this.content = content;
    }

    public Long getUserId() {
        return userId;
    }

    public void setUserId(Long userId) {
        this.userId = userId;
    }
}
