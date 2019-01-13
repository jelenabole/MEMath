//
//  GameController.swift
//  MEMath
//
//  Created by Jelena on 07/01/2019.
//  Copyright © 2019 Jelena. All rights reserved.
//

import UIKit
import CoreData

class GameController: UIViewController {
    
    // passed arguments:
    var argDifficulty: Deck.Difficulty = .hard;
    var argOperations: [Deck.Operation] = [];
    var argMaxScores: Int = 5;
    var playerResults: [PlayerResult] = [];
    var database: DatabaseResults!;
    
    // constants and global variabled:
    let basicColor = #colorLiteral(red: 0, green: 0.5603182912, blue: 0, alpha: 1);
    var cardsDisabled = true;
    let secondsToWait = 2.0;
    
    @IBOutlet weak var cardsView: UIView!
    @IBOutlet weak var timerLabel: UILabel!
    @IBOutlet weak var flipsLabel: UILabel!
    
    // TODO - check - array of buttons:
    var cards = [UIButton]();
    var myDeck: Deck?;
    var shuffledCardIndices: [Int] = [];
    var numberOfPairs: Int = 0;
    
    var currentCardFlippedIndex: Int?;
    var flippedPairs: Int = 0;
    var numberOfFlips: Int = 0 {
        didSet {
            // write number of combinations instead:
            flipsLabel.text = "Tries: \(numberOfFlips)";
        }
    };
    
    // variables for counting cards:
    var timer: Timer?;
    var secondsPassed: Int = 0 {
        didSet {
            timerLabel.text = String(convertToReadable(seconds: secondsPassed));
        }
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad();
        
        // argDifficulty = Deck.Difficulty.test;
        
        // global variable:
        myDeck = Deck(level: argDifficulty, operations: argOperations);
        
        // create an aray of cards and shuffle them:
        numberOfPairs = argDifficulty.rawValue;
        let numberOfDeckCards = numberOfPairs * 2;
        for index in 0 ..< numberOfDeckCards {
            shuffledCardIndices.append(index);
        }
        shuffledCardIndices.shuffle();
        
        // calculate number of cards by row and column:
        let (inRow, inColumn) = calcNumberOfCards(from: argDifficulty);
        createButtons(inRow, inColumn);
        
        // Start time with few seconds delay:
        let deadline = DispatchTime.now() + secondsToWait;
        DispatchQueue.main.asyncAfter(deadline: deadline) {
            self.startTimer();
        }
        
        
        
        
        // TODO - test the DB:
        let appDelegate = UIApplication.shared.delegate as! AppDelegate;
        let context = appDelegate.managedObjectContext;
        database = DatabaseResults(from: context, maxScores: argMaxScores);
        
        playerResults = database.getItems(for: argDifficulty);
    }
    
    func startTimer() {
        cardsDisabled = false;
        timer = Timer(timeInterval: 1, repeats: true) {
            [weak self] _ in self?.secondsPassed += 1;
        }
        RunLoop.current.add(timer!, forMode: RunLoop.Mode.common);
    }
    
    func stopTimer() {
        timer?.invalidate();
    }
    
