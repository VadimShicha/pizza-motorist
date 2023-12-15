//
//  ContentView.swift
//  Pizza Motorist
//
//  Created by Vadim Shicha on 11/25/23.
//

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

enum CarElementType {
    case None, Car
}

struct CarElement: Hashable {
    var imageName = ""
    var carType: CarElementType = CarElementType.None
    var position: [CGFloat]
    
    init(eType: CarElementType = CarElementType.None, name: String) {
        carType = eType
        imageName = name
        position = [0, 0]
    }
}

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

struct GarageCar {
    var carTitle: String = "Blue Car"
    var imageName: String = "BlueCar"
    var cost: Int = 1000
    var owned: Bool = false
    
    init(title: String, name: String, price: Int = 0) {
        carTitle = title
        imageName = name
        cost = price
        owned = false
    }
    
    mutating func setOwned(value: Bool) {
        owned = value
    }
}

struct ContentView: View {
    
    enum WindowType {
        case Home, MainGame
    }
    
    enum PopupType {
        case None, Quest, Shop, Stats, Settings, CarSelect, GameOver, GamePaused
    }
    
    @State private var coinAmount: Int = 100
    
    @State private var currentWindowOpen: WindowType = WindowType.Home
    @State private var currentPopupOpen: PopupType = PopupType.None
    
    @State private var carElements = [[CarElement]](); //array of array with Cars
    @State private var carPositionX: CGFloat = 0
    @State private var carPositionY: CGFloat = 0
    
    @State private var fallingVar: CGFloat = 50
    
    @State private var carGenerator: CarGenerator = CarGenerator()
    
    
    let timer = Timer.publish(every: 0.003, tolerance: 0.0003, on: .main, in: .common).autoconnect()
    
    let carWidth = 70.0 / 1.2
    let carHeight = 109.375 / 1.2
    
    let roadWidth = 70.0
    let roadHeight = 109.375
    
    let carSpeed: CGFloat = 3
    @State private var carSpeedMultiplier: CGFloat = 1
    
    let homeTabColor = Color(red: 128 / 255, green: 78 / 255, blue: 32 / 255)
    let homeTabColorSelected = Color(red: 115 / 255, green: 69 / 255, blue: 25 / 255)
    
    @State private var currentCarLane: [Int] = [2, -1]
    @State private var distanceTraveled: CGFloat = 0.0
    @State private var bestDistance: Int = 0
    @State private var totalQuestsComplete: Int = 0
    
    @State private var gameRunning: Bool = true
    
    @State private var showMoveArea = false
    
    @State private var startRan = false
    
    @State private var quests: [Quest] = [
        QuestManager.generateQuest(),
        QuestManager.generateQuest(),
        QuestManager.generateQuest()
    ]
    
    @State private var shopCars: [GarageCar] = [
        GarageCar(title: "Blue Car Splat", name: "BlueCarSplat", price: 80),
        GarageCar(title: "Red Car Splat", name: "BlueCarSplat", price: 100)
    ]
    
    @State private var ownedCars: [GarageCar] = [
        GarageCar(title: "Default Car", name: "BlueCar")
    ]
    
    //if closed, opens the popup. Otherwise, close the popup
    func togglePopup(name: PopupType) {
        if(currentPopupOpen == name) {
            currentPopupOpen = PopupType.None
        }
        else {
            withAnimation(.spring()) {
                currentPopupOpen = name
            }
        }
    }
    
    //sets up the cars arrays
    func setupGame() {
        for _ in 1...12 {
            carElements.append([CarElement(name: "RedCar"),CarElement(name: "RedCar"),CarElement(name: "RedCar"),CarElement(name: "RedCar"),CarElement(name: "RedCar")])
        }
        
        carPositionY = getScreenYWithYLane(yLane: 6)
        
        carElements[6][0] = CarElement(eType: CarElementType.Car, name: "RedCar")
        //print(-(((12*109.375) - 1000) / 2) + 6 * (109.375))
        //print(-(((12 * carHeight) - UIScreen.main.bounds.size.height) / 2) + (6 * carHeight))
        
    }

    //changes the window while also setting up all the game elements
    func startGame() {
        currentWindowOpen = WindowType.MainGame
        
        carPositionX = 0
        currentCarLane = [2, -1]
        distanceTraveled = 0.0
        
        currentPopupOpen = PopupType.None
        gameRunning = true
        
        carElements = [[CarElement]]()
        setupGame()
    }
    
