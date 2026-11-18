package com.securetrust.accounts.service.client;

import com.securetrust.accounts.dto.LoansDto;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.RequestHeader;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.service.annotation.GetExchange;
import org.springframework.web.service.annotation.HttpExchange;

@HttpExchange("/api")
public interface LoansClient {

    @GetExchange(value = "/fetch", accept = "application/json")
    ResponseEntity<LoansDto> fetchLoanDetails(@RequestHeader("securetrustbank-correlation-id") String correlationId,
                                              @RequestParam String mobileNumber);
}