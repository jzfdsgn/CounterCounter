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
                Section {
                    VStack(alignment: .leading, spacing: 40) {
                        // Starting life section
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Starting Life")
                                .font(.title3)
                                .fontWeight(.semibold)
                            
                            Picker("Starting Life", selection: $settings.selectedStartingLifeOption) {
                                ForEach(StartingLifeOption.allCases, id: \.self) { option in
                                    Text(option.displayText).tag(option)
                                }
                            }
                            .pickerStyle(.segmented)
                            
                            if settings.selectedStartingLifeOption == .custom {
                                HStack {
                                    Text("Custom")
                                        .font(.system(size: 17))
                                    
                                    Spacer()
                                    
                                    TextField("Enter a number", text: $settings.customStartingLifeValue)
                                        .keyboardType(.numberPad)
                                        .multilineTextAlignment(.trailing)
                                        .font(.system(size: 17))
                                        .foregroundColor(.secondary)
                                }
                            }
                        }
                        
                        // Number of players section
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Number of Players")
                                .font(.title3)
                                .fontWeight(.semibold)
                            
                            Picker("Number of Players", selection: $settings.numberOfPlayers) {
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
                            
                            Picker("Color Palette", selection: $settings.selectedPalette) {
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
                                ForEach(1...min(settings.numberOfPlayers, 4), id: \.self) { playerNumber in
                                    ColorPreviewCell(playerNumber: playerNumber)
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
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
            .listSectionSpacing(20)
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
