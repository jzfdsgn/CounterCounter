//
//  PreferencesView.swift
//  CounterCounter
//
//  Created by Jozef on 2/26/25.
//

import SwiftUI

struct PreferencesView: View {
    @EnvironmentObject var settings: AppSettings
    @Environment(\.dismiss) var dismiss

    // Pending settings state — changes aren't applied until the user taps Apply
    @State private var pendingSelectedPalette: ColorPalette
    @State private var pendingNumberOfPlayers: Int
    @State private var pendingSelectedStartingLifeOption: StartingLifeOption
    @State private var pendingCustomStartingLifeValue: String
    @State private var customValueError: String? = nil

    init() {
        let currentSettings = AppSettings.shared
        _pendingSelectedPalette = State(initialValue: currentSettings.selectedPalette)
        _pendingNumberOfPlayers = State(initialValue: currentSettings.numberOfPlayers)
        _pendingSelectedStartingLifeOption = State(initialValue: currentSettings.selectedStartingLifeOption)
        _pendingCustomStartingLifeValue = State(initialValue: currentSettings.customStartingLifeValue)
    }

    // Apply is blocked when the custom field is active and contains an invalid value
    private var canApply: Bool {
        guard pendingSelectedStartingLifeOption == .custom else { return true }
        return validateCustomLife(pendingCustomStartingLifeValue) == nil
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
                            .onChange(of: pendingSelectedStartingLifeOption) { _, _ in
                                // Re-validate when option changes
                                customValueError = pendingSelectedStartingLifeOption == .custom
                                    ? validateCustomLife(pendingCustomStartingLifeValue)
                                    : nil
                            }

                            if pendingSelectedStartingLifeOption == .custom {
                                VStack(alignment: .leading, spacing: 6) {
                                    TextField("Enter a number (1–999)", text: $pendingCustomStartingLifeValue)
                                        .keyboardType(.numberPad)
                                        .font(.system(size: 17))
                                        .textFieldStyle(.plain)
                                        .padding(.bottom, 4)
                                        .overlay(
                                            Rectangle()
                                                .frame(height: 1)
                                                .foregroundColor(customValueError != nil ? .red : .secondary.opacity(0.25)),
                                            alignment: .bottom
                                        )
                                        .padding(.top, 12)
                                        .onChange(of: pendingCustomStartingLifeValue) { _, newValue in
                                            customValueError = validateCustomLife(newValue)
                                        }

                                    if let error = customValueError {
                                        Text(error)
                                            .font(.caption)
                                            .foregroundColor(.red)
                                    }
                                }
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
                    .disabled(!canApply)
                }
            }
            .listSectionSpacing(20)
        }
    }

    // MARK: - Validation

    private func validateCustomLife(_ value: String) -> String? {
        guard !value.isEmpty else { return "Please enter a number" }
        guard let intValue = Int(value) else { return "Please enter a valid whole number" }
        guard intValue > 0 else { return "Starting life must be greater than 0" }
        guard intValue <= 999 else { return "Starting life must be 999 or less" }
        return nil
    }

    // MARK: - Apply

    private func applyAllSettings() {
        settings.selectedPalette = pendingSelectedPalette
        settings.numberOfPlayers = pendingNumberOfPlayers
        settings.selectedStartingLifeOption = pendingSelectedStartingLifeOption
        settings.customStartingLifeValue = pendingCustomStartingLifeValue

        if pendingSelectedStartingLifeOption == .custom,
           let customValue = Int(pendingCustomStartingLifeValue),
           customValue > 0,
           customValue <= 999 {
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
        .environmentObject(AppSettings.shared)
}
