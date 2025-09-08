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
    
    // Pending settings state - changes aren't applied until user taps Apply
    @State private var pendingSelectedPalette: ColorPalette
    @State private var pendingNumberOfPlayers: Int
    @State private var pendingSelectedStartingLifeOption: StartingLifeOption
    @State private var pendingCustomStartingLifeValue: String
    
    init() {
        let currentSettings = AppSettings.shared
        _pendingSelectedPalette = State(initialValue: currentSettings.selectedPalette)
        _pendingNumberOfPlayers = State(initialValue: currentSettings.numberOfPlayers)
        _pendingSelectedStartingLifeOption = State(initialValue: currentSettings.selectedStartingLifeOption)
        _pendingCustomStartingLifeValue = State(initialValue: currentSettings.customStartingLifeValue)
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section {
                    VStack(alignment: .leading, spacing: 40) {
                        // Starting life section
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Starting Life")
                                .font(.title3)
                                .fontWeight(.semibold)
                            
                            Picker("Starting Life", selection: $pendingSelectedStartingLifeOption) {
                                ForEach(StartingLifeOption.allCases, id: \.self) { option in
                                    Text(option.displayText).tag(option)
                                }
                            }
                            .pickerStyle(.segmented)
                            
                            if pendingSelectedStartingLifeOption == .custom {
                                TextField("Enter a number", text: $pendingCustomStartingLifeValue)
                                    .keyboardType(.numberPad)
                                    .font(.system(size: 17))
                                    .textFieldStyle(.plain)
                                    .padding(.bottom, 4)
                                    .overlay(
                                        Rectangle()
                                            .frame(height: 1)
                                            .foregroundColor(.secondary.opacity(0.25)),
                                        alignment: .bottom
                                    )
                                    .padding(.top, 12)
                            }
                        }
                        
                        // Number of players section
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Number of Players")
                                .font(.title3)
                                .fontWeight(.semibold)
                            
                            Picker("Number of Players", selection: $pendingNumberOfPlayers) {
                                ForEach(1...4, id: \.self) { value in
                                    Text("\(value)").tag(value)
                                }
                            }
                            .pickerStyle(.segmented)
                        }
                    }
                    .padding(.vertical, 8)
                }
                
                Section {
                    VStack(alignment: .leading, spacing: 28) {
                        // Color palette section
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Color Palette")
                                .font(.title3)
                                .fontWeight(.semibold)
                            
                            Picker("Color Palette", selection: $pendingSelectedPalette) {
                                ForEach(ColorPalette.allCases) { palette in
                                    Text(palette.rawValue).tag(palette)
                                }
                            }
                            .pickerStyle(.segmented)
                        }
                        
                        // Preview section
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Preview")
                                .font(.headline)
                                .fontWeight(.semibold)
                            
                            HStack(spacing: 8) {
                                ForEach(1...min(pendingNumberOfPlayers, 4), id: \.self) { playerNumber in
                                    ColorPreviewCell(playerNumber: playerNumber, palette: pendingSelectedPalette)
                                }
                            }
                        }
                    }
                    .padding(.vertical, 8)
                }
                
                Section {
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Tips")
                            .font(.title3)
                            .fontWeight(.semibold)
                        
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Text("Swipe left to open the menu")
                            }
                            Divider()
                            HStack {
                                Text("Tap and hold on any life counter area to manually change the number")
                            }
                        }
                        .font(.system(size: 15))
                    }
                    .padding(.vertical, 8)
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Apply") {
                        applyAllSettings()
                        dismiss()
                    }
                }
            }
            .listSectionSpacing(20)
        }
    }
    
    private func applyAllSettings() {
        settings.selectedPalette = pendingSelectedPalette
        settings.numberOfPlayers = pendingNumberOfPlayers
        settings.selectedStartingLifeOption = pendingSelectedStartingLifeOption
        settings.customStartingLifeValue = pendingCustomStartingLifeValue
        
        // Apply custom starting life if valid
        if pendingSelectedStartingLifeOption == .custom,
           let customValue = Int(pendingCustomStartingLifeValue),
           customValue >= 0 {
            settings.appliedCustomStartingLife = customValue
        }
    }
}

struct ColorPreviewCell: View {
    let playerNumber: Int
    let palette: ColorPalette
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.background(for: playerNumber, in: palette))
                .frame(height: 60)
            
            Text("\(playerNumber)")
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(Color.foreground(for: playerNumber, in: palette))
        }
    }
}

#Preview {
    PreferencesView()
} 
