//
//  CircularView.swift
//  SSRadialMenu
//
//  Created by Rishita Panchal on 02/12/24.
import SwiftUI

struct ContentView: View {
    var body: some View {
        FinalView(alignment: .bottomTrailing)
    }
}

#Preview {
    ContentView()
}

struct FinalView: View {
    var alignment: AlignmentType = .bottomTrailing
    @State private var angle: Double = 0.0
    @State private var startAngle: Double = 0.0
    @State private var nameofPizza: String = "Cheese Pizza"
    @State private var priceofPizza: String = "150 $"
    @State private var animatedIndices: Set<Int> = []
    @State private var showingSubMenuForIndex: Int? = nil // Tracks which item's submenu is showing
    @State private var subMenuAnimatedIndices: Set<Int> = [] // Tracks animated submenu items
    let radius: CGFloat = 100
    let subMenuRadius: CGFloat = 165 // Larger radius for submenus
    var step: Double { 
        let totalDisplayItems = hasPlaceholder ? actualVisibleItemsCount + 1 : actualVisibleItemsCount
        return totalDisplayItems <= 4 ? (90.0 / Double(totalDisplayItems) + 20) : (360.0 / Double(totalDisplayItems))
    }
    let maxVisibleItems: Int = 8 // Maximum items to display at once
    
    @State private var showPizzaCards: Bool = false // State to toggle visibility of PizzaCards
    @State private var currentOffset: Int = 0 // Tracks the starting index for visible items
    
    // Computed properties for managing visible items and placeholder
    var visibleItemsCount: Int {
        min(maxVisibleItems, pizzas.count)
    }
    
    var hasPlaceholder: Bool {
        pizzas.count > maxVisibleItems
    }
    
    var actualVisibleItemsCount: Int {
        hasPlaceholder ? maxVisibleItems - 1 : visibleItemsCount
    }
    
    var visibleItems: [Pizza] {
        guard pizzas.count > 0 else { return [] }
        var items: [Pizza] = []
        
        for i in 0..<actualVisibleItemsCount {
            let index = (currentOffset + i) % pizzas.count
            items.append(pizzas[index])
        }
        
        return items
    }
    
    var hiddenItemsCount: Int {
        max(0, pizzas.count - actualVisibleItemsCount)
    }

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea(.all)
            
            // Debug info at the top
            VStack {
                if showPizzaCards {
                    HStack {
                        Text("Visible: \(currentOffset + 1) - \(currentOffset + actualVisibleItemsCount)")
                            .foregroundColor(.white)
                            .font(.caption)
                        if hasPlaceholder {
                            Text("| Hidden: \((currentOffset + actualVisibleItemsCount + 1)) - \(pizzas.count)")
                                .foregroundColor(.gray)
                                .font(.caption)
                        }
                    }
                    .padding(.top, 50)
                }
                Spacer()
            }
            
