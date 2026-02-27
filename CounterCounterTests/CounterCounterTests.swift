//
//  CounterCounterTests.swift
//  CounterCounterTests
//
//  Created by Jozef on 2/21/25.
//

import Testing
import SwiftUI
import UIKit
@testable import CounterCounter

struct CounterCounterTests {

    // MARK: - AppSettings.effectiveStartingLife

    @Test func effectiveStartingLife_preset_three() {
        let settings = AppSettings()
        settings.selectedStartingLifeOption = .three
        #expect(settings.effectiveStartingLife == 3)
    }

    @Test func effectiveStartingLife_preset_four() {
        let settings = AppSettings()
        settings.selectedStartingLifeOption = .four
        #expect(settings.effectiveStartingLife == 4)
    }

    @Test func effectiveStartingLife_preset_five() {
        let settings = AppSettings()
        settings.selectedStartingLifeOption = .five
        #expect(settings.effectiveStartingLife == 5)
    }

    @Test func effectiveStartingLife_customWithNoAppliedValue_fallsBackToFive() {
        let settings = AppSettings()
        settings.selectedStartingLifeOption = .custom
        settings.appliedCustomStartingLife = nil
        #expect(settings.effectiveStartingLife == 5)
    }

    @Test func effectiveStartingLife_customWithZeroValue_fallsBackToFive() {
        let settings = AppSettings()
        settings.selectedStartingLifeOption = .custom
        settings.appliedCustomStartingLife = 0
        #expect(settings.effectiveStartingLife == 5)
    }

    @Test func effectiveStartingLife_customWithValidValue_returnsCustom() {
        let settings = AppSettings()
        settings.selectedStartingLifeOption = .custom
        settings.appliedCustomStartingLife = 20
        #expect(settings.effectiveStartingLife == 20)
    }

    @Test func effectiveStartingLife_customWithLargeValue_returnsCustom() {
        let settings = AppSettings()
        settings.selectedStartingLifeOption = .custom
        settings.appliedCustomStartingLife = 999
        #expect(settings.effectiveStartingLife == 999)
    }

    @Test func effectiveStartingLife_presetIgnoresAppliedCustom() {
        let settings = AppSettings()
        settings.selectedStartingLifeOption = .three
        settings.appliedCustomStartingLife = 50
        // Preset option takes priority over any stored custom value
        #expect(settings.effectiveStartingLife == 3)
    }

    // MARK: - AppSettings.applyCustomStartingLife

    @Test func applyCustomStartingLife_validPositiveValue_applies() {
        let settings = AppSettings()
        settings.selectedStartingLifeOption = .custom
        settings.customStartingLifeValue = "20"
        settings.applyCustomStartingLife()
        #expect(settings.appliedCustomStartingLife == 20)
    }

    @Test func applyCustomStartingLife_zeroValue_doesNotApply() {
        let settings = AppSettings()
        settings.customStartingLifeValue = "0"
        settings.applyCustomStartingLife()
        #expect(settings.appliedCustomStartingLife == nil)
    }

    @Test func applyCustomStartingLife_negativeValue_doesNotApply() {
        let settings = AppSettings()
        settings.customStartingLifeValue = "-5"
        settings.applyCustomStartingLife()
        #expect(settings.appliedCustomStartingLife == nil)
    }

    @Test func applyCustomStartingLife_nonNumericValue_doesNotApply() {
        let settings = AppSettings()
        settings.customStartingLifeValue = "abc"
        settings.applyCustomStartingLife()
        #expect(settings.appliedCustomStartingLife == nil)
    }

    @Test func applyCustomStartingLife_emptyString_doesNotApply() {
        let settings = AppSettings()
        settings.customStartingLifeValue = ""
        settings.applyCustomStartingLife()
        #expect(settings.appliedCustomStartingLife == nil)
    }

    // MARK: - Color(hex:) — smoke tests (no crash on various inputs)

