package com.securetrust.accounts;

import com.securetrust.accounts.dto.AccountsContactInfoDto;
import com.securetrust.accounts.service.client.CardsClient;
import com.securetrust.accounts.service.client.LoansClient;
import io.swagger.v3.oas.annotations.ExternalDocumentation;
import io.swagger.v3.oas.annotations.OpenAPIDefinition;
import io.swagger.v3.oas.annotations.info.Contact;
import io.swagger.v3.oas.annotations.info.Info;
import io.swagger.v3.oas.annotations.info.License;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.boot.context.properties.EnableConfigurationProperties;
import org.springframework.data.jpa.repository.config.EnableJpaAuditing;
import org.springframework.web.service.registry.ImportHttpServices;

@SpringBootApplication
@ImportHttpServices(group = "loans", types = LoansClient.class)
@ImportHttpServices(group = "cards", types = CardsClient.class)
@EnableJpaAuditing(auditorAwareRef = "auditAwareImpl")
@EnableConfigurationProperties(value = {AccountsContactInfoDto.class})
@OpenAPIDefinition(
        info = @Info(
                title = "Accounts microservice REST API Documentation",
                description = "SecureTrust Bank Accounts microservice REST API Documentation",
                version = "v1",
                contact = @Contact(
                        name = "Azeem Mobarak",
                        email = "azeemmubarak.29@gmail.com"

                ),
                license = @License(
                        name = "Apache 2.0"
                )
        ),
        externalDocs = @ExternalDocumentation(
                description = "SecureTrust Bank Accounts microservice REST API Documentation"
        )
)
public class AccountsApplication {

    static void main(String[] args) {
        SpringApplication.run(AccountsApplication.class, args);
    }

}
