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

struct ContentView: View {
    @State private var squares: [Square] = []
    @State private var selectedSquare: Square?
    @State private var gradientColors: [Color] = []

    var body: some View {
        GeometryReader { geometry in
            ScrollView([.horizontal, .vertical], showsIndicators: true) {
                ZStack(alignment: .topLeading) {
                    LinearGradient(
                        gradient: Gradient(colors: gradientColors.isEmpty ? [Color.black] : gradientColors),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                    .frame(width: 1920, height: 1080)

                    if selectedSquare != nil {
                        Color.clear
                            .frame(width: 1920, height: 1080)
                            .contentShape(Rectangle())
                            .onTapGesture {
                                selectedSquare = nil
                            }
                    }

                    ForEach(squares) { square in
                        RoundedRectangle(cornerRadius: 12.0)
                            .glassEffect(.regular.interactive().tint(square.color), in: .rect(cornerRadius: 12.0))
                            .frame(width: square.size, height: square.size)
                            .position(square.position)
                            .onTapGesture {
                                selectedSquare = square
                            }
                    }

                    PPPopover(selection: $selectedSquare, canvasSize: CGSize(width: 1920, height: 1080))
                }
                .onAppear {
                    generateGradient()
                    generateSquares(in: CGSize(width: 1920, height: 1080))
                }
            }
            .background(Color.black)
        }
        .ignoresSafeArea()
    }

    private func generateSquares(in size: CGSize) {
        let numberOfSquares = 40
        let squareSize: CGFloat = 52

        var generatedSquares: [Square] = []
        while generatedSquares.count < numberOfSquares {
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

    private func generateGradient() {
        let numberOfColors = 3
        gradientColors = (0..<numberOfColors).map { _ in
            Color(
                red: Double.random(in: 0...1),
                green: Double.random(in: 0...1),
                blue: Double.random(in: 0...1)
            )
        }
    }
}

struct PPPopover: View {
    @Binding var selection: Square?
    let canvasSize: CGSize

    let popoverWidth: CGFloat = 260.0
    let popoverHeight: CGFloat = 200.0
    let edgePadding: CGFloat = 18.0

    @State private var animationProgress: CGFloat = 0
    @State private var dismissingSquare: Square?
    @State private var currentSquare: Square?

    var body: some View {
        ZStack {
            if let square = currentSquare {
                popoverContent(for: square, isDismissing: false)
                    .id(square.id)
            }

            if let dismissing = dismissingSquare {
                popoverContent(for: dismissing, isDismissing: true)
                    .id("dismissing-\(dismissing.id)")
            }
        }
        .onChange(of: selection) { oldValue, newValue in
            handleSelectionChange(from: oldValue, to: newValue)
        }
        .onAppear {
            if let selected = selection {
                currentSquare = selected
            }
        }
    }

    private func popoverContent(for square: Square, isDismissing: Bool) -> some View {
        PopoverContent(
            square: square,
            canvasSize: canvasSize,
            popoverWidth: popoverWidth,
            popoverHeight: popoverHeight,
            edgePadding: edgePadding,
            isDismissing: isDismissing,
            onDismiss: {
                if !isDismissing {
                    dismissWithAnimation()
                }
            }
        )
    }

    private func handleSelectionChange(from oldValue: Square?, to newValue: Square?) {
        if let old = oldValue, newValue == nil {
            return
        }

        if let old = oldValue, let new = newValue, old.id != new.id {
            dismissingSquare = old
            currentSquare = new

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                dismissingSquare = nil
            }
        } else if let new = newValue {
            currentSquare = new
        } else {
            currentSquare = nil
        }
    }

    private func dismissWithAnimation() {
        if let current = currentSquare {
            dismissingSquare = current
            currentSquare = nil
            selection = nil

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                dismissingSquare = nil
            }
        }
    }
}

struct PopoverContent: View {
    let square: Square
    let canvasSize: CGSize
    let popoverWidth: CGFloat
    let popoverHeight: CGFloat
    let edgePadding: CGFloat
    let isDismissing: Bool
    let onDismiss: () -> Void

    @State private var animationProgress: CGFloat = 0

