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
            subMenuView()
            menuView()
            RadialButtonView(systemImage: "plus") {
                if !shouldDisplaySubSubMenu {
                    isActivated.toggle()
                }
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

// Submenus view
extension SSRadialMenuView {
    func subMenuView() -> some View {
        ForEach(0..<viewModel.subMenus.count, id: \.self) { i in
            SubMenusButtonView(
                isActivated: $shouldDisplaySubSubMenu,
                viewModel: viewModel,
                currentItemIndex: i,
                action: { }
            )
            .transition(.opacity)
            .animation(
                Animation.easeInOut.delay(Double(viewModel.subMenus.count - 1 - i) * 0.1),
                value: shouldDisplaySubSubMenu
            )
        }
    }
}

// Menu view
extension SSRadialMenuView {
    func menuView() -> some View {
        ForEach(0..<viewModel.menus.count, id: \.self) { i in
            MenusButtonView(
                isActivated: $isActivated,
                shouldDisplaySubSubMenu: $shouldDisplaySubSubMenu,
                viewModel: viewModel,
                currentItemIndex: i,
                action: {
                    withAnimation {
                        shouldDisplaySubSubMenu.toggle()
                    }
                }
            )
            .transition(.opacity)
            .animation(
                Animation.easeInOut.delay(Double(viewModel.menus.count - 1 - i) * 0.2),
                value: isActivated
            )
        }
    }
}
