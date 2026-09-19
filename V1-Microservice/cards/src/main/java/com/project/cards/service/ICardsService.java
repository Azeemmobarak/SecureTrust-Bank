package com.project.cards.service;

import com.project.cards.dto.CardsDTO;

public interface ICardsService {

    void createCard(String mobileNumber);

    CardsDTO fetchCard(String mobileNumber);

    boolean updateCard(CardsDTO cardsDTO);

    boolean deleteCard(String mobileNumber);
}