    func endGame() {
        if(!gameRunning) {return} //sometimes this function will be called multiple times
            
        carSpeedMultiplier = 1
        gameRunning = false
        
        if(Int(distanceTraveled) > bestDistance) {
            bestDistance = Int(distanceTraveled)
        }
        
        quests = QuestManager.updateQuests(type: QuestType.DriveDistance, increase: true, value: Int(distanceTraveled), quests: quests)
        quests = QuestManager.updateQuests(type: QuestType.DriveToDistance, increase: false, value: Int(distanceTraveled), quests: quests)
        
        coinAmount += Int(distanceTraveled / 10)
        saveData()
    }
    
    func getScreenYWithYLane(yLane: Int) -> CGFloat {
        
        //-(12 * carHeight - UIScreen.main.bounds.size.height) / 2.0 + (6 * carHeight) + (carHeight / 2) + fallingVar
        
        let firstLaneY = -(12 * roadHeight - UIScreen.main.bounds.size.height) / 2.0
        let lane = firstLaneY + (Double(yLane) * roadHeight)
                    
        return lane + (roadHeight / 2) + fallingVar
    }
    
    func saveData() {
        UserDefaults.standard.set(coinAmount, forKey: "coinAmount")
        UserDefaults.standard.set(bestDistance, forKey: "bestDistance")
        UserDefaults.standard.set(totalQuestsComplete, forKey: "totalQuestsComplete")
        
        for i in 0...quests.count - 1 {
            let questKey = "quest" + String(i)
            
            UserDefaults.standard.set(quests[i].progress, forKey: questKey + "_progress")
            UserDefaults.standard.set(quests[i].valueNeeded, forKey: questKey + "_valueNeeded")
            UserDefaults.standard.set(quests[i].reward, forKey: questKey + "_reward")
            UserDefaults.standard.set(quests[i].questType.rawValue, forKey: questKey + "_questType")
        }
    }
    
    func loadData() {
        if(UserDefaults.standard.object(forKey: "coinAmount") != nil) {
            coinAmount = UserDefaults.standard.integer(forKey: "coinAmount")
        }
        if(UserDefaults.standard.object(forKey: "bestDistance") != nil) {
            bestDistance = UserDefaults.standard.integer(forKey: "bestDistance")
        }
        if(UserDefaults.standard.object(forKey: "totalQuestsComplete") != nil) {
            totalQuestsComplete = UserDefaults.standard.integer(forKey: "totalQuestsComplete")
        }
        if(UserDefaults.standard.object(forKey: "quest0_progress") != nil) {
            
            quests = []
            
            for i in 0...2 {
                let questKey = "quest" + String(i)
                
                let questType: QuestType? = QuestType(rawValue: UserDefaults.standard.integer(forKey: questKey + "_questType"))
                
                if(questType == nil) {
                    print("Quest " + String(i) + " is nil. Generating new quest")
                    quests.append(QuestManager.generateQuest())
                }
                else {
                    var newQuest = Quest(
                        type: questType!,
                        value: UserDefaults.standard.integer(forKey: questKey + "_valueNeeded"),
                        reward: UserDefaults.standard.integer(forKey: questKey + "_reward")
                    )
                    
                    newQuest.progress = UserDefaults.standard.integer(forKey: questKey + "_progress")
                    
                    quests.append(newQuest)
                }
                
            }
        }
    }
    
    func wipeData() {
        UserDefaults.standard.removeObject(forKey: "coinAmount")
        UserDefaults.standard.removeObject(forKey: "bestDistance")
        UserDefaults.standard.removeObject(forKey: "totalQuestsComplete")
        UserDefaults.standard.removeObject(forKey: "quests")
        
        for i in 0...quests.count - 1 {
            let questKey = "quest" + String(i)
            
            UserDefaults.standard.removeObject(forKey: questKey + "_progress")
            UserDefaults.standard.removeObject(forKey: questKey + "_valueNeeded")
            UserDefaults.standard.removeObject(forKey: questKey + "_reward")
            UserDefaults.standard.removeObject(forKey: questKey + "_questType")
        }
        
        coinAmount = 100
        bestDistance = 0
        totalQuestsComplete = 0
        quests = [
            QuestManager.generateQuest(),
            QuestManager.generateQuest(),
            QuestManager.generateQuest()
        ]
    }

