//
//  ContentView.swift
//  CounterCounter
//
//  Created by Jozef on 2/21/25.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var settings: AppSettings
    @State private var showingPreferences = false
    @State private var showingActionMenu = false
    @State private var settingsResetTrigger = UUID()

    // Menu hint state
    @State private var hasUsedMenuThisSession = false
    @State private var isShowingMenuHint = false

    // Animation constants
    private let menuAnimation = Animation.spring(response: 0.4, dampingFraction: 0.8)
    private let hintAnimation = Animation.spring(response: 0.3, dampingFraction: 0.8)

    // Layout / offset constants
    private let contentPushAmount: CGFloat = 80
    private let hintMenuRevealFraction: CGFloat = 0.65
    private let swipeHorizontalThreshold: CGFloat = 100

    // UserDefaults key for permanent hint disable
    private var shouldShowMenuHint: Bool {
        !UserDefaults.standard.bool(forKey: "hasShownMenuHint") && !hasUsedMenuThisSession
    }

    var body: some View {
        GeometryReader { geometry in
            let menuWidth = geometry.size.width * 0.75
            let hintOffset = menuWidth * hintMenuRevealFraction
            let currentMenuOffset = isShowingMenuHint ? hintOffset : (showingActionMenu ? 0 : menuWidth)
            let currentContentOffset = isShowingMenuHint
                ? -(menuWidth * (1 - hintMenuRevealFraction)) + contentPushAmount
                : (showingActionMenu ? -menuWidth + contentPushAmount : 0)

            ZStack(alignment: .leading) {
                // Main content (gets pushed to the left when menu is shown)
                playerCountersView()
                    .offset(x: currentContentOffset)
                    .animation(menuAnimation, value: showingActionMenu)
                    .animation(hintAnimation, value: isShowingMenuHint)

                // Action menu (slides in from right)
                HStack(spacing: 0) {
                    Spacer()
                    actionMenuView(screenHeight: geometry.size.height)
                        .frame(width: menuWidth)
                        .background(Color(red: 0.95, green: 0.95, blue: 0.95))
                }
                .offset(x: currentMenuOffset)
                .animation(menuAnimation, value: showingActionMenu)
                .animation(hintAnimation, value: isShowingMenuHint)
            }
            .gesture(
                DragGesture()
                    .onEnded { value in
                        // Block gestures during hint animation
                        guard !isShowingMenuHint else { return }

                        if abs(value.translation.width) > abs(value.translation.height) {
                            if value.translation.width < -swipeHorizontalThreshold && !showingActionMenu {
                                // Swiped left — show action menu
                                markMenuAsUsed()
                                withAnimation(menuAnimation) {
                                    showingActionMenu = true
                                }
                            } else if value.translation.width > swipeHorizontalThreshold && showingActionMenu {
                                // Swiped right — hide action menu
                                withAnimation(menuAnimation) {
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
                .environmentObject(settings)
        }
        .onReceive(settings.$selectedStartingLifeOption) { _ in
            clearSavedLifeTotals()
            settingsResetTrigger = UUID()
        }
        .onReceive(settings.$appliedCustomStartingLife) { _ in
            clearSavedLifeTotals()
            settingsResetTrigger = UUID()
        }
        .onAppear {
            if shouldShowMenuHint {
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    showMenuHint()
                }
            }
        }
    }

    // MARK: - Action Menu

    @ViewBuilder
    private func actionMenuView(screenHeight: CGFloat) -> some View {
        VStack(spacing: 0) {
            Spacer()

            VStack(spacing: 0) {
                actionMenuButton(
                    title: "Add Player",
                    systemName: "plus",
                    backgroundColor: Color(red: 0.95, green: 0.95, blue: 0.95),
                    isEnabled: settings.numberOfPlayers < 4,
                    action: {
                        withAnimation(.spring()) {
                            settings.numberOfPlayers += 1
                            hideActionMenu()
                        }
                    }
                )

                actionMenuButton(
                    title: "Remove Player",
                    systemName: "minus",
                    backgroundColor: Color(red: 0.90, green: 0.90, blue: 0.90),
                    isEnabled: settings.numberOfPlayers > 1,
                    action: {
                        withAnimation(.spring()) {
                            settings.numberOfPlayers -= 1
                            hideActionMenu()
                        }
                    }
                )

                actionMenuButton(
                    title: "Reset Game",
                    systemName: "arrow.counterclockwise",
                    backgroundColor: Color(red: 0.88, green: 0.88, blue: 0.88),
                    isEnabled: true,
                    action: {
                        clearSavedLifeTotals()
                        settingsResetTrigger = UUID()
                        hideActionMenu()
                    }
                )

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
                    .accessibilityHidden(true)

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
        .accessibilityLabel(title)
    }

    // MARK: - Helpers

    private func hideActionMenu() {
        withAnimation(menuAnimation) {
            showingActionMenu = false
        }
    }

    private func showMenuHint() {
        guard shouldShowMenuHint else { return }

        isShowingMenuHint = true

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.65) {
            isShowingMenuHint = false
        }
    }

    private func markMenuAsUsed() {
        hasUsedMenuThisSession = true
        UserDefaults.standard.set(true, forKey: "hasShownMenuHint")
    }

    private func clearSavedLifeTotals() {
        for i in 1...4 {
            UserDefaults.standard.removeObject(forKey: "lifeTotal_player\(i)")
        }
    }

    // MARK: - Layout

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
                    HStack(spacing: 0) {
                        CounterView(playerNumber: 1)
                            .id(settingsResetTrigger)
                            .frame(width: geometry.size.width / 2)
                        CounterView(playerNumber: 2)
                            .id(settingsResetTrigger)
                            .frame(width: geometry.size.width / 2)
                    }
                } else {
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
        .environmentObject(AppSettings.shared)
}
