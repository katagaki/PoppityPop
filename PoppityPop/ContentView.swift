//
//  ContentView.swift
//  PoppityPop
//
//  Created by シン・ジャスティン on 2025/11/02.
//

import SwiftUI

struct ContentView: View {
    let canvasSize: CGSize = .init(width: 1920, height: 1080)
    @State var squares: [Square] = []
    @State var selectedSquare: Square?

    var body: some View {
        TabView {
            Tab("Map", systemImage: "map") {
                NavigationStack {
                    GeometryReader { geometry in
                        ScrollView([.horizontal, .vertical], showsIndicators: true) {
                            ZStack(alignment: .topLeading) {
                                Color.clear
                                    .contentShape(.rect)
                                    .frame(width: 1920, height: 1080)
                                    .onTapGesture {
                                        selectedSquare = nil
                                    }
                                ForEach(squares) { square in
                                    RoundedRectangle(cornerRadius: 12.0)
                                        .adaptiveGlass(.coloredInteractive(color: square.color), cornerRadius: 12.0)
                                        .frame(width: square.size, height: square.size)
                                        .position(square.position)
                                        .onTapGesture {
                                            selectedSquare = square
                                        }
                                }

                                Popover(
                                    selection: $selectedSquare,
                                    canvasSize: canvasSize,
                                    itemPosition: { $0.position },
                                    itemSize: { $0.size }
                                ) { item in
                                    VStack(alignment: .leading, spacing: 12.0) {
                                        VStack(alignment: .leading, spacing: 4.0) {
                                            if item.red.isEqual(to: 1.0) && item.green.isEqual(to: 1.0) && item.blue.isEqual(to: 1.0) {
                                                ForEach(0..<20, id: \.self) { _ in
                                                    Text("Special Test Point")
                                                        .bold()
                                                }
                                            } else {
                                                Text("Red: \(Int(item.red * 255))")
                                                Text("Green: \(Int(item.green * 255))")
                                                Text("Blue: \(Int(item.blue * 255))")
                                            }
                                        }
                                    }
                                }
                            }
                            .onAppear {
                                generateSquares(in: canvasSize)
                            }
                        }
                        .scrollIndicators(.hidden)
                    }
                    .navigationTitle("Map")
                    .navigationBarTitleDisplayMode(.inline)
                }
            }
            Tab("Search", systemImage: "magnifyingglass") { }
            Tab("More", systemImage: "ellipsis") { }
        }
    }

    func generateSquares(in size: CGSize) {
        let squareSize: CGFloat = 52

        var generatedSquares: [Square] = []
        while generatedSquares.count < 40 {
            let newPosition = CGPoint(
                x: CGFloat.random(in: (squareSize / 2)...(size.width - squareSize / 2)),
                y: CGFloat.random(in: (squareSize / 2)...(size.height - squareSize / 2))
            )
            generatedSquares.append(Square(
                red: Double.random(in: 0...1),
                green: Double.random(in: 0...1),
                blue: Double.random(in: 0...1),
                position: newPosition
            ))
        }

        generatedSquares.append(Square(red: 1, green: 1, blue: 1, position: .init(x: 26, y: 26)))
        generatedSquares.append(Square(red: 1, green: 1, blue: 1, position: .init(x: 26, y: 500)))
        generatedSquares.append(Square(red: 1, green: 1, blue: 1, position: .init(x: 26, y: 1054)))
        generatedSquares.append(Square(red: 1, green: 1, blue: 1, position: .init(x: 500, y: 26)))
        generatedSquares.append(Square(red: 1, green: 1, blue: 1, position: .init(x: 500, y: 1054)))
        generatedSquares.append(Square(red: 1, green: 1, blue: 1, position: .init(x: 1894, y: 26)))
        generatedSquares.append(Square(red: 1, green: 1, blue: 1, position: .init(x: 1894, y: 300)))
        generatedSquares.append(Square(red: 1, green: 1, blue: 1, position: .init(x: 1894, y: 1054)))

        squares = generatedSquares
    }
}

#Preview("Light") {
    ContentView()
        .preferredColorScheme(.light)
}

#Preview("Dark") {
    ContentView()
        .preferredColorScheme(.dark)
}
