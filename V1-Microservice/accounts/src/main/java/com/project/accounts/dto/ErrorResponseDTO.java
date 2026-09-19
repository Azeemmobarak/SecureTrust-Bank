package com.project.accounts.dto;

import io.swagger.v3.oas.annotations.media.Schema;
import lombok.AllArgsConstructor;
import lombok.Data;
import org.springframework.http.HttpStatus;

import java.time.LocalDateTime;

@Data
@AllArgsConstructor
@Schema(
        name = "Error Response",
        description = "Schema to hold Error Response Information"
)
public class ErrorResponseDTO {

    @Schema(
            description = "API Path invoked by Client"
    )
    private String apiPath;

    @Schema(
            description = "Error code representing the Error happened"
    )
    private HttpStatus errorCode;

    @Schema(
            description = "Error message representing the Error happened"
    )
    private String errorMessage;

    @Schema(
            description = "Time representing when the Error happened"
    )
    private LocalDateTime errorTime;
}
