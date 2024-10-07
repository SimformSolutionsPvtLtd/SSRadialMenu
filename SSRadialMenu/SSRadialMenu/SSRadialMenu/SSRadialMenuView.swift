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
    @ObservedObject var viewModel = SSRadialMenuViewModel()
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
                        context.addFilter(.blur(radius: 5))

                        context.drawLayer { ctx in
                            for index in 1...viewModel.menus.count {
                                if let resolvedView = context.resolveSymbol(id: index) {
                                    ctx.draw(
                                        resolvedView,
                                        at: CGPoint(
                                            x: size.width / 2,
                                            y: size.height / 2
                                        )
                                    )
                                }
                            }
                        }
                    } symbols: {
                        Symbol(diameter: 80)
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
                        Image(systemName: viewModel.menus[index].icon)
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
    private func Symbol(offset: CGSize = .zero, diameter: CGFloat = 55) -> some View {
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
            for (index, menu) in viewModel.menus.enumerated() {
                if let menuIndex = viewModel.menus.firstIndex(where: { $0.id == menu.id }) {
                    let delay = Double(index) * 0.2 // Adjust the delay multiplier as needed

                    DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                        withAnimation(.interactiveSpring(response: 0.35, dampingFraction: 0.8, blendDuration: 0.1).speed(0.1)) {
                            let jumpOffset: CGSize = CGSize(width: 0, height: -10)
                            let finalOffset = menu.isCollapsed ? .zero : circularOffset(
                                index: menuIndex,
                                total: viewModel.menus.count,
                                radius: 85
                            )
                            viewModel.menus[menuIndex].offset = jumpOffset
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                withAnimation(.easeOut(duration: 0.3)) {
                                    viewModel.menus[menuIndex].offset = finalOffset
                                }
                            }
                        }
                    }
                }
            }

        }
    }

    func circularOffset(index: Int, total: Int, radius: CGFloat) -> CGSize {
        let angle = 2 * .pi / CGFloat(total) * CGFloat(index) // Calculate angle for each item
        let xOffset = radius * cos(angle) // X offset using cosine
        let yOffset = radius * sin(angle) // Y offset using sine
        return CGSize(width: xOffset, height: yOffset)
    }
}

