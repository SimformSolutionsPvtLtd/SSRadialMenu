//
//  SSRadialMenuApp.swift
//  SSRadialMenu
//
//  Created by Bansi Mamtora on 23/01/23.
//

import SwiftUI

@main
struct SSRadialMenuApp: App {
    @State private var items = [
        MenuItem(color: .green, icon: "heart", size: 50, menuView: AnyView(Image(systemName: "heart.fill")), selected: false, isCollapsed: true, subMenuItems: nil),
        MenuItem(color: .yellow, icon: "heart", size: 50, menuView: AnyView(Image(systemName: "heart.fill")), selected: false, isCollapsed: true, subMenuItems: nil),
        MenuItem(color: .green, icon: "plus", size: 50, menuView: AnyView(Image(systemName: "plus.fill")), selected: false, isCollapsed: true, subMenuItems: nil),
        MenuItem(color: .green, icon: "heart", size: 50, menuView: AnyView(Image(systemName: "heart.fill")), selected: false, isCollapsed: true, subMenuItems: nil),
        MenuItem(color: .yellow, icon: "heart", size: 50, menuView: AnyView(Image(systemName: "heart.fill")), selected: false, isCollapsed: true, subMenuItems: nil),
        MenuItem(color: .green, icon: "plus", size: 50, menuView: AnyView(Image(systemName: "plus.fill")), selected: false, isCollapsed: true, subMenuItems: nil),
        MenuItem(color: .green, icon: "heart", size: 50, menuView: AnyView(Image(systemName: "heart.fill")), selected: false, isCollapsed: true, subMenuItems: nil),
        MenuItem(color: .yellow, icon: "heart", size: 50, menuView: AnyView(Image(systemName: "heart.fill")), selected: false, isCollapsed: true, subMenuItems: nil),
        MenuItem(color: .green, icon: "plus", size: 50, menuView: AnyView(Image(systemName: "plus.fill")), selected: false, isCollapsed: true, subMenuItems: nil)
    ]
    var body: some Scene {
        WindowGroup {
            //            LiquidPeelAwayView(position: .bottomRight)
            CircleView(items: $items)
        }
    }
}
