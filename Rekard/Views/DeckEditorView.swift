import SwiftUI

struct DeckEditorView: View {
    @Binding var deck: Deck?  // nil = creating new deck
    var onSave: (Deck) -> Void
    var onDelete: (Deck) -> Void

    // Local editable state
    @State private var name: String = "=== New Deck ==="
    @State private var icon: String = "book.fill"
    @State private var color: Color = Color(red: 0.85, green: 0.45, blue: 0.45)
    @State private var showIconPicker = false
    @Environment(\.dismiss) private var dismiss

    // SF Symbols sample set (you can expand this array)
    private let icons = [
        "book.fill", "graduationcap.fill", "brain.head.profile",
        "lightbulb.fill",
        "pencil.tip", "square.stack.3d.up.fill", "globe", "music.note.list",
        "wand.and.stars", "leaf.fill", "bolt.fill", "paintbrush.fill",
        "hammer.fill", "folder.fill", "film.fill", "sportscourt",
        "gamecontroller.fill", "terminal.fill", "heart.fill", "star.fill",
    ]

    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                // Live preview
                HStack {
                    Spacer()
                    VStack(spacing: 8) {
                        ZStack {
                            RoundedRectangle(cornerRadius: 18)
                                .fill(
                                    LinearGradient(
                                        colors: [color, color.opacity(0.85)],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .frame(width: 150, height: 110)
                                .shadow(radius: 8)
                                .overlay(
                                    Image(systemName: icon)
                                        .font(
                                            .system(size: 36, weight: .semibold)
                                        )
                                        .foregroundColor(.white)
                                )
                        }
                        Text(name.isEmpty ? "Deck Name" : name)
                            .font(.headline)
                            .foregroundColor(.primary)
                    }
                    Spacer()
                }
                .padding(.top, 8)

                Form {
                    Section("Name") {
                        TextField("Deck name", text: $name)
                    }

                    Section("Icon") {
                        HStack {
                            Image(systemName: icon)
                                .font(.system(size: 22))
                                .frame(width: 36, height: 36)
                            Text(icon)
                                .foregroundColor(.secondary)
                            Spacer()
                            Button {
                                showIconPicker = true
                            } label: {
                                Text("Choose Icon")
                            }
                        }
                    }

                    Section("Color") {
                        ColorPicker(
                            "Pick a color",
                            selection: $color,
                            supportsOpacity: false
                        )
                    }

                    if let existing = deck {
                        Section {
                            Button(role: .destructive) {
                                onDelete(existing)
                                dismiss()
                            } label: {
                                Text("Delete Deck")
                            }
                        }
                    }
                }
            }
            .onAppear {
                if let d = deck {
                    name = d.name
                    icon = d.icon
                    color = d.color.swiftUIColor
                } else {
                    // defaults for new deck
                    name = ""
                    icon = "book.fill"
                    color = Color(red: 0.85, green: 0.45, blue: 0.45)
                }
            }
            .navigationTitle(deck == nil ? "New Deck" : "Edit Deck")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button(deck == nil ? "Create" : "Save") {
                        let colorData = ColorData(color: color)
                        if var d = deck {
                            d.name = name.trimmingCharacters(
                                in: .whitespacesAndNewlines
                            )
                            d.icon = icon
                            d.color = colorData
                            onSave(d)
                        } else {
                            let newDeck = Deck(
                                name: name.trimmingCharacters(
                                    in: .whitespacesAndNewlines
                                ).isEmpty ? "Untitled Deck" : name,
                                icon: icon,
                                color: colorData
                            )
                            onSave(newDeck)
                        }
                        dismiss()
                    }
                    .disabled(
                        name.trimmingCharacters(in: .whitespacesAndNewlines)
                            .isEmpty
                    )
                }
            }
            .sheet(isPresented: $showIconPicker) {
                IconPickerView(selectedIcon: $icon, availableIcons: icons)
            }
        }
    }
}

struct IconPickerView: View {
    @Binding var selectedIcon: String
    let availableIcons: [String]
    @Environment(\.dismiss) private var dismiss

    private let columns = [GridItem(.adaptive(minimum: 64), spacing: 12)]

    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVGrid(columns: columns, spacing: 16) {
                    ForEach(availableIcons, id: \.self) { icon in
                        Button {
                            selectedIcon = icon
                            dismiss()
                        } label: {
                            VStack {
                                ZStack {
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(Color.secondary.opacity(0.08))
                                        .frame(width: 64, height: 64)
                                    Image(systemName: icon)
                                        .font(.system(size: 26))
                                        .foregroundColor(.primary)
                                }
                                Text(icon)
                                    .font(.footnote)
                                    .lineLimit(1)
                                    .truncationMode(.tail)
                            }
                        }
                    }
                }
                .padding()
            }
            .navigationTitle("Choose Icon")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") { dismiss() }
                }
            }
        }
    }
}