    @Test func colorHex_doesNotCrashWithVariousInputs() {
        _ = Color(hex: "")
        _ = Color(hex: "FFF")
        _ = Color(hex: "FFFFFF")
        _ = Color(hex: "FFFFFFFF")
        _ = Color(hex: "#FFFFFF")
        _ = Color(hex: "invalid")
        _ = Color(hex: "ZZZZZZ")
        _ = Color(hex: "FF0000")
        _ = Color(hex: "00FF00")
        _ = Color(hex: "0000FF")
    }

    @Test func colorHex_sixDigitRed_parsesCorrectly() {
        let color = Color(hex: "FF0000")
        var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        UIColor(color).getRed(&r, green: &g, blue: &b, alpha: &a)
        #expect(abs(r - 1.0) < 0.001)
        #expect(abs(g - 0.0) < 0.001)
        #expect(abs(b - 0.0) < 0.001)
        #expect(abs(a - 1.0) < 0.001)
    }

    @Test func colorHex_sixDigitWhite_parsesCorrectly() {
        let color = Color(hex: "FFFFFF")
        var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        UIColor(color).getRed(&r, green: &g, blue: &b, alpha: &a)
        #expect(abs(r - 1.0) < 0.001)
        #expect(abs(g - 1.0) < 0.001)
        #expect(abs(b - 1.0) < 0.001)
    }

    @Test func colorHex_sixDigitBlack_parsesCorrectly() {
        let color = Color(hex: "000000")
        var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        UIColor(color).getRed(&r, green: &g, blue: &b, alpha: &a)
        #expect(abs(r - 0.0) < 0.001)
        #expect(abs(g - 0.0) < 0.001)
        #expect(abs(b - 0.0) < 0.001)
    }

    @Test func colorHex_threeDigitWhite_matchesSixDigit() {
        let white3 = Color(hex: "FFF")
        let white6 = Color(hex: "FFFFFF")
        var r3: CGFloat = 0, g3: CGFloat = 0, b3: CGFloat = 0, a3: CGFloat = 0
        var r6: CGFloat = 0, g6: CGFloat = 0, b6: CGFloat = 0, a6: CGFloat = 0
        UIColor(white3).getRed(&r3, green: &g3, blue: &b3, alpha: &a3)
        UIColor(white6).getRed(&r6, green: &g6, blue: &b6, alpha: &a6)
        #expect(abs(r3 - r6) < 0.001)
        #expect(abs(g3 - g6) < 0.001)
        #expect(abs(b3 - b6) < 0.001)
    }

    @Test func colorHex_invalidInput_returnsBlack() {
        let color = Color(hex: "ZZZZZZ")
        var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        UIColor(color).getRed(&r, green: &g, blue: &b, alpha: &a)
        #expect(abs(r - 0.0) < 0.001)
        #expect(abs(g - 0.0) < 0.001)
        #expect(abs(b - 0.0) < 0.001)
    }

    @Test func colorHex_eightDigitARGB_parsesAlpha() {
        // #80FF0000 = ~50% opacity red
        let color = Color(hex: "80FF0000")
        var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        UIColor(color).getRed(&r, green: &g, blue: &b, alpha: &a)
        #expect(abs(a - (0x80 / 255.0)) < 0.01)
        #expect(abs(r - 1.0) < 0.001)
        #expect(abs(g - 0.0) < 0.001)
        #expect(abs(b - 0.0) < 0.001)
    }

    // MARK: - StartingLifeOption

    @Test func startingLifeOption_allCasesPresent() {
        let cases = StartingLifeOption.allCases
        #expect(cases.contains(.three))
        #expect(cases.contains(.four))
        #expect(cases.contains(.five))
        #expect(cases.contains(.custom))
    }

    @Test func startingLifeOption_rawValues() {
        #expect(StartingLifeOption.three.rawValue == 3)
        #expect(StartingLifeOption.four.rawValue == 4)
        #expect(StartingLifeOption.five.rawValue == 5)
        #expect(StartingLifeOption.custom.rawValue == -1)
    }

    @Test func startingLifeOption_displayText() {
        #expect(StartingLifeOption.three.displayText == "3")
        #expect(StartingLifeOption.four.displayText == "4")
        #expect(StartingLifeOption.five.displayText == "5")
        #expect(StartingLifeOption.custom.displayText == "Custom")
    }
}
