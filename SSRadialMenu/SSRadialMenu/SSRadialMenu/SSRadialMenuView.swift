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
    @State private var selectedItem: MenuItem?
    @State private var showSubMenu: Bool = false
    @State private var subMenuItems: [MenuItem] = []

    var onAllItemsDisplayed: (() -> Void)?

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

        return item.menuView
            .frame(width: item.size, height: item.size)
            .background(item.color)
            .cornerRadius(item.size / 2)
            .offset(x: menuItemsVisible[index] ? x : 0, y: menuItemsVisible[index] ? y : 0)
            .scaleEffect(menuItemsVisible[index] ? 1.2 : 0.0)
            .onTapGesture {
                if let subItems = item.subMenuItems, !subItems.isEmpty {
                    selectedItem = item
                    showSubMenu = true
                } else {
                    selectedItem = item
                    showSubMenu = false
                }
            }
    }
}

struct SubMenuView: View {
    let subItems: [MenuItem]
    let position: Position
    @State private var subMenuItemsVisible: [Bool]
    @State private var subMenuItemsOffsets: [(CGFloat, CGFloat)] // Track offsets for each item

    init(subItems: [MenuItem], position: Position) {
        self.subItems = subItems
        self.position = position
        // Initialize the visibility and offsets state
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
                        .easeOut(duration: 0.2).delay(Double(index) * 0.05), // Fast and sharp ease-out animation
                        value: subMenuItemsVisible[index]
                    )
            }
        }
        .onAppear {
            // Start the staggered animation for each sub-menu item
            startSubMenuAnimation()
        }
    }

    private func createSubMenuItem(_ item: MenuItem, at index: Int) -> some View {
        item.menuView
            .frame(width: item.size, height: item.size)
            .background(item.color)
            .cornerRadius(item.size / 2)
    }

    private func startSubMenuAnimation() {
        // Start the offset animation for each submenu item
        for index in 0..<subItems.count {
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(index) * 0.05) { // Quick staggered timing
                subMenuItemsVisible[index] = true

                // Calculate the offset for the current item, moving from the previous item's offset
                if index > 0 {
                    let previousOffset = subMenuItemsOffsets[index - 1]
                    let newOffset = position.calculateOffset(radius: 200, index: index, totalItems: subItems.count)

                    // Initially, set the offset to the previous item's position
                    subMenuItemsOffsets[index] = previousOffset

                    // Animate the offset to the final calculated position with a quick ease-out effect
                    withAnimation(.easeOut(duration: 0.2)) {
                        subMenuItemsOffsets[index] = newOffset
                    }
                } else {
                    // First item should go to its final position directly
                    subMenuItemsOffsets[index] = position.calculateOffset(
                        radius: 200,
                        index: index,
                        totalItems: subItems.count
                    )
                }
            }
        }
    }
}


struct LiquidPeelAwayView: View {
    let position: Position
    @State private var isPeeling: Bool = false
    @State private var isExpanded: Bool = false
    @State private var menuItemsVisible: [Bool]
    @State private var currentPeelingAngle: Double = 0
    @State private var xOffset: CGFloat = 0.0
    @State private var yOffset: CGFloat = 0.0
    @State private var animationDuration: Double = 0.5
    var radius: CGFloat = 35.0
    @State private var scaleEffect: CGFloat = 1.0
    @State private var isBouncing = false
    @State private var currentDirectionIndex: Int = 0

    // Shadow properties
    @State private var shadowRadius: CGFloat = 10
    @State private var shadowYOffset: CGFloat = 5

    let menuItems: [MenuItem] = [
        MenuItem(color: .blue, icon: "star", size: 50, menuView: AnyView(Image(systemName: "house.circle")), selected: false, isCollapsed: true, subMenuItems: [
            MenuItem(color: .yellow.opacity(0.7), icon: "star.fill", size: 50, menuView: AnyView(Image(systemName: "star.fill")), selected: false, isCollapsed: true),
            MenuItem(color: .green.opacity(0.7), icon: "star.fill", size: 50, menuView: AnyView(Image(systemName: "star.fill")), selected: false, isCollapsed: true),
            MenuItem(color: .red.opacity(0.7), icon: "star.fill", size: 50, menuView: AnyView(Image(systemName: "star.fill")), selected: false, isCollapsed: true),
            MenuItem(color: .purple.opacity(0.7), icon: "star.fill", size: 50, menuView: AnyView(Image(systemName: "star.fill")), selected: false, isCollapsed: true)
        ]),
        MenuItem(color: .green, icon: "heart", size: 50, menuView: AnyView(Image(systemName: "heart.fill")), selected: false, isCollapsed: true, subMenuItems: nil),
        MenuItem(color: .orange, icon: "moon", size: 50, menuView: AnyView(Image(systemName: "moon.fill")), selected: false, isCollapsed: true, subMenuItems: nil),
        MenuItem(color: .green, icon: "heart", size: 50, menuView: AnyView(Image(systemName: "heart.fill")), selected: false, isCollapsed: true, subMenuItems: nil),
        MenuItem(color: .orange, icon: "moon", size: 50, menuView: AnyView(Image(systemName: "moon.fill")), selected: false, isCollapsed: true, subMenuItems: nil)
    ]

