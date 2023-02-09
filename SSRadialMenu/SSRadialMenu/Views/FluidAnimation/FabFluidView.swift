//
//  FabFluidView.swift
//  SSRadialMenu
//
//  Created by Bansi Mamtora on 08/02/23.
//

import SwiftUI

struct FabFluidView: View {
    @State private var isShowing = false
    @State var isDragging: Bool = false
    @State private var isMenuDragging = false
    @State private var enableMenuButtons = false
    var body: some View {

        ZStack(alignment: .center) {

            fabShape()
                .frame(width: 50,height: 50)
                .foregroundColor(customColor)
                .overlay(content: {
                    Image(systemName: customImg)
                        .foregroundColor(.white)
                })
                .onTapGesture {
                    isShowing.toggle()
                    isDragging = true
                    withAnimation(.interpolatingSpring(stiffness: 150, damping: 5 )) {
                        self.isDragging = false
                    }
                }
                .radialMenu(isShowing: $isShowing, menuPopStyle: .circular(.topLeft), distance: 100, autoClose: true, buttons: [
                        menuShape()
                            .zIndex(2), menuShape().zIndex(2),menuShape().zIndex(2)
                        
                ])
                .zIndex(5)
                .onChange(of: isShowing) { newValue in
                    isMenuDragging = true
                    withAnimation(.interpolatingSpring(stiffness: 50, damping: 15)) {
                        self.isMenuDragging = false
                    }
                }
        }
    }

    func menuShape() -> some View {
        func path(in rect: CGRect) -> Path {
            return MorphCircle(isDragging: isDragging, isMenu: false).path(in: rect)
        }

        return GeometryReader { proxy in
            let rect = proxy.frame(in: CoordinateSpace.local)
            return AnyView(SimilarShape(path: path(in: rect)))
        }
    }
    
    func fabShape() -> some View {
        func path(in rect: CGRect) -> Path {
            return MorphCircle(isDragging: isDragging, isMenu: false).path(in: rect)
        }

        return GeometryReader { proxy in
            let rect = proxy.frame(in: CoordinateSpace.local)
            return SimilarShape(path: path(in: rect))
        }
    }

}



extension View {
    var customImg: String {
        return "plus"
    }
    var customSize: CGFloat {
        30
    }
    var customColor: Color {
        .blue
    }
}
struct FabFluidView_Previews: PreviewProvider {
    static var previews: some View {
        FabFluidView()
    }
}