            GeometryReader { geometry in
                let size = geometry.size

                ZStack {
                    // Main menu items
                    if showPizzaCards {
                        // Render visible items
                        ForEach(visibleItems.indices, id: \.self) { index in
                            let totalDisplayItems = hasPlaceholder ? actualVisibleItemsCount + 1 : actualVisibleItemsCount
                            let anglePerPizza = totalDisplayItems <= 4 ? 90.0 / Double(totalDisplayItems) + 20 : 360.0 / Double(totalDisplayItems)
                            let pizzaAngle = alignment.itemAngle(index: index, angle: angle, anglePerPizza: anglePerPizza)
                            let actualIndex = (currentOffset + index) % pizzas.count

                            PizzaCard(pizza: visibleItems[index], itemNumber: actualIndex + 1)
                                .rotationEffect(.degrees(-pizzaAngle))
                                .offset(
                                    x: animatedIndices.contains(index) ? radius * cos(pizzaAngle * .pi / 180) : 0,
                                    y: animatedIndices.contains(index) ? radius * sin(pizzaAngle * .pi / 180) : 0
                                )
                                .scaleEffect(animatedIndices.contains(index) ? 1 : 0.1) // Scale up with animation
                                .animation(.spring(response: 0.5, dampingFraction: 0.6), value: animatedIndices)
                                .onTapGesture {
                                    handlePizzaCardTap(index: actualIndex)
                                }
                                .onChange(of: pizzaAngle, perform: { _ in
                                    if isCardNearTriangle(pizzaAngle) {
                                        nameofPizza = visibleItems[index].pizza
                                        priceofPizza = visibleItems[index].pizzaPrice
                                    }
                                })
                        }
                        
                        // Render placeholder if needed
                        if hasPlaceholder {
                            let totalDisplayItems = actualVisibleItemsCount + 1
                            let anglePerPizza = totalDisplayItems <= 4 ? 90.0 / Double(totalDisplayItems) + 20 : 360.0 / Double(totalDisplayItems)
                            let placeholderIndex = actualVisibleItemsCount
                            let placeholderAngle = alignment.itemAngle(index: placeholderIndex, angle: angle, anglePerPizza: anglePerPizza)
                            
                            PlaceholderCard(count: hiddenItemsCount)
                                .rotationEffect(.degrees(-placeholderAngle))
                                .offset(
                                    x: animatedIndices.contains(placeholderIndex) ? radius * cos(placeholderAngle * .pi / 180) : 0,
                                    y: animatedIndices.contains(placeholderIndex) ? radius * sin(placeholderAngle * .pi / 180) : 0
                                )
                                .scaleEffect(animatedIndices.contains(placeholderIndex) ? 1 : 0.1)
                                .animation(.spring(response: 0.5, dampingFraction: 0.6), value: animatedIndices)
                                .onTapGesture {
                                    // Handle placeholder tap - could show a list or cycle through items
                                    rotateToNextItem()
                                }
                        }
                    }

                    // Submenu items (second layer)
                    if let selectedIndex = showingSubMenuForIndex,
                       let subMenuItems = pizzas[selectedIndex].subMenuItems {
                        ForEach(subMenuItems.indices, id: \.self) { subIndex in
                            // Find the visual index of the selected item in the current visible items
                            let visualIndex = getVisualIndex(for: selectedIndex)
                            let totalDisplayItems = hasPlaceholder ? actualVisibleItemsCount + 1 : actualVisibleItemsCount
                            let anglePerPizza = totalDisplayItems <= 4 ? 90.0 / Double(totalDisplayItems) + 20 : 360.0 / Double(totalDisplayItems)
                            let mainAngle = alignment.itemAngle(
                                index: visualIndex,
                                angle: angle,
                                anglePerPizza: anglePerPizza
                            )

                            // Calculate submenu positioning
                            let subItemCount = Double(subMenuItems.count)
                            let subMenuAngleSpan: Double = 120.0 // Coverage angle for submenu items
                            let subMenuAnglePerItem = subMenuAngleSpan / subItemCount
                            let subMenuStartAngle = mainAngle - (subMenuAngleSpan / 2) + (subMenuAnglePerItem / 2)
                            let subPizzaAngle = subMenuStartAngle + (Double(subIndex) * subMenuAnglePerItem)

                            PizzaCard(pizza: subMenuItems[subIndex])
                                .rotationEffect(.degrees(-subPizzaAngle))
                                .offset(
                                    x: subMenuAnimatedIndices.contains(subIndex) ? subMenuRadius * cos(subPizzaAngle * .pi / 180) : radius * cos(mainAngle * .pi / 180),
                                    y: subMenuAnimatedIndices.contains(subIndex) ? subMenuRadius * sin(subPizzaAngle * .pi / 180) : radius * sin(mainAngle * .pi / 180)
                                )
                                .scaleEffect(subMenuAnimatedIndices.contains(subIndex) ? 1 : 0.1)
                                .animation(.spring(response: 0.5, dampingFraction: 0.6), value: subMenuAnimatedIndices)
                                .onTapGesture {
                                    // Handle submenu item tap
                                    nameofPizza = subMenuItems[subIndex].pizza
                                    priceofPizza = subMenuItems[subIndex].pizzaPrice
                                }
                        }
                    }

                    // Main FAB button
                    Button(action: {
                        // Close any open submenu when toggling main menu
                        if showingSubMenuForIndex != nil {
                            closeSubMenu()
                        }

                        showPizzaCards.toggle()
                        if showPizzaCards {
                            startSequentialAnimation()
                        } else {
                            animatedIndices.removeAll()
                        }
                    }, label: {
                        Image(systemName: "star.fill")
                            .resizable()
                            .frame(width: 50, height: 50)
                            .foregroundColor(.yellow)
                            .clipShape(Circle())
                    })
                    .frame(width: 80, height: 80)
                    .clipShape(Circle())
                }
                .frame(width: size.width, height: size.height, alignment: alignment.toAlignment)
                .padding(.top, -20)
                .gesture(
                    DragGesture()
                        .onChanged { value in
                            let translation = value.translation
                            let delta = -Double((translation.width + translation.height) / 2) / radius * (180 / .pi)
                            angle = startAngle + delta
                        }
                        .onEnded { _ in
                            let normalizedAngle = angle.truncatingRemainder(dividingBy: 360.0)
                            let snapAngle = (normalizedAngle / step).rounded() * step
                            
                            withAnimation(.easeOut(duration: 0.3)) {
                                angle = snapAngle
                                startAngle = snapAngle
                            }
                            
                            // Handle rotation to next/previous items for placeholder system
                            if pizzas.count > maxVisibleItems {
                                let rotationSteps = Int(snapAngle / step)
                                let netRotation = rotationSteps % Int(360 / step)
                                
                                if abs(netRotation) > 0 {
                                    let itemsToRotate = abs(netRotation)
                                    for _ in 0..<itemsToRotate {
                                        if netRotation > 0 {
                                            rotateToNextItem()
                                        } else {
                                            rotateToPreviousItem()
                                        }
                                    }
                                    // Reset angle after updating offset
                                    angle = 0
                                    startAngle = 0
                                }
                            }
                            updatePizzaDetails()
                        }
                )
            }
        }
    }

    // Function to handle pizza card tap
    func handlePizzaCardTap(index: Int) {
        // If there's already an open submenu
        if let currentOpenSubmenu = showingSubMenuForIndex {
            // If the same item is tapped again, close the submenu
            if currentOpenSubmenu == index {
                closeSubMenu()
                return
            }
            // If a different item is tapped, close the current submenu
            closeSubMenu()
        }

        // Only open a submenu if the item has submenu items
        if let subItems = pizzas[index].subMenuItems, !subItems.isEmpty {
            showingSubMenuForIndex = index
            startSubMenuSequentialAnimation(itemCount: subItems.count)
        } else {
            // For items without submenus, just update the selected pizza details
            nameofPizza = pizzas[index].pizza
            priceofPizza = pizzas[index].pizzaPrice
        }
    }

    func closeSubMenu() {
        showingSubMenuForIndex = nil
        subMenuAnimatedIndices.removeAll()
    }

    func startSequentialAnimation() {
        animatedIndices.removeAll() // Reset animation state
        let totalItemsToAnimate = hasPlaceholder ? actualVisibleItemsCount + 1 : actualVisibleItemsCount
        for index in 0..<totalItemsToAnimate {
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(index) * 0.1) {
                withAnimation(.easeIn) {
                    _ = animatedIndices.insert(index) // Animate each item one by one
                }
            }
        }
    }
    
    func rotateToNextItem() {
        if pizzas.count > maxVisibleItems {
            currentOffset = (currentOffset + 1) % pizzas.count
            restartAnimation()
        }
    }
    
    func rotateToPreviousItem() {
        if pizzas.count > maxVisibleItems {
            currentOffset = (currentOffset - 1 + pizzas.count) % pizzas.count
            restartAnimation()
        }
    }
    
    func restartAnimation() {
        animatedIndices.removeAll()
        startSequentialAnimation()
    }
    
    func getVisualIndex(for actualIndex: Int) -> Int {
        // Find the visual position of an actual pizza index in the current visible items
        for (visualIndex, item) in visibleItems.enumerated() {
            let itemActualIndex = (currentOffset + visualIndex) % pizzas.count
            if itemActualIndex == actualIndex {
                return visualIndex
            }
        }
        return 0 // Fallback
    }

    func startSubMenuSequentialAnimation(itemCount: Int) {
        subMenuAnimatedIndices.removeAll() // Reset animation state
        for index in 0..<itemCount {
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(index) * 0.1) {
                withAnimation(.easeIn) {
                    _ = subMenuAnimatedIndices.insert(index) // Animate each submenu item one by one
                }
            }
        }
    }

    @ViewBuilder
    func PizzaCard(pizza: Pizza, itemNumber: Int? = nil) -> some View {
        ZStack {
            Image(pizza.pizzaImage)
                .resizable()
                .frame(width: 80, height: 80)
                .clipShape(Circle())
            
            // Add digit overlay to show item number
            let displayNumber = itemNumber ?? (pizzas.firstIndex(where: { $0.id == pizza.id }) ?? 0) + 1
            Text("\(displayNumber)")
                .font(.bold(.system(size: 20))())
                .foregroundColor(.white)
                .background(
                    Circle()
                        .fill(Color.black.opacity(0.7))
                        .frame(width: 30, height: 30)
                )
                .offset(x: 25, y: -25) // Position in top-right corner
        }
    }
    
    @ViewBuilder
    func PlaceholderCard(count: Int) -> some View {
        ZStack {
            // Stack effect with multiple circles
            Circle()
                .fill(Color.gray.opacity(0.3))
                .frame(width: 80, height: 80)
                .offset(x: 2, y: 2)
            
            Circle()
                .fill(Color.gray.opacity(0.5))
                .frame(width: 80, height: 80)
                .offset(x: 1, y: 1)
            
            Circle()
                .fill(Color.gray.opacity(0.7))
                .frame(width: 80, height: 80)
            
            // Count indicator showing range of hidden items
            VStack(spacing: 2) {
                Text("+\(count)")
                    .font(.bold(.system(size: 14))())
                    .foregroundColor(.white)
                
                // Show range of hidden items
                let startIndex = actualVisibleItemsCount + currentOffset + 1
                let endIndex = startIndex + count - 1
                Text("\(startIndex)-\(endIndex)")
                    .font(.system(size: 10))
                    .foregroundColor(.white.opacity(0.8))
            }
        }
    }

    func updatePizzaDetails() {
        let totalDisplayItems = hasPlaceholder ? actualVisibleItemsCount + 1 : actualVisibleItemsCount
        let anglePerPizza = totalDisplayItems <= 4 ? 90.0 / Double(totalDisplayItems) + 20 : 360.0 / Double(totalDisplayItems)
        
        // Find which item is currently at the "top" position (near the triangle)
        let normalizedAngle = (angle + 360.0).truncatingRemainder(dividingBy: 360.0)
        let itemIndex = Int((normalizedAngle / anglePerPizza).rounded()) % totalDisplayItems
        
        if itemIndex < visibleItems.count {
            nameofPizza = visibleItems[itemIndex].pizza
            priceofPizza = visibleItems[itemIndex].pizzaPrice
        }
    }

    func isCardNearTriangle(_ pizzaAngle: Double) -> Bool {
        let triangleAngle = 270.0
        let threshold: Double = 30.0
        let normalizedPizzaAngle = (pizzaAngle + 360.0).truncatingRemainder(dividingBy: 360.0)
        let normalizedTriangleAngle = (triangleAngle + 360.0).truncatingRemainder(dividingBy: 360.0)
        let angleDifference = abs(normalizedPizzaAngle - normalizedTriangleAngle)
        return angleDifference <= threshold || angleDifference >= (360.0 - threshold)
    }
}

