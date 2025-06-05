//
//  SSRadialMenuApp.swift
//  SSRadialMenu
//
//  Created by Bansi Mamtora on 23/01/23.
//

import SwiftUI

// Default menu items data with 60 items for testing
private let defaultMenuItems: [RadialMenuItems] = {
    var baseItems: [RadialMenuItems] = [
        .init(name: "Action Item", icon: "pizza1", price: "200 $", subMenuItems: [
               RadialMenuItems(name: "Sub Action 1", icon: "pizza1", price: "200 $", subMenuItems: [
                   RadialMenuItems(name: "Sub-Sub Action 1A", icon: "pizza1", price: "205 $"),
                   RadialMenuItems(name: "Sub-Sub Action 1B", icon: "pizza1", price: "215 $")
               ]),
               RadialMenuItems(name: "Sub Action 2", icon: "pizza1", price: "210 $", subMenuItems: [
                   RadialMenuItems(name: "Sub-Sub Action 2A", icon: "pizza1", price: "225 $"),
                   RadialMenuItems(name: "Sub-Sub Action 2B", icon: "pizza1", price: "235 $"),
                   RadialMenuItems(name: "Sub-Sub Action 2C", icon: "pizza1", price: "245 $")
               ]),
               RadialMenuItems(name: "Sub Action 3", icon: "pizza1", price: "220 $"),
               RadialMenuItems(name: "Sub Action 4", icon: "pizza1", price: "220 $"),
               RadialMenuItems(name: "Sub Action 5", icon: "pizza1", price: "220 $"),
               RadialMenuItems(name: "Sub Action 6", icon: "pizza1", price: "220 $"),
               RadialMenuItems(name: "Sub Action 7", icon: "pizza1", price: "220 $"),
               RadialMenuItems(name: "Sub Action 8", icon: "pizza1", price: "220 $"),
               RadialMenuItems(name: "Sub Action 9", icon: "pizza1", price: "220 $"),
               RadialMenuItems(name: "Sub Action 10", icon: "pizza1", price: "220 $"),
               RadialMenuItems(name: "Sub Action 11", icon: "pizza1", price: "220 $"),
               RadialMenuItems(name: "Sub Action 12", icon: "pizza1", price: "220 $"),
               RadialMenuItems(name: "Sub Action 13", icon: "pizza1", price: "220 $"),
               RadialMenuItems(name: "Sub Action 14", icon: "pizza1", price: "220 $"),
               RadialMenuItems(name: "Sub Action 15", icon: "pizza1", price: "220 $"),
               RadialMenuItems(name: "Sub Action 16", icon: "pizza1", price: "220 $"),
               RadialMenuItems(name: "Sub Action 17", icon: "pizza1", price: "220 $"),
               RadialMenuItems(name: "Sub Action 18", icon: "pizza1", price: "220 $"),
               RadialMenuItems(name: "Sub Action 19", icon: "pizza1", price: "220 $"),
               RadialMenuItems(name: "Sub Action 20", icon: "pizza1", price: "220 $"),
               RadialMenuItems(name: "Sub Action 21", icon: "pizza1", price: "220 $"),
               RadialMenuItems(name: "Sub Action 22", icon: "pizza1", price: "220 $"),
               RadialMenuItems(name: "Sub Action 23", icon: "pizza1", price: "220 $"),
               RadialMenuItems(name: "Sub Action 24", icon: "pizza1", price: "220 $"),
               RadialMenuItems(name: "Sub Action 25", icon: "pizza1", price: "220 $"),
               RadialMenuItems(name: "Sub Action 26", icon: "pizza1", price: "220 $"),
               RadialMenuItems(name: "Sub Action 27", icon: "pizza1", price: "220 $"),
               RadialMenuItems(name: "Sub Action 28", icon: "pizza1", price: "220 $"),
               RadialMenuItems(name: "Sub Action 29", icon: "pizza1", price: "220 $"),
               RadialMenuItems(name: "Sub Action 30", icon: "pizza1", price: "220 $"),
               RadialMenuItems(name: "Sub Action 31", icon: "pizza1", price: "220 $"),
               RadialMenuItems(name: "Sub Action 32", icon: "pizza1", price: "220 $"),
               RadialMenuItems(name: "Sub Action 33", icon: "pizza1", price: "220 $"),
               RadialMenuItems(name: "Sub Action 34", icon: "pizza1", price: "220 $"),
               RadialMenuItems(name: "Sub Action 35", icon: "pizza1", price: "220 $")
           ]),
        .init(name: "Settings", icon: "pizza2", price: "150 $", subMenuItems: nil),
        .init(name: "Profile", icon: "pizza3", price: "300 $", subMenuItems: [
               RadialMenuItems(name: "Sub Profile 1", icon: "pizza3", price: "310 $", subMenuItems: [
                   RadialMenuItems(name: "Sub-Sub Profile 1A", icon: "pizza3", price: "315 $"),
                   RadialMenuItems(name: "Sub-Sub Profile 1B", icon: "pizza3", price: "325 $")
               ]),
               RadialMenuItems(name: "Sub Profile 2", icon: "pizza3", price: "320 $")
           ]),
        .init(name: "Dashboard", icon: "pizza4", price: "180 $", subMenuItems: nil),
        .init(name: "Reports", icon: "pizza5", price: "220 $", subMenuItems: nil),
        .init(name: "Analytics", icon: "pizza6", price: "190 $", subMenuItems: nil),
        .init(name: "Messages", icon: "pizza7", price: "250 $", subMenuItems: nil),
        .init(name: "Notifications", icon: "pizza8", price: "210 $", subMenuItems: nil),
        .init(name: "Files", icon: "pizza1", price: "280 $", subMenuItems: nil),
        .init(name: "Calendar", icon: "pizza2", price: "200 $", subMenuItems: nil),
        .init(name: "Tasks", icon: "pizza3", price: "230 $", subMenuItems: nil),
        .init(name: "Contacts", icon: "pizza4", price: "170 $", subMenuItems: nil),
        .init(name: "Help", icon: "pizza5", price: "320 $", subMenuItems: nil)
    ]
    
    // Generate additional items to test carousel with 50+ items
    var allItems = baseItems
    let itemTypes = ["Option", "Tool", "Feature", "Command", "Service", "Module", "Widget", "Component"]
    let itemImages = ["pizza1", "pizza2", "pizza3", "pizza4", "pizza5", "pizza6", "pizza7", "pizza8"]
    
    for i in 14...60 {
        let typeIndex = (i - 14) % itemTypes.count
        let imageIndex = (i - 14) % itemImages.count
        let price = 150 + (i * 10)
        
        allItems.append(.init(
            name: "\(itemTypes[typeIndex]) \(i)",
            icon: itemImages[imageIndex],
            price: "\(price) $",
            subMenuItems: nil
        ))
    }
    
    return allItems
}()

@main
struct SSRadialMenuApp: App {
    var body: some Scene {
        WindowGroup {
            SSRadialMenu(
                menuItems: defaultMenuItems,
                alignment: .bottomTrailing,
                fabIcon: "pizza1"
            )
        }
    }
}
