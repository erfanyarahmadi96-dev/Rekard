import SwiftUI

struct SwipeableCardStack<Item: Identifiable, Card: View>: View {
    let items: [Item]
    @Binding var index: Int
    let card: (Item) -> Card
    var onSwiped: ((Item) -> Void)?

    // Tuning
    private let stackSpacing: CGFloat = -12
    private let maxVisibleCards: Int = 3
    private let swipeThreshold: CGFloat = 120
    private let rotationAngle: Double = 8

    @GestureState private var dragOffset: CGSize = .zero

    var body: some View {
        ZStack {
            ForEach(visibleIndices(), id: \.self) { i in
                let item = items[i]
                card(item)
                    .frame(maxWidth: .infinity)
                    .scaleEffect(scale(for: i))
                    .offset(y: offsetY(for: i))
                    .overlay(overlay(for: i))
                    .rotationEffect(.degrees(rotation(for: i)))
                    .offset(x: xOffset(for: i))
                    .zIndex(zIndex(for: i))
                    .animation(.spring(response: 0.35, dampingFraction: 0.85), value: dragOffset)
                    .animation(.spring(response: 0.35, dampingFraction: 0.85), value: index)
            }
        }
        .contentShape(Rectangle())
        .gesture(dragGesture())
        .accessibilityElement(children: .contain)
    }

    private func visibleIndices() -> [Int] {
        guard !items.isEmpty else { return [] }
        let start = min(index, items.count - 1)
        let end = min(start + maxVisibleCards - 1, items.count - 1)
        return Array(start...end).reversed()
    }

    private func scale(for i: Int) -> CGFloat {
        let pos = i - index
        if pos <= 0 { return 1.0 }
        return 1.0 - CGFloat(pos) * 0.06
    }

    private func offsetY(for i: Int) -> CGFloat {
        let pos = i - index
        return CGFloat(pos) * 16
    }

    private func rotation(for i: Int) -> Double {
        guard i == index else { return 0 }
        let progress = max(-1, min(1, dragOffset.width / 200))
        return Double(progress) * rotationAngle
    }

    private func xOffset(for i: Int) -> CGFloat {
        guard i == index else { return 0 }
        return dragOffset.width
    }

    private func zIndex(for i: Int) -> Double {
        // Top card highest zIndex
        return Double(items.count - i)
    }

    private func overlay(for i: Int) -> some View {
        Group {
            if i == index && dragOffset != .zero {
                let goingRight = dragOffset.width > 0
                RoundedRectangle(cornerRadius: 25)
                    .strokeBorder(goingRight ? Color.green.opacity(0.4) : Color.red.opacity(0.4), lineWidth: 3)
                    .padding(2)
            }
        }
    }

    private func dragGesture() -> some Gesture {
        DragGesture()
            .updating($dragOffset) { value, state, _ in
                state = value.translation
            }
            .onEnded { value in
                let dx = value.translation.width
                if abs(dx) > swipeThreshold {
                    swipeTopCard(direction: dx > 0 ? 1 : -1)
                }
            }
    }

    private func swipeTopCard(direction: Int) {
        guard index < items.count else { return }
        let item = items[index]
        // Advance to next card
        index = min(index + 1, items.count)
        onSwiped?(item)
    }
}

extension SwipeableCardStack {
    init(items: [Item], onSwiped: ((Item) -> Void)? = nil, @ViewBuilder card: @escaping (Item) -> Card) {
        self.items = items
        self._index = .constant(0)
        self.card = card
        self.onSwiped = onSwiped
    }
}

struct SwipeableCardStack_Previews: PreviewProvider {
    struct DemoItem: Identifiable { let id = UUID(); let title: String }
    static var previews: some View {
        StatefulPreviewWrapper(0) { idx in
            SwipeableCardStack(items: [DemoItem(title: "One"), DemoItem(title: "Two"), DemoItem(title: "Three")], index: idx) { item in
                RoundedRectangle(cornerRadius: 25).fill(.white).overlay(Text(item.title).font(.title))
                    .frame(width: 300, height: 200)
            }
        }.padding()
        .background(LinearGradient(colors: [.blue.opacity(0.2), .purple.opacity(0.2)], startPoint: .top, endPoint: .bottom))
    }
}

// Helper for binding in previews
struct StatefulPreviewWrapper<Value, Content: View>: View {
    @State var value: Value
    var content: (Binding<Value>) -> Content
    init(_ value: Value, content: @escaping (Binding<Value>) -> Content) {
        _value = State(initialValue: value)
        self.content = content
    }
    var body: some View { content($value) }
}
