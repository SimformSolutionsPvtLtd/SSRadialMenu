//
//  MenuItemModel.swift
//  SSRadialMenu
//
//  Created by Rishita Panchal on 08/12/23.
//

import SwiftUI

struct MenuItem: Identifiable {
    let id = UUID()
    let color: Color
    let icon: String
    let size: CGFloat
    let menuView: AnyView
    var selected: Bool
}
