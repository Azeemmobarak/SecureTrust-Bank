package com.project.accounts.dto;

import io.swagger.v3.oas.annotations.media.Schema;
import lombok.AllArgsConstructor;
import lombok.Data;

@Data
@AllArgsConstructor
@Schema(
        name = "Response",
        description = "Schema to hold successful Response Information"
)

public class ResponseDTO {

    @Schema(
            description = "Status code in the Response"
    )
    private String statusCode;

    @Schema(
            description = "Status message in the Response"
    )
    private String statusMessage;
}
