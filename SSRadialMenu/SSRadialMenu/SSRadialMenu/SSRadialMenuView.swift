//
//  SSRadialMenuView.swift
//  SSRadialMenuView
//
//  Created by Rishita Panchal on 07/12/23.
//

import SwiftUI

struct SSRadialMenuView: View {
    // MARK: - Variables
    @State var showButtons = false
    @State private var isActivated = false
    @State private var isSubmenuActivated = false
    @ObservedObject var viewModel = MenuViewModel()
    let colors: [Color] = [.cyan, .blue, .indigo]
    @State private var scale: CGFloat = 1
    @State private var offsetX: CGFloat = 0
    @State private var offsetY: CGFloat = 0
    @State var offsetSettings: CGSize = .zero
    @State var offsetHome: CGSize = .zero
    @State private var isSettingsCollapsed: Bool = false
    @State private var isHomeVisible: Bool = false
    @State private var submenuVisible: [Bool] = Array(repeating: false, count: 4) // Number of

    let animation = Animation.easeInOut(duration: 1).repeatForever(autoreverses: true)
    
}

// MARK: - Body view
extension SSRadialMenuView {
    var body: some View {
        content
    }
}

// MARK: - Private views
extension SSRadialMenuView {
    private var content: some View {
        ZStack {
            Rectangle()
                .fill(
                    .linearGradient(colors: [.purple, .pink], startPoint: .top, endPoint: .bottom)
                )
                .mask {
                    Canvas { context, size in
                        context.addFilter(.alphaThreshold(min: 0.8, color: .black))
                        context.addFilter(.blur(radius: 15))

                        context.drawLayer { ctx in
                            for index in [1, 2] {
                                if let resolvedView = context.resolveSymbol(id: index) {
                                    ctx.draw(resolvedView, at: CGPoint(x: size.width / 2, y: size.height / 2))
                                }
                            }
                        }
                    } symbols: {
                        Symbol(diameter: 120)
                            .tag(1)
                        Symbol(offset: offsetSettings)
                            .tag(2)
                    }
                }

            ZStack {
                CancelButton()
                    .blendMode(.softLight)
                    .rotationEffect(Angle(degrees: isSettingsCollapsed ? 90 : 45))

                SettingsButton()
                    .offset(offsetSettings)
                    .blendMode(.softLight)
                    .opacity(isSettingsCollapsed ? 1 : 0)
            }
        }
        .frame(width: 120, height: 500)
        .contentShape(Circle())
    }
}

extension SSRadialMenuView {
    func menuItems(
        isOpened: Bool,
        menuLayer: MenuLayer,
        menuItem: [MenuItem],
        action: @escaping (() -> Void)
    ) -> some View {
        Group {
            var radiusMultiplier: CGFloat {
                switch menuLayer {
                case .first:
                    return 10
                case .second:
                    return 20
                case .third:
                    return 30
                }
            }
            
            var radius: CGFloat {
                return isOpened ? radiusMultiplier * 19 : 0
            }
            
            ForEach(0..<menuItem.count, id: \.self) { i in
                let angle = Angle(degrees: 90.0/Double(menuItem.count - 1) * Double(i))
                Button(action: action) {
                    Circle()
                        .fill(menuItem[i].color)
                        .overlay {
                            Image(systemName: menuItem[i].icon)
                                .frame(width: 30, height: 30)
                                .fontWeight(.semibold)
                                .rotationEffect(-angle)
                        }
                        .shadow(radius: 10)
                        .frame(width: menuItem[i].size, height:  menuItem[i].size)
                }
                .foregroundColor(.black)
                .offset(x: -radius * 0.5)
                //subMenuRotationAngles(at: isSubmenuActivated ? i : viewModel.subMenus.count - 1)
                .rotationEffect(angle)
                .transition(.opacity)
                .animation(
                    Animation.easeInOut.delay(Double(menuItem.count - 1 - i) * 0.2),
                    value: isOpened
                )
            }
        }
    }
}

struct LiquidView: View {
    @StateObject private var viewModel = MenuViewModel()
    @State var show = false
    @State var rotationValue = Angle()
    @State var yOffset = 20
    @State var angleVal = 0.0
    @State var itemCount = 0
    
    var body: some View {
        VStack {
            Rectangle()
                .mask(canvas)
                .overlay {
                    ZStack {
                        
                        Button(action: {
                            withAnimation(.spring(response: 0.5, dampingFraction: 0.5)) {
//                                show.toggle()
                                startTimer()
                            }
                        }, label: {
                            ZStack {
                                Circle()
                                    .fill(Color.black)
                                    .frame(width: 60, height: 60)
                                
                                Image(systemName: "plus").foregroundColor(.white)
                            }
                            .offset(x: -20, y: -30)
                            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomTrailing)
                        })
                    }
                }
        }
        .background(Color.yellow)
        
    }
    
    var canvas: some View {
        Canvas { content, size in
            content.addFilter(.alphaThreshold(min: 0.4))
            content.addFilter(.blur(radius: 5))
            content.drawLayer { drawingContext in
                let drawPoint = CGPoint(x: size.width - 50, y: size.height - 60)
                for index in 1...3 {
                    if let symbol = content.resolveSymbol(id: index) {
                        drawingContext.draw(symbol, at: drawPoint)
                    }
                }
            }
        } symbols: {
            Circle().fill(Color.clear).frame(width: 60, height: 60).tag(1)
            CanCircle(show: $show, yOffset: CGFloat(15), rotationValue: rotationValue, sAnimation: 0.3, tag: 2)
                .id(UUID())
        }
    }
    
    func startTimer() {
        var radius: CGFloat {
            return show ? 10 * 19 : 0
        }
        
        Timer.scheduledTimer(withTimeInterval: 1, repeats: true) {
            timer in
            withAnimation(.easeInOut(duration: radius)) {
                show.toggle()
                angleVal = 0.8
                let angle = Angle(degrees: 90.0/Double(viewModel.menus.count - 1) * Double(angleVal))
                
                rotationValue = angle
                
                yOffset = 0
                
                if itemCount < viewModel.menus.count - 1{
                    
                    itemCount += 1
                } else {
                    itemCount = 0
                    yOffset = 0
                    rotationValue = Angle()
                    timer.invalidate()
                    show = false
                    angleVal = 0
                }
            }
        }
    }
}

