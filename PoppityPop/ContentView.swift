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
    let canvasSize: CGSize = .init(width: 1920, height: 1080)
    @State var squares: [Square] = []
    @State var selectedSquare: Square?
    @State var gradientColors: [Color] = []

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

                    PPPopover(
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

struct PPPopover<Item: Identifiable & Equatable, Content: View>: View {
    @Binding var selection: Item?
    let canvasSize: CGSize
    let itemPosition: (Item) -> CGPoint
    let itemSize: (Item) -> CGFloat
    let content: (Item) -> Content

    let popoverWidth: CGFloat = 260.0
    let popoverHeight: CGFloat = 200.0
    let edgePadding: CGFloat = 18.0

    @State var dismissingItem: Item?
    @State var currentItem: Item?

    var body: some View {
        ZStack {
            if let item = currentItem {
                PopoverContainer(
                    itemPosition: itemPosition(item),
                    itemSize: itemSize(item),
                    canvasSize: canvasSize,
                    popoverWidth: popoverWidth,
                    popoverHeight: popoverHeight,
                    edgePadding: edgePadding,
                    isDismissing: false
                ) {
                    content(item)
                }
                .id(item.id)
            }

            if let dismissing = dismissingItem {
                PopoverContainer(
                    itemPosition: itemPosition(dismissing),
                    itemSize: itemSize(dismissing),
                    canvasSize: canvasSize,
                    popoverWidth: popoverWidth,
                    popoverHeight: popoverHeight,
                    edgePadding: edgePadding,
                    isDismissing: true
                ) {
                    content(dismissing)
                }
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

    func dismiss() {
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

struct PopoverContainer<Content: View>: View {
    let itemPosition: CGPoint
    let itemSize: CGFloat
    let canvasSize: CGSize
    let popoverWidth: CGFloat
    let popoverHeight: CGFloat
    let edgePadding: CGFloat
    let isDismissing: Bool
    let content: () -> Content

    @State var animationProgress: CGFloat = 0

    var body: some View {
        ZStack(alignment: .center) {
            ScrollView {
                content()
                    .padding(.horizontal, 16.0)
                    .padding(.vertical, 8.0)
                    .frame(maxWidth: .infinity, alignment: .leading)
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

    func animatedPosition() -> CGPoint {
        let finalPosition = calculatePopoverPosition()
        let startPosition = itemPosition

        return CGPoint(
            x: startPosition.x + (finalPosition.x - startPosition.x) * animationProgress,
            y: startPosition.y + (finalPosition.y - startPosition.y) * animationProgress
        )
    }

    func calculatePopoverPosition() -> CGPoint {
        let gapFromSquare: CGFloat = 8
        let effectiveHeight = max(popoverHeight, 150)
        let minOffsetX = (itemSize / 2) + gapFromSquare + (popoverWidth / 2)
        let minOffsetY = (itemSize / 2) + gapFromSquare + (effectiveHeight / 2)

        let spaceRight = canvasSize.width - edgePadding - (itemPosition.x + minOffsetX + popoverWidth / 2)
        let spaceLeft = (itemPosition.x - minOffsetX - popoverWidth / 2) - edgePadding
        let spaceBottom = canvasSize.height - edgePadding - (itemPosition.y + minOffsetY + effectiveHeight / 2)
        let spaceTop = (itemPosition.y - minOffsetY - effectiveHeight / 2) - edgePadding

        var x: CGFloat
        var y: CGFloat

        let canFitRight = spaceRight >= 0
        let canFitLeft = spaceLeft >= 0
        let canFitBelow = spaceBottom >= 0
        let canFitAbove = spaceTop >= 0

        let nearTopEdge = itemPosition.y < canvasSize.height * 0.3
        let nearBottomEdge = itemPosition.y > canvasSize.height * 0.7

        if nearTopEdge && canFitBelow {
            x = itemPosition.x
            y = itemPosition.y + minOffsetY
        } else if nearBottomEdge && canFitAbove {
            x = itemPosition.x
            y = itemPosition.y - minOffsetY
        } else if canFitRight {
            x = itemPosition.x + minOffsetX
            y = itemPosition.y

            if y + effectiveHeight / 2 > canvasSize.height - edgePadding {
                y = canvasSize.height - edgePadding - effectiveHeight / 2
            } else if y - effectiveHeight / 2 < edgePadding {
                y = edgePadding + effectiveHeight / 2
            }
        } else if canFitLeft {
            x = itemPosition.x - minOffsetX
            y = itemPosition.y

            if y + effectiveHeight / 2 > canvasSize.height - edgePadding {
                y = canvasSize.height - edgePadding - effectiveHeight / 2
            } else if y - effectiveHeight / 2 < edgePadding {
                y = edgePadding + effectiveHeight / 2
            }
        } else if canFitBelow {
            x = itemPosition.x
            y = itemPosition.y + minOffsetY
        } else if canFitAbove {
            x = itemPosition.x
            y = itemPosition.y - minOffsetY
        } else {
            x = itemPosition.x + minOffsetX
            y = itemPosition.y
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
