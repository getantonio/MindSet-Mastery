import SwiftUI

struct EmptyStateModifier<EmptyContent: View>: ViewModifier {
    let isEmpty: Bool
    let emptyContent: () -> EmptyContent
    
    func body(content: Content) -> some View {
        if isEmpty {
            emptyContent()
        } else {
            content
        }
    }
}

extension View {
    func emptyState<EmptyContent: View>(
        _ isEmpty: Bool,
        @ViewBuilder content: @escaping () -> EmptyContent
    ) -> some View {
        modifier(EmptyStateModifier(isEmpty: isEmpty, emptyContent: content))
    }
} 