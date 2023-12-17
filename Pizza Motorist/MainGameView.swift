//
//  MainGameView.swift
//  Pizza Motorist
//
//  Created by Vadim Shicha on 12/14/23.
//

import SwiftUI

struct MainGameView: View {
    let timer = Timer.publish(every: 0.003, tolerance: 0.0003, on: .main, in: .common).autoconnect()
    
    @State private var carGenerator: CarGenerator = CarGenerator()
    
    @State private var carElements = [[CarElement]](); //array of array with Cars
    
    @State private var fallingVar: CGFloat = 50
    
    let carWidth = 70.0 / 1.2
    let carHeight = 109.375 / 1.2
    
    let roadWidth = 70.0
    let roadHeight = 109.375
    
    let carSpeed: CGFloat = 3
    @State private var carSpeedMultiplier: CGFloat = 1
    
    @State private var currentCarLane: [Int] = [2, -1]
    @State private var distanceTraveled: CGFloat = 0.0
    
    @State private var carPositionX: CGFloat = 0
    @State private var carPositionY: CGFloat = 0
    
    @State private var gameRunning: Bool = true
    
    @State private var showMoveArea = false
    
    @State private var currentPopupOpen: PopupType = PopupType.None
    
    @Binding var currentWindowOpen: WindowType
    @Binding var quests: [Quest]
    
    @Binding var coinAmount: Int
    @Binding var bestDistance: Int
    
    func getScreenYWithYLane(yLane: Int) -> CGFloat {
        
        //-(12 * carHeight - UIScreen.main.bounds.size.height) / 2.0 + (6 * carHeight) + (carHeight / 2) + fallingVar
        
        let firstLaneY = -(12 * roadHeight - UIScreen.main.bounds.size.height) / 2.0
        let lane = firstLaneY + (Double(yLane) * roadHeight)
                    
        return lane + (roadHeight / 2) + fallingVar
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
        //saveData()
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
        //currentWindowOpen = WindowType.MainGame
        
        carPositionX = 0
        currentCarLane = [2, -1]
        distanceTraveled = 0.0
        
        currentPopupOpen = PopupType.None
        gameRunning = true
        
        carElements = [[CarElement]]()
        setupGame()
    }
    
    var body: some View {
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
                
                //print(abs(getScreenYWithYLane(yLane: 6) - UIScreen.main.bounds.size.height + roadHeight - 10))
                
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
                                //print(laneNumber)
                                
                                
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
        .onAppear {
            startGame()
        }
    }
}

#Preview {
    MainGameView(currentWindowOpen: .constant(WindowType.Home), quests: .constant([]), coinAmount: .constant(0), bestDistance: .constant(0))
}
