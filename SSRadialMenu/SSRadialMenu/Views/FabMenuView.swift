//
//  RadialView.swift
//  AnimationPractice
//
//  Created by Bansi Mamtora on 19/01/23.
//

import SwiftUI

struct FabMenuView: View {
    @State private var isShowing = false
    var body: some View {
        ZStack(alignment: .center) {
            Color.clear
            Button {
                isShowing.toggle()
            } label: {
                Image(systemName: "plus")
                    .foregroundColor(.white)
            }
            
            .padding()
            .background(.blue)
            .cornerRadius(.infinity)
            .radialMenu(isShowing: $isShowing,
                        menuPopStyle: .circular(.custom(.degrees(200), .degrees(340))),
                        distance: 70,
                        autoClose: true,
                        buttons: [
                            MenuButton(color: .red, image: "plus", size: 35, action: {
                                print("A")
                            }),
                            MenuButton(color: .green, image: "star", size: 30, action: {
                                print("C")
                            }),
                            MenuButton(color: .green, image: "star", size: 30, action: {
                                print("C")
                            }),
                            MenuButton(color: .green, image: "star", size: 30, action: {
                                print("D")
                            })
                        ])
        }
    }
    
}

struct RadialView_Previews: PreviewProvider {
    static var previews: some View {
        FabMenuView()
    }
}