struct CanCircle: View {
    @Binding var show: Bool
    @State var yOffset: CGFloat
    @State var rotationValue: Angle
    var sAnimation: CGFloat
    var tag: Int
    var body: some View {
        Circle()
            .fill(Color.green) // Try a specific color
            .frame(width: 40, height: 40)
            .tag(tag)
            .offset(y: show ? -yOffset : 0)
            .rotationEffect(rotationValue, anchor: .top)
            .transition(.opacity)
            .animation(.spring(response: 1, dampingFraction: 0.8).delay(show ? sAnimation : 0), value: show)
    }
}



struct StretchedCircle: Shape {
  let scale: CGFloat
  let offsetX: CGFloat
  let offsetY: CGFloat

  func path(in rect: CGRect) -> Path {
    let center = CGPoint(x: rect.midX, y: rect.midY)
    var path = Path()
    path.addArc(center: center, radius: scale * rect.width / 2, startAngle: .zero, endAngle: .degrees(360), clockwise: false)
      return path.offset(CGPoint(x: offsetX, y: offsetY)).path(in: rect)
  }
}


struct LiquidMenuButtons: View {

    // - Properties -
    @State var offsetSettings: CGSize = .zero
    @State var offsetHome: CGSize = .zero
    @State private var isSettingsCollapsed: Bool = false
    @State private var isHomeVisible: Bool = false
    @State private var submenuVisible: [Bool] = Array(repeating: false, count: 4) // Number of submenus

    // - Body -
    var body: some View {
        ZStack {
//            BackgroundView()
//            LiquidMenu()
        }
    }
}


extension SSRadialMenuView {

    private func BackgroundView() -> some View {
        Rectangle()
            .fill(.linearGradient(colors: [.black.opacity(0.9), .black, .black.opacity(0.9)], startPoint: .topLeading, endPoint: .bottomTrailing))
            .edgesIgnoringSafeArea(.all)
    }

    private func LiquidMenu() -> some View {
        ZStack {
            Rectangle()
                .fill(
                    .linearGradient(colors: [.purple, .pink], startPoint: .top, endPoint: .bottom)
                )
                .mask {
                    Canvas { context, size in
                        context.addFilter(.alphaThreshold(min: 0.8, color: .black))
                        context.addFilter(.blur(radius: 15))

                        context.drawLayer { ctx in
                            for index in [1, 2] {
                                if let resolvedView = context.resolveSymbol(id: index) {
                                    ctx.draw(resolvedView, at: CGPoint(x: size.width / 2, y: size.height / 2))
                                }
                            }
                        }
                    } symbols: {
                        Symbol(diameter: 120)
                            .tag(1)
                        Symbol(offset: offsetSettings)
                            .tag(2)
                    }
                }

            ZStack {
                CancelButton()
                    .blendMode(.softLight)
                    .rotationEffect(Angle(degrees: isSettingsCollapsed ? 90 : 45))

                SettingsButton()
                    .offset(offsetSettings)
                    .blendMode(.softLight)
                    .opacity(isSettingsCollapsed ? 1 : 0)
            }
        }
        .frame(width: 120, height: 500)
        .contentShape(Circle())
    }
    private func Symbol(offset: CGSize = .zero, diameter: CGFloat = 75) -> some View {
        Circle()
            .frame(width: diameter, height: diameter)
            .offset(offset)
    }

    func CancelButton() -> some View {
        ZStack {
            Image(systemName: "xmark")
                .resizable()
                .frame(width: 35, height: 35)
                .aspectRatio(.zero, contentMode: .fit).contentShape(Circle())
        }
        .frame(width: 100, height: 100)
        .contentShape(Rectangle())
        .onTapGesture {
            debugPrint("-- Cancel Tapped --")
            withAnimation {
                isSettingsCollapsed.toggle()
                isHomeVisible.toggle() // Toggle visibility of HomeButton
            }
            withAnimation(.interactiveSpring(response: 0.35, dampingFraction: 0.8, blendDuration: 0.1).speed(0.5)) {
                offsetSettings = isSettingsCollapsed ? CGSize(width: 0, height: -120) : .zero
                offsetHome = isHomeVisible ? CGSize(width: 0, height: -205) : .zero // Control HomeButton offset separately
            }
        }
    }
//
    func SettingsButton() -> some View {
        ZStack {
            Image(systemName: "gear")
                .resizable()
                .frame(width: 28, height: 28)
        }
        .frame(width: 65, height: 65)
    }
}
