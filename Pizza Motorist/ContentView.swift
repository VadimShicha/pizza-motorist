//
//  ContentView.swift
//  Pizza Motorist
//
//  Created by Vadim Shicha on 11/25/23.
//

import SwiftUI

struct ContentView: View {
    @State private var currentWindowOpen: WindowType = WindowType.Home
    @State private var currentPopupOpen: PopupType = PopupType.None
    
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
                        change the window */
                        currentWindowOpen = WindowType.MainGame
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
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    Text("Main Game")
                    Spacer()
                }
                
                Spacer()
            }
            .background(Color.blue)
            .contentShape(Rectangle())
            .onTapGesture {
                currentWindowOpen = WindowType.Home
            }
        }
    }
}

#Preview {
    ContentView()
}
