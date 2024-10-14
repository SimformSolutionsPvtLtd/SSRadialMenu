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

    var body: some View {
        ZStack {
            if isExpanded {
                ForEach(items.indices, id: \.self) { index in
                    createMenuItem(items[index], at: index, position: position)
                        .opacity(menuItemsVisible[index] ? 1 : 0)
                        .scaleEffect(menuItemsVisible[index] ? 1.0 : 0.0)
                        .animation(.easeInOut.delay(Double(index) * 0.1), value: menuItemsVisible[index])
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
    @State private var bounceAnimation: CGFloat = 1.0

    let menuItems: [MenuItem] = [
        MenuItem(color: .blue, icon: "star", size: 50, menuView: AnyView(Image(systemName: "house.circle")), selected: false, isCollapsed: true, subMenuItems: [
            MenuItem(color: .yellow.opacity(0.7), icon: "star.fill", size: 50, menuView: AnyView(Image(systemName: "star.fill")), selected: false, isCollapsed: true),
            MenuItem(color: .green.opacity(0.7), icon: "star.fill", size: 50, menuView: AnyView(Image(systemName: "star.fill")), selected: false, isCollapsed: true),
            MenuItem(color: .red.opacity(0.7), icon: "star.fill", size: 50, menuView: AnyView(Image(systemName: "star.fill")), selected: false, isCollapsed: true),
            MenuItem(color: .purple.opacity(0.7), icon: "star.fill", size: 50, menuView: AnyView(Image(systemName: "star.fill")), selected: false, isCollapsed: true)
        ]),
        MenuItem(color: .green, icon: "heart", size: 50, menuView: AnyView(Image(systemName: "heart.fill")), selected: false, isCollapsed: true, subMenuItems: nil),
        MenuItem(color: .orange, icon: "moon", size: 50, menuView: AnyView(Image(systemName: "moon.fill")), selected: false, isCollapsed: true, subMenuItems: nil)
    ]

    init(position: Position) {
        self.position = position
        _menuItemsVisible = State(initialValue: Array(repeating: false, count: menuItems.count))
    }

    var body: some View {
        ZStack {
            // Main menu with stretch effect
            Circle()
                .fill(Color.red)
                .frame(width: isExpanded ? 90 : 60, height: 60)  // Stretch horizontally when expanded
                .scaleEffect(isPeeling ? 1.3 : (isExpanded ? 1.2 : 1.0))  // Stretch scaling effect
                .blur(radius: isPeeling ? 2 : 0)  // Blur to add a liquid feel
                .animation(.spring(response: 0.4, dampingFraction: 0.6, blendDuration: 0.2), value: isPeeling)
                .shadow(color: Color.black.opacity(0.5), radius: 4, x: 0, y: 3)
                .overlay {
                    Circle()
                        .fill(Color.red)
                        .frame(width: 33 * bounceAnimation, height: 33 * bounceAnimation)
                        .scaleEffect(isPeeling ? 1.5 : 1.0)
                        .offset(x: cos(currentPeelingAngle) * 10, y: sin(currentPeelingAngle) * 10)
                        .animation(.spring(response: 0.4, dampingFraction: 0.5, blendDuration: 0.2).delay(0.1), value: isPeeling)
                        .overlay {
                            // Icon inside the button
                            if !isExpanded {
                                Image(systemName: "plus")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 25, height: 25)
                                    .transition(.scale)
                                    .animation(.easeInOut(duration: 0.3), value: isExpanded)
                            }

                            if isExpanded {
                                Image(systemName: "xmark")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 25, height: 25)
                                    .transition(.scale)
                                    .animation(.easeInOut(duration: 0.3), value: isExpanded)
                            }
                        }
                }
                .overlay {
                    Circle()
                        .stroke(Color.red.opacity(0.4), lineWidth: 2)
                        .scaleEffect(isPeeling ? 1.2 : 1.0)
                        .opacity(isPeeling ? 1 : 0)
                        .animation(.easeInOut(duration: 0.3).delay(0.1), value: isPeeling)
                }

            // Radial menu containing subitems
            RadialMenu(
                items: menuItems, position: position,
                isExpanded: $isExpanded,
                menuItemsVisible: $menuItemsVisible,
                currentPeelingAngle: $currentPeelingAngle
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
                }
                startPeelAnimation()
            } else {
                withAnimation {
                    isExpanded = false
                }
            }
        }
    }

    private func startPeelAnimation() {
        // Start peeling animation logic
        for index in 0..<menuItems.count {
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(index) * 0.1) {
                menuItemsVisible[index] = true
            }
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            isPeeling = false
        }
    }
}


enum Position {
    case topRight, bottomRight, topLeft, bottomLeft, center

    var floatingButtonAlignment: Alignment {
        switch self {
        case .topRight:
            .topTrailing
        case .bottomRight:
            .bottomTrailing
        case .topLeft:
            .topLeading
        case .bottomLeft:
            .bottomLeading
        case .center:
            .center
        }
    }

    func calculateOffset(radius: CGFloat, index: Int, totalItems: Int) -> (CGFloat, CGFloat) {
        let baseAngle: CGFloat
        let angleRange: CGFloat
        switch self {
        case .topRight:
            baseAngle = .pi / 2
            angleRange = .pi / 2
        case .bottomRight:
            baseAngle = 3 * .pi / 2
            angleRange = -.pi / 2
        case .topLeft:
            baseAngle = 0
            angleRange = .pi / 2
        case .bottomLeft:
            baseAngle = 3 * .pi / 2
            angleRange = .pi / 2
        case .center:
            baseAngle = 0
            angleRange = 2 * .pi
        }

        let angle: CGFloat
        if self == .center {
            angle = (angleRange / CGFloat(totalItems)) * CGFloat(index)
        } else {
            angle = baseAngle + (angleRange / CGFloat(totalItems - 1)) * CGFloat(index)
        }
        let x = radius * cos(angle)
        let y = radius * sin(angle)
        return (x, y)
    }

}

import SwiftUI

struct MetaBallView: View {
    @State private var progress = 0.0
    @State private var rotation: Double = 0.0 // State variable for rotation

    var body: some View {
        ZStack {
            Circle()
                .fill(Color.black)
                .blur(radius: 20.0)
                .frame(width: 40.0, height: 40.0)
                .offset(x: progress * 30.0) // Only this circle will move
                .rotationEffect(.degrees(rotation)) // Apply rotation effect

            Circle()
                .fill(Color.black)
                .blur(radius: 20.0)
                .frame(width: 100.0, height: 100.0)
                // The second circle is stationary, no offset applied
        }
        .frame(width: 200.0, height: 200.0)
        .overlay(
            Color(white: 0.5)
                .blendMode(.colorBurn)
        )
        .overlay(
            Color(white: 1.0)
                .blendMode(.colorDodge)
        )
        .overlay(
            LinearGradient(colors: [.purple, .red],
                           startPoint: .leading,
                           endPoint: .trailing)
                .blendMode(.plusLighter)
        )
        .onAppear {
            withAnimation(
                .easeInOut(duration: 1.0)
                .repeatForever(autoreverses: true)
            ) {
                progress = 1.0 // Animate the movement of the first circle
            }

            withAnimation(
                .linear(duration: 2.0) // Set the duration for rotation
                .repeatForever(autoreverses: false)
            ) {
                rotation = 360.0 // Complete rotation of the first circle
            }
        }
    }
}

struct MetaBallView_Previews: PreviewProvider {
    static var previews: some View {
        MetaBallView()
    }
}
