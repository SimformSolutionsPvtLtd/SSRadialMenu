//
//  MenuItemModel.swift
//  SSRadialMenu
//
//  Created by Rishita Panchal on 08/12/23.
//

import SwiftUI

struct MenuItem {
    let id = UUID()
    let color: Color
    let icon: String
    let menuView: AnyView
    var selected: Bool
}
