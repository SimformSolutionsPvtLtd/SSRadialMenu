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
    let step: Double = 45.0

    @State private var showPizzaCards: Bool = false // State to toggle visibility of PizzaCards

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea(.all)
            GeometryReader { geometry in
                let size = geometry.size

                ZStack {
                    // Main menu items
                    if showPizzaCards {
                        ForEach(pizzas.indices, id: \.self) { index in
                            let anglePerPizza = pizzas.count <= 4 ? 90.0 / Double(pizzas.count) + 20 : 360.0 / Double(pizzas.count)
                            let pizzaAngle = alignment.itemAngle(index: index, angle: angle, anglePerPizza: anglePerPizza)

                            PizzaCard(pizza: pizzas[index])
                                .rotationEffect(.degrees(-pizzaAngle))
                                .offset(
                                    x: animatedIndices.contains(index) ? radius * cos(pizzaAngle * .pi / 180) : 0,
                                    y: animatedIndices.contains(index) ? radius * sin(pizzaAngle * .pi / 180) : 0
                                )
                                .scaleEffect(animatedIndices.contains(index) ? 1 : 0.1) // Scale up with animation
                                .animation(.spring(response: 0.5, dampingFraction: 0.6), value: animatedIndices)
                                .onTapGesture {
                                    handlePizzaCardTap(index: index)
                                }
                                .onChange(of: pizzaAngle, perform: { _ in
                                    if isCardNearTriangle(pizzaAngle) {
                                        nameofPizza = pizzas[index].pizza
                                        priceofPizza = pizzas[index].pizzaPrice
                                    }
                                })
                        }
                    }

                    // Submenu items (second layer)
                    if let selectedIndex = showingSubMenuForIndex,
                       let subMenuItems = pizzas[selectedIndex].subMenuItems {
                        ForEach(subMenuItems.indices, id: \.self) { subIndex in
                            let mainAngle = alignment.itemAngle(
                                index: selectedIndex,
                                angle: angle,
                                anglePerPizza: pizzas.count <= 4 ? 90.0 / Double(pizzas.count) + 20 : 360.0 / Double(pizzas.count)
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
                    pizzas.count > 4 ? DragGesture()
                        .onChanged { value in
                            let translation = value.translation
                            let delta = -Double((translation.width + translation.height) / 2) / radius * (180 / .pi)
                            angle = startAngle + delta
                        }
                        .onEnded { _ in
                            angle = (angle / step).rounded() * step
                            startAngle = angle
                            updatePizzaDetails()
                        } : nil
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
        for index in 0..<pizzas.count {
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(index) * 0.1) {
                withAnimation(.easeIn) {
                    _ = animatedIndices.insert(index) // Animate each item one by one
                }
            }
        }
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
    func PizzaCard(pizza: Pizza) -> some View {
        Image(pizza.pizzaImage)
            .resizable()
            .frame(width: 80, height: 80)
            .clipShape(Circle())
    }

    func updatePizzaDetails() {
        let anglePerPizza = 360.0 / Double(pizzas.count)
        let index = Int((angle / anglePerPizza).truncatingRemainder(dividingBy: Double(pizzas.count)))
        let validIndex = index >= 0 ? index : (index + pizzas.count) % pizzas.count
        nameofPizza = pizzas[validIndex].pizza
        priceofPizza = pizzas[validIndex].pizzaPrice
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
    .init(pizza: "Cheese Pizza", pizzaImage: "pizza2",pizzaPrice: "150 $", subMenuItems: nil),
    .init(pizza: "Italian Pizza", pizzaImage: "pizza3",pizzaPrice: "300 $", subMenuItems: nil),
    .init(pizza: "Cheese Pizza", pizzaImage: "pizza2",pizzaPrice: "150 $", subMenuItems: nil),
    .init(pizza: "Italian Pizza", pizzaImage: "pizza3",pizzaPrice: "300 $", subMenuItems: nil),
    .init(pizza: "Cheese Pizza", pizzaImage: "pizza2",pizzaPrice: "150 $", subMenuItems: nil),
    .init(pizza: "Italian Pizza", pizzaImage: "pizza3",pizzaPrice: "300 $", subMenuItems: nil)
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
