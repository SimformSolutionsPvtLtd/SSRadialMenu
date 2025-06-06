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
        .init(name: "Action Item", icon: "1.circle", subMenuItems: [
               RadialMenuItems(name: "Sub Action 1", icon: "heart.fill", subMenuItems: [
                    RadialMenuItems(name: "Sub-Sub Action 1A", icon: "star.fill"),
                    RadialMenuItems(name: "Sub-Sub Action 1B", icon: "heart.fill")
               ]),
               RadialMenuItems(name: "Sub Action 2", icon: "gear", image: "pizza1", subMenuItems: [
                    RadialMenuItems(name: "Sub-Sub Action 1A", icon: "star.fill"),
                    RadialMenuItems(name: "Sub-Sub Action 1B", icon: "heart.fill")
               ]),
               RadialMenuItems(name: "Sub-Sub Action 1A", icon: "2.circle"),
               RadialMenuItems(name: "Sub-Sub Action 1B", icon: "3.circle"),
               RadialMenuItems(name: "Sub-Sub Action 1A", icon: "4.circle"),
               RadialMenuItems(name: "Sub-Sub Action 1B", icon: "heart.fill"),
               RadialMenuItems(name: "Sub-Sub Action 1A", icon: "star.fill"),
               RadialMenuItems(name: "Sub-Sub Action 1B", icon: "heart.fill"),
               RadialMenuItems(name: "Sub-Sub Action 1A", icon: "star.fill"),
               RadialMenuItems(name: "Sub-Sub Action 1B", icon: "heart.fill"),
               RadialMenuItems(name: "Sub-Sub Action 1A", icon: "star.fill"),
               RadialMenuItems(name: "Sub-Sub Action 1B", icon: "heart.fill"),
               RadialMenuItems(name: "Sub-Sub Action 1A", icon: "star.fill"),
               RadialMenuItems(name: "Sub-Sub Action 1B", icon: "heart.fill"),
               RadialMenuItems(name: "Sub-Sub Action 1A", icon: "star.fill"),
               RadialMenuItems(name: "Sub-Sub Action 1B", icon: "heart.fill"),
               RadialMenuItems(name: "Sub-Sub Action 1A", icon: "star.fill"),
               RadialMenuItems(name: "Sub-Sub Action 1B", icon: "heart.fill"),
               RadialMenuItems(name: "Sub-Sub Action 1A", icon: "star.fill"),
               RadialMenuItems(name: "Sub-Sub Action 1B", icon: "heart.fill")
           ]),
        .init(name: "Settings", icon: "2.circle", subMenuItems: nil),
        .init(name: "Profile", icon: "3.circle", subMenuItems: [
               RadialMenuItems(name: "Sub Profile 1", icon: "person.circle", subMenuItems: [
                    RadialMenuItems(name: "Sub-Sub Action 1A", icon: "star.fill"),
                    RadialMenuItems(name: "Sub-Sub Action 1B", icon: "heart.fill"),
                    RadialMenuItems(name: "Sub-Sub Action 1A", icon: "star.fill"),
                    RadialMenuItems(name: "Sub-Sub Action 1B", icon: "heart.fill"),
                    RadialMenuItems(name: "Sub-Sub Action 1A", icon: "star.fill"),
                    RadialMenuItems(name: "Sub-Sub Action 1B", icon: "heart.fill")
               ]),
               RadialMenuItems(name: "Sub-Sub Action 1A", icon: "star.fill"),
               RadialMenuItems(name: "Sub-Sub Action 1B", icon: "heart.fill"),
               RadialMenuItems(name: "Sub-Sub Action 1A", icon: "star.fill"),
               RadialMenuItems(name: "Sub-Sub Action 1B", icon: "heart.fill"),
               RadialMenuItems(name: "Sub-Sub Action 1A", icon: "star.fill"),
               RadialMenuItems(name: "Sub-Sub Action 1B", icon: "heart.fill")
           ]),
        .init(name: "Settings", icon: "4.circle", subMenuItems: nil),
        .init(name: "Settings", icon: "5.circle", subMenuItems: nil),
        .init(name: "Settings", icon: "6.circle", subMenuItems: nil),
        .init(name: "Settings", icon: "7.circle", subMenuItems: nil),
        .init(name: "Settings", icon: "8.circle", subMenuItems: nil),
        .init(name: "Settings", icon: "9.circle", subMenuItems: nil),
        .init(name: "Settings", icon: "10.circle", subMenuItems: nil),
        .init(name: "Settings", icon: "11.circle", subMenuItems: nil),
        .init(name: "Settings", icon: "12.circle", subMenuItems: nil)
    ]
    
    // Generate additional items to test carousel with 50+ items
    var allItems = baseItems
    let itemTypes = ["Option", "Tool", "Feature", "Command", "Service", "Module", "Widget", "Component"]
    let itemImages = ["pizza1", "pizza2", "pizza3", "pizza4", "pizza5", "pizza6", "pizza7", "pizza8"]
    let sfSymbols = ["star.fill", "heart.fill", "gear", "person.fill", "house.fill", "phone.fill", "mail.fill", "camera.fill"]
    
//    for i in 14...60 {
//        let typeIndex = (i - 14) % itemTypes.count
//        let imageIndex = (i - 14) % itemImages.count
//        let symbolIndex = (i - 14) % sfSymbols.count
//        
//        // Alternate between items with images and SF symbols only
//        let useImage = i % 3 != 0 // Use images for 2/3 of items, SF symbols only for 1/3
//        
//        allItems.append(.init(
//            name: "\(itemTypes[typeIndex]) \(i)",
//            icon: sfSymbols[symbolIndex],
//            image: useImage ? itemImages[imageIndex] : nil,
//            subMenuItems: nil
//        ))
//    }
    
    return allItems
}()

@main
struct SSRadialMenuApp: App {
    var body: some Scene {
        WindowGroup {
            SSRadialMenu(
                menuItems: defaultMenuItems,
                alignment: .bottomTrailing,
                expandMenuIcon: "calendar.badge.plus",
                collapseMenuIcon: "calendar.badge.minus",
                mainCardSize: 45.0,
                spinsItemsDuringDrag: false
            )
        }
    }
}
