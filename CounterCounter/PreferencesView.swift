//
//  PreferencesView.swift
//  CounterCounter
//
//  Created by Jozef on 2/26/25.
//

import SwiftUI

struct PreferencesView: View {
    @ObservedObject private var settings = AppSettings.shared
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Game Settings")) {
                    // Default starting life
                    VStack(alignment: .leading) {
                        Text("Default Starting Life")
                            .font(.headline)
                        
                        Picker("Default Starting Life", selection: $settings.defaultStartingLife) {
                            ForEach([2, 3, 4, 5, 6], id: \.self) { value in
                                Text("\(value)").tag(value)
                            }
                        }
                        .pickerStyle(.segmented)
                    }
                    .padding(.vertical, 8)
                    
                    // Number of players
                    VStack(alignment: .leading) {
                        Text("Number of Players")
                            .font(.headline)
                        
                        Picker("Number of Players", selection: $settings.numberOfPlayers) {
                            ForEach(1...4, id: \.self) { value in
                                Text("\(value)").tag(value)
                            }
                        }
                        .pickerStyle(.segmented)
                    }
                    .padding(.vertical, 8)
                }
                
                Section(header: Text("Appearance")) {
                    // Color palette
                    VStack(alignment: .leading) {
                        Text("Color Palette")
                            .font(.headline)
                        
                        Picker("Color Palette", selection: $settings.selectedPalette) {
                            ForEach(ColorPalette.allCases) { palette in
                                Text(palette.rawValue).tag(palette)
                            }
                        }
                        .pickerStyle(.segmented)
                    }
                    .padding(.vertical, 8)
                    
                    // Color palette preview
                    VStack(spacing: 12) {
                        Text("Preview")
                            .font(.headline)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        
                        HStack(spacing: 8) {
                            ForEach(1...min(settings.numberOfPlayers, 4), id: \.self) { playerNumber in
                                ColorPreviewCell(playerNumber: playerNumber)
                            }
                        }
                    }
                    .padding(.vertical, 8)
                }
            }
            .navigationTitle("Preferences")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

struct ColorPreviewCell: View {
    @ObservedObject private var settings = AppSettings.shared
    let playerNumber: Int
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.background(for: playerNumber, in: settings.selectedPalette))
                .frame(height: 60)
            
            Text("\(playerNumber)")
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(Color.foreground(for: playerNumber, in: settings.selectedPalette))
        }
    }
}

#Preview {
    PreferencesView()
} 