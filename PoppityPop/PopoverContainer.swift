//
//  PopoverContainer.swift
//  PoppityPop
//
//  Created by シン・ジャスティン on 2025/11/02.
//

import SwiftUI

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
            .adaptiveGlass(.regular, cornerRadius: 16.0)
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
