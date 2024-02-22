//
//  SSRadialMenuViewModel.swift
//  SSRadialMenu
//
//  Created by Rishita Panchal on 08/12/23.
//

import SwiftUI

class MenuViewModel: ObservableObject {
    @Published var menus: [MenuItem] = [
        MenuItem(
            color: .red,
            icon: "menucard.fill",
            menuView: AnyView(EmptyView()),
            selected: false
        ),
        MenuItem(
            color: .blue,
            icon: "ellipsis.bubble.fill",
            menuView: AnyView(EmptyView()),
            selected: true
        ),
        MenuItem(
            color: .yellow,
            icon: "ellipsis",
            menuView: AnyView(EmptyView()),
            selected: false
        ),
    ]
    
    @Published var subMenus: [MenuItem] = [
        MenuItem(
            color: .pink,
            icon: "menucard.fill",
            menuView: AnyView(EmptyView()),
            selected: false
        ),
        MenuItem(
            color: .cyan,
            icon: "ellipsis.bubble.fill",
            menuView: AnyView(EmptyView()),
            selected: true
        ),
        MenuItem(
            color: .green,
            icon: "ellipsis",
            menuView: AnyView(EmptyView()),
            selected: false
        ),
        MenuItem(
            color: .gray,
            icon: "ellipsis",
            menuView: AnyView(EmptyView()),
            selected: false
        )
    ]
}
