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
        monthOfThirtyFirst.append(RadialMenuItems(name: "Day \(i)", icon: "\(i).circle"))
    }

    var monthsOfThirty: [RadialMenuItems] = []
    for i in 1...30 {
        monthsOfThirty.append(RadialMenuItems(name: "Day \(i)", icon: "\(i).circle"))
    }


    var baseItems: [RadialMenuItems] = [
        .init(name: "January", icon: "snowflake", badgeText: "1", subMenuItems: monthOfThirtyFirst),
        .init(name: "February", icon: "heart.fill", badgeText: "2", subMenuItems: monthOfThirtyFirst),
        .init(name: "March", icon: "leaf.fill", badgeText: "3", subMenuItems: monthOfThirtyFirst),
        .init(name: "April", icon: "cloud.rain.fill", badgeText: "4", subMenuItems: monthsOfThirty),
        .init(name: "May", icon: "sun.max.fill", badgeText: "5", subMenuItems: monthOfThirtyFirst),
        .init(name: "June", icon: "flame.fill", badgeText: "6", subMenuItems: monthsOfThirty),
        .init(name: "July", icon: "beach.umbrella.fill", badgeText: "7", subMenuItems: monthOfThirtyFirst),
        .init(name: "August", icon: "hurricane", badgeText: "8", subMenuItems: monthOfThirtyFirst),
        .init(name: "September", icon: "tree.fill" , badgeText: "9", subMenuItems: monthsOfThirty),
        .init(name: "October", icon: "moon.haze.fill", badgeText: "10", subMenuItems: monthOfThirtyFirst),
        .init(name: "November", icon: "wind", badgeText: "11", subMenuItems: monthsOfThirty),
        .init(name: "Deecember", icon: "gift.fill", badgeText: "12", subMenuItems: monthOfThirtyFirst)
    ]

    // Generate additional items to test carousel with 50+ items
    var allItems = baseItems
    let itemTypes = ["Option", "Tool", "Feature", "Command", "Service", "Module", "Widget", "Component"]
    let itemImages = ["pizza1", "pizza2", "pizza3", "pizza4", "pizza5", "pizza6", "pizza7", "pizza8"]
    let sfSymbols = ["star.fill", "heart.fill", "gear", "person.fill", "house.fill", "phone.fill", "mail.fill", "camera.fill"]

    // Add more items to test scrolling behavior (especially spin wheel effect)
//    for i in 5...25 {
//        let typeIndex = (i - 5) % itemTypes.count
//        let imageIndex = (i - 5) % itemImages.count
//        let symbolIndex = (i - 5) % sfSymbols.count
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

    //    var baseItems: [RadialMenuItems] = [
    //        .init(name: "Macron", image: "macron", subMenuItems: [
    //            RadialMenuItems(name: "macaron1", image: "macaron1"),
    //            RadialMenuItems(name: "macaron2", image: "macaron2"),
    //            RadialMenuItems(name: "macaron3", image: "macaron3"),
    //            RadialMenuItems(name: "macaron3", image: "macaron4")
    //        ]),
    //        .init(name: "waffle", image: "waffle", subMenuItems: [
    //            RadialMenuItems(name: "waffle1", image: "waffle1"),
    //            RadialMenuItems(name: "waffle2", image: "waffle2"),
    //            RadialMenuItems(name: "waffle3", image: "waffle3"),
    //            RadialMenuItems(name: "waffle4", image: "waffle4"),
    //            RadialMenuItems(name: "waffle5", image: "waffle5")
    //        ]),
    //        .init(name: "Donut", image: "donut"),
    //        .init(name: "Cake - Slice", image: "cakeSlice")
    //    ]

    return allItems
}()

@main
struct SSRadialMenuApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}

struct ContentView: View {
    var body: some View {
        DemoSelectionView()
    }
}
