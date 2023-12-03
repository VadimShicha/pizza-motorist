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
        //print(holeCount)
        
        if(holeCount == 3) {
            holeCount = 0
            
            var carArr = [CarElement]()
            
            var holeIndex = Int.random(in: 0...4)
            
            for i in 0...4 {
                
                if(i != holeIndex) {
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

enum QuestType {
    case DriveDistance
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
        
        return ""
    }
}

struct ContentView: View {
    
    enum WindowType {
        case Home, MainGame
    }
    
    enum PopupType {
        case None, Quest, Shop, News, Settings, GameOver, GamePaused
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
    
    let carWidth = 70.0
    let carHeight = 109.375
    
    let carSpeed: CGFloat = 3
    
    let homeTabColor = Color(red: 128 / 255, green: 78 / 255, blue: 32 / 255)
    let homeTabColorSelected = Color(red: 115 / 255, green: 69 / 255, blue: 25 / 255)
    
    @State private var currentCarLane: [Int] = [2, -1]
    @State private var distanceTraveled: CGFloat = 0.0
    
    @State private var gameRunning: Bool = true
    
    @State private var showMoveArea = true
    
    @State private var quests: [Quest] = [
        Quest(type: QuestType.DriveDistance, value: 1000, reward: 100),
        Quest(type: QuestType.DriveDistance, value: 10000, reward: 200),
        Quest(type: QuestType.DriveDistance, value: 20000, reward: 300)
    ]
    
    //if closed, opens the popup. Otherwise, close the popup
    func togglePopup(name: PopupType) {
        if(currentPopupOpen == name) {
            currentPopupOpen = PopupType.None
        }
        else {
            currentPopupOpen = name
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
            
        gameRunning = false
        
        coinAmount += Int(round(distanceTraveled / 10))
    }
    
    func getScreenYWithYLane(yLane: Int) -> CGFloat {
        
        //-(12 * carHeight - UIScreen.main.bounds.size.height) / 2.0 + (6 * carHeight) + (carHeight / 2) + fallingVar
        
        let firstLaneY = -(12 * carHeight - UIScreen.main.bounds.size.height) / 2.0
        let lane = firstLaneY + (Double(yLane) * carHeight)
                    
        return lane + (carHeight / 2) + fallingVar
    }
    
    var body: some View {

        if(currentWindowOpen == WindowType.Home) {
            ZStack {
                
                VStack(spacing: 0) {
                    Text("Pizza Motorist")
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
                                
                            } label: {
                                Text("Change Car")
                                    .font(.custom("ChalkboardSE-Bold", size: 15))
                                    .foregroundColor(Color.green)
                            }
                        }
                        Spacer()
                    }
                    
                    
                    
                    Spacer()
//                    HStack {
//                        Spacer()
//                    }
                    
                    Text("Tap to play!")
                        .font(.custom("ChalkboardSE-Bold", size: 24))
                        .padding(25)
                }
                .contentShape(Rectangle())
                .onTapGesture {
                    /* when the VStack is tapped (not a button on the stack),
                    start the game */
                    startGame()
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
                                togglePopup(name: PopupType.News)
                            } label: {
                                Image(systemName: "newspaper")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 66, height: 66)
                                    .foregroundColor(Color.green)
                                    .padding(5)
                                    .background(currentPopupOpen == PopupType.News ? homeTabColorSelected : homeTabColor)
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
                
                if(currentPopupOpen == PopupType.Quest) {
                    VStack {
                        Text("Quests")
                            .font(.custom("ChalkboardSE-Bold", size: 35))
                        
                        ForEach(0...2, id: \.self) { i in
                            VStack {
                                HStack {
                                    Text(quests[i].getQuestTitle())
                                        .font(.custom("ChalkboardSE-Bold", size: 20))
                                        .foregroundColor(Color.gray)
                                    Spacer()
                                    Button() {
                                        
                                    } label: {
                                        HStack {
                                            Text(String(quests[i].reward))
                                                .font(.custom("ChalkboardSE-Bold", size: 20))
                                                .foregroundColor(Color.red)
                                                .padding(1)
                                            Image("Coin")
                                                .resizable()
                                                .scaledToFit()
                                                .frame(width: 25, height: 25)
                                        }
                                        
                                    }
                                    .padding(3)
                                    .background(Color.brown)
                                    .cornerRadius(5)
                                }
                                
                                Text(String(quests[i].progress) + " / " + String(quests[i].valueNeeded))
                                    .font(.custom("ChalkboardSE-Bold", size: 18))
                                    .foregroundColor(Color.red)
                                
                            }.padding(8)
                            
                        }
                    }
                    .frame(maxWidth: UIScreen.main.bounds.size.width - 80)
                    .background(Color.yellow)
                    .padding(.trailing, 80)
                    .padding(.leading, 3)
                }
                else if(currentPopupOpen == PopupType.Shop) {
                    VStack {
                        Text("Shop")
                            .font(.custom("ChalkboardSE-Bold", size: 35))

                        Button() {
                            
                        } label: {
                            Image(systemName: "cart.fill")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 66, height: 66)
                                .foregroundColor(Color.gray)
                        }
                        
                        
                    }
                    .frame(maxWidth: UIScreen.main.bounds.size.width - 80)
                    .padding(.bottom, 40)
                    .background(Color.orange)
                    .padding(.trailing, 80)
                    .padding(.leading, 3)
                }
                else if(currentPopupOpen == PopupType.News) {
                    VStack {
                        Text("News")
                            .font(.custom("ChalkboardSE-Bold", size: 35))

                        Button() {
                            
                        } label: {
                            Image(systemName: "newspaper")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 66, height: 66)
                                .foregroundColor(Color.gray)
                        }
                        
                    }
                    .frame(maxWidth: UIScreen.main.bounds.size.width - 80)
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
                            //Text("Show move area")
                                //.font(.custom("ChalkboardSE-Bold", size: 25))
                           
                            Toggle("Show move area", isOn: $showMoveArea)
                                .font(.custom("ChalkboardSE-Bold", size: 25))
                        }
                        .padding(8)
                        
                        
                    }
                    .frame(maxWidth: UIScreen.main.bounds.size.width - 80)
                    .background(Color.gray)
                    .padding(.trailing, 80)
                    .padding(.leading, 3)
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
                                            .frame(width: carWidth, height: carHeight)
                                        Image(car.imageName)
                                            .resizable()
                                            .frame(width: carWidth, height: carHeight)
                                    }
                                }
                                else {
                                    Image("Road")
                                        .resizable()
                                        .frame(width: carWidth, height: carHeight)
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
                            .frame(width: carWidth, height: carHeight)
                    }.padding(25)
                }
                .onReceive(timer) { time in
                    if(gameRunning) {
                        fallingVar += carSpeed / 2
                        distanceTraveled += 0.1
                    }
                    
                    //detect car collisions
                    for i in 0...4 {
                        //if the player car is colliding with a car
                        if((carElements[6][i].carType == CarElementType.Car ||
                            carElements[7][i].carType == CarElementType.Car) &&
                           (currentCarLane[0] == i || currentCarLane[1] == i)) {
                            
                            //let _ = print(abs(getScreenYWithYLane(yLane: 6) - UIScreen.main.bounds.size.height + 135))
                            
                            if(abs(getScreenYWithYLane(yLane: 6) - UIScreen.main.bounds.size.height + 135) <= carHeight) {
                                endGame()
                                currentPopupOpen = PopupType.GameOver
                            }
                        }
                    }
                    
                    //loop the car back to top of array when it reaches the bottom
                    if(fallingVar >= carHeight + 0) {
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
                        .gesture(DragGesture()
                            .onChanged { value in
                                if(gameRunning) {
                                    let _ = carPositionX = (value.location.x - (UIScreen.main.bounds.size.width / 2))
                                    
                                    let laneNumber = (carPositionX / carWidth) + 2
                                    var roundedLaneNumber = Int(round(laneNumber))
                                    
                                    //make sure the current lane isn't out of bounds
                                    if(roundedLaneNumber < 0) {
                                        roundedLaneNumber = 0
                                    }
                                    else if(roundedLaneNumber > 4) {
                                        roundedLaneNumber = 4
                                    }
                                    
                                    currentCarLane[0] = roundedLaneNumber
                                    
                                    if(roundedLaneNumber != 0 &&
                                       laneNumber.truncatingRemainder(dividingBy: 1) < 0.7 &&
                                       laneNumber.truncatingRemainder(dividingBy: 1) > 0.4) {
                                        
                                        currentCarLane[1] = Int(round(laneNumber)) - 1
                                    }
                                    else if(roundedLaneNumber != 4 &&
                                            laneNumber.truncatingRemainder(dividingBy: 1) > 0.3 &&
                                            laneNumber.truncatingRemainder(dividingBy: 1) < 0.7) {
                                        
                                        currentCarLane[1] = Int(round(laneNumber)) + 1
                                    }
                                    else {
                                        currentCarLane[1] = -1
                                    }
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
