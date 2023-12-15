//
//  GlobalData.swift
//  Pizza Motorist
//
//  Created by Vadim Shicha on 12/14/23.
//

import Foundation

struct GlobalData {
    static var currentWindowOpen: WindowType = WindowType.Home
    static var quests: [Quest] = [
        QuestManager.generateQuest(),
        QuestManager.generateQuest(),
        QuestManager.generateQuest()
    ]
    static var coinAmount: Int = 100
    
    static var bestDistance: Int = 0
}
