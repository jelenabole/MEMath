//
//  GameController.swift
//  MEMath
//
//  Created by Jelena on 07/01/2019.
//  Copyright © 2019 Jelena. All rights reserved.
//

import UIKit

class GameController: UIViewController {

    // test variables:
    var test = 0;
    
    @IBOutlet weak var upperView: UIStackView!
    @IBOutlet weak var cardsView: UIView!
    
    // timer:
    @IBOutlet weak var timerLabel: UILabel!
    @IBOutlet weak var flipsLabel: UILabel!
    
    // TODO - check - array of buttons:
    var cards = [UIButton]();
    var combos: Int = 0;
    var currentCardFlippedIndex: Int?;
    var cardsArray: [String] = [];
    
    var flippedCards: Int = 0 {
        didSet {
            // write number of combinations instead:
            flipsLabel.text = "Tries: \(flippedCards)";
        }
    };
    
    // variables for counting cards:
    var timer: Timer?;
    var secondsPassed: Int = 0 {
        didSet {
            let min: Int = secondsPassed / 60;
            let sec: Int = secondsPassed - (min * 60);
            
            var passed: String = "\(min):";
            if (sec < 10) {
                passed += "0";
            }
            passed += "\(sec)";
            
            timerLabel.text = String(passed);
        }
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad();
        
        // get this info from the view before (config):
        let numberOfPairs = 6;
        combos = numberOfPairs;
        // create 2 objects (pairs = Q&A)
        // shuffle values to array (use object index % 2)
        cardsArray = ["2+2", "4", "2+3", "5", "7", "8",
                      "9", "10", "12", "12", "13", "14"];
        
        // for 2 combinations = 4 cards:
        // upperView.frame = CGRectMake(0, 0, self.view.frame.width, CGFloat(partHeight * 2));
        createButtons(for: numberOfPairs);
        
        startTimer();
    }
    
    func startTimer() {
        timer = Timer(timeInterval: 1, repeats: true) {
            [weak self] _ in self?.secondsPassed += 1;
        }
        RunLoop.current.add(timer!, forMode: RunLoop.Mode.common);
    }
    func stopTimer() {
        timer?.invalidate();
    }
    func restartTimer() {
        // TODO - check if the timer needs to be initialized
        timer?.fire();
    }
    
    
    func createButtons(for pairs: Int) {
        // get size of a parent:
        let parentWidth = Int(cardsView.frame.width);
        let parentHeight = Int(cardsView.frame.height);
        
        // TODO - calculate how much cards will be in each row/column:
        let cardsInRow = 3;
        let cardsInColumn = 4;
        
        print("parent size: \(parentWidth) + \(parentHeight)");
        
        // divide on the number of cards:
        // calculate size by the smaller scale (either by the screen width or height)
        var cardSize = Int(parentWidth / cardsInRow);
        if (cardSize > parentHeight / cardsInColumn) {
            cardSize = Int(parentHeight / cardsInColumn);
        }
        
        // 1/10 of padding on each side:
        let padding = cardSize / 10;
        cardSize = cardSize - padding;
        
        print("card size: \(cardSize) - padding: \(padding)");
        
        // start values:
        var x, y: Int;
        
        var index = 0;
        y = padding / 2;
        for ind in 1...cardsInColumn {
            x = padding / 2;
            // add cards to this row:
            for jnd in 1...cardsInRow {
                let button = UIButton(type: .system);
                button.frame = CGRect(x: x, y: y, width: cardSize, height: cardSize);
                button.backgroundColor = #colorLiteral(red: 0, green: 0.5898008943, blue: 1, alpha: 1);
                button.tintColor = #colorLiteral(red: 0, green: 0.5898008943, blue: 1, alpha: 1);
                button.setTitle(String(cardsArray[index]), for: .normal);
                index += 1;
                button.setTitle(String(ind) + " - " + String(jnd), for: .normal);
                button.addTarget(self, action: #selector(buttonClicked), for: .touchUpInside);
                cards.append(button);
                cardsView.addSubview(button);
                
                // TODO - add text to the card
                
                x += cardSize + padding;
            }
            y += cardSize + padding;
        }
        
    }
    
    // GAME -- AFTER START
    
    @objc func buttonClicked(sender: UIButton!) {
        // button (card) touched
        let cardIndex = cards.firstIndex(of: sender)!;
        print("** card touched - index: \(String(describing: cardIndex))");
        
        // if its not currently turned around card, then turn it around
        // if there is already one card turned, check and wait 2 seconds
        // .. either flip them back, and delete currentFlipped
        // .. or disable touch on both cards, and let them be flipped
        
        // check if one card is already opened (or NIL):
        if let currentIndex = currentCardFlippedIndex {
            if (currentIndex == cardIndex) {
                // clicked on the same card (already opened and active)
                return;
            }
            openCard(on: sender);
            
            print("second card");
            // check if those cards match:
            print("check index: \(cardIndex) and \(currentCardFlippedIndex)");
            let cardsSame: Bool = checkPair(first: cardIndex, second: currentIndex);
            
            // TODO - wait for 2sec, then continue the app
            print("wait 2 sec");
            Timer.scheduledTimer(
                timeInterval: 0.9,
                target: self,
                selector: #selector(countdown),
                userInfo: nil,
                repeats: true);
            
            if (cardsSame) {
                // stay opened, disable touch on them:
                disableButton(on: cardIndex);
                disableButton(on: currentCardFlippedIndex!);
                
                
                isGameFinished();
            } else {
                closeCard(on: cardIndex);
                closeCard(on: currentCardFlippedIndex!);
            }
            
            flippedCards += 1;
            currentCardFlippedIndex = nil;
        } else {
            print("first card");
            openCard(on: sender);
            currentCardFlippedIndex = cardIndex;
        }
        
        // .. not same? - wait for few seconds, return positions and restart turn
        // .. same? - stay opened, add points (?) & sign, if last cards = finish game!
        // .. if no, just open it
        
    }
    
    // finished game:
    func isGameFinished() {
        // check if all cards are turned:
        if (flippedCards == combos) {
            stopTimer();
        }
    }
    
    // forwards time by 1 sec - used for
    var counter = 2;
    @objc func countdown() {
        if counter > 0 {
            counter -= 1;
        }
    }
    
    
    // checks if cards on given indexes are the same
    func checkPair(first x: Int, second y: Int) -> Bool {
        // check if those cards are the same (cardArray on those indexes)
        // TODO
        return true;
    }
    
    
    // disables touch on a button
    func  disableButton(on index: Int) {
        cards[index].isEnabled = false;
    }
    
    
    func closeCard(on index: Int) {
        print("close card: \(index)");
        cards[index].backgroundColor = #colorLiteral(red: 0, green: 0.5898008943, blue: 1, alpha: 1);
    }
    
    func openCard(on button: UIButton) {
        // TODO - for now - check by the color of the button,and change it (text same color)
        print("open card");
        // button.backgroundColor = #colorLiteral(red: 0.2745098174, green: 0.4862745106, blue: 0.1411764771, alpha: 1);
        button.setTitleColor(.black, for: .normal);
        
        button.backgroundColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0);
    }
    
    
    
    
}
