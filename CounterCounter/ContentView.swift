//
//  ContentView.swift
//  CounterCounter
//
//  Created by Jozef on 2/21/25.
//

import SwiftUI

struct ContentView: View {
    @ObservedObject private var settings = AppSettings.shared
    @State private var showingPreferences = false
    @State private var horizontalDragOffset: CGFloat = 0
    @State private var verticalDragOffset: CGFloat = 0
    @State private var showingSideMenu = false
    @State private var isLeftMenu = false
    
    private let menuWidth: CGFloat = 60
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Main content
                playerCountersView()
                    .offset(x: horizontalDragOffset, y: verticalDragOffset)
                    .animation(.interactiveSpring(), value: horizontalDragOffset)
                    .animation(.interactiveSpring(), value: verticalDragOffset)
                
                // Add Player indicator (right side)
                HStack(spacing: 0) {
                    Spacer()
                    indicatorView(systemName: "plus.square.fill", width: menuWidth)
                        .offset(x: horizontalDragOffset + menuWidth)
                }
                .opacity(horizontalDragOffset < 0 ? 1 : 0)
                
                // Remove Player indicator (left side)
                HStack(spacing: 0) {
                    indicatorView(systemName: "minus.square.fill", width: menuWidth)
                        .offset(x: horizontalDragOffset - menuWidth)
                    Spacer()
                }
                .opacity(horizontalDragOffset > 0 ? 1 : 0)
                
                // Preferences indicator
                indicatorView(systemName: "gearshape.fill", width: geometry.size.width)
                    .frame(maxHeight: .infinity, alignment: .top)
                    .offset(y: -menuWidth + verticalDragOffset)
                    .opacity(verticalDragOffset > 0 ? 1 : 0)
            }
            .gesture(
                DragGesture()
                    .onChanged { value in
                        // Determine if the drag is more horizontal or vertical
                        let horizontalDrag = abs(value.translation.width) > abs(value.translation.height)
                        
                        if horizontalDrag {
                            self.horizontalDragOffset = value.translation.width
                            self.verticalDragOffset = 0
                        } else if value.translation.height >= 0 { // Only allow downward swipes
                            self.verticalDragOffset = value.translation.height
                            self.horizontalDragOffset = 0
                        }
                    }
                    .onEnded { value in
                        let horizontalThreshold = geometry.size.width * 0.2
                        let verticalThreshold = geometry.size.height * 0.2
                        
                        withAnimation(.spring()) {
                            // Handle horizontal swipes
                            if abs(value.translation.width) > abs(value.translation.height) {
                                if value.translation.width > horizontalThreshold {
                                    // Swiped right - decrease player count
                                    if settings.numberOfPlayers > 1 {
                                        settings.numberOfPlayers -= 1
                                    }
                                } else if value.translation.width < -horizontalThreshold {
                                    // Swiped left - increase player count
                                    if settings.numberOfPlayers < 4 {
                                        settings.numberOfPlayers += 1
                                    }
                                }
                            }
                            // Handle vertical swipes (downward only)
                            else if value.translation.height > verticalThreshold {
                                // Swiped down - show preferences
                                self.showingPreferences = true
                            }
                            
                            // Reset positions
                            self.horizontalDragOffset = 0
                            self.verticalDragOffset = 0
                        }
                    }
            )
        }
        .sheet(isPresented: $showingPreferences) {
            PreferencesView()
        }
    }
    
    @ViewBuilder
    private func indicatorView(systemName: String, width: CGFloat) -> some View {
        ZStack {
            Rectangle()
                .fill(.clear)
                .frame(width: width, height: menuWidth)
            
            Image(systemName: systemName)
                .font(.system(size: 32))
                .foregroundColor(.primary)
                .animation(.none) // Prevent icon animation
        }
    }
    
    @ViewBuilder
    private func playerCountersView() -> some View {
        switch settings.numberOfPlayers {
        case 1:
            CounterView(playerNumber: 1)
        case 2:
            VStack(spacing: 0) {
                CounterView(playerNumber: 1)
                CounterView(playerNumber: 2)
            }
        case 3:
            VStack(spacing: 0) {
                CounterView(playerNumber: 1)
                HStack(spacing: 0) {
                    CounterView(playerNumber: 2)
                    CounterView(playerNumber: 3)
                }
            }
        case 4:
            VStack(spacing: 0) {
                HStack(spacing: 0) {
                    CounterView(playerNumber: 1)
                    CounterView(playerNumber: 2)
                }
                HStack(spacing: 0) {
                    CounterView(playerNumber: 3)
                    CounterView(playerNumber: 4)
                }
            }
        default:
            CounterView(playerNumber: 1)
        }
    }
}

#Preview {
    ContentView()
}
