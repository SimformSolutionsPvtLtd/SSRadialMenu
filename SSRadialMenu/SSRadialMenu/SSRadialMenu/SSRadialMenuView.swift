//
//  SSRadialMenuView.swift
//  SSRadialMenuView
//
//  Created by Rishita Panchal on 07/12/23.
//
import SwiftUI

// Define the RadialMenu view
struct RadialMenu: View {
    let items: [MenuItem]
    @Binding var isExpanded: Bool
    @Binding var menuItemsVisible: [Bool] // Pass visibility state from parent
    @Binding var currentPeelingAngle: Double // Track the current angle for peeling

    @State private var selectedItem: MenuItem?

    var body: some View {
        ZStack {
            if isExpanded {
                ForEach(items.indices, id: \.self) { index in
                    createMenuItem(items[index], at: index)
                        .opacity(menuItemsVisible[index] ? 1 : 0) // Show or hide based on visibility state
                        .animation(.easeInOut.delay(Double(index) * 0.1), value: menuItemsVisible[index]) // Delay based on index
                        .onAppear {
                            // Update peeling direction based on the current angle of the submenu
                            let angle = (2 * .pi / CGFloat(items.count)) * CGFloat(index)
                            currentPeelingAngle = angle
                        }
                }
                .onAppear {
                    for index in items.indices {
                        DispatchQueue.main.asyncAfter(deadline: .now() + Double(index) * 0.1) {
                            withAnimation {
                                menuItemsVisible[index] = true
                            }
                        }
                    }
                }
            }
        }
    }

    private func createMenuItem(_ item: MenuItem, at index: Int) -> some View {
        let radius: CGFloat = 100 // Distance from center
        let angle = (2 * .pi / CGFloat(items.count)) * CGFloat(index)
        let x = radius * cos(angle)
        let y = radius * sin(angle)

        return item.menuView
            .frame(width: item.size, height: item.size)
            .background(item.color)
            .cornerRadius(item.size / 2)
            .offset(x: x, y: y)
            .onTapGesture {
                // Handle item tap, update state or call an action
                selectedItem = item
            }
    }
}

struct LiquidPeelAwayView: View {
    @State private var isPeeling: Bool = false
    @State private var scale: CGFloat = 1.0
    @State private var isExpanded: Bool = false // State to control the radial menu
    @State private var menuItemsVisible: [Bool] // Visibility of each menu item
    @State private var currentPeelingAngle: Double = 0 // Angle of peeling based on submenu position
    @State private var bounceAnimation: CGFloat = 1.0 // Bounce effect

    let menuItems: [MenuItem] = [
        MenuItem(
            color: .blue,
            icon: "star",
            size: 50,
            menuView: AnyView(Image(systemName: "house.circle")),
            selected: false,
            isCollapsed: true
        ),
        MenuItem(
            color: .green,
            icon: "heart",
            size: 50,
            menuView:AnyView(Image(systemName: "house.circle")),
            selected: false,
            isCollapsed: true
        ),
        MenuItem(
            color: .orange,
            icon: "moon",
            size: 50,
            menuView: AnyView(Image(systemName: "house.circle")),
            selected: false, isCollapsed: true
        ),
        MenuItem(
            color: .green,
            icon: "heart",
            size: 50,
            menuView: AnyView(Image(systemName: "house.circle")),
            selected: false,
            isCollapsed: true
        ),
        MenuItem(
            color: .orange,
            icon: "moon",
            size: 50, 
            menuView: AnyView(Image(systemName: "house.circle")),
            selected: false, isCollapsed: true
        ),
        MenuItem(
            color: .orange,
            icon: "moon",
            size: 50,
            menuView: AnyView(Image(systemName: "house.circle")),
            selected: false,
            isCollapsed: true
        ),
        MenuItem(
            color: .green,
            icon: "heart",
            size: 50,
            menuView: AnyView(Image(systemName: "house.circle")),
            selected: false,
            isCollapsed: true
        ),
        MenuItem(
            color: .orange,
            icon: "moon",
            size: 50,
            menuView: AnyView(Image(systemName: "house.circle")),
            selected: false,
            isCollapsed: true
        )
    ]

    init() {
        // Initialize the visibility array based on menuItems count
        _menuItemsVisible = State(initialValue: Array(repeating: false, count: menuItems.count))
    }

    var body: some View {
        ZStack {
            // Main circle with liquid peel effect


            Circle()
                .fill(Color.red)
                .frame(width: 40 * bounceAnimation, height: 40 * bounceAnimation)
                .offset(x: cos(currentPeelingAngle) * 8, y: sin(currentPeelingAngle) * 8)
                .scaleEffect(isPeeling ? bounceAnimation : 1.0)
                .overlay {
                    Circle()
                        .fill(Color.red)
                        .frame(width: 60, height: 60)
                        .overlay(
                            Image(systemName: "plus") // Example image (SF Symbol)
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 30, height: 30) // Adjust size to fit the circle
                        )
                        .scaleEffect(isExpanded ? 1.1 : 1.0)
                        .animation(.easeInOut(duration: 0.3), value: isExpanded)
                }
                .animation(.easeInOut(duration: 0.3), value: isPeeling)

            // Radial menu for submenu items
            RadialMenu(items: menuItems, isExpanded: $isExpanded, menuItemsVisible: $menuItemsVisible, currentPeelingAngle: $currentPeelingAngle)
                .frame(width: 120, height: 120) // Adjust based on your layout
        }
        .onTapGesture {
            if !isExpanded {
                // Start the peel effect and expand the menu
                withAnimation {
                    isPeeling = true
                    isExpanded = true
                }
                // Peeling effect occurs as the menu items come out
                startPeelingEffect()
            } else {
                // Collapse the menu and reset peel effect
                withAnimation {
                    isPeeling = false
                    isExpanded = false
                }
                // Reset visibility and peeling when collapsing
                resetPeelingEffect()
                menuItemsVisible = Array(repeating: false, count: menuItems.count)
            }
        }
    }

    private func startPeelingEffect() {
        // Start a subtle bouncing/stretch effect in sync with the menu items
        for index in menuItems.indices {
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(index) * 0.2) {
                // Update the currentPeelingAngle to target the submenu item
                let angle = (2 * .pi / CGFloat(menuItems.count)) * CGFloat(index)
                withAnimation(.easeInOut(duration: 0.3)) {
                    currentPeelingAngle = angle
                    bounceAnimation = 1.2 // Bounce out
                }
                withAnimation(.easeInOut(duration: 0.2).delay(0.3)) {
                    bounceAnimation = 1.0 // Bounce back in
                }
            }
        }
    }

    private func resetPeelingEffect() {
        // Reset the bouncing/stretch effect when collapsing
        bounceAnimation = 1.0
    }
}
