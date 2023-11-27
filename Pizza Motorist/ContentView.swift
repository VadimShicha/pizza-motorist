//
//  ContentView.swift
//  Pizza Motorist
//
//  Created by Vadim Shicha on 11/25/23.
//

import SwiftUI

struct CarElement: Hashable {
    var imageName = ""
    
    init(name: String) {
        imageName = name
    }
}



struct ContentView: View {
    @State private var currentWindowOpen: WindowType = WindowType.Home
    @State private var currentPopupOpen: PopupType = PopupType.None
    
    @State private var sliderValue: Double = 0
    
    @State private var carElements = [[CarElement]](); //array of array with Cars
    
    @State private var fallingVar: CGFloat = 0
    
    enum WindowType {
        case Home, MainGame
    }
    
    enum PopupType {
        case None, Quest, News, Settings
    }
    
    func togglePopup(name: PopupType) {
        if(currentPopupOpen == name) {
            currentPopupOpen = PopupType.None
        }
        else {
            currentPopupOpen = name
        }
    }
    
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
                        .font(.custom("AmericanTypewriter", size: 45))
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
                        .font(.custom("AmericanTypewriter", size: 20))
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
                        Button() {
                            
                        } label: {
                            Image(systemName: "gearshape.fill")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 66, height: 66)
                                .foregroundColor(Color.gray)
                        }
                    }.background(Color.red)
                }
                else if(currentPopupOpen == PopupType.Settings) {
                    VStack {
                        Button() {
                            
                        } label: {
                            Image(systemName: "gearshape")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 66, height: 66)
                                .foregroundColor(Color.gray)
                        }
                    }.background(Color.red)
                }
                
            }
        }
        else if(currentWindowOpen == WindowType.MainGame) {
            ZStack {
                VStack {
                    
                }
                .background(Color.blue)
                //let cars: [Int] = [0, 1, 2, 3, 4]
                
                
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
                //.padding(.top, CGFloat(fallingVar))
                .contentShape(Rectangle())
                .onTapGesture {
                    currentWindowOpen = WindowType.Home
                }
                
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        ZStack {
                            Image("BlueCar")
                                .resizable()
                                .position(x: carWidth * sliderValue + (carWidth / 2))
                                .frame(width: carWidth, height: carHeight)
                            Slider(value: $sliderValue, in: -2...2, step: 1)
                        }
                        
                        Spacer()
                    }.padding(50)
                }
                .onReceive(timer) { time in
                    fallingVar += 0.6
                    
                    if(fallingVar >= carHeight + 7.5) {
                        fallingVar = 0
                    }
                }
            }
            .background(Color.blue)
        }
    }
}

#Preview {
    ContentView()
}
