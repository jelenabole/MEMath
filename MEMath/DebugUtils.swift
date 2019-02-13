//
//  DebugUtils.swift
//  MEMath
//
//  Created by Jelena on 13/02/2019.
//  Copyright © 2019 Jelena. All rights reserved.
//
// Debugging methods
//

import Foundation


func getStartTime() -> UInt64 {
    return DispatchTime.now().uptimeNanoseconds;
}

func printEndTime(start from: UInt64) {
    let total = (DispatchTime.now().uptimeNanoseconds - from) / 1000;
    print("time passed (in microsec): \(total)");
}
