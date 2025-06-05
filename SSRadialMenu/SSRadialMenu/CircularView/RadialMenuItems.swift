//
//  RadialMenuItems.swift
//  SSRadialMenu
//
//  Created by Rishita Panchal on 04/06/25.
//


import SwiftUI

struct RadialMenuItems : Identifiable {
    var id : UUID = .init()
    var name : String
    var icon : String
    var price : String
    var action: (() -> Void)? = nil
    var subMenuItems: [RadialMenuItems]?
}