    func createButtons(_ inRow: Int, _ inColumn: Int) {
        // get size of a parent:
        let parentWidth = Int(cardsView.frame.width);
        let parentHeight = Int(cardsView.frame.height);
        
        print("parent size: \(parentWidth) + \(parentHeight)");
        
        // divide on the number of cards:
        // calculate size by the smaller scale (either by the screen width or height)
        var cardSize = Int(parentWidth / inRow);
        if (cardSize > parentHeight / inColumn) {
            cardSize = Int(parentHeight / inColumn);
        }
        
        // 1/10 of padding on each side:
        let padding = cardSize / 10;
        cardSize = cardSize - padding;
        
        print("card size: \(cardSize) - padding: \(padding)");
        
        // start values:
        var x, y: Int;
        
        var index = 0;
        y = padding / 2;
        for _ in 1...inColumn {
            x = padding / 2;
            // add cards to this row:
            for _ in 1...inRow {
                let button = UIButton(type: .system);
                button.frame = CGRect(x: x, y: y, width: cardSize, height: cardSize);
                button.backgroundColor = basicColor;
                button.tintColor = basicColor;
                button.titleLabel?.font = UIFont(name: "Marker Felt", size: 22);
                
                // get value by the index in card array (question / answer):
                let cardIndex = shuffledCardIndices[index];
                let card = myDeck!.cards[(cardIndex / 2)];
                if (cardIndex % 2 == 0) {
                    button.setTitle(card.question, for: .normal);
                } else {
                    button.setTitle(card.answer, for: .normal);
                }
                index += 1;
                
                button.addTarget(self, action: #selector(cardClicked), for: .touchUpInside);
                cards.append(button);
                cardsView.addSubview(button);
                
                x += cardSize + padding;
            }
            y += cardSize + padding;
        }
        
    }
    
    
    // GAME -- AFTER START
    
    @objc func cardClicked(sender: UIButton!) {
        // button (card) touched
        if (cardsDisabled) {
            return;
        }
        let cardIndex = cards.firstIndex(of: sender)!;
        print("** card touched - open index: \(String(describing: cardIndex))");
        
        // check if one card is already opened (or NIL):
        if let currentIndex = currentCardFlippedIndex {
            if (currentIndex == cardIndex) {
                print("card already opened");
                // clicked on the same card (already opened and active)
                return;
            }
            print("second card opened");
            openCard(on: sender);
            
            // check if those cards match (indexes from same card):
            let cardsSame: Bool = checkPair(first: shuffledCardIndices[cardIndex], second: shuffledCardIndices[currentIndex]);
            
            // TODO - remove to another method
            let deadline = DispatchTime.now() + secondsToWait;
            cardsDisabled = true;
            DispatchQueue.main.asyncAfter(deadline: deadline) {
                self.checkCards(same: cardsSame, first: cardIndex, second: currentIndex);
            }
            
            numberOfFlips += 1;
            currentCardFlippedIndex = nil;
        } else {
            print("first card opened");
            openCard(on: sender);
            currentCardFlippedIndex = cardIndex;
        }
    }
    
    func checkCards(same cardsSame: Bool, first index1: Int, second index2: Int) {
        cardsDisabled = false;
        if (cardsSame) {
            print("PAIR FOUND");
            // stay opened, disable touch on them:
            disableButton(on: index1);
            disableButton(on: index2);
            
            flippedPairs += 1;
            isGameFinished();
        } else {
            print("pair wrong!");
            closeCard(on: index1);
            closeCard(on: index2);
        }
    }
    
    // checks if cards on given indexes are the same
    func checkPair(first x: Int, second y: Int) -> Bool {
        // TODO - check if both are truncated:
        print ("check pair: \(x / 2) - \(y / 2)");
        if ((x / 2) == (y / 2)) {
            return true;
        } else {
            return false;
        }
    }
    
    // checks if game is finished (all cards turned)
    func isGameFinished() {
        print("check if game finished: \(flippedPairs) - \(numberOfPairs)");
        if (flippedPairs == numberOfPairs) {
            print("GAME FINISHED");
            stopTimer();
            checkScores();
        }
    }
    
    func checkScores() {
        // create current player:
        let currentPlayer = PlayerResult(username: "***", time: convertToReadable(seconds: secondsPassed), points: secondsPassed, flips: numberOfFlips, difficulty: argDifficulty.rawValue);
        
        //check with last player, if he is on the list - choose the message and shove him in the list
        if (playerResults.count == 0 || secondsPassed < playerResults.last!.points) {
            
            // create a list of player to show (max 5)
            var list: [PlayerResult] = [];
            var currentPlayerIndex : Int = 0;
            argMaxScores = playerResults.count < argMaxScores ? playerResults.count : argMaxScores;
            
            var iresults = 0;
            for ilist in 0 ..< argMaxScores {
                if (iresults == ilist) {
                    if (currentPlayer.points < playerResults[iresults].points) {
                        list.append(currentPlayer);
                        currentPlayerIndex = ilist;
                    } else {
                        list.append(playerResults[iresults]);
                        iresults += 1;
                    }
                } else {
                    list.append(playerResults[iresults]);
                    iresults += 1;
                }
            }
            
            showSuccess(list: list, for: currentPlayerIndex);
        } else {
            showFailure();
        }
    }
    
    func showSuccess(list players: [PlayerResult], for playerIndex: Int) {
        var msg = "You finished the game in: \(timerLabel!.text!) \n";
        for player in players {
            msg += "\n \(player.username)  --  \(player.time)";
        }
        // DB data: username, time -- points, flips, difficulty
        
        // show current time and add text field:
        let alert = UIAlertController(title: "CONGRATS!!",
                                      message: msg,
            preferredStyle: .alert);
        alert.addTextField { (textField) in
            textField.placeholder = "Username"
        }
        
        alert.addAction(UIAlertAction(
            title: "Save", style: .default, handler: { [weak alert] (_) in
                self.database.save(item: players[playerIndex], as: (alert?.textFields![0].text)!)
                _ = self.navigationController?.popViewController(animated: true);
        }))
        
        self.present(alert, animated: true, completion: nil);
    }
    
    func showFailure() {
        let alert = UIAlertController(title: "SORRY!!",
                                      message: "Try better next time! Your time is: \(timerLabel!.text!)",
            preferredStyle: .alert);
        
        alert.addAction(UIAlertAction(
            title: "BACK", style: .default, handler: { [weak alert] (_) in
                _ = self.navigationController?.popViewController(animated: true);
        }))
        
        self.present(alert, animated: true, completion: nil);
    }
    
    
    
    
    
    
    // TODO - needed for counting the pause (between guesses)
    // forwards time by 1 sec - used for
    var counter = 2;
    @objc func countdown() {
        if counter > 0 {
            counter -= 1;
        }
    }
    
    
    
    
    
    
    
    func openCard(on button: UIButton) {
        // button.setTitleColor(.black, for: .normal);
        button.backgroundColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0);
    }
    
    func closeCard(on index: Int) {
        cards[index].backgroundColor = basicColor;
    }
    
    // disables touch on a button
    func  disableButton(on index: Int) {
        cards[index].isEnabled = false;
    }
    
}
