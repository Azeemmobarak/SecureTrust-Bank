package com.securetrust.accounts.service.impl;

import com.securetrust.accounts.dto.AccountsDto;
import com.securetrust.accounts.dto.CardsDto;
import com.securetrust.accounts.dto.CustomerDetailsDto;
import com.securetrust.accounts.dto.LoansDto;
import com.securetrust.accounts.entity.Accounts;
import com.securetrust.accounts.entity.Customer;
import com.securetrust.accounts.exception.ResourceNotFoundException;
import com.securetrust.accounts.mapper.AccountsMapper;
import com.securetrust.accounts.mapper.CustomerMapper;
import com.securetrust.accounts.repository.AccountsRepository;
import com.securetrust.accounts.repository.CustomerRepository;
import com.securetrust.accounts.service.ICustomersService;
import com.securetrust.accounts.service.client.CardsClient;
import com.securetrust.accounts.service.client.LoansClient;
import lombok.AllArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Service;

@Service
@AllArgsConstructor
public class CustomersServiceImpl implements ICustomersService {

    private AccountsRepository accountsRepository;
    private CustomerRepository customerRepository;
    private CardsClient cardsClient;
    private LoansClient loansClient;


    @Override
    public CustomerDetailsDto fetchCustomerDetails(String mobileNumber) {
        Customer customer = customerRepository.findByMobileNumber(mobileNumber).orElseThrow(
                () -> new ResourceNotFoundException("Customer", "mobileNumber", mobileNumber)
        );
        Accounts accounts = accountsRepository.findByCustomerId(customer.getCustomerId()).orElseThrow(
                () -> new ResourceNotFoundException("Account", "customerId", customer.getCustomerId().toString())
        );

        CustomerDetailsDto customerDetailsDto = CustomerMapper.mapToCustomerDetailsDto(customer, new CustomerDetailsDto());
        customerDetailsDto.setAccountsDto(AccountsMapper.mapToAccountsDto(accounts, new AccountsDto()));

        ResponseEntity<LoansDto> loansDtoResponseEntity = loansClient.fetchLoanDetails(mobileNumber);
        customerDetailsDto.setLoansDto(loansDtoResponseEntity.getBody());

        ResponseEntity<CardsDto> cardsDtoResponseEntity = cardsClient.fetchCardDetails(mobileNumber);
        customerDetailsDto.setCardsDto(cardsDtoResponseEntity.getBody());

        return customerDetailsDto;

    }
}
