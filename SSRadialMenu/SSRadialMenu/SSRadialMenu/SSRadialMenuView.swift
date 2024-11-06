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
                }

                if let selectedItem, let subItems = selectedItem.subMenuItems {
                    SubMenuView(subItems: subItems, position: position, isExpand: $showSubMenu)
                        .transition(.scale)
                        .animation(.easeInOut, value: showSubMenu)
                }
            }
        }
    }

    private func createMenuItem(_ item: MenuItem, at index: Int, position: Position) -> some View {
        let radius: CGFloat = 100
        let (x, y) = position.calculateOffset(radius: radius, index: index, totalItems: items.count)
        return MenuItemView(item: item, x: x, y: y, selectedItem: $selectedItem, menuItemsVisible: menuItemsVisible, index: index, onTap: {
            selectedItem = item
            startBounceAndPeelAnimation(item: item)
            if let subItems = item.subMenuItems, !subItems.isEmpty {
                showSubMenu.toggle()
            } else {
                showSubMenu = false
            }
        }, xOffset: $xOffset, yOffset: $yOffset)
        .onDisappear {
            if showSubMenu {
                showSubMenu = false
            }
        }
    }

    private func startBounceAndPeelAnimation(item: MenuItem?) {
        subMenuItemsVisible = Array(repeating: false, count: 1)
        var directions: [(CGFloat, CGFloat)] = []
        if let item, let subMenuItems = item.subMenuItems {
            for index in 0..<1 {
                let offset = position.calculateOffset(radius: radius, index: index, totalItems: subMenuItems.count)
                directions.append(offset)
            }

            for index in 0..<1{
                DispatchQueue.main.asyncAfter(deadline: .now() + Double(index) * (0.4 / 6)) {
                    withAnimation(.interactiveSpring) {
                        subMenuItemsVisible[index] = true
                    }
                }

                DispatchQueue.main.asyncAfter(deadline: .now() + Double(index) * 0.4) {
                    let nextDirection = directions[index]
                    xOffset = nextDirection.0
                    yOffset = nextDirection.1

                    print("xoffset: \(xOffset) - yOffset: \(yOffset)")
                    withAnimation(Animation.interactiveSpring(response: 0.5, dampingFraction: 0.4, blendDuration: 0)) {
                        self.xOffset = 0
                        self.yOffset = 0
                        self.scaleEffect = 0.8
                        self.shadowRadius = 15
                        self.shadowYOffset = 10
                    }

                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { // Adjusted delay for fluidity
                        withAnimation(Animation.interactiveSpring(response: 0.5, dampingFraction: 0.5, blendDuration: 0)) {
                            self.scaleEffect = 1.0
                            self.shadowRadius = 10
                            self.shadowYOffset = 5
                        }
                    }

                    if index == subMenuItems.count - 1 {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                            if subMenuItemsVisible.allSatisfy({ $0 }) {
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

struct MenuItemView: View {
    var item: MenuItem
    var x: CGFloat
    var y: CGFloat
    @Binding var selectedItem: MenuItem?
    var menuItemsVisible: [Bool]
    var index: Int
    var onTap: (() -> Void)

    @Binding var xOffset: CGFloat
    @Binding var yOffset: CGFloat
    @State var scaleEffect: CGFloat = 1.0

    var radius: CGFloat = 100

    var body: some View {
        ZStack {
            // Selected item view
            if let selectedItem, selectedItem.id == item.id {
                Circle()
                    .fill(Color.black)
                    .blur(radius: 18.0)
                    .frame(width: 30, height: 40)
                    .offset(x: selectedItem.id == item.id ? xOffset : 0, y: selectedItem.id == item.id ? yOffset : 0)
                    .scaleEffect(selectedItem.id == item.id ? scaleEffect : 1.0)
                    .onAppear {
                        print("SelectedItem : \(selectedItem.id) , \(item.id) -> \(selectedItem.id == item.id)")
                    }
            } else {
                Circle()
                    .fill(Color.black)
                    .blur(radius: 18.0)
                    .frame(width: 30, height: 40)
                    .onAppear {
                        print("Hey : SelectedItem : \(selectedItem?.id) , \(item.id)")
                    }
            }

            // Menu item overlay
            Circle()
                .fill(Color.black)
                .blur(radius: 20.0)
                .frame(width: 70, height: 90)

            item.menuView
                .foregroundColor(.blue)
        }
        .overlay(
            Color(white: 0.5).opacity(0.8)
                .blendMode(.colorBurn)
                .allowsHitTesting(false)
        )
        .overlay(
            Color(white: 1.0).opacity(0.8)
                .blendMode(.colorDodge)
                .allowsHitTesting(false)
        )
        .overlay(
            item.color.opacity(0.8)
                .blendMode(.plusLighter)
                .allowsHitTesting(false)
        )
        .cornerRadius(item.size / 2)
        .offset(x: menuItemsVisible[index] ? x : 0, y: menuItemsVisible[index] ? y : 0)
        .scaleEffect(menuItemsVisible[index] ? 1.2 : 0.0)
        .onTapGesture {
            onTap()
        }
    }
}
