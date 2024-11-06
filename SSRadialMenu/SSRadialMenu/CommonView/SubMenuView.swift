//
//  SubMenuView.swift
//  SSRadialMenu
//
//  Created by Rishita Panchal on 06/11/24.
//

import SwiftUI

struct SubMenuView: View {
    let subItems: [MenuItem]
    let position: Position
    @State private var subMenuItemsVisible: [Bool]
    @State private var subMenuItemsOffsets: [(CGFloat, CGFloat)]
    @State private var isCollapsed: Bool = false // Track if the menu is collapsed or expanded

    init(subItems: [MenuItem], position: Position) {
        self.subItems = subItems
        self.position = position
        self._subMenuItemsVisible = State(initialValue: Array(repeating: false, count: subItems.count))
        self._subMenuItemsOffsets = State(initialValue: Array(repeating: (0, 0), count: subItems.count))
    }

    var body: some View {
        ZStack {
            ForEach(subItems.indices, id: \.self) { index in
                createSubMenuItem(subItems[index], at: index)
                    .opacity(subMenuItemsVisible[index] ? 1 : 0) // Animate opacity
                    .scaleEffect(subMenuItemsVisible[index] ? 1.0 : 0.0) // Animate scale
                    .offset(
                        x: subMenuItemsOffsets[index].0,
                        y: subMenuItemsOffsets[index].1
                    ) // Offset for animation
                    .animation(
                        .easeOut(duration: 0.3).delay(Double(index) * 0.05), // Adjusted for smoother stagger
                        value: subMenuItemsVisible[index]
                    )
            }
        }
        .onAppear {
            // Start the staggered animation for each sub-menu item
            startSubMenuAnimation()
        }
        .onChange(of: isCollapsed) { _ in
            // Trigger the collapse or expansion animation when the state changes
            if isCollapsed {
                collapseSubMenu()
            } else {
                startSubMenuAnimation()
            }
        }
    }

    private func createSubMenuItem(_ item: MenuItem, at index: Int) -> some View {
        item.menuView
            .frame(width: item.size, height: item.size)
            .background(item.color)
            .cornerRadius(item.size / 2)
    }

    private func startSubMenuAnimation() {
        for index in 0..<subItems.count {
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(index) * 0.05) {
                subMenuItemsVisible[index] = true
                if index > 0 {
                    let previousOffset = subMenuItemsOffsets[index - 1]
                    let newOffset = position.calculateOffset(radius: 200, index: index, totalItems: subItems.count)
                    subMenuItemsOffsets[index] = previousOffset
                    withAnimation(.easeOut(duration: 0.3)) {
                        subMenuItemsOffsets[index] = newOffset
                    }
                } else {
                    // First item should go directly to its final position
                    subMenuItemsOffsets[index] = position.calculateOffset(
                        radius: 200,
                        index: index,
                        totalItems: subItems.count
                    )
                }
            }
        }
    }

    private func collapseSubMenu() {
        for index in 0..<subItems.count {
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(index) * 0.05) {
                subMenuItemsVisible[index] = false // Hide the items
                subMenuItemsOffsets[index] = (0, 0) // Reset offset to initial position
            }
        }
    }
}
