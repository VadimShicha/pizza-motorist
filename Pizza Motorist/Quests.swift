//
//  Quests.swift
//  Pizza Motorist
//
//  Created by Vadim Shicha on 12/14/23.
//

import Foundation

enum QuestType: Int {
    case DriveDistance = 0
     case CollectCoins = 1
     case DriveToDistance = 2
}

struct Quest {
    var questType: QuestType = QuestType.DriveDistance
    var progress: Int = 0
    var valueNeeded: Int = 0
    var reward: Int = 100
    
    init(type: QuestType, value: Int, reward: Int = 100) {
        questType = type
        valueNeeded = value
        self.reward = reward
    }
    
    func getQuestTitle() -> String {
        if(questType == QuestType.DriveDistance) {
            return "Drive for " + String(valueNeeded) + " feet"
        }
        else if(questType == QuestType.CollectCoins) {
            return "Collect " + String(valueNeeded) + " coins"
        }
        else if(questType == QuestType.DriveToDistance) {
            return "Drive " + String(valueNeeded) + " feet in one run"
        }
        
        return ""
    }
    
    func questCompleted() -> Bool {
        return (progress == valueNeeded)
    }
}

struct QuestManager {
    static func generateQuest() -> Quest{
//        let questType = QuestType.allCases[Int.random(in: 0...QuestType.allCases.count - 1)]
        
        let quests = [
            Quest(type: QuestType.DriveDistance, value: 50, reward: 20),
            Quest(type: QuestType.DriveDistance, value: 130, reward: 100),
            Quest(type: QuestType.DriveDistance, value: 200, reward: 180),
            Quest(type: QuestType.DriveDistance, value: 300, reward: 290),
            Quest(type: QuestType.DriveDistance, value: 400, reward: 380),
            Quest(type: QuestType.DriveDistance, value: 500, reward: 450),
            
            Quest(type: QuestType.CollectCoins, value: 40, reward: 50),
            Quest(type: QuestType.CollectCoins, value: 50, reward: 60),
            Quest(type: QuestType.CollectCoins, value: 80, reward: 110),
            Quest(type: QuestType.CollectCoins, value: 100, reward: 160),
            
            Quest(type: QuestType.DriveToDistance, value: 250, reward: 200),
            Quest(type: QuestType.DriveToDistance, value: 380, reward: 350),
            Quest(type: QuestType.DriveToDistance, value: 500, reward: 600)
        ]
        
        return quests[Int.random(in: 0...quests.count - 1)]
    }
    
    static func updateQuests(type: QuestType, increase: Bool, value: Int, quests: [Quest]) -> [Quest] {
        var newQuests = quests
        
        for i in (0...newQuests.count - 1) {
            if(newQuests[i].questType == type) {
                
                if(increase) {
                    if(newQuests[i].progress + value > newQuests[i].valueNeeded) {
                        newQuests[i].progress = newQuests[i].valueNeeded
                    }
                    else {
                        newQuests[i].progress += value
                    }
                }
                else {
                    if(value >= newQuests[i].valueNeeded) {
                        newQuests[i].progress = newQuests[i].valueNeeded
                    }
                }
            }
        }
        
        return newQuests
    }
}
