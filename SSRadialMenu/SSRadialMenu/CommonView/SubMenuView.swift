//
//  SubMenuView.swift
//  SSRadialMenu
//
//  Created by Rishita Panchal on 06/11/24.
//

import SwiftUI

struct SubMenuView: View {
    let subItems: [MenuItem]
      var position: Position
      @Binding var parentOffset: (CGFloat, CGFloat)
      @Binding var parentIndex: Int
      @Binding var isExpand: Bool
      @State private var subMenuItemsVisible: [Bool]
      @State private var subMenuItemsOffsets: [(CGFloat, CGFloat)]

      init(
          subItems: [MenuItem],
          position: Position,
          isExpand: Binding<Bool>,
          parentOffset: Binding<(CGFloat, CGFloat)>,
          parentIndex: Binding<Int>
      ) {
          self.subItems = subItems
          self.position = position
          self._isExpand = isExpand
          self._subMenuItemsVisible = State(initialValue: Array(repeating: false, count: subItems.count))
          self._subMenuItemsOffsets = State(initialValue: Array(repeating: (0, 0), count: subItems.count))
          self._parentOffset = parentOffset // Initialize the binding
          self._parentIndex = parentIndex

      }
    var body: some View {
        ZStack {
            ForEach(subItems.indices, id: \.self) { index in
                createSubMenuItem(subItems[index], at: index)
                    .opacity(subMenuItemsVisible[index] ? 1 : 0)
                    .scaleEffect(subMenuItemsVisible[index] ? 1.0 : 0.0)
                    .offset(
                        x: subMenuItemsOffsets[index].0,
                        y: subMenuItemsOffsets[index].1
                    )
                    .animation(
                        .easeOut(duration: 0.3).delay(Double(index) * 0.05),
                        value: subMenuItemsVisible[index]
                    )
            }
        }
        .onAppear {
            if isExpand {
                startSubMenuAnimation()
            }
        }
        .onChange(of: isExpand) { _, newValue in
            if !newValue {
                collapseSubMenu()
            } else {
                startSubMenuAnimation()
            }
        }
    }

    private func createSubMenuItem(_ item: MenuItem, at index: Int) -> some View {
        item.menuView
            .frame(width: item.size, height: item.size)
            .background(item.color)
            .cornerRadius(item.size / 2)
    }

    private func startSubMenuAnimation() {
        for index in 0..<subItems.count {
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(index) * 0.03) {
                subMenuItemsVisible[index] = true
                if index > 0 {
                    let previousOffset = subMenuItemsOffsets[index - 1]
                    guard let newOffset = position.calculateOffset(
                        radius: 200,
                        index: index,
                        totalItems: subItems.count,
                        parentIndex: parentIndex
                    ) else { return }
                    subMenuItemsOffsets[index] = previousOffset

                    withAnimation(.easeOut(duration: 0.2)) { 
                        subMenuItemsOffsets[index] = newOffset
                    }
                } else {
                    guard let subMenuItemOffset = position.calculateOffset(
                        radius: 200,
                        index: index,
                        totalItems: subItems.count,
                        parentIndex: parentIndex
                    ) else { return }
                    print(parentOffset)
                    subMenuItemsOffsets[index] = subMenuItemOffset
                }
            }
        }
    }

    private func collapseSubMenu() {
        for index in (0..<subItems.count).reversed() {
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(subItems.count - 1 - index) * 0.05) {
                // Animate the offset change before hiding the item
                if index > 0 {
                    let previousOffset = subMenuItemsOffsets[index - 1]
                    guard let newOffset = position.calculateOffset(
                        radius: 200,
                        index: index,
                        totalItems: subItems.count,
                        parentIndex: parentIndex
                    ) else { return }
                    subMenuItemsOffsets[index] = newOffset
                    withAnimation(.easeOut(duration: 0.7).speed(2.5)) {
                        subMenuItemsOffsets[index] = previousOffset
                    }
                } else {
                    guard let parentOffset = position.calculateOffset(
                        radius: 100,
                        index: index,
                        totalItems: subItems.count,
                        parentIndex: parentIndex
                    ) else { return }
                    withAnimation(.easeOut(duration: 0.7).speed(2.5)) {
                        subMenuItemsOffsets[index] = parentOffset
                    }
                    withAnimation(.easeOut(duration: 0.7).speed(2.5).delay(0.2)) {
                        subMenuItemsVisible[index] = false
                    }
                }
                withAnimation(.easeOut(duration: 0.7).delay(0.7).speed(2.5)) {
                    subMenuItemsVisible[index] = false
                }
            }
        }
    }
}
