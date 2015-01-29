//
//  GameData.swift
//  Break
//
//  Created by Mollie on 1/29/15.
//  Copyright (c) 2015 Proximity Viz LLC. All rights reserved.
//

import UIKit

let _mainData: GameData = { GameData() }()

class GameData: NSObject {
    
    var topScore: Int = 0
    
    var gamesPlayed: [[String:Int]] = []
    
    var currentGame: [String:Int]? {
        
        get {
            
            return gamesPlayed[gamesPlayed.count - 1]
            
        }
        
        set {
            
            gamesPlayed[gamesPlayed.count - 1] = newValue!
            
        }
        
    }
    
    var allLevels = [
    
        (3, 1),
        (5, 1),
        (5, 2),
        (5, 3),
        (6, 1),
        (6, 2),
        (6, 3),
        (7, 1),
        (7, 2),
        (7, 3),
        (7, 4),
        (8, 2),
        (8, 3),
        (8, 4)
    
    ]
    
    var currentLevel: Int = 0
    
    class func mainData() -> GameData {
        
        return _mainData
        
    }
    
    func startGame() {
        
        gamesPlayed.append([
            
            "livesLost":0,
            "bricksBusted":0,
            "levelBeaten":0,
            "totalScore":0
            
        ])
        
    }
    
    func adjustValue(difference: Int, forKey key: String) {
        
        if var value = currentGame?[key] {
            
            currentGame?[key] = value + difference
            
        }
        
    }
   
}

// GameData.mainData()
