//
//  Popover.swift
//  PoppityPop
//
//  Created by シン・ジャスティン on 2025/11/02.
//

import SwiftUI

struct Popover<Item: Identifiable & Equatable, Content: View>: View {
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
