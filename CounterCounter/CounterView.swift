//
//  CounterView.swift
//  CounterCounter
//
//  Created by Jozef on 2/21/25.
//

import SwiftUI

struct CounterView: View {
    @State private var lifeTotal: Int = 5
    @State private var showingLifePicker = false
    
    private let backgroundColor = Color(hex: "0F0F0F") // Player 1 Grayscale
    private let foregroundColor = Color(hex: "FFFFFF")
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                backgroundColor.ignoresSafeArea()
                
                VStack(spacing: 20) {
                    // Up arrow button
                    Image(systemName: "chevron.compact.up")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(foregroundColor)
                    
                    // Life total display
                    Text("\(lifeTotal)")
                        .font(.system(size: 180,weight: .black))
                        .fontWidth(.expanded)
                        .foregroundColor(foregroundColor)
                        .contentTransition(.numericText())
                    
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
                                    withAnimation(.spring(response: 0.3)) {
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
                                    withAnimation(.spring(response: 0.3)) {
                                        lifeTotal -= 1
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
}

#Preview {
    CounterView()
}
