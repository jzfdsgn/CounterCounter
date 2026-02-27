//
//  CounterView.swift
//  CounterCounter
//
//  Created by Jozef on 2/21/25.
//

import SwiftUI
import UIKit

// MARK: - CounterView

struct CounterView: View {
    @State private var lifeTotal: Int
    @State private var showingLifePicker = false
    @EnvironmentObject var settings: AppSettings

    var playerNumber: Int = 1
    var rotationAngle: Double = 0
    var fontSize: CGFloat = 180
    var vStackSpacing: CGFloat = 20

    private static let maxLife = 999
    private static func savedLifeKey(for player: Int) -> String { "lifeTotal_player\(player)" }

    // Dynamic color properties based on palette and player number
    private var backgroundColor: Color {
        Color.background(for: playerNumber, in: settings.selectedPalette)
    }

    private var foregroundColor: Color {
        Color.foreground(for: playerNumber, in: settings.selectedPalette)
    }

    // Red when at zero so players immediately see the eliminated state
    private var lifeTotalColor: Color {
        lifeTotal == 0 ? .red : foregroundColor
    }

    init(playerNumber: Int = 1, rotationAngle: Double = 0, fontSize: CGFloat = 180, vStackSpacing: CGFloat = 20) {
        self.playerNumber = playerNumber
        self.rotationAngle = rotationAngle
        self.fontSize = fontSize
        self.vStackSpacing = vStackSpacing
        // Restore persisted life total; fall back to the app's current starting life on first launch
        // or after a game reset (when the saved value has been cleared).
        let savedValue = UserDefaults.standard.object(forKey: Self.savedLifeKey(for: playerNumber)) as? Int
        _lifeTotal = State(initialValue: savedValue ?? AppSettings.shared.effectiveStartingLife)
    }

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                backgroundColor.ignoresSafeArea()

                VStack(spacing: vStackSpacing) {
                    Image(systemName: "chevron.compact.up")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(foregroundColor)

                    Text("\(lifeTotal)")
                        .font(.system(size: fontSize, weight: .black))
                        .fontWidth(.expanded)
                        .foregroundColor(lifeTotalColor)
                        .contentTransition(.numericText(value: Double(lifeTotal)))
                        .accessibilityLabel("Player \(playerNumber) life total")
                        .accessibilityValue("\(lifeTotal)")

                    Image(systemName: "chevron.compact.down")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(foregroundColor)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)

                // Tap zones — transparent overlays covering top and bottom halves
                VStack(spacing: 0) {
                    Rectangle()
                        .fill(Color.clear)
                        .contentShape(Rectangle())
                        .frame(height: geometry.size.height / 2)
                        .accessibilityLabel("Increase life")
                        .accessibilityHint("Tap to add 1 to Player \(playerNumber)'s life total")
                        .accessibilityAddTraits(.isButton)
                        .gesture(
                            SpatialTapGesture()
                                .onEnded { _ in
                                    withAnimation(.snappy(duration: 0.2)) {
                                        if lifeTotal < Self.maxLife {
                                            lifeTotal += 1
                                        }
                                    }
                                }
                        )

                    Rectangle()
                        .fill(Color.clear)
                        .contentShape(Rectangle())
                        .frame(height: geometry.size.height / 2)
                        .accessibilityLabel("Decrease life")
                        .accessibilityHint("Tap to subtract 1 from Player \(playerNumber)'s life total")
                        .accessibilityAddTraits(.isButton)
                        .gesture(
                            SpatialTapGesture()
                                .onEnded { _ in
                                    withAnimation(.snappy(duration: 0.2)) {
                                        if lifeTotal > 0 {
                                            lifeTotal -= 1
                                        }
                                    }
                                }
                        )
                }
                .gesture(
                    LongPressGesture()
                        .onEnded { _ in
                            showingLifePicker = true
                        }
                )
            }
        }
        .rotationEffect(.degrees(rotationAngle))
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .sheet(isPresented: $showingLifePicker) {
            LifePickerView(lifeTotal: $lifeTotal)
        }
        .onChange(of: lifeTotal) { _, newValue in
            UserDefaults.standard.set(newValue, forKey: Self.savedLifeKey(for: playerNumber))
            if newValue == 0 {
                let generator = UINotificationFeedbackGenerator()
                generator.notificationOccurred(.warning)
            }
        }
    }
}

// MARK: - Life Picker

struct LifePickerView: View {
    @Binding var lifeTotal: Int
    @Environment(\.dismiss) var dismiss

    var body: some View {
        NavigationView {
            Picker("Life Total", selection: $lifeTotal) {
                ForEach(0...999, id: \.self) { value in
                    Text("\(value)")
                }
            }
            .pickerStyle(.wheel)
            .navigationTitle("Set Life Total")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
        .presentationDetents([.height(300)])
    }
}

// MARK: - Color Extensions

extension Color {
    // Hex initializer for convenience
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }

    // MARK: - Dynamic Color Access

    static func background(for playerNumber: Int, in palette: ColorPalette) -> Color {
        let validPlayerNumber = max(1, min(playerNumber, 4))
        let prefix: String

        switch palette {
        case .grayscale: prefix = "GrayScale"
        case .sage: prefix = "Sage"
        case .sunrise: prefix = "Sunrise"
        }

        return Color("\(prefix)_Background\(validPlayerNumber)")
    }

    static func foreground(for playerNumber: Int, in palette: ColorPalette) -> Color {
        let validPlayerNumber = max(1, min(playerNumber, 4))

        switch palette {
        case .grayscale:
            return validPlayerNumber <= 2 ?
                Color("GrayScale_Foreground1") :
                Color("GrayScale_Foreground2")
        case .sage:
            return validPlayerNumber <= 2 ?
                Color("Sage_Foreground1") :
                Color("Sage_Foreground2")
        case .sunrise:
            return Color("Sunrise_Foreground")
        }
    }
}

#Preview {
    CounterView()
        .environmentObject(AppSettings.shared)
}
