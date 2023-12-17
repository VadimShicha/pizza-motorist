//
//  GameGeneration.swift
//  Pizza Motorist
//
//  Created by Vadim Shicha on 12/16/23.
//

import Foundation
import SwiftUI

struct CarGenerator {
    @State private var carsLastGenerated: Bool = false
    var holeCount: Int = 0
    
    mutating func generateNextRow() -> [CarElement] {
        if(holeCount == 3) {
            
            var holeAmount = 1
            
            if(Int.random(in: 0...2) == 0) {
                holeAmount = 2
            }
            else {
                holeAmount = 1
            }
            
            holeCount = 0
            
            var carArr = [CarElement]()
            
            let holeIndex = Int.random(in: 0...4)
            
            var secondHoleIndex = holeIndex
            
            if(holeAmount > 1) {
                secondHoleIndex = Int.random(in: 0...4)
            }
            
            for i in 0...4 {
                
                if(i != holeIndex && i != secondHoleIndex) {
                    carArr.append(CarElement(eType: CarElementType.Car, name: "RedCar"))
                }
                else {
                    carArr.append(CarElement(eType: CarElementType.None, name: "Road"))
                }
            }
            
            
            
            return carArr
        }
        
        carsLastGenerated = !carsLastGenerated
        
        holeCount += 1
        print(holeCount)
        return [CarElement(name: "Road"),CarElement(name: "Road"),CarElement(name: "Road"),CarElement(name: "Road"),CarElement(name: "Road")]
    }
}
