package com.example.assistant_therapeutique.service;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.HttpEntity;
import org.springframework.http.HttpHeaders;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Service;
import org.springframework.web.client.RestTemplate;

import java.util.HashMap;
import java.util.Map;

@Service
public class AiService {
    
    @Value("${ai.service.url:http://localhost:8000}")
    private String aiServiceUrl;
    
    private final RestTemplate restTemplate = new RestTemplate();
    
    /**
     * Get AI response from the FastAPI server
     * @param userMessage The user's message
     * @return AI generated response
     */
    public String getAiResponse(String userMessage) {
        try {
            HttpHeaders headers = new HttpHeaders();
            headers.setContentType(MediaType.APPLICATION_JSON);
            
            Map<String, Object> requestBody = new HashMap<>();
            requestBody.put("message", userMessage);
            requestBody.put("max_tokens", 200);
            requestBody.put("temperature", 0.4);
            
            HttpEntity<Map<String, Object>> request = new HttpEntity<>(requestBody, headers);
            
            ResponseEntity<Map> response = restTemplate.postForEntity(
                aiServiceUrl + "/chat",
                request,
                Map.class
            );
            
            if (response.getStatusCode().is2xxSuccessful() && response.getBody() != null) {
                Map<String, Object> responseBody = response.getBody();
                return (String) responseBody.get("response");
            } else {
                return "Je suis désolé, je ne peux pas répondre pour le moment. Veuillez réessayer.";
            }
            
        } catch (Exception e) {
            System.err.println("Error calling AI API: " + e.getMessage());
            return "Je suis désolé, une erreur s'est produite. Veuillez réessayer plus tard.";
        }
    }
    
    /**
     * Check if AI service is available
     * @return true if AI service is running
     */
    public boolean isAiServiceAvailable() {
        try {
            ResponseEntity<Map> response = restTemplate.getForEntity(
                aiServiceUrl + "/health",
                Map.class
            );
            return response.getStatusCode().is2xxSuccessful();
        } catch (Exception e) {
            return false;
        }
    }
}