    var body: some View {
        ZStack(alignment: .center) {
            ScrollView {
                VStack(alignment: .leading, spacing: 12.0) {
                    HStack {
                        Spacer()
                        Button(action: onDismiss) {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(.primary.opacity(0.5))
                                .font(.title)
                        }
                    }
                    VStack(alignment: .leading, spacing: 4.0) {
                        if square.red.isEqual(to: 1.0) && square.green.isEqual(to: 1.0) && square.blue.isEqual(to: 1.0) {
                            Text("Special Test Point")
                                .bold()
                            Text("Special Test Point")
                                .bold()
                            Text("Special Test Point")
                                .bold()
                            Text("Special Test Point")
                                .bold()
                            Text("Special Test Point")
                                .bold()
                            Text("Special Test Point")
                                .bold()
                            Text("Special Test Point")
                                .bold()
                        } else {
                            Text("Red: \(Int(square.red * 255))")
                            Text("Green: \(Int(square.green * 255))")
                            Text("Blue: \(Int(square.blue * 255))")
                        }
                    }
                }
                .padding(.horizontal, 16.0)
                .padding(.vertical, 8.0)
            }
            .contentMargins(.vertical, 8.0)
            .frame(width: popoverWidth, height: popoverHeight)
            .glassEffect(.regular, in: .rect(cornerRadius: 16.0))
        }
        .scaleEffect(0.3 + (0.7 * animationProgress))
        .opacity(animationProgress)
        .position(animatedPosition())
        .onAppear {
            if isDismissing {
                animationProgress = 1
                withAnimation(.spring(response: 0.25, dampingFraction: 0.6)) {
                    animationProgress = 0
                }
            } else {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                    animationProgress = 1
                }
            }
        }
    }

    private func animatedPosition() -> CGPoint {
        let finalPosition = calculatePopoverPosition()
        let startPosition = square.position

        return CGPoint(
            x: startPosition.x + (finalPosition.x - startPosition.x) * animationProgress,
            y: startPosition.y + (finalPosition.y - startPosition.y) * animationProgress
        )
    }

    private func calculatePopoverPosition() -> CGPoint {
        let gapFromSquare: CGFloat = 8
        let effectiveHeight = max(popoverHeight, 150)
        let minOffsetX = (square.size / 2) + gapFromSquare + (popoverWidth / 2)
        let minOffsetY = (square.size / 2) + gapFromSquare + (effectiveHeight / 2)

        let spaceRight = canvasSize.width - edgePadding - (square.position.x + minOffsetX + popoverWidth / 2)
        let spaceLeft = (square.position.x - minOffsetX - popoverWidth / 2) - edgePadding
        let spaceBottom = canvasSize.height - edgePadding - (square.position.y + minOffsetY + effectiveHeight / 2)
        let spaceTop = (square.position.y - minOffsetY - effectiveHeight / 2) - edgePadding

        var x: CGFloat
        var y: CGFloat

        let canFitRight = spaceRight >= 0
        let canFitLeft = spaceLeft >= 0
        let canFitBelow = spaceBottom >= 0
        let canFitAbove = spaceTop >= 0

        let nearTopEdge = square.position.y < canvasSize.height * 0.3
        let nearBottomEdge = square.position.y > canvasSize.height * 0.7

        if nearTopEdge && canFitBelow {
            x = square.position.x
            y = square.position.y + minOffsetY
        } else if nearBottomEdge && canFitAbove {
            x = square.position.x
            y = square.position.y - minOffsetY
        } else if canFitRight {
            x = square.position.x + minOffsetX
            y = square.position.y

            if y + effectiveHeight / 2 > canvasSize.height - edgePadding {
                y = canvasSize.height - edgePadding - effectiveHeight / 2
            } else if y - effectiveHeight / 2 < edgePadding {
                y = edgePadding + effectiveHeight / 2
            }
        } else if canFitLeft {
            x = square.position.x - minOffsetX
            y = square.position.y

            if y + effectiveHeight / 2 > canvasSize.height - edgePadding {
                y = canvasSize.height - edgePadding - effectiveHeight / 2
            } else if y - effectiveHeight / 2 < edgePadding {
                y = edgePadding + effectiveHeight / 2
            }
        } else if canFitBelow {
            x = square.position.x
            y = square.position.y + minOffsetY
        } else if canFitAbove {
            x = square.position.x
            y = square.position.y - minOffsetY
        } else {
            x = square.position.x + minOffsetX
            y = square.position.y
        }

        x = max(edgePadding + popoverWidth / 2, min(canvasSize.width - edgePadding - popoverWidth / 2, x))
        y = max(edgePadding + effectiveHeight / 2, min(canvasSize.height - edgePadding - effectiveHeight / 2, y))

        return CGPoint(x: x, y: y)
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
