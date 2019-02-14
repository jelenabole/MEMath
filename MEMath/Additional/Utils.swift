//
//  Utils.swift
//  MEMath
//
//  Created by Jelena on 13/01/2019.
//  Copyright © 2019 Jelena. All rights reserved.
//

import Foundation

func convertToReadable(seconds number: Int) -> String {
    let min: Int = number / 60;
    let sec: Int = number - (min * 60);
    
    var str: String = "\(min):";
    if (sec < 10) {
        str += "0";
    }
    str += "\(sec)";
    
    return str;
}

// adds padding "0x" if needed:
func convertToString(time number: Int) -> String {
    if (number < 10) {
        return "0" + "\(number)";
    } else {
        return "\(number)";
    }
}

// hardcoded values
func getCardsByRowAndColumn(from difficulty: Deck.Difficulty) -> (Int, Int) {
    
    // 6, 12, 30 (pairs: 3, 6, 15)
    switch difficulty {
    case .test:
        return (1, 2);
    case .easy:
        return (2, 3);
    case .medium:
        return (3, 4);
    case .hard:
        return (4, 6);
    }
}
