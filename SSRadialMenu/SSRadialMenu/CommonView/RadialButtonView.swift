//
//  MenuButtonView.swift
//  SSRadialMenu
//
//  Created by Rishita Panchal on 07/12/23.
//

import SwiftUI

struct RadialButtonView: View {
    // MARK: - Variables
    var icon: String
    var backGroundColor: Color
    var size: CGFloat
    var constantRadius = 50.0
    @State private var opened = false
    @State private var rotationValue = 45.0
    @State private var cornerRadius = 18.0
    @State private var liquidOffset: CGFloat = 0.0
    var action: (() -> Void)? = nil
}

// MARK: Body view
extension RadialButtonView {
    var body: some View {
        content
    }
}

// MARK: - Private views
extension RadialButtonView {
    private var content: some View {
        HStack{ }
            .frame(width: size, height: size)
            .background(backGroundColor)
            .clipShape(.circle)
            .rotationEffect(.degrees(opened ? rotationValue : 0))
            .animation(.easeInOut, value: cornerRadius)
            .padding(10)
            .overlay {
                Image(systemName: icon)
                    .foregroundColor(.white)
                    .font(.headline)
                    .fontWeight(.bold)
                    .frame(width: 60, height: 60)
                    .rotationEffect(.degrees(opened ? 45 : 0))
                    .animation(.easeInOut, value: opened)
            }
            .onTapGesture {
                withAnimation(.spring(response: 0.5, dampingFraction: 0.5)) {
                    opened.toggle()
                    action?()
                    liquidOffset = opened ? -15.0 : 0.0
                }
            }
    }
}
