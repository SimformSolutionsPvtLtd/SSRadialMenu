//
//  SSRadialMenuApp.swift
//  SSRadialMenu
//
//  Created by Bansi Mamtora on 23/01/23.
//

import SwiftUI

// Default menu items data with 60 items for testing
private let defaultMenuItems: [RadialMenuItems] = {
    // Create sub items for Action Item using a loop
    var monthOfThirtyFirst: [RadialMenuItems] = []
    for i in 1...31 {
        monthOfThirtyFirst.append(RadialMenuItems(name: "Sub Item \(i)", icon: "\(i).circle"))
    }

    var monthsOfThirty: [RadialMenuItems] = []
    for i in 1...30 {
        monthsOfThirty.append(RadialMenuItems(name: "Sub Item \(i)", icon: "\(i).circle"))
    }


    var baseItems: [RadialMenuItems] = [
        .init(name: "January", icon: "1.square", subMenuItems: monthOfThirtyFirst),
        .init(name: "February", icon: "2.square", subMenuItems: monthOfThirtyFirst),
        .init(name: "March", icon: "3.square", subMenuItems: monthOfThirtyFirst),
        .init(name: "April", icon: "4.square", subMenuItems: monthsOfThirty),
        .init(name: "May", icon: "5.square", subMenuItems: monthOfThirtyFirst),
        .init(name: "June", icon: "6.square", subMenuItems: monthsOfThirty),
        .init(name: "July", icon: "7.square", subMenuItems: monthOfThirtyFirst),
        .init(name: "August", icon: "8.square", subMenuItems: monthOfThirtyFirst),
        .init(name: "September", icon: "9.square", subMenuItems: monthsOfThirty),
        .init(name: "October", icon: "10.square", subMenuItems: monthOfThirtyFirst),
        .init(name: "November", icon: "11.square", subMenuItems: monthsOfThirty),
        .init(name: "Deecember", icon: "12.square", subMenuItems: monthOfThirtyFirst)
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
            // Example 1: Icon-based FAB buttons with mixed menu items
            SSRadialMenu(
                menuItems: defaultMenuItems,
                alignment: .bottomTrailing,
                expandMenuIcon: "calendar.badge.plus",
                collapseMenuIcon: "calendar.badge.minus",
                mainCardSize: 45.0,
                spinsItemsDuringDrag: false,
                wrapEnabled: true,
                zoomEffectEnabled: true,
                zoomEffectScale: nil
            )
            
//             Example 2: Image-based FAB buttons with mixed menu items (uncomment to test)

//            SSRadialMenu(
//                menuItems: defaultMenuItems,
//                alignment: .bottomTrailing,
//                expandMenuImage: "pizza1",
//                mainCardSize: 45.0,
//                spinsItemsDuringDrag: false,
//                wrapEnabled: true,
//                zoomEffectEnabled: true,
//                zoomEffectScale: nil
//            )
        }
    }
}
