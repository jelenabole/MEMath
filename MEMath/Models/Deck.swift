//
//  Deck.swift
//  MEMath
//
//  Created by Jelena on 08/01/2019.
//  Copyright © 2019 Jelena. All rights reserved.
//

import Foundation

class Deck {
    
    var difficulty: Difficulty;
    var operations: [Operation] = [];
    var cards: [Card] = [];
    
    // additional info:
    var numberOfPairs: Int;
    var numberOfCards: Int;
    
    init(level: Difficulty, operations: [Operation]) {
        self.difficulty = level;
        self.operations = operations;
        self.numberOfPairs = level.rawValue;
        self.numberOfCards = self.numberOfPairs * 2;
        createCombos();
    }
    
    // create combinations (Q&A) for the game cards:
    func createCombos() {
        for _ in 1 ... difficulty.rawValue {
            let (que, ans) = getRandomNumbersAndResult();
            cards.append(Card(question: que, answer: ans));
        }
    }
    
    func getRandomNumbersAndResult() -> (question: String, answer: String) {
        // choose operation and range of numbers
        let (operation, max) = chooseOperation();
        
        var x: Int?;
        var y: Int?;
        var result: Int?;
        
        // loop until adequate numbers are found:
        while (result == nil) {
            x = Int.random(in: 0 ... max);
            y = Int.random(in: 0 ... max);
            
            result = checkPairResult(&x!, &y!, operation: operation);
        }
        
        return (String(x!) + operation.rawValue + String(y!), String(result!));
    }
    
    // chose random operation:
    func chooseOperation() -> (operation: Operation, max: Int) {
        let random = Int.random(in: 0 ..< operations.count);
        let op = operations[random];
        
        // +/- = numbers up to 100
        // *// = numbers up to 20
        switch op {
        case .addition, .subtraction:
            return (op, 50);
        case .multiplication, .division:
            return (op, 10);
        }
    }
    
    func checkPairResult(_ x: inout Int,_ y: inout Int, operation op: Operation) -> Int? {
        var result: Int?;
        
        switch op {
        case .addition:
            result = x + y;
        case .subtraction:
            changeToSmallerFirst(&x, &y);
            result = x - y;
        case .multiplication:
            result = x * y;
        case .division:
            changeToSmallerFirst(&x, &y);
            
            if (y == 0) {
                return nil;
            }
            if (x % y != 0) {
                return nil;
            }
            result = x / y;
        }
        
        // check existing results (cant be equal):
        for index in 0 ..< cards.count {
            if (Int(cards[index].answer) == result) {
                return nil;
            }
        }
        
        return result;
    }
    
    func changeToSmallerFirst (_ x: inout Int, _ y: inout Int) {
        if (x < y) {
            let temp = x;
            x = y;
            y = temp;
        }
    }
    
    
    
    class Card {
        var question: String;
        var answer: String;
        
        init (question: String, answer: String) {
            self.question = question;
            self.answer = answer;
        }
    }
    
    enum Operation: String {
        case addition = " + "
        case subtraction = " - "
        case multiplication = " * "
        case division = " / "
    }
    
    // number of pairs (cards: 6, 12, 30)
    enum Difficulty: Int {
        case test = 1;
        case easy = 3;
        case medium = 6;
        case hard = 12;
    }
 
}