    init(position: Position) {
        self.position = position
        _menuItemsVisible = State(initialValue: Array(repeating: false, count: menuItems.count))
    }

    var body: some View {
        ZStack {
            ZStack {
                Circle()
                    .fill(Color.black)
                    .blur(radius: 18.0)
                    .frame(width: 35.0, height: 50.0)
                    .offset(x: xOffset, y: yOffset)
                    .scaleEffect(scaleEffect)
                Circle()
                    .fill(Color.black)
                    .blur(radius: 20.0)
                    .frame(width: 80.0, height: 100.0)
            }
            .frame(width: 200.0, height: 200.0)
            .overlay(
                Color(white: 0.5).opacity(0.8)
                    .blendMode(.colorBurn)
            )
            .overlay(
                Color(white: 1.0).opacity(0.8)
                    .blendMode(.colorDodge)
            )
            .overlay(
                Color.blue.opacity(0.8)
                    .blendMode(.plusLighter)
            )
            PlusToCrossView(isCross: $isExpanded)

            RadialMenu(
                items: menuItems, position: position,
                isExpanded: $isExpanded,
                menuItemsVisible: $menuItemsVisible,
                currentPeelingAngle: $currentPeelingAngle,
                onAllItemsDisplayed: {
                    print("Hey all displayed")
                }
            )
            .frame(width: 120, height: 120)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: position.floatingButtonAlignment)
        .padding(16)
        .onTapGesture {
            if !isExpanded {
                withAnimation {
                    isPeeling = true
                    isExpanded = true
                    isBouncing = true
                }
                currentDirectionIndex = .zero
                startBounceAndPeelAnimation()
            } else {
                DispatchQueue.main.asyncAfter(deadline: .now() + Double(menuItems.count) * 0.2) {
                    withAnimation {
                        isExpanded = false
                        isBouncing = true
                        isPeeling = true
                    }
                }
                collapseMenuItems()
            }
        }
    }

    private func startBounceAndPeelAnimation() {
        var directions: [(CGFloat, CGFloat)] = []
        for index in 0..<menuItems.count {
            let offset = position.calculateOffset(radius: radius, index: index, totalItems: menuItems.count)
            directions.append(offset)
        }

        for index in menuItems.indices {
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(index) * (0.3 / 6)) {
                menuItemsVisible[index] = true
            }

            DispatchQueue.main.asyncAfter(deadline: .now() + Double(index) * 0.3) {
                let nextDirection = directions[index]
                xOffset = nextDirection.0
                yOffset = nextDirection.1

                // First bounce animation for water drop effect
                withAnimation(Animation.interactiveSpring(response: 0.4, dampingFraction: 0.3, blendDuration: 0)) {
                    self.xOffset = 0
                    self.yOffset = 0
                    self.scaleEffect = 0.8 // More reduction for the droplet effect
                    self.shadowRadius = 15
                    self.shadowYOffset = 10
                }

                // Second bounce animation after a short delay
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { // Adjusted delay for fluidity
                    withAnimation(Animation.interactiveSpring(response: 0.4, dampingFraction: 0.3, blendDuration: 0)) {
                        self.scaleEffect = 1.0
                        self.shadowRadius = 10
                        self.shadowYOffset = 5
                    }
                }

                // Final state check
                if index == menuItems.count - 1 {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        if menuItemsVisible.allSatisfy({ $0 }) {
                            isPeeling = false
                            isBouncing = false
                        }
                    }
                }
            }
        }
        isBouncing = true
    }

    private func collapseMenuItems() {
        // Create an array of offsets for the bouncing effect
        var bounceDirections: [(CGFloat, CGFloat)] = []
        for index in 0..<menuItems.count {
            let offset = position.calculateOffset(radius: radius, index: index, totalItems: menuItems.count)
            bounceDirections.append(offset)
        }

        for index in menuItems.indices {
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(index) * 0.25) {
                let nextDirection = bounceDirections[index]
                xOffset = nextDirection.0
                yOffset = nextDirection.1

                withAnimation(Animation.interactiveSpring(response: 0.5, dampingFraction: 0.5, blendDuration: 0)) {
                    self.xOffset = 0
                    self.yOffset = 0
                }

                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                    withAnimation(Animation.easeInOut(duration: 0.4)) {
                        menuItemsVisible = Array(repeating: false, count: menuItems.count)
                    }
                }
            }
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + Double(menuItems.count) * 0.25 + 0.6) {
            isPeeling = false
            isBouncing = false
        }
    }
}
