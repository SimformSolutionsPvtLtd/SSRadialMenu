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
    @State private var subMenuItems: [MenuItem] = []

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
