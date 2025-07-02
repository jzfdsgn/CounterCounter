//
//  CounterView.swift
//  CounterCounter
//
//  Created by Jozef on 2/21/25.
//

import SwiftUI

// Enum to represent the different color palettes
enum ColorPalette: String, CaseIterable, Identifiable {
    case grayscale = "Grayscale"
    case sage = "Sage"
    case sunrise = "Sunrise"
    
    var id: String { self.rawValue }
}

// Class to manage app settings
class AppSettings: ObservableObject {
    @Published var selectedPalette: ColorPalette = .grayscale
    @Published var numberOfPlayers: Int = 1
    @Published var defaultStartingLife: Int = 5
    
    // Singleton instance
    static let shared = AppSettings()
    
    private init() {}
}

struct CounterView: View {
    @State private var lifeTotal: Int
    @State private var showingLifePicker = false
    @StateObject private var settings = AppSettings.shared
    
    // Player number (1-4)
    var playerNumber: Int = 1
    
    // Rotation angle for 2-player mode
    var rotationAngle: Double = 0
    
    // Font size for life total
    var fontSize: CGFloat = 180
    
    // Spacing for VStack containing arrows and life total
    var vStackSpacing: CGFloat = 20
    
    // Dynamic color properties based on palette and player number
    private var backgroundColor: Color {
        Color.background(for: playerNumber, in: settings.selectedPalette)
    }
    
    private var foregroundColor: Color {
        Color.foreground(for: playerNumber, in: settings.selectedPalette)
    }
    
    // Initialize with default life total from settings
    init(playerNumber: Int = 1, rotationAngle: Double = 0, fontSize: CGFloat = 180, vStackSpacing: CGFloat = 20) {
        self.playerNumber = playerNumber
        self.rotationAngle = rotationAngle
        self.fontSize = fontSize
        self.vStackSpacing = vStackSpacing
        // Use _lifeTotal to initialize the @State property
        _lifeTotal = State(initialValue: AppSettings.shared.defaultStartingLife)
    }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                backgroundColor.ignoresSafeArea()
                
                VStack(spacing: vStackSpacing) {
                    // Up arrow button
                    Image(systemName: "chevron.compact.up")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(foregroundColor)
                    
                    // Life total display
                    Text("\(lifeTotal)")
                        .font(.system(size: fontSize, weight: .black))
                        .fontWidth(.expanded)
                        .foregroundColor(foregroundColor)
                        .contentTransition(.numericText(value: Double(lifeTotal)))
                    
                    // Down arrow button
                    Image(systemName: "chevron.compact.down")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(foregroundColor)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                
                // Combined gesture area
                VStack(spacing: 0) {
                    Rectangle()
                        .fill(Color.clear)
                        .contentShape(Rectangle())
                        .frame(height: geometry.size.height / 2)
                        .gesture(
                            SpatialTapGesture()
                                .onEnded { _ in
                                    withAnimation(.snappy(duration: 0.2)) {
                                        lifeTotal += 1
                                    }
                                }
                        )
                    
                    Rectangle()
                        .fill(Color.clear)
                        .contentShape(Rectangle())
                        .frame(height: geometry.size.height / 2)
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
    }
}

struct LifePickerView: View {
    @Binding var lifeTotal: Int
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            Picker("Life Total", selection: $lifeTotal) {
                ForEach(0...99, id: \.self) { value in
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
    
    // Get background color for a specific player and palette
    static func background(for playerNumber: Int, in palette: ColorPalette) -> Color {
        let validPlayerNumber = max(1, min(playerNumber, 4)) // Ensure player number is between 1-4
        let prefix: String
        
        switch palette {
        case .grayscale: prefix = "GrayScale"
        case .sage: prefix = "Sage"
        case .sunrise: prefix = "Sunrise"
        }
        
        return Color("\(prefix)_Background\(validPlayerNumber)")
    }
    
    // Get foreground color for a specific player and palette
    static func foreground(for playerNumber: Int, in palette: ColorPalette) -> Color {
        let validPlayerNumber = max(1, min(playerNumber, 4)) // Ensure player number is between 1-4
        
        switch palette {
        case .grayscale:
            // Players 1-2 use foreground1, players 3-4 use foreground2
            return validPlayerNumber <= 2 ? 
                Color("GrayScale_Foreground1") : 
                Color("GrayScale_Foreground2")
        case .sage:
            // Players 1-2 use foreground1, players 3-4 use foreground2
            return validPlayerNumber <= 2 ? 
                Color("Sage_Foreground1") : 
                Color("Sage_Foreground2")
        case .sunrise:
            // All players use the same foreground
            return Color("Sunrise_Foreground")
        }
    }
}

#Preview {
    CounterView()
}
