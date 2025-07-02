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
    @State private var showingActionMenu = false
    @State private var actionMenuOffset: CGFloat = 0
    
    private let menuWidth: CGFloat = 60
    private let actionButtonWidth: CGFloat = 80
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Main content with offset when action menu is shown
                playerCountersView()
                    .offset(x: actionMenuOffset)
                    .animation(.interactiveSpring(), value: actionMenuOffset)
                
                // Action menu (slides in from right)
                if showingActionMenu || actionMenuOffset < 0 {
                    HStack(spacing: 0) {
                        Spacer()
                        actionMenuView()
                    }
                    .offset(x: showingActionMenu ? 0 : actionButtonWidth * 3)
                    .animation(.interactiveSpring(), value: showingActionMenu)
                }
            }
            .gesture(
                DragGesture()
                    .onChanged { value in
                        let horizontalDrag = abs(value.translation.width) > abs(value.translation.height)
                        
                        if horizontalDrag && value.translation.width < 0 {
                            // Swiping left - show action menu
                            let dragDistance = min(abs(value.translation.width), actionButtonWidth * 3)
                            actionMenuOffset = -dragDistance
                            showingActionMenu = dragDistance > 50
                        } else if horizontalDrag && value.translation.width > 0 && showingActionMenu {
                            // Swiping right - hide action menu
                            let dragDistance = max(0, actionButtonWidth * 3 - value.translation.width)
                            actionMenuOffset = -dragDistance
                            showingActionMenu = dragDistance > actionButtonWidth * 1.5
                        }
                    }
                    .onEnded { value in
                        let horizontalThreshold: CGFloat = 100
                        
                        withAnimation(.spring()) {
                            if abs(value.translation.width) > abs(value.translation.height) {
                                if value.translation.width < -horizontalThreshold {
                                    // Swiped left - show action menu
                                    showingActionMenu = true
                                    actionMenuOffset = -(actionButtonWidth * 3)
                                } else if value.translation.width > horizontalThreshold && showingActionMenu {
                                    // Swiped right - hide action menu
                                    showingActionMenu = false
                                    actionMenuOffset = 0
                                } else {
                                    // Snap back to current state
                                    actionMenuOffset = showingActionMenu ? -(actionButtonWidth * 3) : 0
                                }
                            } else {
                                // Vertical gesture - keep current menu state
                                actionMenuOffset = showingActionMenu ? -(actionButtonWidth * 3) : 0
                            }
                        }
                    }
            )
        }
        .ignoresSafeArea()
        .sheet(isPresented: $showingPreferences) {
            PreferencesView()
        }
    }
    
    @ViewBuilder
    private func actionMenuView() -> some View {
        HStack(spacing: 0) {
            // Add Player button
            actionButton(
                systemName: "plus.circle.fill",
                color: .blue,
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
            actionButton(
                systemName: "minus.circle.fill",
                color: .orange,
                action: {
                    if settings.numberOfPlayers > 1 {
                        withAnimation(.spring()) {
                            settings.numberOfPlayers -= 1
                            hideActionMenu()
                        }
                    }
                }
            )
            
            // Preferences button
            actionButton(
                systemName: "gearshape.fill",
                color: .red,
                action: {
                    showingPreferences = true
                    hideActionMenu()
                }
            )
        }
    }
    
    @ViewBuilder
    private func actionButton(systemName: String, color: Color, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            ZStack {
                Rectangle()
                    .fill(color)
                    .frame(width: actionButtonWidth, height: UIScreen.main.bounds.height)
                
                Image(systemName: systemName)
                    .font(.system(size: 30, weight: .bold))
                    .foregroundColor(.white)
            }
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private func hideActionMenu() {
        withAnimation(.spring()) {
            showingActionMenu = false
            actionMenuOffset = 0
        }
    }
    
    @ViewBuilder
    private func playerCountersView() -> some View {
        switch settings.numberOfPlayers {
        case 1:
            CounterView(playerNumber: 1)
        case 2:
            GeometryReader { geometry in
                let isLandscape = geometry.size.width > geometry.size.height
                
                if isLandscape {
                    // Landscape: side-by-side, both upright
                    HStack(spacing: 0) {
                        CounterView(playerNumber: 1)
                            .frame(width: geometry.size.width / 2)
                        CounterView(playerNumber: 2)
                            .frame(width: geometry.size.width / 2)
                    }
                } else {
                    // Portrait: top-bottom with one rotated 180°
                    VStack(spacing: 0) {
                        CounterView(playerNumber: 2, rotationAngle: 180)
                            .frame(height: geometry.size.height / 2)
                        CounterView(playerNumber: 1)
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
                            .frame(width: geometry.size.width / 3)
                        CounterView(playerNumber: 2, fontSize: 156)
                            .frame(width: geometry.size.width / 3)
                        CounterView(playerNumber: 3, fontSize: 156)
                            .frame(width: geometry.size.width / 3)
                    }
                } else {
                    // Portrait: top two players rotated 180°, bottom player upright
                    VStack(spacing: 0) {
                        HStack(spacing: 0) {
                            CounterView(playerNumber: 2, rotationAngle: 180, fontSize: 156)
                                .frame(width: geometry.size.width / 2)
                            CounterView(playerNumber: 3, rotationAngle: 180, fontSize: 156)
                                .frame(width: geometry.size.width / 2)
                        }
                        .frame(height: geometry.size.height / 2)
                        CounterView(playerNumber: 1, fontSize: 156)
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
                                .frame(width: geometry.size.width / 2)
                            CounterView(playerNumber: 4, rotationAngle: 180, fontSize: 120, vStackSpacing: 0)
                                .frame(width: geometry.size.width / 2)
                        }
                        .frame(height: geometry.size.height / 2)
                        HStack(spacing: 0) {
                            CounterView(playerNumber: 1, fontSize: 120, vStackSpacing: 0)
                                .frame(width: geometry.size.width / 2)
                            CounterView(playerNumber: 2, fontSize: 120, vStackSpacing: 0)
                                .frame(width: geometry.size.width / 2)
                        }
                        .frame(height: geometry.size.height / 2)
                    }
                } else {
                    // Portrait: 2x2 grid with top row rotated 180°
                    VStack(spacing: 0) {
                        HStack(spacing: 0) {
                            CounterView(playerNumber: 3, rotationAngle: 180, fontSize: 156)
                                .frame(width: geometry.size.width / 2)
                            CounterView(playerNumber: 4, rotationAngle: 180, fontSize: 156)
                                .frame(width: geometry.size.width / 2)
                        }
                        .frame(height: geometry.size.height / 2)
                        HStack(spacing: 0) {
                            CounterView(playerNumber: 1, fontSize: 156)
                                .frame(width: geometry.size.width / 2)
                            CounterView(playerNumber: 2, fontSize: 156)
                                .frame(width: geometry.size.width / 2)
                        }
                        .frame(height: geometry.size.height / 2)
                    }
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
