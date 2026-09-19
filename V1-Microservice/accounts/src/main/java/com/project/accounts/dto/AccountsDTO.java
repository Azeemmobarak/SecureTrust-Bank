package com.project.accounts.dto;

import io.swagger.v3.oas.annotations.media.Schema;
import jakarta.validation.constraints.NotEmpty;
import jakarta.validation.constraints.Pattern;
import lombok.Data;

@Data
@Schema(
        name = "Accounts",
        description = "Schema to hold Account Information"
)
public class AccountsDTO {
    @Schema(
            description = "Account Number of SecureTrust Bank", example = "6475210039"
    )
    @NotEmpty(message = "Account number can not be null or empty.")
    @Pattern(regexp = "(^$|[0-9]{10})", message = "Account Number must be 10 digits.")
    private Long accountNumber;

    @Schema(
            description = "Account type of SecureTrust Bank", example = "Saving"
    )
    @NotEmpty(message = "Account type can not be null or empty.")
    private String accountType;

    @Schema(
            description = "Branch address of SecureTrust Bank", example = "123 New York City"
    )
    @NotEmpty(message = "Branch Address can not be null or empty.")
    private String branchAddress;
}
