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
    @State private var showingActionMenu = false
    @State private var menuOffset: CGFloat = 0
    @State private var settingsResetTrigger = UUID()
    
    var body: some View {
        GeometryReader { geometry in
            let menuWidth = geometry.size.width * 0.75 // Menu takes up 75% of screen width
            
            ZStack(alignment: .leading) {
                // Main content (gets pushed to the left when menu is shown)
                playerCountersView()
                    .offset(x: showingActionMenu ? -menuWidth + 80 : 0)
                    .animation(.spring(response: 0.4, dampingFraction: 0.8), value: showingActionMenu)
                
                // Action menu (slides in from right)
                HStack(spacing: 0) {
                    Spacer()
                    actionMenuView(screenHeight: geometry.size.height)
                        .frame(width: menuWidth)
                        .background(Color(red: 0.95, green: 0.95, blue: 0.95))
                }
                .offset(x: showingActionMenu ? 0 : menuWidth)
                .animation(.spring(response: 0.4, dampingFraction: 0.8), value: showingActionMenu)
            }
            .gesture(
                DragGesture()
                    .onEnded { value in
                        let horizontalThreshold: CGFloat = 100
                        
                        if abs(value.translation.width) > abs(value.translation.height) {
                            if value.translation.width < -horizontalThreshold {
                                // Swiped left - show action menu
                                withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                                    showingActionMenu = true
                                }
                            } else if value.translation.width > horizontalThreshold && showingActionMenu {
                                // Swiped right - hide action menu
                                withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                                    showingActionMenu = false
                                }
                            }
                        }
                    }
            )
        }
        .ignoresSafeArea()
        .sheet(isPresented: $showingPreferences) {
            PreferencesView()
        }
        .onReceive(settings.$selectedStartingLifeOption) { _ in
            settingsResetTrigger = UUID()
        }
        .onReceive(settings.$appliedCustomStartingLife) { _ in
            settingsResetTrigger = UUID()
        }
    }
    
    @ViewBuilder
    private func actionMenuView(screenHeight: CGFloat) -> some View {
        VStack(spacing: 0) {
            Spacer()
            
            // Menu items aligned to bottom
            VStack(spacing: 0) {
                // Add Player button
                actionMenuButton(
                    title: "Add Player",
                    systemName: "plus",
                    backgroundColor: Color(red: 0.95, green: 0.95, blue: 0.95),
                    isEnabled: settings.numberOfPlayers < 4,
                    action: {
                        if settings.numberOfPlayers < 4 {
                            withAnimation(.spring()) {
                                settings.numberOfPlayers += 1
                                hideActionMenu()
                            }
                        }
                    }
                )
                
                // Remove Player button
                actionMenuButton(
                    title: "Remove Player",
                    systemName: "minus",
                    backgroundColor: Color(red: 0.90, green: 0.90, blue: 0.90),
                    isEnabled: settings.numberOfPlayers > 1,
                    action: {
                        if settings.numberOfPlayers > 1 {
                            withAnimation(.spring()) {
                                settings.numberOfPlayers -= 1
                                hideActionMenu()
                            }
                        }
                    }
                )
                
                // Settings button
                actionMenuButton(
                    title: "Settings",
                    systemName: "gearshape",
                    backgroundColor: Color(red: 0.85, green: 0.85, blue: 0.85),
                    isEnabled: true,
                    action: {
                        showingPreferences = true
                        hideActionMenu()
                    }
                )
            }
        }
    }
    
    @ViewBuilder
    private func actionMenuButton(title: String, systemName: String, backgroundColor: Color, isEnabled: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack {
                Image(systemName: systemName)
                    .font(.system(size: 24, weight: .medium))
                    .foregroundColor(isEnabled ? .primary : .secondary)
                    .frame(width: 30)
                
                Text(title)
                    .font(.custom("SFProDisplay-Medium", size: 28))
                    .fontWidth(.expanded)
                    .foregroundColor(isEnabled ? .primary : .secondary)
                
                Spacer()
            }
            .padding(.horizontal, 20)
            .frame(height: 90)
            .background(backgroundColor)
        }
        .disabled(!isEnabled)
        .buttonStyle(PlainButtonStyle())
    }
    
    private func hideActionMenu() {
        withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
            showingActionMenu = false
        }
    }
    
    @ViewBuilder
    private func playerCountersView() -> some View {
        switch settings.numberOfPlayers {
        case 1:
            CounterView(playerNumber: 1)
                .id(settingsResetTrigger)
        case 2:
            GeometryReader { geometry in
                let isLandscape = geometry.size.width > geometry.size.height
                
                if isLandscape {
                    // Landscape: side-by-side, both upright
                    HStack(spacing: 0) {
                        CounterView(playerNumber: 1)
                            .id(settingsResetTrigger)
                            .frame(width: geometry.size.width / 2)
                        CounterView(playerNumber: 2)
                            .id(settingsResetTrigger)
                            .frame(width: geometry.size.width / 2)
                    }
                } else {
                    // Portrait: top-bottom with one rotated 180°
                    VStack(spacing: 0) {
                        CounterView(playerNumber: 2, rotationAngle: 180)
                            .id(settingsResetTrigger)
                            .frame(height: geometry.size.height / 2)
                        CounterView(playerNumber: 1)
                            .id(settingsResetTrigger)
                            .frame(height: geometry.size.height / 2)
                    }
                }
            }
        case 3:
            GeometryReader { geometry in
                let isLandscape = geometry.size.width > geometry.size.height
                
                if isLandscape {
                    // Landscape: all three side-by-side, all upright
                    HStack(spacing: 0) {
                        CounterView(playerNumber: 1, fontSize: 156)
                            .id(settingsResetTrigger)
                            .frame(width: geometry.size.width / 3)
                        CounterView(playerNumber: 2, fontSize: 156)
                            .id(settingsResetTrigger)
                            .frame(width: geometry.size.width / 3)
                        CounterView(playerNumber: 3, fontSize: 156)
                            .id(settingsResetTrigger)
                            .frame(width: geometry.size.width / 3)
                    }
                } else {
                    // Portrait: top two players rotated 180°, bottom player upright
                    VStack(spacing: 0) {
                        HStack(spacing: 0) {
                            CounterView(playerNumber: 2, rotationAngle: 180, fontSize: 156)
                                .id(settingsResetTrigger)
                                .frame(width: geometry.size.width / 2)
                            CounterView(playerNumber: 3, rotationAngle: 180, fontSize: 156)
                                .id(settingsResetTrigger)
                                .frame(width: geometry.size.width / 2)
                        }
                        .frame(height: geometry.size.height / 2)
                        CounterView(playerNumber: 1, fontSize: 156)
                            .id(settingsResetTrigger)
                            .frame(height: geometry.size.height / 2)
                    }
                }
            }
        case 4:
            GeometryReader { geometry in
                let isLandscape = geometry.size.width > geometry.size.height
                
                if isLandscape {
                    // Landscape: 2x2 grid, same positions as portrait but all upright
                    VStack(spacing: 0) {
                        HStack(spacing: 0) {
                            CounterView(playerNumber: 3, rotationAngle: 180, fontSize: 120, vStackSpacing: 0)
                                .id(settingsResetTrigger)
                                .frame(width: geometry.size.width / 2)
                            CounterView(playerNumber: 4, rotationAngle: 180, fontSize: 120, vStackSpacing: 0)
                                .id(settingsResetTrigger)
                                .frame(width: geometry.size.width / 2)
                        }
                        .frame(height: geometry.size.height / 2)
                        HStack(spacing: 0) {
                            CounterView(playerNumber: 1, fontSize: 120, vStackSpacing: 0)
                                .id(settingsResetTrigger)
                                .frame(width: geometry.size.width / 2)
                            CounterView(playerNumber: 2, fontSize: 120, vStackSpacing: 0)
                                .id(settingsResetTrigger)
                                .frame(width: geometry.size.width / 2)
                        }
                        .frame(height: geometry.size.height / 2)
                    }
                } else {
                    // Portrait: 2x2 grid with top row rotated 180°
                    VStack(spacing: 0) {
                        HStack(spacing: 0) {
                            CounterView(playerNumber: 3, rotationAngle: 180, fontSize: 156)
                                .id(settingsResetTrigger)
                                .frame(width: geometry.size.width / 2)
                            CounterView(playerNumber: 4, rotationAngle: 180, fontSize: 156)
                                .id(settingsResetTrigger)
                                .frame(width: geometry.size.width / 2)
                        }
                        .frame(height: geometry.size.height / 2)
                        HStack(spacing: 0) {
                            CounterView(playerNumber: 1, fontSize: 156)
                                .id(settingsResetTrigger)
                                .frame(width: geometry.size.width / 2)
                            CounterView(playerNumber: 2, fontSize: 156)
                                .id(settingsResetTrigger)
                                .frame(width: geometry.size.width / 2)
                        }
                        .frame(height: geometry.size.height / 2)
                    }
                }
            }
        default:
            CounterView(playerNumber: 1)
                .id(settingsResetTrigger)
        }
    }
}

#Preview {
    ContentView()
}
