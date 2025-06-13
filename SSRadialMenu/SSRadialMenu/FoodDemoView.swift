//
//  FoodDemoView.swift
//  SSRadialMenu
//
//  Created by Rishita Panchal on 11/06/25.
//

import SwiftUI

struct FoodDemoView: View {
    let onBack: () -> Void

    // State variables to track selected items from each menu level
    @State private var selectedMainItem: RadialMenuItems? = nil
    @State private var selectedSubItem: RadialMenuItems? = nil
    @State private var selectedSubSubItem: RadialMenuItems? = nil

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea(.all)

            VStack {
                // Header with back button
                // Calendar radial menu
                SSRadialMenu(
                    menuItems: foodMenuItems,
                    alignment: AlignmentType.topLeading,
                    expandMenuImage: "dineIn",
                    mainCardSize: 40.0,
                    spinsItemsDuringDrag: false,
                    wrapEnabled: true,
                    zoomEffectEnabled: true,
                    zoomEffectScale: 1.05,
                    scrollThresholdItemCount: 4,
                    scrollingBehavior: ScrollingBehavior.spinWheel,
                    spinWheelSpeed: .fast,
                    onMainMenuSelection: { item in
                        selectedMainItem = item
                        selectedSubItem = nil // Reset sub selection when main changes
                        print("Main menu selected: \(item.name)")
                    },
                    onSubMenuSelection: { item in
                        selectedSubItem = item
                        print("Sub menu selected: \(item.name)")
                    },
                    onSubSubMenuSelection: { item in
                        selectedSubSubItem = item
                        print("Sub-sub menu selected: \(item.name)")
                    }
                )

                Spacer()

                HStack {
                    Button(action: onBack) {
                        HStack(spacing: 8) {
                            Image(systemName: "arrow.left.circle.fill")
                                .font(.system(size: 24))
                                .foregroundColor(.white)
                            
                            Text("Back to Selection")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(.white)
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 10)
                        .background(
                            Capsule()
                                .fill(Color.white.opacity(0.1))
                                .overlay(
                                    Capsule()
                                        .stroke(Color.white.opacity(0.3), lineWidth: 1)
                                )
                        )
                    }
                    .buttonStyle(PlainButtonStyle())

                    Spacer()
                }
                .padding(.top, 50)
                .padding(.horizontal, 20)

                // Title and Description
                VStack(spacing: 16) {
                    Text("Food Menu Demo")
                        .font(.system(size: 32, weight: .bold, design: .rounded))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [Color.orange, Color.red],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                    
                    Text("Explore delicious food categories and items")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.white.opacity(0.7))
                        .multilineTextAlignment(.center)
                }
                .padding(.top, 20)
                
                // Current selections display
                VStack(alignment: .leading, spacing: 8) {
                    Text("Current Selection:")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding(.top, 30)
                    
                    Group {
                        HStack {
                            Image(systemName: "fork.knife")
                                .foregroundColor(.orange)
                            Text("Category: \(selectedMainItem?.name ?? "None")")
                        }
                        
                        HStack {
                            Image(systemName: "heart.fill")
                                .foregroundColor(.red)
                            Text("Item: \(selectedSubItem?.name ?? "None")")
                        }
                        
                        if selectedSubSubItem != nil {
                            HStack {
                                Image(systemName: "star.fill")
                                    .foregroundColor(.yellow)
                                Text("Variant: \(selectedSubSubItem?.name ?? "None")")
                            }
                        }
                    }
                    .font(.body)
                    .foregroundColor(.gray)
                    .padding(.horizontal)
                }
                .frame(maxWidth: .infinity, alignment: .leading)

            }
        }
    }
}

// Calendar menu items data
private let foodMenuItems: [RadialMenuItems] = {

    let burgerAddOns: [RadialMenuItems] = [
        .init(name: "Bell-Pepper", image: "bellPepper", badgeText: "20"),
        .init(name: "Onion", image: "onion", badgeText: "15"),
        .init(name: "Cheese", image: "cheeseSlice", badgeText: "48"),
        .init(name: "Cabbage", image: "cabbage", badgeText: "18"),
        .init(name: "Cucumber", image: "cucumber", badgeText: "20"),
        .init(name: "Lettuce", image: "lettuce", badgeText: "15"),
        .init(name: "Purple Cabbage", image: "purpleCabbage", badgeText: "18"),
        .init(name: "Tomato Slice", image: "tomatoSlice", badgeText: "18")
    ]

    let waffleAddOns: [RadialMenuItems] = [
        .init(name: "Chocolate", image: "chocolate", badgeText: "20"),
        .init(name: "Strawberry", image: "strawberry", badgeText: "15"),
        .init(name: "Choco-sauce", image: "chocoSauce", badgeText: "48")
    ]

    let mocktailAddOns: [RadialMenuItems] = [
        .init(name: "Lemon", image: "lemon", badgeText: "20"),
        .init(name: "Mint", image: "mint", badgeText: "15"),
        .init(name: "Ice-cube", image: "iceCube", badgeText: "48")
    ]

    return [
        .init(name: "Burger", image: "burger", subMenuItems: burgerAddOns),
        .init(name: "Waffle", image: "waffle", subMenuItems: waffleAddOns),
        .init(name: "Drink", image: "mocktail", subMenuItems: mocktailAddOns),
        .init(name: "Tortilla-wrap", image: "tortilla", subMenuItems: burgerAddOns),
        .init(name: "Sandwich", image: "sandwich", subMenuItems: burgerAddOns),
        .init(name: "Dosa", image: "masalaDosa", subMenuItems: burgerAddOns),
    ]
}()

#Preview {
    CalendarDemoView(onBack: {})
}

