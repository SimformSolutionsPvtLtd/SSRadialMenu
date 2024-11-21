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
    @State var subSubMenuPeelingAngle = 0.0
    @State private var xOffset: CGFloat = 0.0
    @State private var yOffset: CGFloat = 0.0
    @State private var selectedItem: MenuItem?
    @State private var showSubMenu: Bool = false
    @State private var scaleEffect: CGFloat = 1.0
    @State private var dragOffset: CGSize = .zero  // Track drag offset

    @State private var isBouncing = false
    @State private var currentDirectionIndex: Int = 0

    // Shadow properties
    var radius: CGFloat = 35.0
    @State private var shadowRadius: CGFloat = 10
    @State private var shadowYOffset: CGFloat = 5
    @State var subMenuItemsVisible: [Bool] = [Bool]()

    var body: some View {
        ZStack {
            if isExpanded {
                ForEach(items.indices, id: \.self) { index in
                    createMenuItem(items[index], at: index, position: position)
                        .opacity(menuItemsVisible[index] ? 1 : 0)
                        .scaleEffect(menuItemsVisible[index] ? 1.0 : 0.0)
                        .animation(.easeInOut.delay(Double(index) * 0.2), value: menuItemsVisible[index])
                        .rotationEffect(.degrees(currentPeelingAngle), anchor: .center) // Adjust rotation anchor
                        .gesture(
                            DragGesture()
                                .onChanged { value in
                                    if !showSubMenu {
                                        if items.count > 4 {
                                            dragOffset = value.translation
                                            let angle = atan2(dragOffset.height, dragOffset.width)
                                            currentPeelingAngle = angle * 180 / .pi
                                            print(currentPeelingAngle)
                                        }
                                    }
                                }
                                .onEnded { value in
                                    withAnimation {
                                        dragOffset = .zero
                                    }
                                }
                        )

                }

                if let selectedItem, let subItems = selectedItem.subMenuItems {
                    SubMenuView(subItems: subItems, position: position, isExpand: $showSubMenu)
                        .transition(.scale)
                        .animation(.easeInOut, value: showSubMenu)
                        .rotationEffect(.degrees(subSubMenuPeelingAngle), anchor: .center)
                        .gesture(
                            DragGesture()
                                .onChanged { value in
                                    if items.count > 4 {
                                        dragOffset = value.translation
                                        let angle = atan2(dragOffset.height, dragOffset.width)
                                        subSubMenuPeelingAngle = angle * 180 / .pi  // Convert to degrees
                                        print(subSubMenuPeelingAngle)
                                    }
                                }
                                .onEnded { value in
                                    withAnimation {
                                        dragOffset = .zero
                                    }
                                }
                        )
                }
            }
        }
    }

    private func createMenuItem(_ item: MenuItem, at index: Int, position: Position) -> some View {
        let radius: CGFloat = 100
        let (x, y) = position.calculateOffset(radius: radius, index: index, totalItems: items.count) ?? (0, 0)

        return MenuItemView(
            item: item,
            isExpanded: $isExpanded,
            x: .constant(x),
            y: .constant(y),
            selectedItem: $selectedItem,
            menuItemsVisible: menuItemsVisible,
            index: index,
            onTap: {
                subSubMenuPeelingAngle = currentPeelingAngle
                selectedItem = item
                if let subItems = item.subMenuItems, !subItems.isEmpty {
                    showSubMenu.toggle()
                } else {
                    showSubMenu = false
                    subSubMenuPeelingAngle = currentPeelingAngle
                }
            },
            xOffset: $xOffset,
            yOffset: $yOffset
        )
        .modifier(ShadowModifier(isSelected: selectedItem?.id == item.id && showSubMenu))// Apply shadow based on selection
        .onDisappear {
            if showSubMenu {
                showSubMenu = false
            }
        }
    }

}

struct ShadowModifier: ViewModifier {
    let isSelected: Bool

    func body(content: Content) -> some View {
        if isSelected {
            return AnyView(content
                .shadow(color: .black, radius: 10, x: 0, y: 5))
        } else {
            return AnyView(content)
        }
    }
}
