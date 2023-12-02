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

struct ContentView: View {
    
    enum WindowType {
        case Home, MainGame
    }
    
    enum PopupType {
        case None, Quest, News, Settings, GameOver
    }
    
    @State private var coinAmount: Int = 0
    
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
    
    
    @State private var currentCarLane: [Int] = [2, -1]
    @State private var distanceTraveled: CGFloat = 0.0
    
    @State private var gameRunning: Bool = true
    
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
    
    func getScreenYWithYLane(yLane: Int) -> CGFloat {
        
        //-(12 * carHeight - UIScreen.main.bounds.size.height) / 2.0 + (6 * carHeight) + (carHeight / 2) + fallingVar
        
        let firstLaneY = -(12 * carHeight - UIScreen.main.bounds.size.height) / 2.0
        let lane = firstLaneY + (Double(yLane) * carHeight)
                    
        return lane + (carHeight / 2) + fallingVar
    }
    
    var body: some View {

        if(currentWindowOpen == WindowType.Home) {
            ZStack {
                
                VStack {
                    Text("Pizza Motorist")
                        .font(.custom("ChalkboardSE-Bold", size: 45))
                        .padding(.top, 5)
                    Text("Coins: " + String(coinAmount))
                        .font(.custom("ChalkboardSE-Bold", size: 35))
                        .foregroundColor(Color.yellow)
                    
                    
                    Spacer()
                    HStack {
                        Spacer()
                    }
                    
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
                                    .background(currentPopupOpen == PopupType.Quest ? Color(red: 0.4, green: 0.4, blue: 0.4) : Color.gray)
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
                                    .background(currentPopupOpen == PopupType.News ? Color(red: 0.4, green: 0.4, blue: 0.4) : Color.gray)
                            }
                            Button() {
                                togglePopup(name: PopupType.Settings)
                            } label: {
                                Image(systemName: "gearshape.fill")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 66, height: 66)
                                    .foregroundColor(Color.red)
                                    .padding(5)
                                    .background(currentPopupOpen == PopupType.Settings ? Color(red: 0.4, green: 0.4, blue: 0.4) : Color.gray)
                            }
                        }
                        .background(Color.gray)
                        .cornerRadius(8)
                    }
                    Spacer()
                }
                
                if(currentPopupOpen == PopupType.Quest) {
                    VStack {
                        Text("Quests")
                            .font(.custom("ChalkboardSE-Bold", size: 35))

                        Button() {
                            
                        } label: {
                            Image(systemName: "gearshape.fill")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 66, height: 66)
                                .foregroundColor(Color.gray)
                        }
                        
                    }
                    .padding([.horizontal, .bottom], 50)
                    .background(Color.yellow)
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
                    .padding([.horizontal, .bottom], 50)
                    .background(Color.green)
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
                        
                    }
                    .padding([.horizontal, .bottom], 50)
                    .background(Color.gray)
                }
            }
            .background(Color("HomeBackgroundColor"))
        }
        else if(currentWindowOpen == WindowType.MainGame) {

            //let _ = print(-((12 * carHeight) - UIScreen.main.bounds.size.height))
            ZStack {
                
                    Text("BLAH")
                    .position(x: 0, y: getScreenYWithYLane(yLane: 6))
                
                
                
                
                
//                VStack {
//                    //var index = 0
//                    ForEach(0..<carElements.count) { i in
//                        HStack {
//                            Spacer()
//                            ForEach(carElements[i], id: \.self) { car in
//                                if(car.carType == CarElementType.Car) {
//                                    ZStack {
//                                        Image("Road")
//                                            .resizable()
//                                            .frame(width: carWidth, height: carHeight)
//                                        Image(car.imageName)
//                                            .resizable()
//                                            .frame(width: carWidth, height: carHeight)
//                                    }
//                                    //.position(y: car.position[1])
//                                }
//                                else {
//                                    Image("Road")
//                                        .resizable()
//                                        .frame(width: carWidth, height: carHeight)
//                                        //.position(y: car.position[1] + fallingVar)
//                                }
//                            }
//                            Spacer()
//                            
//                        }
//                        .position(y: (i * carHeight) + CGFloat(fallingVar))
//                        
//                        let _ = print(i)
//                        //index += 1
//                    }
//                }
                
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
                        if(carElements[6][i].carType == CarElementType.Car && (currentCarLane[0] == i || currentCarLane[1] == i)) {
                            let _ = print(abs(getScreenYWithYLane(yLane: 5) - UIScreen.main.bounds.size.height + 235))
                            if(abs(getScreenYWithYLane(yLane: 6) - UIScreen.main.bounds.size.height + 135) <= carHeight || abs(getScreenYWithYLane(yLane: 5) - UIScreen.main.bounds.size.height + 235) <= carHeight) {
                                gameRunning = false
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
                    .background(Color.red.opacity(0.1))
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
                            currentWindowOpen = WindowType.Home
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
                            }.padding(.horizontal, 5)
                            
                            Button() {
                                startGame()
                            } label: {
                                Image(systemName: "gobackward")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 66, height: 66)
                                    .foregroundColor(Color.gray)
                            }.padding(.horizontal, 5)
                        }
                        
                    }
                    .padding([.horizontal, .bottom], 50)
                    .background(Color.yellow)
                }
            }
            .background(Color.blue)
        }
    }
}

#Preview {
    ContentView()
}
