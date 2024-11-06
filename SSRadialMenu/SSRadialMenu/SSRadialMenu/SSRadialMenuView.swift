//
//  SSRadialMenuView.swift
//  SSRadialMenuView
//
//  Created by Rishita Panchal on 07/12/23.
//

import SwiftUI

struct RadialMenu: View {
    let items: [MenuItem]
    let position: Position
    @Binding var isExpanded: Bool
    @Binding var menuItemsVisible: [Bool]
    @Binding var currentPeelingAngle: Double
    @State private var xOffset: CGFloat = 0.0
    @State private var yOffset: CGFloat = 0.0
    @State private var selectedItem: MenuItem?
    @State private var showSubMenu: Bool = false
    @State private var scaleEffect: CGFloat = 1.0
    @State private var isBouncing = false
    @State private var shadowRadius: CGFloat = 10

    @State var subMenuItemsVisible = [Bool]()
    var radius: CGFloat = 35.0
    @State private var shadowYOffset: CGFloat = 5

    var body: some View {
        ZStack {
            if isExpanded {
                ForEach(items.indices, id: \.self) { index in
                    createMenuItem(items[index], at: index, position: position)
                        .opacity(menuItemsVisible[index] ? 1 : 0)
                        .scaleEffect(menuItemsVisible[index] ? 1.0 : 0.0)
                        .animation(.easeInOut.delay(Double(index) * 0.2), value: menuItemsVisible[index])
                }

                if showSubMenu, let selectedItem = selectedItem, let subItems = selectedItem.subMenuItems {
                    SubMenuView(subItems: subItems, position: position)
                        .transition(.scale)
                        .animation(.easeInOut, value: showSubMenu)
                }
            }
        }
    }

    private func createMenuItem(_ item: MenuItem, at index: Int, position: Position) -> some View {
        let radius: CGFloat = 100
        let (x, y) = position.calculateOffset(radius: radius, index: index, totalItems: items.count)

        return ZStack {
            ZStack {
                Circle()
                    .fill(Color.pink)
                    .frame(width: 35, height: 40)
                    .offset(x: xOffset, y: yOffset)
                    .scaleEffect(scaleEffect)
                Circle()
                    .fill(Color.pink)
                    .frame(width: 70, height: 80)
            }
        }
        .offset(x: menuItemsVisible[index] ? x : 0, y: menuItemsVisible[index] ? y : 0)
        .onTapGesture {
            subMenuItemsVisible = Array(repeating: false, count: item.subMenuItems?.count ?? .zero)
            startBounceAndPeelAnimation(item: item)
            if let subItems = item.subMenuItems, !subItems.isEmpty {
                selectedItem = item
                showSubMenu = true
            } else {
                selectedItem = item
                showSubMenu = false
            }
        }
    }

    private func startBounceAndPeelAnimation(item: MenuItem?) {
        var directions: [(CGFloat, CGFloat)] = []
        if let item, let subMenuItems = item.subMenuItems {
            for index in 0..<subMenuItems.count {
                let offset = position.calculateOffset(radius: radius, index: index, totalItems: subMenuItems.count)
                directions.append(offset)
            }

            for index in subMenuItems.indices {
                DispatchQueue.main.asyncAfter(deadline: .now() + Double(index) * (0.4 / 6)) {
                    withAnimation(.interactiveSpring) {
                        subMenuItemsVisible[index] = true
                    }
                }

                DispatchQueue.main.asyncAfter(deadline: .now() + Double(index) * 0.4) {
                    let nextDirection = directions[index]
                    xOffset = nextDirection.0
                    yOffset = nextDirection.1

                    // First bounce animation for water drop effect
                    withAnimation(Animation.interactiveSpring(response: 0.4, dampingFraction: 0.3, blendDuration: 0)) {
                        self.xOffset = 0
                        self.yOffset = 0
                        self.scaleEffect = 0.8
                        self.shadowRadius = 15
                        self.shadowYOffset = 10
                    }

                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { // Adjusted delay for fluidity
                        withAnimation(Animation.interactiveSpring(response: 0.4, dampingFraction: 0.3, blendDuration: 0)) {
                            self.scaleEffect = 1.0
                            self.shadowRadius = 10
                            self.shadowYOffset = 5
                        }
                    }

                    // Final state check
                    if index == subMenuItems.count - 1 {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                            if subMenuItemsVisible.allSatisfy({ $0 }) {
//                                isPeeling = false
                                isBouncing = false
                            }
                        }
                    }
                }
            }
            isBouncing = true
        }
    }
}
