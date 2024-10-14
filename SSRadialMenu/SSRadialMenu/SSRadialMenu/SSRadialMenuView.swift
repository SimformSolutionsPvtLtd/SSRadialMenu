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
    
    var body: some View {
        ZStack {
            if isExpanded {
                ForEach(items.indices, id: \.self) { index in
                    createMenuItem(items[index], at: index, position: position)
                        .opacity(menuItemsVisible[index] ? 1 : 0)
                        .scaleEffect(menuItemsVisible[index] ? 1.0 : 0.0)
                        .animation(.easeInOut.delay(Double(index) * 0.1), value: menuItemsVisible[index])
                        .onAppear {
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


    private func calculateOffset(radius: CGFloat, index: Int, totalItems: Int, position: Position) -> (CGFloat, CGFloat) {
        let baseAngle: CGFloat
        let angleRange: CGFloat
        switch position {
        case .topRight:
            // fan out from 90° to 180°
            baseAngle = .pi / 2
            angleRange = .pi / 2
        case .bottomRight:
            // fan out from 180° to 270°
            baseAngle = .pi
            angleRange = .pi / 2
        case .topLeft:
            // fan out from 0° to 90°
            baseAngle = 0
            angleRange = .pi / 2
        case .bottomLeft:
            // fan out from 270° to 360°
            baseAngle = 3 * .pi / 2
            angleRange = .pi / 2
        case .center:
            // Fan out from the center
            baseAngle = 0
            angleRange = 2 * .pi
        }
        let angle: CGFloat
        if position == .center {
            angle = (angleRange / CGFloat(totalItems)) * CGFloat(index)
        } else {
            angle = baseAngle + (angleRange / CGFloat(totalItems - 1)) * CGFloat(index)
        }
        let x = radius * cos(angle)
        let y = radius * sin(angle)
        return (x, y)
    }


    private func createMenuItem(_ item: MenuItem, at index: Int, position: Position) -> some View {
        let radius: CGFloat = 100
        let (x, y) = calculateOffset(radius: radius, index: index, totalItems: items.count, position: position)

        return item.menuView
            .frame(width: item.size, height: item.size)
            .background(item.color)
            .cornerRadius(item.size / 2)
            .offset(x: menuItemsVisible[index] ? x : 0, y: menuItemsVisible[index] ? y : 0)
            .scaleEffect(menuItemsVisible[index] ? 1.2 : 0.0)
            .animation(.easeOut(duration: 0.3).delay(Double(index) * 0.1), value: menuItemsVisible[index])
            .onTapGesture {
                selectedItem = item
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
        MenuItem(color: .blue, icon: "star", size: 50, menuView: AnyView(Image(systemName: "house.circle")), selected: false, isCollapsed: true),
        MenuItem(color: .green, icon: "heart", size: 50, menuView: AnyView(Image(systemName: "house.circle")), selected: false, isCollapsed: true),
        MenuItem(color: .orange, icon: "moon", size: 50, menuView: AnyView(Image(systemName: "house.circle")), selected: false, isCollapsed: true)
    ]

    init(position: Position) {
        self.position = position
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
                        .frame(width: 33 * bounceAnimation, height: 33 * bounceAnimation)
                        .scaleEffect(isPeeling ? 1.5 : 1.0)
                        .offset(x: cos(currentPeelingAngle) * 10, y: sin(currentPeelingAngle) * 10)
                        .animation(.spring(response: 0.4, dampingFraction: 0.5, blendDuration: 0.2).delay(0.1), value: isPeeling)
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
                .scaleEffect(isPeeling ? 1.05 : 1.0)
                .overlay {
                    Circle()
                        .stroke(Color.red.opacity(0.4), lineWidth: 2)
                        .scaleEffect(isPeeling ? 1.2 : 1.0)
                        .opacity(isPeeling ? 1 : 0)
                        .animation(.easeInOut(duration: 0.3).delay(0.1), value: isPeeling)
                }

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
}
