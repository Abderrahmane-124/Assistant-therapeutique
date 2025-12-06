package com.example.assistant_therapeutique.dto;

public class ChatMessageRequestDTO {
    private Long senderId;
    private Long conversationId;
    private String content;

    // Constructors
    public ChatMessageRequestDTO() {
    }

    public ChatMessageRequestDTO(Long senderId, Long conversationId, String content) {
        this.senderId = senderId;
        this.conversationId = conversationId;
        this.content = content;
    }

    // Getters and Setters
    public Long getSenderId() {
        return senderId;
    }

    public void setSenderId(Long senderId) {
        this.senderId = senderId;
    }

    public Long getConversationId() {
        return conversationId;
    }

    public void setConversationId(Long conversationId) {
        this.conversationId = conversationId;
    }

    public String getContent() {
        return content;
    }

    public void setContent(String content) {
        this.content = content;
    }
}
