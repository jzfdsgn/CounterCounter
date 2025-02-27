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
    @State private var dragOffset: CGFloat = 0
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Main content
                playerCountersView()
                
                // Side menu indicators
                HStack {
                    // Left edge indicator
                    Rectangle()
                        .fill(Color.gray.opacity(0.3))
                        .frame(width: 5)
                        .opacity(dragOffset > 0 ? 1 : 0)
                    
                    Spacer()
                    
                    // Right edge indicator
                    Rectangle()
                        .fill(Color.gray.opacity(0.3))
                        .frame(width: 5)
                        .opacity(dragOffset < 0 ? 1 : 0)
                }
                .ignoresSafeArea()
            }
            .gesture(
                DragGesture()
                    .onChanged { value in
                        self.dragOffset = value.translation.width
                    }
                    .onEnded { value in
                        let threshold = geometry.size.width * 0.2
                        
                        if value.translation.width > threshold {
                            // Swiped right - show remove player menu
                            if settings.numberOfPlayers > 1 {
                                settings.numberOfPlayers -= 1
                            }
                        } else if value.translation.width < -threshold {
                            // Swiped left - show add player menu
                            if settings.numberOfPlayers < 4 {
                                settings.numberOfPlayers += 1
                            }
                        }
                        
                        // Reset drag offset
                        self.dragOffset = 0
                    }
            )
            .onLongPressGesture {
                showingPreferences = true
            }
            .sheet(isPresented: $showingPreferences) {
                PreferencesView()
            }
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
