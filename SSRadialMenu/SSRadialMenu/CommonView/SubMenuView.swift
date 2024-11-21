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
    @Binding var isExpand: Bool
    @State private var subMenuItemsVisible: [Bool]
    @State private var subMenuItemsOffsets: [(CGFloat, CGFloat)]

    init(subItems: [MenuItem], position: Position, isExpand: Binding<Bool>) {
        self.subItems = subItems
        self.position = position
        self._isExpand = isExpand
        self._subMenuItemsVisible = State(initialValue: Array(repeating: false, count: subItems.count))
        self._subMenuItemsOffsets = State(initialValue: Array(repeating: (0, 0), count: subItems.count))

    }

    var body: some View {
        ZStack {
            ForEach(subItems.indices, id: \.self) { index in
                createSubMenuItem(subItems[index], at: index)
                    .opacity(subMenuItemsVisible[index] ? 1 : 0)
                    .scaleEffect(subMenuItemsVisible[index] ? 1.0 : 0.0)
                    .offset(
                        x: subMenuItemsOffsets[index].0,
                        y: subMenuItemsOffsets[index].1
                    )
                    .animation(
                        .easeOut(duration: 0.3).delay(Double(index) * 0.05),
                        value: subMenuItemsVisible[index]
                    )
            }
        }
        .onAppear {
            // Start the staggered animation for each sub-menu item
            if isExpand {

                startSubMenuAnimation()
            }
        }
        .onChange(of: isExpand) { _, newValue in
            if newValue {
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
            // Reduce the delay to speed up the animation sequence
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(index) * 0.05) { // Reduced delay for faster sequential animation
                withAnimation(.easeOut(duration: 0.3)) { // Reduced duration for quicker transitions
                    subMenuItemsVisible[index] = true

                    // Start from the previous item's position
                    if index > 0 {
                        let previousOffset = subMenuItemsOffsets[index - 1]
                        subMenuItemsOffsets[index] = previousOffset
                    }

                    // Calculate the final offset for the current item
                    guard let finalOffset = position.calculateOffset(
                        radius: 200,
                        index: index,
                        totalItems: subItems.count
                    ) else { return }

                    // Animate to the final position
                    withAnimation(.easeOut(duration: 0.3)) {
                        subMenuItemsOffsets[index] = finalOffset
                    }
                }
            }
        }
    }


    private func collapseSubMenu() {
        for index in (0..<subItems.count).reversed() {
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(subItems.count - 1 - index) * 0.05) { // Further reduce the delay
                // Animate the offset change before hiding the item
                if index > 0 {
                    let previousOffset = subMenuItemsOffsets[index - 1]
                    guard let newOffset = position.calculateOffset(radius: 200, index: index, totalItems: subItems.count) else { return }
                    subMenuItemsOffsets[index] = newOffset

                    withAnimation(.easeOut(duration: 0.7).speed(2.5)) { // Reduce duration and increase speed
                        subMenuItemsOffsets[index] = previousOffset
                    }
                } else {
                    // For the first item, move it to the parent position
                    guard let parentOffset = position.calculateOffset(radius: 100, index: index, totalItems: subItems.count) else {
                        return
                    }// Move it to the parent position
                    subMenuItemsOffsets[index] = parentOffset

                    // Animate this offset change back to the parent position
                    withAnimation(.easeOut(duration: 0.7).speed(2.5)) {
                        subMenuItemsOffsets[index] = parentOffset
                    }
                }

                // Delay hiding the item until after the animation completes, starting from the last item
                withAnimation(.easeOut(duration: 0.7).delay(0.7).speed(2.5)) { // Faster hiding with less delay
                    subMenuItemsVisible[index] = false
                }
            }
        }
    }

}
