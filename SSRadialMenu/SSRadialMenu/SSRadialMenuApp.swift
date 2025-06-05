//
//  SSRadialMenuApp.swift
//  SSRadialMenu
//
//  Created by Bansi Mamtora on 23/01/23.
//

import SwiftUI

// Default menu items data with 60 items for testing
private let defaultMenuItems: [RadialMenuItems] = {
    var basePizzas: [RadialMenuItems] = [
        .init(name: "Panner Pizza", icon: "pizza1", pizzaPrice: "200 $", subMenuItems: [
               RadialMenuItems(name: "Sub Panner Pizza 1", icon: "pizza1", pizzaPrice: "200 $", subMenuItems: [
                   RadialMenuItems(name: "Sub-Sub Panner 1A", icon: "pizza1", pizzaPrice: "205 $"),
                   RadialMenuItems(name: "Sub-Sub Panner 1B", icon: "pizza1", pizzaPrice: "215 $")
               ]),
               RadialMenuItems(name: "Sub Panner Pizza 2", icon: "pizza1", pizzaPrice: "210 $", subMenuItems: [
                   RadialMenuItems(name: "Sub-Sub Panner 2A", icon: "pizza1", pizzaPrice: "225 $"),
                   RadialMenuItems(name: "Sub-Sub Panner 2B", icon: "pizza1", pizzaPrice: "235 $"),
                   RadialMenuItems(name: "Sub-Sub Panner 2C", icon: "pizza1", pizzaPrice: "245 $")
               ]),
               RadialMenuItems(name: "Sub Panner Pizza 3", icon: "pizza1", pizzaPrice: "220 $"),
               RadialMenuItems(name: "Sub Panner Pizza 4", icon: "pizza1", pizzaPrice: "220 $"),
               RadialMenuItems(name: "Sub Panner Pizza 5", icon: "pizza1", pizzaPrice: "220 $"),
               RadialMenuItems(name: "Sub Panner Pizza 6", icon: "pizza1", pizzaPrice: "220 $"),
               RadialMenuItems(name: "Sub Panner Pizza 7", icon: "pizza1", pizzaPrice: "220 $"),
               RadialMenuItems(name: "Sub Panner Pizza 8", icon: "pizza1", pizzaPrice: "220 $"),
               RadialMenuItems(name: "Sub Panner Pizza 9", icon: "pizza1", pizzaPrice: "220 $"),
               RadialMenuItems(name: "Sub Panner Pizza 10", icon: "pizza1", pizzaPrice: "220 $"),
               RadialMenuItems(name: "Sub Panner Pizza 11", icon: "pizza1", pizzaPrice: "220 $"),
               RadialMenuItems(name: "Sub Panner Pizza 12", icon: "pizza1", pizzaPrice: "220 $"),
               RadialMenuItems(name: "Sub Panner Pizza 13", icon: "pizza1", pizzaPrice: "220 $"),
               RadialMenuItems(name: "Sub Panner Pizza 14", icon: "pizza1", pizzaPrice: "220 $"),
               RadialMenuItems(name: "Sub Panner Pizza 15", icon: "pizza1", pizzaPrice: "220 $"),
               RadialMenuItems(name: "Sub Panner Pizza 16", icon: "pizza1", pizzaPrice: "220 $"),
               RadialMenuItems(name: "Sub Panner Pizza 17", icon: "pizza1", pizzaPrice: "220 $"),
               RadialMenuItems(name: "Sub Panner Pizza 18", icon: "pizza1", pizzaPrice: "220 $"),
               RadialMenuItems(name: "Sub Panner Pizza 19", icon: "pizza1", pizzaPrice: "220 $"),
               RadialMenuItems(name: "Sub Panner Pizza 20", icon: "pizza1", pizzaPrice: "220 $"),
               RadialMenuItems(name: "Sub Panner Pizza 21", icon: "pizza1", pizzaPrice: "220 $"),
               RadialMenuItems(name: "Sub Panner Pizza 22", icon: "pizza1", pizzaPrice: "220 $"),
               RadialMenuItems(name: "Sub Panner Pizza 23", icon: "pizza1", pizzaPrice: "220 $"),
               RadialMenuItems(name: "Sub Panner Pizza 24", icon: "pizza1", pizzaPrice: "220 $"),
               RadialMenuItems(name: "Sub Panner Pizza 25", icon: "pizza1", pizzaPrice: "220 $"),
               RadialMenuItems(name: "Sub Panner Pizza 26", icon: "pizza1", pizzaPrice: "220 $"),
               RadialMenuItems(name: "Sub Panner Pizza 27", icon: "pizza1", pizzaPrice: "220 $"),
               RadialMenuItems(name: "Sub Panner Pizza 28", icon: "pizza1", pizzaPrice: "220 $"),
               RadialMenuItems(name: "Sub Panner Pizza 29", icon: "pizza1", pizzaPrice: "220 $"),
               RadialMenuItems(name: "Sub Panner Pizza 30", icon: "pizza1", pizzaPrice: "220 $"),
               RadialMenuItems(name: "Sub Panner Pizza 31", icon: "pizza1", pizzaPrice: "220 $"),
               RadialMenuItems(name: "Sub Panner Pizza 32", icon: "pizza1", pizzaPrice: "220 $"),
               RadialMenuItems(name: "Sub Panner Pizza 33", icon: "pizza1", pizzaPrice: "220 $"),
               RadialMenuItems(name: "Sub Panner Pizza 34", icon: "pizza1", pizzaPrice: "220 $"),
               RadialMenuItems(name: "Sub Panner Pizza 35", icon: "pizza1", pizzaPrice: "220 $")
           ]),
        .init(name: "Cheese Pizza", icon: "pizza2", pizzaPrice: "150 $", subMenuItems: nil),
        .init(name: "Italian Pizza", icon: "pizza3", pizzaPrice: "300 $", subMenuItems: [
               RadialMenuItems(name: "Sub Italian 1", icon: "pizza3", pizzaPrice: "310 $", subMenuItems: [
                   RadialMenuItems(name: "Sub-Sub Italian 1A", icon: "pizza3", pizzaPrice: "315 $"),
                   RadialMenuItems(name: "Sub-Sub Italian 1B", icon: "pizza3", pizzaPrice: "325 $")
               ]),
               RadialMenuItems(name: "Sub Italian 2", icon: "pizza3", pizzaPrice: "320 $")
           ]),
        .init(name: "Margherita Pizza", icon: "pizza4", pizzaPrice: "180 $", subMenuItems: nil),
        .init(name: "Pepperoni Pizza", icon: "pizza5", pizzaPrice: "220 $", subMenuItems: nil),
        .init(name: "Veggie Pizza", icon: "pizza6", pizzaPrice: "190 $", subMenuItems: nil),
        .init(name: "BBQ Pizza", icon: "pizza7", pizzaPrice: "250 $", subMenuItems: nil),
        .init(name: "Hawaiian Pizza", icon: "pizza8", pizzaPrice: "210 $", subMenuItems: nil),
        .init(name: "Meat Lovers", icon: "pizza1", pizzaPrice: "280 $", subMenuItems: nil),
        .init(name: "Four Cheese", icon: "pizza2", pizzaPrice: "200 $", subMenuItems: nil),
        .init(name: "Spicy Jalapeno", icon: "pizza3", pizzaPrice: "230 $", subMenuItems: nil),
        .init(name: "Mushroom Delight", icon: "pizza4", pizzaPrice: "170 $", subMenuItems: nil),
        .init(name: "Seafood Special", icon: "pizza5", pizzaPrice: "320 $", subMenuItems: nil)
    ]
    
    // Generate additional pizzas to test carousel with 50+ items
    var allPizzas = basePizzas
    let pizzaTypes = ["Supreme", "Mediterranean", "Buffalo Chicken", "White Sauce", "Pesto", "Ranch", "Taco", "Breakfast"]
    let pizzaImages = ["pizza1", "pizza2", "pizza3", "pizza4", "pizza5", "pizza6", "pizza7", "pizza8"]
    
    for i in 14...60 {
        let typeIndex = (i - 14) % pizzaTypes.count
        let imageIndex = (i - 14) % pizzaImages.count
        let price = 150 + (i * 10)
        
        allPizzas.append(.init(
            name: "\(pizzaTypes[typeIndex]) Pizza \(i)",
            icon: pizzaImages[imageIndex],
            pizzaPrice: "\(price) $",
            subMenuItems: nil
        ))
    }
    
    return allPizzas
}()

@main
struct SSRadialMenuApp: App {
    var body: some Scene {
        WindowGroup {
            SSRadialMenu(menuItems: defaultMenuItems, alignment: .topTrailing, fabIcon: "pizza2")
        }
    }
}
