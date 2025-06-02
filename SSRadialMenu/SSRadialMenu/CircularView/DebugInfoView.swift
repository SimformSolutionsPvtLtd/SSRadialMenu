//
//  DebugInfoView 2.swift
//  SSRadialMenu
//
//  Created by Rishita Panchal on 04/06/25.
//

import SwiftUI

struct DebugInfoView: View {
    let showPizzaCards: Bool
    let continuousRotation: Double
    let pizzaCount: Int
    let isMainMenuScrollingEnabled: Bool
    let anglePerItem: Double
    let animatedIndicesCount: Int
    let showingSubMenuForIndex: Int?
    let subMenuRotation: Double
    let subMenuItemsCount: Int
    let isSubMenuScrollingEnabled: (Int) -> Bool
    let rotateSubMenuToPreviousItem: () -> Void
    let rotateSubMenuToNextItem: () -> Void
    let rotateToPreviousItem: () -> Void
    let rotateToNextItem: () -> Void

    var body: some View {
        VStack {
            if showPizzaCards {
                VStack(spacing: 4) {
                    // Main menu debug info
                    mainMenuDebugInfo

                    // Submenu debug info
                    if let selectedIndex = showingSubMenuForIndex {
                        subMenuDebugInfo(for: selectedIndex)
                    }
                }
                .padding(.top, 50)

                // Main menu controls
                if isMainMenuScrollingEnabled {
                    mainMenuControls
                }
            }
        }
    }

    // MARK: - Private Views

    @ViewBuilder
    private var mainMenuDebugInfo: some View {
        HStack {
            Text("Rotation: \(String(format: "%.1f", continuousRotation))°")
                .foregroundColor(.white)
                .font(.caption)
            Text("| Items: \(pizzaCount)")
                .foregroundColor(.gray)
                .font(.caption)
            Text("| Scroll: \(isMainMenuScrollingEnabled ? "ON" : "OFF")")
                .foregroundColor(isMainMenuScrollingEnabled ? .green : .red)
                .font(.caption)
        }

        // Position info based on scrolling state
        if isMainMenuScrollingEnabled {
            infiniteScrollingPositionInfo
        } else {
            staticModeInfo
        }
    }

    @ViewBuilder
    private var infiniteScrollingPositionInfo: some View {
        let currentPosition = continuousRotation / anglePerItem
        HStack {
            Text("Position: \(String(format: "%.1f", currentPosition))")
                .foregroundColor(.cyan)
                .font(.caption2)
            Text("| Visible: \(animatedIndicesCount)")
                .foregroundColor(.orange)
                .font(.caption2)
        }
    }

    @ViewBuilder
    private var staticModeInfo: some View {
        HStack {
            Text("Static Mode: All \(pizzaCount) items visible")
                .foregroundColor(.yellow)
                .font(.caption2)
        }
    }

    @ViewBuilder
    private func subMenuDebugInfo(for selectedIndex: Int) -> some View {
        Divider()
            .background(Color.gray)
            .frame(width: 200)
            .padding(.vertical, 4)

        HStack {
            Text("Submenu: \(String(format: "%.1f", subMenuRotation))°")
                .foregroundColor(.white)
                .font(.caption)
            Text("| Items: \(subMenuItemsCount)")
                .foregroundColor(.gray)
                .font(.caption)
            Text("| Scroll: \(isSubMenuScrollingEnabled(selectedIndex) ? "ON" : "OFF")")
                .foregroundColor(isSubMenuScrollingEnabled(selectedIndex) ? .green : .red)
                .font(.caption)
        }

        // Submenu controls
        if isSubMenuScrollingEnabled(selectedIndex) {
            subMenuControls
        }
    }

    @ViewBuilder
    private var subMenuControls: some View {
        HStack(spacing: 20) {
            Button("◀") {
                rotateSubMenuToPreviousItem()
            }
            .foregroundColor(.white)
            .font(.title3)

            Button("▶") {
                rotateSubMenuToNextItem()
            }
            .foregroundColor(.white)
            .font(.title3)
        }
        .padding(.top, 2)
    }

    @ViewBuilder
    private var mainMenuControls: some View {
        HStack(spacing: 20) {
            Button("◀") {
                rotateToPreviousItem()
            }
            .foregroundColor(.white)
            .font(.title2)

            Button("▶") {
                rotateToNextItem()
            }
            .foregroundColor(.white)
            .font(.title2)
        }
        .padding(.top, 5)
    }
}
