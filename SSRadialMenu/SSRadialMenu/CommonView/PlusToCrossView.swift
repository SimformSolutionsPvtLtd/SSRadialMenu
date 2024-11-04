//
//  PlusToCrossView.swift
//  SSRadialMenu
//
//  Created by Rishita Panchal on 04/11/24.
//

import SwiftUI

struct PlusToCrossView: View {
    @Binding var isCross: Bool

    var body: some View {
        Image(systemName: "plus")
            .resizable()
            .frame(width: 30, height: 30)
            .foregroundColor(.white)
            .shadow(color: Color.black.opacity(0.5), radius: 3, x: 0, y: 3)
            .rotationEffect(.degrees(isCross ? 45 : 0)) // Rotate by 45 degrees to create "cross"
            .animation(.easeInOut(duration: 0.3), value: isCross) // Smooth transition
    }
}
