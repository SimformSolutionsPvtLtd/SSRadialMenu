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
    @State private var isExpanded: Bool = false
    @State private var menuItemsVisible: [Bool]
    @State private var currentPeelingAngle: Double = 0
    @State private var bounceAnimation: CGFloat = 1.0

    let menuItems: [MenuItem] = [
        MenuItem(color: .blue, icon: "star", size: 50, menuView: AnyView(Image(systemName: "house.circle")), selected: false, isCollapsed: true),
        MenuItem(color: .green, icon: "heart", size: 50, menuView: AnyView(Image(systemName: "house.circle")), selected: false, isCollapsed: true),
        MenuItem(color: .orange, icon: "moon", size: 50, menuView: AnyView(Image(systemName: "house.circle")), selected: false, isCollapsed: true),
        MenuItem(color: .green, icon: "heart", size: 50, menuView: AnyView(Image(systemName: "house.circle")), selected: false, isCollapsed: true),
        MenuItem(color: .orange, icon: "moon", size: 50, menuView: AnyView(Image(systemName: "house.circle")), selected: false, isCollapsed: true),
        MenuItem(color: .orange, icon: "moon", size: 50, menuView: AnyView(Image(systemName: "house.circle")), selected: false, isCollapsed: true),
        MenuItem(color: .green, icon: "heart", size: 50, menuView: AnyView(Image(systemName: "house.circle")), selected: false, isCollapsed: true),
        MenuItem(color: .orange, icon: "moon", size: 50, menuView: AnyView(Image(systemName: "house.circle")), selected: false, isCollapsed: true)
    ]

    init() {
        _menuItemsVisible = State(initialValue: Array(repeating: false, count: menuItems.count))
    }

    var body: some View {
        ZStack {
            Circle()
                .fill(Color.red)
                .frame(width: 60, height: 60)
                .scaleEffect(isExpanded ? 1.1 : 1.0)
                .shadow(color: Color.black.opacity(0.5), radius: 4, x: 0, y: 3)
                .overlay {
                    Circle()
                        .fill(Color.red)
                        .frame(width: 31 * bounceAnimation, height: 31 * bounceAnimation)
                        .scaleEffect(isPeeling ? 1.5 : 1.0) // Scale effect for stretching
                        .offset(x: cos(currentPeelingAngle) * 11, y: sin(currentPeelingAngle) * 11)
                        .animation(.easeInOut(duration: 0.3).delay(0.1), value: isPeeling)
                        .overlay {
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
                .scaleEffect(isPeeling ? 1.05 : 1.0) // Slight scale effect for the liquid illusion
                .overlay {
                    Circle() // Create a second overlay for the liquid effect
                        .stroke(Color.red.opacity(0.4), lineWidth: 2)
                        .scaleEffect(isPeeling ? 1.2 : 1.0)
                        .opacity(isPeeling ? 1 : 0) // Fade in when peeling
                        .animation(.easeInOut(duration: 0.3).delay(0.1), value: isPeeling)
                }

            RadialMenu(items: menuItems, isExpanded: $isExpanded, menuItemsVisible: $menuItemsVisible, currentPeelingAngle: $currentPeelingAngle)
                .frame(width: 120, height: 120)
        }
        .onTapGesture {
            if !isExpanded {
                withAnimation {
                    isPeeling = true
                    isExpanded = true
                }
                startPeelingEffect()
            } else {
                withAnimation {
                    isPeeling = false
                    isExpanded = false
                }
                resetPeelingEffect()
                menuItemsVisible = Array(repeating: false, count: menuItems.count)
            }
        }
    }

    private func startPeelingEffect() {
        for index in menuItems.indices {
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(index) * 0.2) {
                let angle = (2 * .pi / CGFloat(menuItems.count)) * CGFloat(index)
                withAnimation(.easeInOut(duration: 0.3)) {
                    currentPeelingAngle = angle
                    bounceAnimation = 1.2
                }
                withAnimation(.easeInOut(duration: 0.2).delay(0.3)) {
                    bounceAnimation = 1.0
                }
            }
        }
    }

    private func resetPeelingEffect() {
        bounceAnimation = 1.0
    }
}
