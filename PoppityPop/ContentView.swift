import SwiftUI

protocol PopoverItem: Identifiable, Equatable {
    var position: CGPoint { get }
    var size: CGFloat { get }
}

struct Square: Identifiable, Equatable, PopoverItem {
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
    let canvasSize: CGSize = .init(width: 1920, height: 1080)
    @State private var squares: [Square] = []
    @State private var selectedSquare: Square?
    @State private var gradientColors: [Color] = []

    var body: some View {
        GeometryReader { geometry in
            ScrollView([.horizontal, .vertical], showsIndicators: true) {
                ZStack(alignment: .topLeading) {
                    LinearGradient(
                        gradient: Gradient(colors: gradientColors),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                    .frame(width: 1920, height: 1080)
                    .onTapGesture {
                        selectedSquare = nil
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

                    PPPopover(selection: $selectedSquare, canvasSize: canvasSize) { square in
                        VStack(alignment: .leading, spacing: 4.0) {
                            if square.red.isEqual(to: 1.0) && square.green.isEqual(to: 1.0) && square.blue.isEqual(to: 1.0) {
                                ForEach(0..<20, id: \.self) { _ in
                                    Text("Special Test Point")
                                        .bold()
                                }
                            } else {
                                Text("Red: \(Int(square.red * 255))")
                                Text("Green: \(Int(square.green * 255))")
                                Text("Blue: \(Int(square.blue * 255))")
                            }
                        }
                    }
                }
                .onAppear {
                    generateGradient()
                    generateSquares(in: canvasSize)
                }
            }
        }
        .ignoresSafeArea()
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

    func generateGradient() {
        gradientColors = (0..<3).map { _ in
            Color(
                red: Double.random(in: 0...1),
                green: Double.random(in: 0...1),
                blue: Double.random(in: 0...1)
            )
        }
    }
}

struct PPPopover<Item: PopoverItem, Content: View>: View {
    @Binding var selection: Item?
    let canvasSize: CGSize
    let content: (Item) -> Content

    let popoverWidth: CGFloat = 260.0
    let popoverHeight: CGFloat = 200.0
    let edgePadding: CGFloat = 18.0

    @State private var animationProgress: CGFloat = 0
    @State private var dismissingItem: Item?
    @State private var currentItem: Item?

    var body: some View {
        ZStack {
            if let item = currentItem {
                popoverContent(for: item, isDismissing: false)
                    .id(item.id)
            }

            if let dismissing = dismissingItem {
                popoverContent(for: dismissing, isDismissing: true)
                    .id("!\(dismissing.id)")
            }
        }
        .onChange(of: selection) { oldValue, newValue in
            if oldValue != nil, newValue == nil {
                dismiss()
            } else if let oldValue, let newValue, oldValue.id != newValue.id {
                dismissingItem = oldValue
                currentItem = newValue
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    dismissingItem = nil
                }
            } else if let newValue {
                currentItem = newValue
            } else {
                currentItem = nil
            }
        }
        .onAppear {
            if let selected = selection {
                currentItem = selected
            }
        }
    }

    private func popoverContent(for item: Item, isDismissing: Bool) -> some View {
        PopoverContent(
            item: item,
            canvasSize: canvasSize,
            popoverWidth: popoverWidth,
            popoverHeight: popoverHeight,
            edgePadding: edgePadding,
            isDismissing: isDismissing,
            content: content,
            onDismiss: {
                if !isDismissing {
                    dismiss()
                }
            }
        )
    }

    private func dismiss() {
        if let current = currentItem {
            dismissingItem = current
            currentItem = nil
            selection = nil

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                dismissingItem = nil
            }
        }
    }
}

struct PopoverContent<Item: PopoverItem, Content: View>: View {
    let item: Item
    let canvasSize: CGSize
    let popoverWidth: CGFloat
    let popoverHeight: CGFloat
    let edgePadding: CGFloat
    let isDismissing: Bool
    let content: (Item) -> Content
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

                    content(item)
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
        let startPosition = item.position

        return CGPoint(
            x: startPosition.x + (finalPosition.x - startPosition.x) * animationProgress,
            y: startPosition.y + (finalPosition.y - startPosition.y) * animationProgress
        )
    }

    private func calculatePopoverPosition() -> CGPoint {
        let gapFromSquare: CGFloat = 8
        let effectiveHeight = max(popoverHeight, 150)
        let minOffsetX = (item.size / 2) + gapFromSquare + (popoverWidth / 2)
        let minOffsetY = (item.size / 2) + gapFromSquare + (effectiveHeight / 2)

        let spaceRight = canvasSize.width - edgePadding - (item.position.x + minOffsetX + popoverWidth / 2)
        let spaceLeft = (item.position.x - minOffsetX - popoverWidth / 2) - edgePadding
        let spaceBottom = canvasSize.height - edgePadding - (item.position.y + minOffsetY + effectiveHeight / 2)
        let spaceTop = (item.position.y - minOffsetY - effectiveHeight / 2) - edgePadding

        var x: CGFloat
        var y: CGFloat

        let canFitRight = spaceRight >= 0
        let canFitLeft = spaceLeft >= 0
        let canFitBelow = spaceBottom >= 0
        let canFitAbove = spaceTop >= 0

        let nearTopEdge = item.position.y < canvasSize.height * 0.3
        let nearBottomEdge = item.position.y > canvasSize.height * 0.7

        if nearTopEdge && canFitBelow {
            x = item.position.x
            y = item.position.y + minOffsetY
        } else if nearBottomEdge && canFitAbove {
            x = item.position.x
            y = item.position.y - minOffsetY
        } else if canFitRight {
            x = item.position.x + minOffsetX
            y = item.position.y

            if y + effectiveHeight / 2 > canvasSize.height - edgePadding {
                y = canvasSize.height - edgePadding - effectiveHeight / 2
            } else if y - effectiveHeight / 2 < edgePadding {
                y = edgePadding + effectiveHeight / 2
            }
        } else if canFitLeft {
            x = item.position.x - minOffsetX
            y = item.position.y

            if y + effectiveHeight / 2 > canvasSize.height - edgePadding {
                y = canvasSize.height - edgePadding - effectiveHeight / 2
            } else if y - effectiveHeight / 2 < edgePadding {
                y = edgePadding + effectiveHeight / 2
            }
        } else if canFitBelow {
            x = item.position.x
            y = item.position.y + minOffsetY
        } else if canFitAbove {
            x = item.position.x
            y = item.position.y - minOffsetY
        } else {
            x = item.position.x + minOffsetX
            y = item.position.y
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
