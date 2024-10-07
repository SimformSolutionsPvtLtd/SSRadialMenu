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
                    .linearGradient(
                        colors: [.purple, .pink],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .mask {
                    Canvas { context, size in
                        context.addFilter(.alphaThreshold(min: 0.8, color: .black))
                        context.addFilter(.blur(radius: 15))

                        context.drawLayer { ctx in
                            for index in 1...viewModel.menus.count {
                                if let resolvedView = context.resolveSymbol(id: index) {
                                    ctx.draw(resolvedView, at: CGPoint(x: size.width / 2, y: size.height / 2))
                                }
                            }
                        }
                    } symbols: {
                        Symbol(diameter: 100)
                            .tag(1)
                        ForEach(viewModel.menus.indices, id: \.self) { index in
                            Symbol(offset: viewModel.menus[index].offset)
                                .tag(index + 1)
                        }
                    }
                }

            ZStack {
                CancelButton()
                    .blendMode(.softLight)
                    .rotationEffect(Angle(degrees: viewModel.menus.contains(where: { $0.isCollapsed }) ? 45 : 90))

                ForEach(viewModel.menus.indices, id: \.self) { index in
                    ZStack {
                        Image(systemName: "gear")
                            .resizable()
                            .frame(width: 28, height: 28)
                    }
                    .frame(width: 65, height: 65)
                    .offset(viewModel.menus[index].offset)
                    .blendMode(.softLight)
                    .opacity(viewModel.menus[index].isCollapsed ? 0 : 1)
                }

            }
        }
        .frame(width: 500, height: 500)
        .contentShape(Circle())
    }
}

extension SSRadialMenuView {
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
                viewModel.menus.forEach { menus in
                    if let index = viewModel.menus.firstIndex(where: { $0.id == menus.id }) {
                        viewModel.menus[index].isCollapsed.toggle()
                        print(viewModel.menus[index].isCollapsed)
                    }
                }
            }
            withAnimation(
                .interactiveSpring(response: 0.35, dampingFraction: 0.8, blendDuration: 0.1).speed(0.5)
            ) {
                viewModel.menus.forEach { menu in
                    if let index = viewModel.menus.firstIndex(where: { $0.id == menu.id }) {
                        viewModel.menus[index].offset = menu.isCollapsed ? .zero : circularOffset(
                            index: index,
                            total: viewModel.menus.count,
                            radius: 120
                        )
                    }
                }
            }
        }
    }

    func SettingsButton() -> some View {
        ZStack {
            Image(systemName: "gear")
                .resizable()
                .frame(width: 28, height: 28)
        }
        .frame(width: 65, height: 65)
    }

    func circularOffset(index: Int, total: Int, radius: CGFloat) -> CGSize {
        let angle = 2 * .pi / CGFloat(total) * CGFloat(index) // Calculate angle for each item
        let xOffset = radius * cos(angle) // X offset using cosine
        let yOffset = radius * sin(angle) // Y offset using sine
        return CGSize(width: xOffset, height: yOffset)
    }
}

