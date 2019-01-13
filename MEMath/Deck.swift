//
//  Deck.swift
//  MEMath
//
//  Created by Jelena on 08/01/2019.
//  Copyright © 2019 Jelena. All rights reserved.
//

import Foundation

class Deck {
    
    // number of combos:
    var difficulty: Difficulty;
    var operations: [Operation] = [];
    var cards: [Card] = [];
    
    init(level: Difficulty, operations: [Operation]) {
        self.difficulty = level;
        self.operations = operations;
        createCombos();
    }
    
    // create combinations (Q&A) for the game cards:
    func createCombos() {
        for _ in 1 ... difficulty.rawValue {
            let (que, ans) = getRandomNumbersAndResult();
            cards.append(Card(question: que, answer: ans));
        }
        
        // TODO - test:
        print(" ** cards:");
        for index in 0 ..< difficulty.rawValue {
            print(cards[index].question + "  ==  " + cards[index].answer);
        }
    }
    
    
    func getRandomNumbersAndResult() -> (question: String, answer: String) {
        // choose operation and range for numbers
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
    
    // randomly chooses the operation for 1 card:
    func chooseOperation() -> (operation: Operation, max: Int) {
        // choose random operation:
        let random = Int.random(in: 0 ..< operations.count);
        let op = operations[random];
        
        // +/- = numbers up to 100
        // *// = numbers up to 20
        switch op {
        case .addition, .subtraction:
            return (op, 100);
        case .multiplication, .division:
            return (op, 20);
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
            
            // TODO - dividing by zero:
            if (y == 0) {
                print ("dividing by zero!");
                return nil;
            }
            if (x % y != 0) {
                return nil;
            }
            result = x / y;
        }
        
        for index in 0 ..< cards.count {
            // go through each one and check their results
            if (Int(cards[index].answer) == result) {
                print("The result already exists: " + String(result!));
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
        // TODO - easy as TEST
        case easy = 1;
        // case easy = 3;
        case medium = 6;
        case hard = 12;
    }
 
}
