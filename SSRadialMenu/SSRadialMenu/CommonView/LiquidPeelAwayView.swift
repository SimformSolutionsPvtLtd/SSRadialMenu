//
//  LiquidPeelAwayView.swift
//  SSRadialMenu
//
//  Created by Rishita Panchal on 06/11/24.
//

import SwiftUI

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
        MenuItem(color: .pink, icon: "star", size: 40, menuView: AnyView(Image(systemName: "house.circle")), selected: false, isCollapsed: true, subMenuItems: [
            MenuItem(color: .yellow.opacity(0.7), icon: "star.fill", size: 50, menuView: AnyView(Image(systemName: "star.fill")), selected: false, isCollapsed: true),
            MenuItem(color: .green.opacity(0.7), icon: "star.fill", size: 50, menuView: AnyView(Image(systemName: "star.fill")), selected: false, isCollapsed: true),
            MenuItem(color: .red.opacity(0.7), icon: "star.fill", size: 50, menuView: AnyView(Image(systemName: "star.fill")), selected: false, isCollapsed: true),
            MenuItem(color: .purple.opacity(0.7), icon: "star.fill", size: 50, menuView: AnyView(Image(systemName: "star.fill")), selected: false, isCollapsed: true),
            MenuItem(color: .yellow.opacity(0.7), icon: "star.fill", size: 50, menuView: AnyView(Image(systemName: "star.fill")), selected: false, isCollapsed: true),
            MenuItem(color: .green.opacity(0.7), icon: "star.fill", size: 50, menuView: AnyView(Image(systemName: "star.fill")), selected: false, isCollapsed: true),
            MenuItem(color: .red.opacity(0.7), icon: "star.fill", size: 50, menuView: AnyView(Image(systemName: "star.fill")), selected: false, isCollapsed: true),
            MenuItem(color: .purple.opacity(0.7), icon: "star.fill", size: 50, menuView: AnyView(Image(systemName: "star.fill")), selected: false, isCollapsed: true),
            MenuItem(color: .yellow.opacity(0.7), icon: "star.fill", size: 50, menuView: AnyView(Image(systemName: "star.fill")), selected: false, isCollapsed: true),
            MenuItem(color: .green.opacity(0.7), icon: "star.fill", size: 50, menuView: AnyView(Image(systemName: "star.fill")), selected: false, isCollapsed: true)
        ]),
        MenuItem(color: .red, icon: "heart", size: 40, menuView: AnyView(Image(systemName: "heart.fill")), selected: false, isCollapsed: true, subMenuItems: [
            MenuItem(color: .yellow.opacity(0.7), icon: "star.fill", size: 50, menuView: AnyView(Image(systemName: "star.fill")), selected: false, isCollapsed: true),
            MenuItem(color: .green.opacity(0.7), icon: "star.fill", size: 50, menuView: AnyView(Image(systemName: "star.fill")), selected: false, isCollapsed: true),
            MenuItem(color: .red.opacity(0.7), icon: "star.fill", size: 50, menuView: AnyView(Image(systemName: "star.fill")), selected: false, isCollapsed: true),
            MenuItem(color: .yellow.opacity(0.7), icon: "star.fill", size: 50, menuView: AnyView(Image(systemName: "star.fill")), selected: false, isCollapsed: true),
            MenuItem(color: .green.opacity(0.7), icon: "star.fill", size: 50, menuView: AnyView(Image(systemName: "star.fill")), selected: false, isCollapsed: true),
            MenuItem(color: .red.opacity(0.7), icon: "star.fill", size: 50, menuView: AnyView(Image(systemName: "star.fill")), selected: false, isCollapsed: true)
        ]),
        MenuItem(color: .orange, icon: "moon", size: 40, menuView: AnyView(Image(systemName: "moon.fill")), selected: false, isCollapsed: true, subMenuItems: nil),
        MenuItem(color: .red, icon: "heart", size: 40, menuView: AnyView(Image(systemName: "heart.fill")), selected: false, isCollapsed: true, subMenuItems: nil),
        MenuItem(color: .orange, icon: "moon", size: 40, menuView: AnyView(Image(systemName: "moon.fill")), selected: false, isCollapsed: true, subMenuItems: nil),
        MenuItem(color: .red, icon: "heart", size: 40, menuView: AnyView(Image(systemName: "heart.fill")), selected: false, isCollapsed: true, subMenuItems: nil),
        MenuItem(color: .orange, icon: "moon", size: 40, menuView: AnyView(Image(systemName: "moon.fill")), selected: false, isCollapsed: true, subMenuItems: nil)
    ]

    init(position: Position) {
        self.position = position
        _menuItemsVisible = State(initialValue: Array(repeating: false, count: menuItems.count))
    }

    var body: some View {
        ZStack {
            BlurredOverlayCircles(isExpanded: $isExpanded, xOffset: $xOffset, yOffset: $yOffset, scaleEffect: $scaleEffect, currentPeelingAngle: $currentPeelingAngle, color: Color.blue, isMainMenu: true, externalFrameWidth: 100, externalFrameHeight: 100, index: 0)

//            RadialMenu(
//                items: menuItems,
//                position: position,
//                isExpanded: $isExpanded,
//                menuItemsVisible: $menuItemsVisible,
//                currentPeelingAngle: $currentPeelingAngle)
          
            .onChange(of: isExpanded) { _, newVal in
                if !newVal {
                    currentPeelingAngle = 0
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: position.floatingButtonAlignment)
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

        // Calculate offsets for each menu item
        for index in 0..<menuItems.count {
            if let offset = position.calculateOffset(radius: radius, index: index, totalItems: menuItems.count) {
                directions.append(offset)
            } else {
                print("Offset is nil for item at index \(index)")
                directions.append((0.0, 0.0))
            }
        }
        // Start the bounce and peel animation
        for index in menuItems.indices {
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(index) * (0.4 / 6)) {
                withAnimation(.interactiveSpring) {
                    menuItemsVisible[index] = true
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
            if let offset = position.calculateOffset(radius: radius, index: index, totalItems: menuItems.count) {
                bounceDirections.append(offset)
            } else {
                print("Offset is nil for item at index \(index)")
                bounceDirections.append((0.0, 0.0))
            }
        }

        // Convert the currentPeelingAngle to radians
        let rotationAngle = currentPeelingAngle * (.pi / 180)  // Convert degrees to radians
        let rotationTransform = CGAffineTransform(rotationAngle: rotationAngle)

        // Apply the rotation transform to each direction
        bounceDirections = bounceDirections.map { direction in
            let point = CGPoint(x: direction.0, y: direction.1)
            let rotatedPoint = point.applying(rotationTransform)
            return (rotatedPoint.x, rotatedPoint.y)
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
