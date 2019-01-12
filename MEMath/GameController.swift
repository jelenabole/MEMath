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
    
    let basicColor = #colorLiteral(red: 0, green: 0.5603182912, blue: 0, alpha: 1);
    
    @IBOutlet weak var cardsView: UIView!
    
    // timer:
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
        
        // START OF THE APPLICATION:
        // stuff to get from the screen before:
        let difficulty = Deck.Difficulty.easy;
        // let ops: [Deck.Operation] = [.addition, .subtraction, .multiplication, .division];
        let ops: [Deck.Operation] = [.addition];
        print("starting the game: \(difficulty) with pairs: \(difficulty.rawValue) and operations: \(ops.count)");
        
        
        
        
        // global variable:
        myDeck = Deck(level: difficulty, operations: ops);
        
        // create an aray of cards and shuffle them:
        numberOfPairs = difficulty.rawValue;
        let numberOfDeckCards = numberOfPairs * 2;
        for index in 0 ..< numberOfDeckCards {
            shuffledCardIndices.append(index);
        }
        shuffledCardIndices.shuffle();
        
        // calculate number of cards by row and column:
        let (inRow, inColumn) = calcNumberOfCards(from: difficulty);
        createButtons(inRow, inColumn);
        
        startTimer();
        
        
        // TODO - test the DB:
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate;
        let context = appDelegate.managedObjectContext;
        let database = DatabaseResults(from: context);
        
        // get all items (sorted from highest points):
        var playerResults: [NSManagedObject] = database.getItems();
        
        // get filtered items:
        playerResults = database.getItems(for: .easy);
        
        // create new user:
        let result = PlayerResult(username: "user2", time: "0:30", points: 30, flips: 30, difficulty: 3);
        database.save(item: result);
        
        database.deleteAll();
    }
    
    func calcNumberOfCards(from difficulty: Deck.Difficulty) -> (Int, Int) {
        // TODO - create a better solution for this! (a real calculation by screen size)
        
        // 6, 12, 30 (pairs: 3, 6, 15)
        switch difficulty {
        case .easy:
            return (2, 3);
        case .medium:
            return (3, 4);
        case .hard:
            return (4, 6);
        }
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
            
            // TODO - wait for 2sec, then continue the app
            print("--- wait 2 sec");
            /*
            Timer.scheduledTimer(
                timeInterval: 0.9,
                target: self,
                selector: #selector(countdown),
                userInfo: nil,
                repeats: true);
            */
            
            if (cardsSame) {
                print("PAIR FOUND");
                // stay opened, disable touch on them:
                disableButton(on: cardIndex);
                disableButton(on: currentCardFlippedIndex!);
                
                flippedPairs += 1;
                isGameFinished();
            } else {
                print("pair wrong!");
                closeCard(on: cardIndex);
                closeCard(on: currentCardFlippedIndex!);
            }
            
            numberOfFlips += 1;
            currentCardFlippedIndex = nil;
        } else {
            print("first card opened");
            openCard(on: sender);
            currentCardFlippedIndex = cardIndex;
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
            showAlert();
        }
    }
    
    func showAlert() {
        // TODO - check results and decide which screen to show!
        
        // TODO - set the message and leader-board
        // back button (!)
        
        // 2 messages:
        // in top 10 = get usrname and save it
        // not = sy "do better next time" - OK
        
        // show current time and add text field:
        let alert = UIAlertController(title: "CONGRATS!!",
                                      message: "You finished the game in: \(timerLabel!.text!)",
            preferredStyle: .alert);
        alert.addTextField { (textField) in
            textField.placeholder = "User"
        }
        alert.addAction(UIAlertAction(
            title: "Save", style: .default, handler: { [weak alert] (_) in
                let textField = alert?.textFields![0];
                print("username: \(textField!.text!)");
                
                // TODO - save the username with the time for the leaderboard
                // TODO - open another alert for the leaderboard, and show that one
                // .. go back on OK.
                print("navigator : \(self.navigationController == nil)");
                _ = self.navigationController?.popViewController(animated: true);
        }))
        // TODO - get previous times
        // set your name, or something -
        
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
