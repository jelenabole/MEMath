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
    var cardsDisabled = true;
    
    let basicColor = #colorLiteral(red: 0, green: 0.5603182912, blue: 0, alpha: 1);
    let secondsBetweenTurns = 2.0;
    let secondsToStart = 5.0;
    
    @IBOutlet weak var readyLabel: UILabel!
    @IBOutlet weak var cardsView: UIView!
    @IBOutlet weak var timerLabel: UILabel!
    @IBOutlet weak var flipsLabel: UILabel!
    
    var cards = [UIButton]();
    var myDeck: Deck!;
    var shuffledCardIndices: [Int] = [];
    
    // vars for counting cards:
    var currentCardFlippedIndex: Int?;
    var flippedPairs: Int = 0;
    var numberOfFlips: Int = 0 {
        didSet {
            flipsLabel.text = "Tries: \(numberOfFlips)";
        }
    };
    
    // vars for time:
    var timer: Timer?;
    var secondsPassed: Int = 0 {
        didSet {
            timerLabel.text = String(convertToReadable(seconds: secondsPassed));
            
            // end long game:
            if (secondsPassed == (argDifficulty.rawValue * 30)) {
                stopTimer();
                openAllCards();
                showFailure();
            }
        }
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad();
        
        // argDifficulty = Deck.Difficulty.test;
        myDeck = Deck(level: argDifficulty, operations: argOperations);
        
        // create an aray of cards and shuffle them:
        for index in 0 ..< myDeck.numberOfCards {
            shuffledCardIndices.append(index);
        }
        shuffledCardIndices.shuffle();
        
        // get number of cards by row and column:
        let (inRow, inColumn) = getCardsByRowAndColumn(from: argDifficulty);
        createButtons(inRow, inColumn);
        
        // start time with few seconds delay:
        let deadline = DispatchTime.now() + secondsToStart;
        DispatchQueue.main.asyncAfter(deadline: deadline) {
            self.startTimer();
        }
        
        // DB repo:
        let appDelegate = UIApplication.shared.delegate as! AppDelegate;
        let context = appDelegate.managedObjectContext;
        database = DatabaseResults(from: context, maxScores: argMaxScores);
        playerResults = database.getItems(for: argDifficulty);
    }
    
    func startTimer() {
        cardsDisabled = false;
        readyLabel.removeFromSuperview();
        timer = Timer(timeInterval: 1, repeats: true) {
            [weak self] _ in self?.secondsPassed += 1;
        }
        RunLoop.current.add(timer!, forMode: RunLoop.Mode.common);
    }
    
    func stopTimer() {
        timer?.invalidate();
    }
    
    func createButtons(_ inRow: Int, _ inColumn: Int) {
        let parentWidth = Int(cardsView.frame.width);
        let parentHeight = Int(cardsView.frame.height);
        // print("parent size: \(parentWidth) + \(parentHeight)");
        
        // divide on the number of cards (by width or height - smaller size):
        var cardSize = Int(parentWidth / inRow);
        if (cardSize > parentHeight / inColumn) {
            cardSize = Int(parentHeight / inColumn);
        }
        
        // 1/10 of padding on each side:
        let padding = cardSize / 10;
        cardSize = cardSize - padding;
        // print("card size: \(cardSize) - padding: \(padding)");
        
        // start values:
        var x, y: Int;
        
        var index = 0;
        y = padding / 2;
        for _ in 1...inColumn {
            x = padding / 2;
            
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
        
        // check if one card is already opened (or NIL):
        if let currentIndex = currentCardFlippedIndex {
            if (currentIndex == cardIndex) {
                print("card already opened");
                // clicked on the same card (already opened and active)
                return;
            }
            print("second card opened");
            openCard(on: sender);
            numberOfFlips += 1;
            
            // check if those cards match (indexes from same card):
            let cardsSame: Bool = checkPair(first: shuffledCardIndices[cardIndex], second: shuffledCardIndices[currentIndex]);
            cardsDisabled = true;
            
            if (cardsSame) {
                flippedPairs += 1;
                isGameFinished();
            }
            
            let deadline = DispatchTime.now() + secondsBetweenTurns;
            DispatchQueue.main.asyncAfter(deadline: deadline) {
                self.changeCardStatus(same: cardsSame, first: cardIndex, second: currentIndex);
            }
            
            currentCardFlippedIndex = nil;
        } else {
            print("first card opened");
            openCard(on: sender);
            currentCardFlippedIndex = cardIndex;
        }
    }
    
    // either disable the cards or turn them back down
    func changeCardStatus(same cardsSame: Bool, first index1: Int, second index2: Int) {
        cardsDisabled = false;
        if (cardsSame) {
            disableButton(on: index1);
            disableButton(on: index2);
        } else {
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
        if (flippedPairs == myDeck.numberOfPairs) {
            print("GAME FINISHED");
            stopTimer();
            checkScores();
        }
    }
    
    func checkScores() {
        // create current player:
        let currentPlayer = PlayerResult(username: " *** ", time: convertToReadable(seconds: secondsPassed), points: secondsPassed, flips: numberOfFlips, difficulty: argDifficulty.rawValue);
        
        // depending on a last player, decide which message to show:
        if (playerResults.count == 0 || secondsPassed < playerResults.last!.points) {
            
            // create a list of player to show (max 5)
            var list: [PlayerResult] = [];
            var currentPlayerIndex : Int = 0;
            argMaxScores = playerResults.count < argMaxScores ? playerResults.count : argMaxScores;
            
            // add current player to the list:
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
            msg += "\n \(player.username)  --  \(player.time) (\(player.flips))";
        }
        
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
    
    
    
    func openCard(on button: UIButton) {
        // button.setTitleColor(.black, for: .normal);
        button.backgroundColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0);
    }
    
    func openAllCards() {
        for card in cards {
            card.backgroundColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0);
        }
    }
    
    func closeCard(on index: Int) {
        cards[index].backgroundColor = basicColor;
    }
    
    func  disableButton(on index: Int) {
        cards[index].isEnabled = false;
    }
    
}
