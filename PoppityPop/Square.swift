//
//  Square.swift
//  PoppityPop
//
//  Created by シン・ジャスティン on 2025/11/02.
//

import SwiftUI

struct Square: Identifiable, Equatable {
    let id = UUID()
    let color: Color
    let red: Double
    let green: Double
    let blue: Double
    let position: CGPoint
    let size: CGFloat = 52

    init(red: Double, green: Double, blue: Double, position: CGPoint) {
        self.red = red
        self.green = green
        self.blue = blue
        self.color = Color(red: red, green: green, blue: blue)
        self.position = position
    }

    static func == (lhs: Square, rhs: Square) -> Bool {
        lhs.id == rhs.id
    }
}