struct Triangle: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()

        let point1 = CGPoint(x: rect.midX, y: rect.minY)
        let point2 = CGPoint(x: rect.minX, y: rect.maxY)
        let point3 = CGPoint(x: rect.maxX, y: rect.maxY)

        path.move(to: point1)
        path.addLine(to: point2)
        path.addLine(to: point3)
        path.closeSubpath()

        return path
    }
}

struct Pizza : Identifiable {
    var id : UUID = .init()
    var pizza : String
    var pizzaImage : String
    var pizzaPrice : String
    var subMenuItems: [Pizza]?
}

var pizzas : [Pizza] = [
    .init(pizza: "Panner Pizza", pizzaImage: "pizza1", pizzaPrice: "200 $", subMenuItems: [
           Pizza(pizza: "Sub Panner Pizza 1", pizzaImage: "pizza1", pizzaPrice: "200 $"),
           Pizza(pizza: "Sub Panner Pizza 2", pizzaImage: "pizza1", pizzaPrice: "210 $"),
           Pizza(pizza: "Sub Panner Pizza 3", pizzaImage: "pizza1", pizzaPrice: "220 $")
       ]),
    .init(pizza: "Cheese Pizza", pizzaImage: "pizza2",pizzaPrice: "150 $", subMenuItems: nil),
    .init(pizza: "Italian Pizza", pizzaImage: "pizza3",pizzaPrice: "300 $", subMenuItems: [
           Pizza(pizza: "Sub Italian 1", pizzaImage: "pizza3", pizzaPrice: "310 $"),
           Pizza(pizza: "Sub Italian 2", pizzaImage: "pizza3", pizzaPrice: "320 $")
       ]),
    .init(pizza: "Margherita Pizza", pizzaImage: "pizza4",pizzaPrice: "180 $", subMenuItems: nil),
    .init(pizza: "Pepperoni Pizza", pizzaImage: "pizza5",pizzaPrice: "220 $", subMenuItems: nil),
    .init(pizza: "Veggie Pizza", pizzaImage: "pizza6",pizzaPrice: "190 $", subMenuItems: nil),
    .init(pizza: "BBQ Pizza", pizzaImage: "pizza7",pizzaPrice: "250 $", subMenuItems: nil),
    .init(pizza: "Hawaiian Pizza", pizzaImage: "pizza8",pizzaPrice: "210 $", subMenuItems: nil),
    .init(pizza: "Meat Lovers", pizzaImage: "pizza1",pizzaPrice: "280 $", subMenuItems: nil),
    .init(pizza: "Four Cheese", pizzaImage: "pizza2",pizzaPrice: "200 $", subMenuItems: nil),
    .init(pizza: "Spicy Jalapeno", pizzaImage: "pizza3",pizzaPrice: "230 $", subMenuItems: nil),
    .init(pizza: "Mushroom Delight", pizzaImage: "pizza4",pizzaPrice: "170 $", subMenuItems: nil),
    .init(pizza: "Seafood Special", pizzaImage: "pizza5",pizzaPrice: "320 $", subMenuItems: nil)
]

enum AlignmentType {
    case topLeading, topTrailing, bottomLeading, bottomTrailing

    var toAlignment: Alignment {
        switch self {
        case .topLeading:
                .topLeading
        case .topTrailing:
                .topTrailing
        case .bottomLeading:
                .bottomLeading
        case .bottomTrailing:
                .bottomTrailing
        }
    }
    func itemAngle(index: Int, angle: Double, anglePerPizza: Double) -> Double {
        switch self {
        case .topLeading:
            -(anglePerPizza * Double(index) + 100 + angle - 190.0).truncatingRemainder(dividingBy: 360.0)
        case .topTrailing:
            (anglePerPizza * Double(index) + 280 + angle - 190.0).truncatingRemainder(dividingBy: 360.0)
        case .bottomLeading:
            (anglePerPizza * Double(index) + 100 + angle - 190.0).truncatingRemainder(dividingBy: 360.0)
        case .bottomTrailing:
            -(anglePerPizza * Double(index) + 280 + angle - 190.0).truncatingRemainder(dividingBy: 360.0)
        }
    }
}
