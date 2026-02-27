//
//  CounterCounterApp.swift
//  CounterCounter
//
//  Created by Jozef on 2/21/25.
//

import SwiftUI

@main
struct CounterCounterApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(AppSettings.shared)
        }
    }
}
