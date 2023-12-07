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
    @State private var shouldDisplaySubSubMenu = false
    @State private var visibleIndexes: [Int] = []
    @ObservedObject var viewModel = MenuViewModel()
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
            if shouldDisplaySubSubMenu {
                ForEach(0..<viewModel.subMenus.count, id: \.self) { i in
                    SubSubMenuButtonView(
                        isActivated: $shouldDisplaySubSubMenu,
                        viewModel: viewModel,
                        currentItemIndex: i,
                        action: {
                            print("Hewdiwhejw")
                        }
                    )
                }
            }
            ForEach(0..<viewModel.menus.count, id: \.self) { i in
                SubMenuButtonView(
                    isActivated: $isActivated,
                    shouldDisplaySubSubMenu: $shouldDisplaySubSubMenu,
                    viewModel: viewModel,
                    currentItemIndex: i,
                    action: {
                        print("Hewdiwhejw")
                    }
                )
                .transition(
                    .offset(y: visibleIndexes.contains(i) ? 0 : -1000)
                )
                .animation(
                    Animation.easeInOut.delay(Double(viewModel.menus.count - i - 1) * 0.1)
                )
                .onAppear {
                    withAnimation {
                        visibleIndexes.append(i)
                    }
                }
            }
            MenuButtonView(
                systemImage: "plus"
            ) {
                if !shouldDisplaySubSubMenu {
                    isActivated.toggle()
                }
            }
            .rotationEffect(.degrees(isActivated ? 45 : 0))
            .animation(.easeInOut, value: isActivated)
            .onChange(of: shouldDisplaySubSubMenu) { newValue in
                print("Newvalue : \(newValue)")
            }
        }
        .frame(
            maxWidth: .infinity,
            maxHeight: .infinity,
            alignment: .bottomTrailing
        )
        .padding(.trailing, 20)
    }
}
