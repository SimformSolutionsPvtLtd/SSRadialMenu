//
//  SimilarShape.swift
//  SSRadialMenu
//
//  Created by Bansi Mamtora on 08/02/23.
//

import SwiftUI

public struct SimilarShape: Shape, Animatable {
    var path: Path

    public init(path: Path) {
        self.path = path
    }

    public func path(in rect: CGRect) -> Path {
        return path
    }

   public var animatableData: AnimatableDataShape {
        get {
            AnimatableDataShape(path: path)
        }
        set {
            path = newValue.makePath()
        }
    }
}


