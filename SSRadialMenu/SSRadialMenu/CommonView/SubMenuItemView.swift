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
            // Selected item view with reduced blur
            if let selectedItem, selectedItem.id == item.id {
                Circle()
                    .fill(Color.black)
                    .blur(radius: 5.0) // Reduced blur radius
                    .frame(width: 30, height: 40)
                    .offset(x: selectedItem.id == item.id ? xOffset : 0, y: selectedItem.id == item.id ? yOffset : 0)
                    .scaleEffect(selectedItem.id == item.id ? scaleEffect : 1.0)
                    .onAppear {
                        print("SelectedItem : \(selectedItem.id) , \(item.id) -> \(selectedItem.id == item.id)")
                    }
            } else {
                Circle()
                    .fill(Color.black)
                    .frame(width: 60, height: 90)
                    .onAppear {
                        print("Hey : SelectedItem : \(selectedItem?.id) , \(item.id)")
                    }
            }

            // Optional menu item overlay with reduced blur
            Circle()
                .fill(Color.black)
                .blur(radius: 2.0) // Reduced blur radius
                .frame(width: 70, height: 90)

            item.menuView
                .foregroundColor(.blue)
        }
        .offset(x: menuItemsVisible[index] ? x : 0, y: menuItemsVisible[index] ? y : 0)
        .scaleEffect(menuItemsVisible[index] ? 1.2 : 0.0)
        .onTapGesture {
            onTap()
        }
    }
}
