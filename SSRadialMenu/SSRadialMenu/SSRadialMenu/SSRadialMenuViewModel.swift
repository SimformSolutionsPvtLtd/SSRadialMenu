//
//  SSRadialMenuViewModel.swift
//  SSRadialMenu
//
//  Created by Rishita Panchal on 08/12/23.
//

import SwiftUI

class SSRadialMenuViewModel: ObservableObject {
    @Published var menus: [MenuItem] = [
        MenuItem(
            color: .red,
            icon: "menucard.fill",
            size: 60,
            menuView: AnyView(EmptyView()),
            selected: false,
            isCollapsed: true
        ),
        MenuItem(
            color: .blue,
            icon: "ellipsis.bubble.fill", 
            size: 60,
            menuView: AnyView(EmptyView()),
            selected: true,
            isCollapsed: true
        ),
        MenuItem(
            color: .yellow,
            icon: "ellipsis",
            size: 60,
            menuView: AnyView(EmptyView()),
            selected: false,
            isCollapsed: true
        ),
        MenuItem(
            color: .yellow,
            icon: "ellipsis",
            size: 60,
            menuView: AnyView(EmptyView()),
            selected: false,
            isCollapsed: true
        ),
        MenuItem(
            color: .yellow,
            icon: "ellipsis",
            size: 60,
            menuView: AnyView(EmptyView()),
            selected: false,
            isCollapsed: true
        ),
        MenuItem(
            color: .yellow,
            icon: "ellipsis",
            size: 60,
            menuView: AnyView(EmptyView()),
            selected: false,
            isCollapsed: true
        ),
        MenuItem(
            color: .yellow,
            icon: "ellipsis",
            size: 60,
            menuView: AnyView(EmptyView()),
            selected: false,
            isCollapsed: true
        ),
        MenuItem(
            color: .yellow,
            icon: "ellipsis",
            size: 60,
            menuView: AnyView(EmptyView()),
            selected: false,
            isCollapsed: true
        )
    ]
}
