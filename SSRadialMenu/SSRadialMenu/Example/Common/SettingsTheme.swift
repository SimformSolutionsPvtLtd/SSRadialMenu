//
//  SettingsTheme.swift
//  SSRadialMenu
//
//  Created by Rishita Panchal on 16/06/25.
//

import SwiftUI

// MARK: - Settings Theme Configuration
struct SettingsTheme {
    let titleColor: Color
    let accentColor: Color
    let backgroundGradient: LinearGradient
    let borderColor: Color
    let title: String
    
    static let calendar = SettingsTheme(
        titleColor: .white,
        accentColor: .blue,
        backgroundGradient: LinearGradient(
            colors: [Color.black.opacity(0.9), Color.gray.opacity(0.8)],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        ),
        borderColor: Color.white.opacity(0.3),
        title: "Radial Menu Settings"
    )
    
    static let food = SettingsTheme(
        titleColor: .white,
        accentColor: .orange,
        backgroundGradient: LinearGradient(
            colors: [Color.black.opacity(0.9), Color.orange.opacity(0.3)],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        ),
        borderColor: Color.orange.opacity(0.5),
        title: "Food Menu Settings"
    )
}
