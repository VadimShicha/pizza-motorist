//
//  ContentView.swift
//  Pizza Motorist
//
//  Created by Vadim Shicha on 11/25/23.
//

import SwiftUI

struct CarGenerator {
    @State private var carsLastGenerated: Bool = false
    
    func generateNextRow() {
        carsLastGenerated = !carsLastGenerated
    }
}

enum CarElementType {
    case None, Car
}

struct CarElement: Hashable {
    var imageName = ""
    var carType: CarElementType = CarElementType.None
    
    init(eType: CarElementType = CarElementType.None, name: String) {
        carType = eType
        imageName = name
    }
}

struct ContentView: View {
    @State private var currentWindowOpen: WindowType = WindowType.Home
    @State private var currentPopupOpen: PopupType = PopupType.None
    
    @State private var carElements = [[CarElement]](); //array of array with Cars
    @State private var carPositionX: CGFloat = 0
    
    @State private var fallingVar: CGFloat = 0
    
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
        for _ in 1...10 {
            carElements.append([CarElement(name: "RedCar"),CarElement(name: "RedCar"),CarElement(name: "RedCar"),CarElement(name: "RedCar"),CarElement(name: "RedCar")])
        }
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
            ZStack {
                VStack {
                    ForEach(carElements, id: \.self) { carArray in
                        HStack {
                            ForEach(carArray, id: \.self) { car in
                                Image(car.imageName)
                                    .resizable()
                                    .frame(width: carWidth, height: carHeight)
                            }
                        }
                    }
                    Spacer()
                }
                .background(Color.gray)
                .position(x: UIScreen.main.bounds.size.width / 2,
                          y: UIScreen.main.bounds.size.height / 2 + carHeight + CGFloat(fallingVar))
                .contentShape(Rectangle())
                .onTapGesture {
                    currentWindowOpen = WindowType.Home
                }
                
                
                VStack {
                    Spacer()
                    HStack {
                        
                    }
                    .frame(width: UIScreen.main.bounds.size.width,
                           height: UIScreen.main.bounds.size.height / 4)
                    .background(Color.red.opacity(0.2))
                    .gesture(DragGesture()
                        .onChanged { value in
                            let _ = (carPositionX = value.location.x - (UIScreen.main.bounds.size.width / 2))
                        }
                    )
                        
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
//                    fallingVar += 0.6
//                    
//                    if(fallingVar >= carHeight + 7.5) {
//                        fallingVar = 0
//                    }
                }
            }
            .background(Color.blue)
        }
    }
}

#Preview {
    ContentView()
}
