package com.securetrust.accounts.service.client;

import com.securetrust.accounts.dto.CardsDto;
import org.springframework.cloud.client.circuitbreaker.httpservice.HttpServiceFallback;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Component;

@Component
@HttpServiceFallback(value = CardsFallback.class, group = "cards")
public class CardsFallback {

    public ResponseEntity<CardsDto> fetchCardDetails(String correlationId, String mobileNumber) {
        return null;
    }
}