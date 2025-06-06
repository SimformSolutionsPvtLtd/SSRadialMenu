//
//  CircleView.swift
//  SSRadialMenu
//
//  Created by Rishita Panchal on 08/11/24.
//

import SwiftUI

struct CircleView: View {
    // MARK: - Variables
    var distance = 120.0
    var buttonHeight = 55.0
    var endAngle = 120.0
    var startAngle = 0.0
    @State var plusDegree = 0.0
    @State var plusOpacity = 1.0
    @State var plusScale = false
    @State var isBounceAnimating = false
    @State var isDistance = 0.0

    // MARK: - Binding variables
    @Binding var items: [MenuItem]
}

extension CircleView {
    var body: some View {
        Rectangle()
            .fill(.purple)
            .frame(width: distance * 2 + buttonHeight, height: distance * 2 + buttonHeight)
            .overlay {
                ZStack {
                    plusView()
                    ForEach(items, id: \.id) { item in
                        itemView(item)
                            .onAppear {
                                print("Item placed")
                            }
                    }
                }

            }
            .onAppear {
                updateItems()
            }
    }

    fileprivate func updateItems() {
        let step = getStep()
        for i in 0..<items.count {
            let angle = startAngle + Double(i) * step
//            items[i].id = i
            items[i].angle = angle
            print(angle)
        }
    }

    fileprivate func getStep() -> Double {
        var length = endAngle - startAngle
        var count = items.count
        if length < endAngle {
            count -= 1
        } else if length > endAngle {
            length = endAngle
        }
        return length / Double(count)
    }
}

// MARK: - Plus view
extension CircleView {
    @ViewBuilder
    private func plusView() -> some View {
        Button(action: {
            guard !isBounceAnimating else {
                return
            }
            isBounceAnimating = true
            plusDidTap()
        }, label: {
            Image(systemName: "plus.circle.fill")
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: buttonHeight, height: buttonHeight)
                .clipShape(.rect(cornerRadius: buttonHeight / 2))
                .foregroundColor(.blue)
        })
        .zIndex(5)
        .rotationEffect(.degrees(plusDegree))
        .scaleEffect(plusScale ? 0.9 : 1.0)
        .opacity(plusOpacity)
    }

    fileprivate func plusDidTap() {
        plusScale.toggle()
        withAnimation(.spring(response: 0.4, dampingFraction: 0.6)) {
            plusDegree = plusDegree == 45 ? .zero : 45
            plusOpacity = plusDegree == 45 ? 0.4 : 1.0
            plusScale.toggle()
            isDistance = plusDegree == 45 ? distance : 0.0
        }
        
        // Use DispatchQueue for completion to maintain macOS 13.0 compatibility
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
            isBounceAnimating = false
        }
    }
}

// MARK: - Item view
extension CircleView {
    private func itemView(_ item: MenuItem) -> some View {
        RoundedRectangle(cornerSize: CGSize(width: buttonHeight / 2, height: buttonHeight / 2))
            .fill(item.color)
            .overlay(content: {
                Button(action: {
                    print("Hello")
                }, label: {
                    Image(systemName: item.icon)
                        .frame(width: buttonHeight, height: buttonHeight)
                        .tint(.white)
                        .background(item.color)
                        .clipShape(.rect(cornerRadius: buttonHeight/2))
                })
                .rotationEffect(.degrees(Double(-item.angle)))
            })
            .frame(width: buttonHeight, height: buttonHeight)
            .offset(x: -isDistance)
            .rotationEffect(.degrees(item.angle))
            .id(item.id)
    }
}
