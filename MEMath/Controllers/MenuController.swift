//
//  ViewController.swift
//  MEMath
//
//  Created by Jelena on 04/01/2019.
//  Copyright © 2019 Jelena. All rights reserved.
//

import UIKit

class MenuController: UIViewController {
    
    @IBOutlet weak var difficultySegment: UISegmentedControl!
    
    @IBOutlet weak var plusButton: UIButton!
    @IBOutlet weak var minusButton: UIButton!
    @IBOutlet weak var multiButton: UIButton!
    @IBOutlet weak var divisionButton: UIButton!
    
    @IBOutlet weak var allButton: UIButton!
    var operations: [Deck.Operation] = [.addition, .subtraction, .multiplication, .division];
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    // check all operations
    @IBAction func setAllOperations(_ sender: UIButton) {
        plusButton.isSelected = false;
        minusButton.isSelected = false;
        multiButton.isSelected = false;
        divisionButton.isSelected = false;
        
        allButton.isSelected = true;
        operations = [.addition, .subtraction, .multiplication, .division];
    }
    
    // change status of the operation
    @IBAction func changeOperation(_ sender: UIButton) {
        if (allButton.isSelected) {
            operations = [];
            allButton.isSelected = false;
        }
        
        // get operation by the button:
        let op = getOperation(sender);
        if (sender.isSelected) {
            operations.remove(at: operations.index(of: op)!);
        } else {
            operations.append(op);
        }
        
        sender.isSelected = !sender.isSelected;
    }
    
    func getOperation(_ sender: UIButton) -> Deck.Operation {
        switch sender {
        case plusButton:
            return .addition;
        case minusButton:
            return .subtraction;
        case multiButton:
            return .multiplication;
        case divisionButton:
            return .division;
            
        // TODO - error ??
        default:
            return .addition;
        }
    }
    
    func getDifficulty() -> Deck.Difficulty {
        switch difficultySegment.selectedSegmentIndex {
        case 0:
            return .easy;
        case 1:
            return .medium;
        case 2:
            return .hard;
        default:
            return .easy;
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.destination is GameController {
            let view = segue.destination as? GameController;
            
            view?.argDifficulty = getDifficulty();
            view?.argOperations = operations;
            view?.argMaxScores = 5;
        }
    }
}