    //code that runs once after the first render
    func startLogic() {
        print("Start")
        wipeData()
        loadData()
    }
    
    var body: some View {
        if(currentWindowOpen == WindowType.Home) {
            ZStack {
                
                VStack(spacing: 0) {
                    Text("Speedy Pizzas")
                        .font(.custom("ChalkboardSE-Bold", size: 45))
                        .padding(.top, 5)
                    
                    HStack {
                        Image("Coin")
                            .resizable()
                            .frame(width: 40, height: 40)
                        Text(String(coinAmount))
                            .font(.custom("ChalkboardSE-Bold", size: 40))
                            .foregroundColor(Color.yellow)
                            .padding(.bottom, 5)
                    }
                    
                    Spacer()
                    HStack {
                        Spacer()
                        VStack {
                            Image("BlueCar")
                                .resizable()
                                .frame(width: carWidth * 2, height: carHeight * 2)
                                .rotationEffect(.degrees(325))
                                .shadow(color: Color(red: 0.3, green: 0.3, blue: 0.3), radius: 3, x: 0, y: 20)
                            Button() {
                                currentPopupOpen = PopupType.CarSelect
                            } label: {
                                Text("Change Car")
                                    .font(.custom("ChalkboardSE-Bold", size: 15))
                                    .foregroundColor(Color.green)
                            }
                        }
                        Spacer()
                    }
                    
                    
                    
                    Spacer()
                    
                    Text("Tap to play!")
                        .font(.custom("ChalkboardSE-Bold", size: 24))
                        .padding(25)
                }
                .contentShape(Rectangle())
                .onTapGesture {
                    //if a popup isn't open and the VStack is tapped (not a button on the stack), start the game
                    if(currentPopupOpen == PopupType.None) {
                        startGame()
                    }
                    //otherwise, close the popup
                    else {
                        currentPopupOpen = PopupType.None
                    }
                }
                
                if(currentPopupOpen == PopupType.Quest) {
                    VStack {
                        Text("Quests")
                            .font(.custom("ChalkboardSE-Bold", size: 35))
                        
                        ForEach(0...2, id: \.self) { i in
                            VStack {
                                HStack {
                                    Text(quests[i].getQuestTitle())
                                        .font(.custom("ChalkboardSE-Bold", size: 20))
                                        .foregroundColor(Color.black)
                                    Spacer()
                                    //button
                                }
                                
                                HStack {
                                    Button() {
                                        quests[i] = QuestManager.generateQuest() //generate a new quest
                                        saveData()
                                    } label: {
                                        Image("Trash")
                                            .resizable()
                                            .scaledToFit()
                                            .frame(width: 25, height: 25)
                                    }
                                    .padding(3)
                                    .background(Color.brown.opacity(0.7))
                                    .cornerRadius(5)
                                    
                                    Text(quests[i].questCompleted() ? "Quest Complete" : String(quests[i].progress) + " / " + String(quests[i].valueNeeded))
                                        .font(.custom("ChalkboardSE-Bold", size: 18))
                                        .foregroundColor(quests[i].questCompleted() ? Color.green : Color.red)
                                    
                                        .padding(.leading, 20)
                                    Spacer()
                                    Button() {
                                        if(quests[i].questCompleted()) {
                                            totalQuestsComplete += 1
                                            coinAmount += quests[i].reward
                                            quests[i] = QuestManager.generateQuest() //generate a new quest
                                            saveData()
                                        }
                                    } label: {
                                        HStack {
                                            Text(String(quests[i].reward))
                                                .font(.custom("ChalkboardSE-Bold", size: 20))
                                                .foregroundColor(quests[i].questCompleted() ? Color.green : Color.red)
                                                .padding(1)
                                            Image("Coin")
                                                .resizable()
                                                .scaledToFit()
                                                .frame(width: 25, height: 25)
                                        }
                                        
                                    }
                                    .padding(3)
                                    .background(Color.brown.opacity(0.7))
                                    .cornerRadius(5)
                                }
                                
                                
                            }.padding(4)
                                .background(Color.brown.opacity(0.1))
                                .cornerRadius(5)
                                .padding(4)
                            
                        }
                    }
                    .frame(maxWidth: UIScreen.main.bounds.size.width - 80)
                    .transition(.move(edge: .trailing))
                    .background(Color.yellow)
                    .padding(.trailing, 80)
                    .padding(.leading, 3)
                }
                else if(currentPopupOpen == PopupType.Shop) {
                    VStack {
                        Text("Shop")
                            .font(.custom("ChalkboardSE-Bold", size: 35))
                        
                        ScrollView {
                            VStack {
                                ForEach(0...1, id: \.self) { i in
                                    VStack {
                                        HStack {
                                            Spacer()
                                            Text(shopCars[i].carTitle)
                                                .font(.custom("ChalkboardSE-Bold", size: 23))
                                            Spacer()
                                        }
                                        
                                        Image(shopCars[i].imageName)
                                            .resizable()
                                            .scaledToFit()
                                            .frame(width: 66, height: 66)
                                        
                                        HStack {
                                            Spacer()
                                            Button() {
                                                if(coinAmount >= shopCars[i].cost) {
                                                    shopCars[i].owned = true
                                                    coinAmount -= shopCars[i].cost
                                                    ownedCars.append(GarageCar(title: shopCars[i].carTitle, name: shopCars[i].imageName))
                                                }
                                            } label: {
                                                HStack {
                                                    if(shopCars[i].owned) {
                                                        Text("Bought")
                                                            .font(.custom("ChalkboardSE-Bold", size: 17))
                                                            .foregroundColor(Color.black)
                                                            .padding(1)
                                                    }
                                                    else {
                                                        Text(String(shopCars[i].cost))
                                                            .font(.custom("ChalkboardSE-Bold", size: 17))
                                                            .foregroundColor((coinAmount < shopCars[i].cost) ? Color.red : Color.black)
                                                            .padding(1)
                                                        Image("Coin")
                                                            .resizable()
                                                            .scaledToFit()
                                                            .frame(width: 22, height: 22)
                                                    }
                                                }
                                                
                                            }
                                            .padding(3)
                                            .background(Color.brown.opacity(0.7))
                                            .cornerRadius(5)
                                            Spacer()
                                        }
                                    }
                                    .padding(4)
                                    .background(Color.brown.opacity(0.1))
                                    .cornerRadius(5)
                                    .padding(4)
                                }
                            }
                        }
                        .frame(height: 400)
                        
                        
                        
                    }
                    .frame(maxWidth: UIScreen.main.bounds.size.width - 80)
                    .transition(.move(edge: .trailing))
                    .padding(.bottom, 40)
                    .background(Color.orange)
                    .padding(.trailing, 80)
                    .padding(.leading, 3)
                }
                else if(currentPopupOpen == PopupType.Stats) {
                    VStack {
                        Text("Stats")
                            .font(.custom("ChalkboardSE-Bold", size: 35))
                        
                        HStack {
                            Text("Best distance:")
                                .font(.custom("ChalkboardSE-Bold", size: 20))
                            Spacer()
                            Text(String(bestDistance) + "ft")
                                .font(.custom("ChalkboardSE-Bold", size: 20))
                        }.padding(8)
                        
                        HStack {
                            Text("Quests complete:")
                                .font(.custom("ChalkboardSE-Bold", size: 20))
                            Spacer()
                            Text(String(totalQuestsComplete))
                                .font(.custom("ChalkboardSE-Bold", size: 20))
                        }.padding(8)
                        
                    }
                    .frame(maxWidth: UIScreen.main.bounds.size.width - 80)
                    .transition(.move(edge: .trailing))
                    .padding(.bottom, 40)
                    .background(Color.green)
                    .padding(.trailing, 80)
                    .padding(.leading, 3)
                }
                else if(currentPopupOpen == PopupType.Settings) {
                    VStack {
                        Text("Settings")
                            .font(.custom("ChalkboardSE-Bold", size: 35))

                        Button() {
                            
                        } label: {
                            Image(systemName: "gearshape.fill")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 66, height: 66)
                                .foregroundColor(Color.red)
                        }
                        
                        HStack {
                            Toggle("Show move area", isOn: $showMoveArea)
                                .font(.custom("ChalkboardSE-Bold", size: 25))
                        }
                        .padding(8)
                        
                        HStack {
                            Button() {
                                loadData()
                            } label: {
                                Text("Load Data")
                                    .font(.custom("ChalkboardSE-Bold", size: 18))
                                    .foregroundColor(Color.white)
                            }
                            .padding(5)
                            .background(Color.blue)
                            .cornerRadius(5)
                            
                            Button() {
                                wipeData()
                            } label: {
                                Text("Wipe Data")
                                    .font(.custom("ChalkboardSE-Bold", size: 18))
                                    .foregroundColor(Color.white)
                            }
                            .padding(5)
                            .background(Color.red)
                            .cornerRadius(5)
                        }
                        .padding(8)
                    }
                    .frame(maxWidth: UIScreen.main.bounds.size.width - 80)
                    .transition(.move(edge: .trailing))
                    .background(Color.gray)
                    .padding(.trailing, 80)
                    .padding(.leading, 3)
                }
                else if(currentPopupOpen == PopupType.CarSelect) {
                    VStack {
                        Text("Garage")
                            .font(.custom("ChalkboardSE-Bold", size: 35))
                        
                        ScrollView {
                            VStack {
                                ForEach(0..<1, id: \.self) { i in
                                    HStack {
                                        ForEach(0...1, id: \.self) { j in
                                            VStack {
//                                                if((i * 2) + j < ownedCars.count) {
//                                                    HStack {
//                                                        Spacer()
//                                                        Text(ownedCars[i].carTitle)
//                                                            .font(.custom("ChalkboardSE-Bold", size: 23))
//                                                        Spacer()
//                                                    }
//                                                    
//                                                    Image(ownedCars[i].imageName)
//                                                        .resizable()
//                                                        .scaledToFit()
//                                                        .frame(width: 66, height: 66)
//                                                    
//                                                    HStack {
//                                                        Spacer()
//                                                        Button() {
//                                                            
//                                                        } label: {
//                                                            Text("Equip")
//                                                                .font(.custom("ChalkboardSE-Bold", size: 17))
//                                                                .foregroundColor(Color.black)
//                                                                .padding(1)
//                                                        }
//                                                        .padding(3)
//                                                        .background(Color.brown.opacity(0.7))
//                                                        .cornerRadius(5)
//                                                        Spacer()
//                                                    }
//                                                }
//                                                else {
//                                                    HStack {
//                                                        Spacer()
//                                                    }
//                                                }
                                                
                                            }
                                            .padding(4)
                                            .background(Color.cyan.opacity(0.4))
                                            .cornerRadius(5)
                                            .padding(4)
                                        }
                                    }
                                    
                                }
                            }
                        }
                        .frame(height: 400)
                        
                    }
                    .frame(maxWidth: UIScreen.main.bounds.size.width - 80)
                    .transition(.move(edge: .trailing))
                    .padding(.bottom, 40)
                    .background(Color.mint)
                    .padding(.trailing, 80)
                    .padding(.leading, 3)
                }
                
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        VStack(spacing: 0) {
                            Button() {
                                togglePopup(name: PopupType.Quest)
                            } label: {
                                Image("pencil.and.list.clipboard")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 66, height: 66)
                                    .padding(5)
                                    .background(currentPopupOpen == PopupType.Quest ? homeTabColorSelected : homeTabColor)
                            }
                            Button() {
                                togglePopup(name: PopupType.Shop)
                            } label: {
                                Image(systemName: "cart.fill")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 66, height: 66)
                                    .foregroundColor(Color.orange)
                                    .padding(5)
                                    .background(currentPopupOpen == PopupType.Shop ? homeTabColorSelected : homeTabColor)
                            }
                            Button() {
                                togglePopup(name: PopupType.Stats)
                            } label: {
                                Image(systemName: "chart.bar.xaxis")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 66, height: 66)
                                    .foregroundColor(Color.green)
                                    .padding(5)
                                    .background(currentPopupOpen == PopupType.Stats ? homeTabColorSelected : homeTabColor)
                            }
                            Button() {
                                togglePopup(name: PopupType.Settings)
                            } label: {
                                Image(systemName: "gearshape.fill")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 66, height: 66)
                                    .foregroundColor(Color.gray)
                                    .padding(5)
                                    .background(currentPopupOpen == PopupType.Settings ? homeTabColorSelected : homeTabColor)
                            }
                        }
                        .background(homeTabColor)
                        .cornerRadius(8)
                    }
                    Spacer()
                }
            }
            .background(
                LinearGradient(gradient: Gradient(colors: [
                    Color(red: 0.6, green: 0.6, blue: 0.6),
                    Color(red: 0.5, green: 0.5, blue: 0.5),
                    Color(red: 0.4, green: 0.4, blue: 0.4),
                    Color(red: 0.5, green: 0.5, blue: 0.5)
                ]), startPoint: .topLeading, endPoint: .bottomTrailing)
                //LinearGradient(gradient: Gradient(colors: [Color("HomeBackgroundColor"), Color.red, Color.orange]), startPoint: .topLeading, endPoint: .bottomTrailing)
            )
            .onAppear() {
                loadData()
            }
        }
        else if(currentWindowOpen == WindowType.MainGame) {

            //let _ = print(-((12 * carHeight) - UIScreen.main.bounds.size.height))
            ZStack {
                
                //Text("BLAH").position(x: 0, y: getScreenYWithYLane(yLane: 6))
                
                VStack(spacing: 0) {
                    ForEach(carElements, id: \.self) { carArray in
                        HStack(spacing: 0) {
                            ForEach(carArray, id: \.self) { car in
                                if(car.carType == CarElementType.Car) {
                                    
                                    ZStack {
                                        Image("Road")
                                            .resizable()
                                            .frame(width: roadWidth, height: roadHeight)
                                        Image(car.imageName)
                                            .resizable()
                                            .frame(width: carWidth, height: carHeight)
                                    }
                                }
                                else {
                                    Image("Road")
                                        .resizable()
                                        .frame(width: roadWidth, height: roadHeight)
                                }
                            }
                        }
                    }
                    Spacer()
                }
                .background(Color(red: 0.6, green: 0.6, blue: 0.6))
                .position(x: UIScreen.main.bounds.size.width / 2,
                          y: UIScreen.main.bounds.size.height / 2 + CGFloat(fallingVar)) // + carHeight
                .contentShape(Rectangle())
                
                VStack {
                    Spacer()
                    HStack {
                        Image("BlueCar")
                            .resizable()
                            .position(x: carPositionX + carWidth / 2)
                            .frame(width: carWidth / 1.15, height: carHeight / 1.15)
                    }.padding(25)
                }
                .onReceive(timer) { time in
                    if(gameRunning) {
                        fallingVar += ((carSpeed * carSpeedMultiplier) / 2)
                        distanceTraveled += (0.1 * ((carSpeed * carSpeedMultiplier) / 3))
                        
                        if(distanceTraveled >= 1000) {
                            carSpeedMultiplier = 1.5
                        }
                        else if(distanceTraveled >= 800) {
                            carSpeedMultiplier = 1.4
                        }
                        else if(distanceTraveled >= 650) {
                            carSpeedMultiplier = 1.3
                        }
                        else if(distanceTraveled >= 500) {
                            carSpeedMultiplier = 1.2
                        }
                        else if(distanceTraveled >= 350) {
                            carSpeedMultiplier = 1.15
                        }
                        else if(distanceTraveled >= 200) {
                            carSpeedMultiplier = 1.1
                        }
                        else if(distanceTraveled >= 100) {
                            carSpeedMultiplier = 1.05
                        }
                    }
                    
                    print(abs(getScreenYWithYLane(yLane: 6) - UIScreen.main.bounds.size.height + roadHeight - 10))
                    
                    //detect car collisions
                    for i in 0...4 {
                        //if the player car is colliding with a car
                        if((carElements[6][i].carType == CarElementType.Car ||
                            carElements[7][i].carType == CarElementType.Car) &&
                           (currentCarLane[0] == i || currentCarLane[1] == i)) {
                            
                            //let _ = print(abs(getScreenYWithYLane(yLane: 6) - UIScreen.main.bounds.size.height + 135))
                            
                            
                            if(abs(getScreenYWithYLane(yLane: 6) - UIScreen.main.bounds.size.height + roadHeight - 10) <= roadHeight) {
                                endGame()
                                currentPopupOpen = PopupType.GameOver
                            }
                        }
                    }
                    
                    //loop the car back to top of array when it reaches the bottom
                    if(fallingVar >= roadHeight + 0) {
                        fallingVar = 0
                        
                        carElements.removeLast()
                        carElements.insert(carGenerator.generateNextRow(), at: 0)
                    }
                }
                
                
                
                //the input area where you drag your finger to move
                VStack {
                    Spacer()
                    HStack {}
                        .frame(width: UIScreen.main.bounds.size.width,
                               height: UIScreen.main.bounds.size.height / 3)
                        .background(showMoveArea ? Color.black.opacity(0.05) : Color.black.opacity(0))
                        .contentShape(Rectangle())
                        .gesture(DragGesture()
                            .onChanged { value in
                                if(gameRunning) {
                                    let _ = carPositionX = (value.location.x - (UIScreen.main.bounds.size.width / 2))
                                    
                                    let laneNumber = (carPositionX / roadWidth) + 2
                                    var roundedLaneNumber = Int(round(laneNumber))
                                    
                                    //make sure the current lane isn't out of bounds
                                    if(roundedLaneNumber < 0) {
                                        roundedLaneNumber = 0
                                    }
                                    else if(roundedLaneNumber > 4) {
                                        roundedLaneNumber = 4
                                    }
                                    
                                    currentCarLane[0] = roundedLaneNumber
                                    print(laneNumber)
                                    
                                    
//                                    let laneDecimal = laneNumber.truncatingRemainder(dividingBy: 1)
//                                    
//                                    if(laneDecimal > 0.4) {
//                                        if(roundedLaneNumber != 4 && laneDecimal < 0.6) {
//                                            currentCarLane[1] = Int(round(laneNumber)) + 1
//                                        }
//                                    }
//                                    else if(laneDecimal < 0.6) {
//                                        if(roundedLaneNumber != 0 && laneDecimal > 0.4) {
//                                            currentCarLane[1] = Int(round(laneNumber)) - 1
//                                        }
//                                    }
//                                    else {
//                                        currentCarLane[1] = -1
//                                    }
                                }
                            }
                        )
                    
                }
                
                VStack {
                    HStack(alignment: .top) {
                        Button() {
                            currentPopupOpen = PopupType.GamePaused
                            endGame()
                        } label: {
                            Image(systemName: "pause.fill")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 60, height: 60)
                                .foregroundColor(Color(red: 0.2, green: 0.2, blue: 0.2))
                        }.padding(5)
                        Spacer()
                        Text(String(Int(distanceTraveled)) + "ft")
                            .font(.custom("ChalkboardSE-Bold", size: 30))
                    }
                    Spacer()
                }
                
                if(currentPopupOpen == PopupType.GameOver) {
                    VStack {
                        Text("Game Over")
                            .font(.custom("ChalkboardSE-Bold", size: 35))
                        
                        Text("You traveled " + String(Int(distanceTraveled)) + " feet")
                            .font(.custom("ChalkboardSE-Bold", size: 25))
                        
                        HStack {
                            Button() {
                                currentWindowOpen = WindowType.Home
                            } label: {
                                Image(systemName: "house.fill")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 66, height: 66)
                                    .foregroundColor(Color.gray)
                            }.padding(.horizontal, 15)
                            
                            Button() {
                                startGame()
                            } label: {
                                Image(systemName: "gobackward")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 66, height: 66)
                                    .foregroundColor(Color.gray)
                            }.padding(.horizontal, 15)
                        }
                        
                    }
                    .padding([.horizontal, .bottom], 50)
                    .background(Color.yellow)
                }
                else if(currentPopupOpen == PopupType.GamePaused) {
                    VStack {
                        Text("Game Paused")
                            .font(.custom("ChalkboardSE-Bold", size: 35))
                        
                        Text("You traveled " + String(Int(distanceTraveled)) + " feet")
                            .font(.custom("ChalkboardSE-Bold", size: 25))
                        
                        HStack {
                            Button() {
                                currentWindowOpen = WindowType.Home
                            } label: {
                                Image(systemName: "house.fill")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 66, height: 66)
                                    .foregroundColor(Color.gray)
                            }.padding(.horizontal, 15)
                            
                            Button() {
                                currentPopupOpen = PopupType.None
                                gameRunning = true
                            } label: {
                                Image(systemName: "play.fill")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 66, height: 66)
                                    .foregroundColor(Color.gray)
                            }.padding(.horizontal, 15)
                        }
                        
                    }
                    .padding([.horizontal, .bottom], 50)
                    .background(Color.orange)
                }
                
            }
            .background(Color.blue)
        }
    }
}

#Preview {
    ContentView()
}
