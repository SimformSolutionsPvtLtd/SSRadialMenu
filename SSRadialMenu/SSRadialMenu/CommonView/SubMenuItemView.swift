//
//  SubMenuItemView.swift
//  SSRadialMenu
//
//  Created by Rishita Panchal on 06/11/24.
//

import SwiftUI

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
