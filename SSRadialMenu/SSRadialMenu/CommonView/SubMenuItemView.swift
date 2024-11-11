//
//  SubMenuItemView.swift
//  SSRadialMenu
//
//  Created by Rishita Panchal on 06/11/24.
//

import SwiftUI

struct MenuItemView: View {
    var item: MenuItem
    @Binding var isExpanded: Bool
    @Binding var x: CGFloat
    @Binding var y: CGFloat
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
            BlurredOverlayCircles(isExpanded: $isExpanded, xOffset: $xOffset, yOffset: $y, scaleEffect: .constant(0.1), frameWidth: 30, frameHeight: 35)
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
