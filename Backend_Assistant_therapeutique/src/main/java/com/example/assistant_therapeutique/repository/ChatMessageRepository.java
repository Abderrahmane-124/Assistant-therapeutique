package com.example.assistant_therapeutique.repository;

import com.example.assistant_therapeutique.model.ChatMessage;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface ChatMessageRepository extends JpaRepository<ChatMessage, Long> {
    List<ChatMessage> findBySenderId(Long senderId);
    List<ChatMessage> findByConversationId(Long conversationId);
}
