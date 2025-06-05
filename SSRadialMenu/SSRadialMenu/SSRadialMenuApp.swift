//
//  SSRadialMenuApp.swift
//  SSRadialMenu
//
//  Created by Bansi Mamtora on 23/01/23.
//

import SwiftUI

// Default menu items data
private let defaultMenuItems: [RadialMenuItems] = [
    .init(name: "Panner Pizza", icon: "pizza1", pizzaPrice: "200 $", subMenuItems: [
           RadialMenuItems(name: "Sub Panner Pizza 1", icon: "pizza1", pizzaPrice: "200 $", subMenuItems: [
               RadialMenuItems(name: "Sub-Sub Panner 1A", icon: "pizza1", pizzaPrice: "205 $"),
               RadialMenuItems(name: "Sub-Sub Panner 1B", icon: "pizza1", pizzaPrice: "215 $")
           ]),
           RadialMenuItems(name: "Sub Panner Pizza 2", icon: "pizza1", pizzaPrice: "250 $", subMenuItems: [
               RadialMenuItems(name: "Sub-Sub Panner 2A", icon: "pizza1", pizzaPrice: "255 $"),
               RadialMenuItems(name: "Sub-Sub Panner 2B", icon: "pizza1", pizzaPrice: "265 $")
           ]),
           RadialMenuItems(name: "Sub Panner Pizza 3", icon: "pizza1", pizzaPrice: "180 $"),
           RadialMenuItems(name: "Sub Panner Pizza 3", icon: "pizza1", pizzaPrice: "180 $"),
           RadialMenuItems(name: "Sub Panner Pizza 3", icon: "pizza1", pizzaPrice: "180 $"),
           RadialMenuItems(name: "Sub Panner Pizza 3", icon: "pizza1", pizzaPrice: "180 $"),
           RadialMenuItems(name: "Sub Panner Pizza 3", icon: "pizza1", pizzaPrice: "180 $"),
           RadialMenuItems(name: "Sub Panner Pizza 3", icon: "pizza1", pizzaPrice: "180 $"),
           RadialMenuItems(name: "Sub Panner Pizza 3", icon: "pizza1", pizzaPrice: "180 $"),
           RadialMenuItems(name: "Sub Panner Pizza 3", icon: "pizza1", pizzaPrice: "180 $"),
           RadialMenuItems(name: "Sub Panner Pizza 3", icon: "pizza1", pizzaPrice: "180 $"),
           RadialMenuItems(name: "Sub Panner Pizza 3", icon: "pizza1", pizzaPrice: "180 $"),
           RadialMenuItems(name: "Sub Panner Pizza 3", icon: "pizza1", pizzaPrice: "180 $"),
           RadialMenuItems(name: "Sub Panner Pizza 3", icon: "pizza1", pizzaPrice: "180 $"),
           RadialMenuItems(name: "Sub Panner Pizza 3", icon: "pizza1", pizzaPrice: "180 $"),
           RadialMenuItems(name: "Sub Panner Pizza 3", icon: "pizza1", pizzaPrice: "180 $"),
           RadialMenuItems(name: "Sub Panner Pizza 3", icon: "pizza1", pizzaPrice: "180 $"),
           RadialMenuItems(name: "Sub Panner Pizza 3", icon: "pizza1", pizzaPrice: "180 $"),
           RadialMenuItems(name: "Sub Panner Pizza 3", icon: "pizza1", pizzaPrice: "180 $"),
           RadialMenuItems(name: "Sub Panner Pizza 3", icon: "pizza1", pizzaPrice: "180 $"),
           RadialMenuItems(name: "Sub Panner Pizza 3", icon: "pizza1", pizzaPrice: "180 $"),
           RadialMenuItems(name: "Sub Panner Pizza 3", icon: "pizza1", pizzaPrice: "180 $"),
           RadialMenuItems(name: "Sub Panner Pizza 3", icon: "pizza1", pizzaPrice: "180 $"),
           RadialMenuItems(name: "Sub Panner Pizza 3", icon: "pizza1", pizzaPrice: "180 $"),
           RadialMenuItems(name: "Sub Panner Pizza 3", icon: "pizza1", pizzaPrice: "180 $"),
           RadialMenuItems(name: "Sub Panner Pizza 3", icon: "pizza1", pizzaPrice: "180 $"),
           RadialMenuItems(name: "Sub Panner Pizza 3", icon: "pizza1", pizzaPrice: "180 $"),
           RadialMenuItems(name: "Sub Panner Pizza 3", icon: "pizza1", pizzaPrice: "180 $"),
           RadialMenuItems(name: "Sub Panner Pizza 3", icon: "pizza1", pizzaPrice: "180 $"),
           RadialMenuItems(name: "Sub Panner Pizza 3", icon: "pizza1", pizzaPrice: "180 $")
    ]),
    .init(name: "Mushroom Pizza", icon: "pizza2", pizzaPrice: "180 $", subMenuItems: [
           RadialMenuItems(name: "Sub Mushroom Pizza 1", icon: "pizza2", pizzaPrice: "180 $"),
           RadialMenuItems(name: "Sub Mushroom Pizza 2", icon: "pizza2", pizzaPrice: "190 $"),
           RadialMenuItems(name: "Sub Mushroom Pizza 3", icon: "pizza2", pizzaPrice: "200 $", subMenuItems: [
               RadialMenuItems(name: "Sub-Sub Mushroom 3A", icon: "pizza2", pizzaPrice: "205 $"),
               RadialMenuItems(name: "Sub-Sub Mushroom 3B", icon: "pizza2", pizzaPrice: "210 $")
           ])
    ]),
    .init(name: "Onion Pizza", icon: "pizza3", pizzaPrice: "150 $", subMenuItems: [
           RadialMenuItems(name: "Sub Onion Pizza 1", icon: "pizza3", pizzaPrice: "150 $"),
           RadialMenuItems(name: "Sub Onion Pizza 2", icon: "pizza3", pizzaPrice: "160 $")
    ]),
    .init(name: "Cheese Pizza", icon: "pizza4", pizzaPrice: "220 $", subMenuItems: [
           RadialMenuItems(name: "Sub Cheese Pizza 1", icon: "pizza4", pizzaPrice: "220 $", subMenuItems: [
               RadialMenuItems(name: "Sub-Sub Cheese 1A", icon: "pizza4", pizzaPrice: "225 $"),
               RadialMenuItems(name: "Sub-Sub Cheese 1B", icon: "pizza4", pizzaPrice: "230 $"),
               RadialMenuItems(name: "Sub-Sub Cheese 1C", icon: "pizza4", pizzaPrice: "235 $")
           ]),
           RadialMenuItems(name: "Sub Cheese Pizza 2", icon: "pizza4", pizzaPrice: "240 $"),
           RadialMenuItems(name: "Sub Cheese Pizza 3", icon: "pizza4", pizzaPrice: "250 $")
    ]),
    .init(name: "Pepperoni Pizza", icon: "pizza5", pizzaPrice: "280 $", subMenuItems: [
           RadialMenuItems(name: "Sub Pepperoni Pizza 1", icon: "pizza5", pizzaPrice: "280 $"),
           RadialMenuItems(name: "Sub Pepperoni Pizza 2", icon: "pizza5", pizzaPrice: "300 $", subMenuItems: [
               RadialMenuItems(name: "Sub-Sub Pepperoni 2A", icon: "pizza5", pizzaPrice: "305 $"),
               RadialMenuItems(name: "Sub-Sub Pepperoni 2B", icon: "pizza5", pizzaPrice: "310 $")
           ]),
           RadialMenuItems(name: "Sub Pepperoni Pizza 3", icon: "pizza5", pizzaPrice: "320 $")
    ]),
    .init(name: "Chicken Pizza", icon: "pizza6", pizzaPrice: "300 $", subMenuItems: [
           RadialMenuItems(name: "Sub Chicken Pizza 1", icon: "pizza6", pizzaPrice: "300 $"),
           RadialMenuItems(name: "Sub Chicken Pizza 2", icon: "pizza6", pizzaPrice: "320 $", subMenuItems: [
               RadialMenuItems(name: "Sub-Sub Chicken 2A", icon: "pizza6", pizzaPrice: "325 $"),
               RadialMenuItems(name: "Sub-Sub Chicken 2B", icon: "pizza6", pizzaPrice: "330 $"),
               RadialMenuItems(name: "Sub-Sub Chicken 2C", icon: "pizza6", pizzaPrice: "335 $"),
               RadialMenuItems(name: "Sub-Sub Chicken 2D", icon: "pizza6", pizzaPrice: "340 $")
           ]),
           RadialMenuItems(name: "Sub Chicken Pizza 3", icon: "pizza6", pizzaPrice: "350 $")
    ]),
    .init(name: "Veggie Pizza", icon: "pizza7", pizzaPrice: "250 $", subMenuItems: [
           RadialMenuItems(name: "Sub Veggie Pizza 1", icon: "pizza7", pizzaPrice: "250 $", subMenuItems: [
               RadialMenuItems(name: "Sub-Sub Veggie 1A", icon: "pizza7", pizzaPrice: "255 $"),
               RadialMenuItems(name: "Sub-Sub Veggie 1B", icon: "pizza7", pizzaPrice: "260 $")
           ]),
           RadialMenuItems(name: "Sub Veggie Pizza 2", icon: "pizza7", pizzaPrice: "270 $"),
           RadialMenuItems(name: "Sub Veggie Pizza 3", icon: "pizza7", pizzaPrice: "280 $"),
           RadialMenuItems(name: "Sub Veggie Pizza 4", icon: "pizza7", pizzaPrice: "290 $")
    ]),
    .init(name: "Hawaiian Pizza", icon: "pizza8", pizzaPrice: "320 $", subMenuItems: [
           RadialMenuItems(name: "Sub Hawaiian Pizza 1", icon: "pizza8", pizzaPrice: "320 $"),
           RadialMenuItems(name: "Sub Hawaiian Pizza 2", icon: "pizza8", pizzaPrice: "340 $", subMenuItems: [
               RadialMenuItems(name: "Sub-Sub Hawaiian 2A", icon: "pizza8", pizzaPrice: "345 $"),
               RadialMenuItems(name: "Sub-Sub Hawaiian 2B", icon: "pizza8", pizzaPrice: "350 $"),
               RadialMenuItems(name: "Sub-Sub Hawaiian 2C", icon: "pizza8", pizzaPrice: "355 $")
           ]),
           RadialMenuItems(name: "Sub Hawaiian Pizza 3", icon: "pizza8", pizzaPrice: "360 $")
    ])
]

@main
struct SSRadialMenuApp: App {
    var body: some Scene {
        WindowGroup {
            SSRadialMenu(menuItems: defaultMenuItems, alignment: .topTrailing)
        }
    }
}
