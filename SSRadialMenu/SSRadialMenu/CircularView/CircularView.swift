//
//  CircularView.swift
//  SSRadialMenu
//
//  Created by Rishita Panchal on 02/12/24.
//

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
    let radius: CGFloat = 100
    let step: Double = 45.0

    @State private var showPizzaCards: Bool = false // State to toggle visibility of PizzaCards

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea(.all)
            GeometryReader { geometry in
                let size = geometry.size

                ZStack {
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
                                .onChange(of: pizzaAngle, perform: { _ in
                                    if isCardNearTriangle(pizzaAngle) {
                                        nameofPizza = pizzas[index].pizza
                                        priceofPizza = pizzas[index].pizzaPrice
                                    }
                                })
                                .onAppear {
                                    print(anglePerPizza)
                                }
                        }
                    }

                    Button(action: {
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
                            let translation = value.translation.width
                            let deltaAngle = Double(translation / radius) * (180 / .pi)
                            angle = startAngle + deltaAngle
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

    func startSequentialAnimation() {
        animatedIndices.removeAll() // Reset animation state
        for index in 0..<pizzas.count {
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(index) * 0.2) {
                withAnimation(.easeIn) {
                    _ = animatedIndices.insert(index) // Animate each item one by one
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
           Pizza(pizza: "Sub Panner Pizza", pizzaImage: "pizza1", pizzaPrice: "200 $"),
           Pizza(pizza: "Sub Panner Pizza", pizzaImage: "pizza1", pizzaPrice: "200 $"),
           Pizza(pizza: "Sub Panner Pizza", pizzaImage: "pizza1", pizzaPrice: "200 $")
       ]),
    .init(pizza: "Cheese Pizza", pizzaImage: "pizza2",pizzaPrice: "150 $", subMenuItems: nil),
    .init(pizza: "Italian Pizza", pizzaImage: "pizza3",pizzaPrice: "300 $", subMenuItems: nil),
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
