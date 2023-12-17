//
//  ContentView.swift
//  Pizza Motorist
//
//  Created by Vadim Shicha on 11/25/23.
//

import SwiftUI

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

enum PopupType {
    case None, Quest, Shop, Stats, Settings, CarSelect, GameOver, GamePaused
}

enum WindowType {
    case Home, MainGame
}

struct ContentView: View {

    @State private var currentWindowOpen: WindowType = WindowType.Home
    @State private var currentPopupOpen: PopupType = PopupType.None
    
    let homeTabColor = Color(red: 128 / 255, green: 78 / 255, blue: 32 / 255)
    let homeTabColorSelected = Color(red: 115 / 255, green: 69 / 255, blue: 25 / 255)
    
    @State private var totalQuestsComplete: Int = 0
    
    @State var quests: [Quest] = [
        QuestManager.generateQuest(),
        QuestManager.generateQuest(),
        QuestManager.generateQuest()
    ]
    
    @State var coinAmount: Int = 100
    @State var bestDistance: Int = 0
    
    
//    @State private var gameRunning: Bool = true
    
//    @State private var showMoveArea = false
    
    @State private var startRan = false
    
    @State private var shopCars: [GarageCar] = [
        GarageCar(title: "Blue Car Splat", name: "BlueCarSplat", price: 80),
        GarageCar(title: "Red Car Splat", name: "BlueCarSplat", price: 100)
    ]
    
    @State private var ownedCars: [GarageCar] = [
        GarageCar(title: "Default Car", name: "BlueCar")
    ]
    
    @State private var gameDataLoaded: Bool = false
    
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

    //these variables are used when displaying the player car
    let carWidth = 70.0 / 1.2
    let carHeight = 109.375 / 1.2
    
    //saves app data variables to player data
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
    
    //loads all the player data to app variables
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
    
    //deletes all the player data
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
    
    //if game data has been loaded, save player data otherwise load it
    func updateGameData() {
        if(gameDataLoaded) {
            saveData()
        }
        else {
            gameDataLoaded = true
            loadData()
        }
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
                        ///////////////startGame()
                        currentWindowOpen = WindowType.MainGame
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
//                            Toggle("Show move area", isOn: $showMoveArea)
//                                .font(.custom("ChalkboardSE-Bold", size: 25))
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
                updateGameData()
            }
        }
        else if(currentWindowOpen == WindowType.MainGame) {
            MainGameView(currentWindowOpen: $currentWindowOpen, quests: $quests, coinAmount: $coinAmount, bestDistance: $bestDistance)
        }
    }
}

#Preview {
    ContentView()
}
