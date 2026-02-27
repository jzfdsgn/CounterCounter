//
//  AppSettings.swift
//  CounterCounter
//
//  Created by Jozef on 2/21/25.
//

import SwiftUI

// MARK: - Color Palette

enum ColorPalette: String, CaseIterable, Identifiable {
    case grayscale = "Grayscale"
    case sage = "Sage"
    case sunrise = "Sunrise"

    var id: String { self.rawValue }
}

// MARK: - Starting Life Option

enum StartingLifeOption: Int, CaseIterable {
    case three = 3
    case four = 4
    case five = 5
    case custom = -1

    var displayText: String {
        switch self {
        case .three: return "3"
        case .four: return "4"
        case .five: return "5"
        case .custom: return "Custom"
        }
    }
}

// MARK: - App Settings

class AppSettings: ObservableObject {
    static let shared = AppSettings()

    @Published var selectedPalette: ColorPalette = .grayscale
    @Published var numberOfPlayers: Int = 1
    @Published var selectedStartingLifeOption: StartingLifeOption = .five
    @Published var customStartingLifeValue: String = ""
    @Published var appliedCustomStartingLife: Int? = nil

    var effectiveStartingLife: Int {
        if selectedStartingLifeOption == .custom,
           let appliedCustomValue = appliedCustomStartingLife,
           appliedCustomValue > 0 {
            return appliedCustomValue
        }
        return selectedStartingLifeOption.rawValue > 0 ? selectedStartingLifeOption.rawValue : 5
    }

    func applyCustomStartingLife() {
        if let customValue = Int(customStartingLifeValue), customValue > 0 {
            appliedCustomStartingLife = customValue
        }
    }

    // Internal init allows unit testing with fresh instances; use AppSettings.shared in production.
    init() {}
}
