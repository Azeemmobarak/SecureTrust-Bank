package com.project.accounts.dto;

import io.swagger.v3.oas.annotations.media.Schema;
import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.NotEmpty;
import jakarta.validation.constraints.Pattern;
import jakarta.validation.constraints.Size;
import lombok.Data;

@Data
@Schema(
        name = "Customer",
        description = "Schema to hold Customer and Account Information"
)
public class CustomerDTO {
    @Schema(
            description = "Name of the Customer", example = "Joy Martin"
    )
    @NotEmpty(message = "Name can not be null or empty.")
    @Size(min = 5, max = 30, message = "The length of the customer name should be between 5 and 30.")
    private String name;

    @Schema(
            description = "Email Address of the Customer", example = "martinjoy@gmail.com"
    )
    @NotEmpty(message = "Email Address can not be null or empty.")
    @Email(message = "Email Address should be a valid value.")
    private String email;

    @Schema(
            description = "Mobile Number of the Customer", example = "7824596301"
    )
    @Pattern(regexp = "(^$|[0-9]{10})", message = "Mobile Number must be  10 digits.")
    private String mobileNumber;

    @Schema(
            description = "Account Details of the Customer"
    )
    private AccountsDTO accountsDTO;
}
