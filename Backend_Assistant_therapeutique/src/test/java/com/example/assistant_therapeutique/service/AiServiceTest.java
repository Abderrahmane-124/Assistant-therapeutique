package com.example.assistant_therapeutique.service;

import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;
import org.springframework.http.HttpEntity;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.test.util.ReflectionTestUtils;
import org.springframework.web.client.RestClientException;
import org.springframework.web.client.RestTemplate;

import java.util.HashMap;
import java.util.Map;

import static org.assertj.core.api.Assertions.assertThat;
import static org.mockito.ArgumentMatchers.*;
import static org.mockito.Mockito.*;

/**
 * Tests unitaires pour AiService
 * Couvre : appel API réussi, gestion erreurs, vérification disponibilité
 */
@ExtendWith(MockitoExtension.class)
class AiServiceTest {

    @Mock
    private RestTemplate restTemplate;

    @InjectMocks
    private AiService aiService;

    private static final String AI_SERVICE_URL = "http://15.236.232.37:8000";

    @BeforeEach
    void setUp() {
        ReflectionTestUtils.setField(aiService, "restTemplate", restTemplate);
        ReflectionTestUtils.setField(aiService, "aiServiceUrl", AI_SERVICE_URL);
    }

    @Test
    @DisplayName("getAiResponse - réponse réussie")
    void getAiResponse_WhenSuccessful_ShouldReturnResponse() {
        Map<String, Object> responseBody = new HashMap<>();
        responseBody.put("response", "Bonjour!");
        ResponseEntity<Map> response = new ResponseEntity<>(responseBody, HttpStatus.OK);

        when(restTemplate.postForEntity(eq(AI_SERVICE_URL + "/chat"), any(HttpEntity.class), eq(Map.class)))
                .thenReturn(response);

        String result = aiService.getAiResponse("Salut");

        assertThat(result).isEqualTo("Bonjour!");
    }

    @Test
    @DisplayName("getAiResponse - erreur serveur -> message d'erreur")
    void getAiResponse_WhenServerError_ShouldReturnErrorMessage() {
        ResponseEntity<Map> response = new ResponseEntity<>(null, HttpStatus.INTERNAL_SERVER_ERROR);

        when(restTemplate.postForEntity(eq(AI_SERVICE_URL + "/chat"), any(HttpEntity.class), eq(Map.class)))
                .thenReturn(response);

        String result = aiService.getAiResponse("Salut");

        assertThat(result).contains("désolé");
    }

    @Test
    @DisplayName("getAiResponse - exception réseau -> message d'erreur")
    void getAiResponse_WhenNetworkError_ShouldReturnErrorMessage() {
        when(restTemplate.postForEntity(eq(AI_SERVICE_URL + "/chat"), any(HttpEntity.class), eq(Map.class)))
                .thenThrow(new RestClientException("Connection refused"));

        String result = aiService.getAiResponse("Salut");

        assertThat(result).contains("erreur");
    }

    @Test
    @DisplayName("isAiServiceAvailable - service disponible")
    void isAiServiceAvailable_WhenAvailable_ShouldReturnTrue() {
        ResponseEntity<Map> response = new ResponseEntity<>(new HashMap<>(), HttpStatus.OK);

        when(restTemplate.getForEntity(eq(AI_SERVICE_URL + "/health"), eq(Map.class)))
                .thenReturn(response);

        boolean result = aiService.isAiServiceAvailable();

        assertThat(result).isTrue();
    }

    @Test
    @DisplayName("isAiServiceAvailable - service indisponible")
    void isAiServiceAvailable_WhenUnavailable_ShouldReturnFalse() {
        when(restTemplate.getForEntity(eq(AI_SERVICE_URL + "/health"), eq(Map.class)))
                .thenThrow(new RestClientException("Connection refused"));

        boolean result = aiService.isAiServiceAvailable();

        assertThat(result).isFalse();
    }
}
