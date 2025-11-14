import SwiftUI

struct CardEditorView: View {
    @Binding var card: Card?  // nil = creating new card
    let deckID: UUID

    var onSave: (Card) -> Void
    var onDelete: (Card) -> Void

    @State private var question: String = ""
    @State private var answer: String = ""
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            Form {
                Section("Question") {
                    TextEditor(text: $question)
                        .frame(minHeight: 80, maxHeight: 160)
                }
                Section("Answer") {
                    TextEditor(text: $answer)
                        .frame(minHeight: 80, maxHeight: 160)
                }

                if let existing = card {
                    Section {
                        Button(role: .destructive) {
                            onDelete(existing)
                            dismiss()
                        } label: {
                            Text("Delete Card")
                        }
                    }
                }
            }
            .navigationTitle(card == nil ? "New Card" : "Edit Card")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button(card == nil ? "Create" : "Save") {
                        let newCard = Card(
                            id: card?.id ?? UUID(),
                            question: question.trimmingCharacters(
                                in: .whitespacesAndNewlines
                            ),
                            answer: answer.trimmingCharacters(
                                in: .whitespacesAndNewlines
                            )
                        )
                        onSave(newCard)
                        dismiss()
                    }
                    .disabled(
                        question.trimmingCharacters(in: .whitespacesAndNewlines)
                            .isEmpty
                            || answer.trimmingCharacters(
                                in: .whitespacesAndNewlines
                            ).isEmpty
                    )
                }
            }
            .onAppear {
                if let c = card {
                    question = c.question
                    answer = c.answer
                } else {
                    question = ""
                    answer = ""
                }
            }
        }
    }
}
