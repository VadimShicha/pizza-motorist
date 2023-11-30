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
    @State private var currentWindowOpen: WindowType = WindowType.Home
    @State private var currentPopupOpen: PopupType = PopupType.None
    
    @State private var carElements = [[CarElement]](); //array of array with Cars
    @State private var carPositionX: CGFloat = 0
    
    @State private var fallingVar: CGFloat = 0
    
    @State private var carGenerator: CarGenerator = CarGenerator()
    
    enum WindowType {
        case Home, MainGame
    }
    
    enum PopupType {
        case None, Quest, News, Settings
    }
    
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
        
        carElements[7][0] = CarElement(eType: CarElementType.Car, name: "RedCar")
    }

    //changes the window while also setting up all the game elements
    func startGame() {
        currentWindowOpen = WindowType.MainGame
        
        if(carElements.count == 0) {
            setupGame()
        }
    }
    
    let timer = Timer.publish(every: 0.0015, tolerance: 0.00015, on: .main, in: .common).autoconnect()
    
    let carWidth = 70.0
    let carHeight = 109.375
    
    let carSpeed: CGFloat = 2
    
    @State private var currentCarLane: Int = 2
    
    @State private var gameRunning: Bool = true
    //var activeCarPositionArray = [[CGFloat]]
    
    var body: some View {

        if(currentWindowOpen == WindowType.Home) {
            ZStack {
                VStack {
                    Text("Pizza Motorist")
                        .font(.custom("ChalkboardSE-Bold", size: 45))
                        .padding(5)
                    
                    Spacer()
                    HStack {
                        Spacer()
                        Button() {
                            togglePopup(name: PopupType.Quest)
                        } label: {
                            Image("pencil.and.list.clipboard")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 76, height: 76)
                        }
                    }
                    HStack {
                        Spacer()
                        Button() {
                            togglePopup(name: PopupType.News)
                        } label: {
                            Image(systemName: "newspaper")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 66, height: 66)
                                .foregroundColor(Color.green)
                        }
                    }
                    HStack {
                        Spacer()
                        Button() {
                            togglePopup(name: PopupType.Settings)
                        } label: {
                            Image(systemName: "gearshape.fill")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 66, height: 66)
                                .foregroundColor(Color.gray)
                        }
                    }
                    
                    Spacer()
                    Text("Tap to play!")
                        .font(.custom("ChalkboardSE-Bold", size: 24))
                        .padding(25)
                }
                    .background(Color("HomeBackgroundColor"))
                    .contentShape(Rectangle())
                    .onTapGesture {
                        /* when the VStack is tapped (not a button on the stack),
                        start the game */
                        startGame()
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
        }
        else if(currentWindowOpen == WindowType.MainGame) {
            if(!gameRunning) {
                let _ = (currentWindowOpen = WindowType.Home)
            }
            ZStack {
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
                          y: UIScreen.main.bounds.size.height / 2 + carHeight + CGFloat(fallingVar))
                .contentShape(Rectangle())
                .onTapGesture {
                    currentWindowOpen = WindowType.Home
                }
                
                VStack {
                    Spacer()
                    HStack {
                        ZStack {
                            Image("BlueCar")
                                .resizable()
                                .position(x: carPositionX + carWidth / 2)
                                .frame(width: carWidth, height: carHeight)
                        }
                        
                    }.padding(50)
                }
                .onReceive(timer) { time in
                    fallingVar += carSpeed / 2
                    
                    //detect car collisions
                    for i in 0...4 {
                        if(carElements[6][i].carType == CarElementType.Car && currentCarLane == i) {
                            print("LOSE")
                            gameRunning = false
                        }
                    }

                    //loop the car back to top of array when it reaches the bottom
                    if(fallingVar >= carHeight + 0) {
                        fallingVar = 0
                        
                        carElements.removeLast()
                        carElements.insert(carGenerator.generateNextRow(), at: 0)
                    }
                }
                
                VStack {
                    Spacer()
                    HStack {
                        
                    }
                    .frame(width: UIScreen.main.bounds.size.width,
                           height: UIScreen.main.bounds.size.height / 3)
                    .background(Color.red.opacity(0.1))
                    .gesture(DragGesture()
                        .onChanged { value in
                            let _ = carPositionX = (value.location.x - (UIScreen.main.bounds.size.width / 2))
                            
                            currentCarLane = (Int(round(carPositionX / carWidth)) + 2)
                        }
                    )
                        
                }
            }
            .background(Color.blue)
        }
    }
}

#Preview {
    ContentView()
}
