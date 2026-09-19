package com.project.loans.service;

import com.project.loans.dto.LoansDTO;

public interface ILoansService {

    void createLoan(String mobileNumber);

    LoansDTO fetchLoan(String mobileNumber);

    boolean updateLoan(LoansDTO loansDto);

    boolean deleteLoan(String mobileNumber);

}
