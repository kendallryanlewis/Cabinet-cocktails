//
//  ShoppingListView.swift
//  Cocktail-bar
//
//  Created by Kendall Lewis on 12/30/25.
//

import SwiftUI

struct ShoppingListView: View {
    @StateObject private var shoppingList = ShoppingListManager.shared
    @State private var showingAddItem = false
    @State private var newItemName = ""
    @State private var showingShareSheet = false
    @State private var showingClearConfirmation = false
    @State private var selectedFormat: ExportFormat = .text

    var body: some View {
        ZStack {
            COLOR_BACKGROUND.ignoresSafeArea()

            if shoppingList.items.isEmpty {
                VStack(spacing: 0) {
                    fixedHeader
                    Rectangle().fill(Color.white.opacity(0.08)).frame(height: 1)
                    EmptyShoppingListView()
                }
            } else {
                VStack(spacing: 0) {
                    // ── Fixed header ──
                    fixedHeader
                        .background(COLOR_BACKGROUND)

                    Rectangle().fill(Color.white.opacity(0.08)).frame(height: 1)

                    // ── Scrollable content ──
                    ScrollView(showsIndicators: false) {
                        VStack(alignment: .leading, spacing: 28) {
                            ForEach(shoppingList.groupedItems(), id: \.category) { group in
                                VStack(alignment: .leading, spacing: 12) {
                                    Text(group.category.rawValue.uppercased())
                                        .font(.system(size: 11, weight: .semibold))
                                        .foregroundColor(COLOR_TEXT_SECONDARY)
                                        .kerning(1)
                                        .padding(.horizontal, 20)

                                    VStack(spacing: 8) {
                                        ForEach(group.items) { item in
                                            ShoppingListItemRow(item: item)
                                        }
                                    }
                                    .padding(.horizontal, 20)
                                }
                            }

                            Spacer(minLength: 48)
                        }
                        .padding(.top, 24)
                    }
                }
            }
        }
        .sheet(isPresented: $showingAddItem) {
            AddShoppingItemSheet(isPresented: $showingAddItem)
        }
        .sheet(isPresented: $showingShareSheet) {
            ExportFormatSelector(
                contentType: .shoppingList(shoppingList.asShoppingList),
                selectedFormat: $selectedFormat,
                isPresented: $showingShareSheet
            )
        }
        .alert("Clear Shopping List?", isPresented: $showingClearConfirmation) {
            Button("Clear All", role: .destructive) { shoppingList.clearAll() }
            Button("Clear Checked Only", role: .destructive) { shoppingList.removeCheckedItems() }
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("This action cannot be undone.")
        }
    }

    // MARK: - Fixed Header

    private var fixedHeader: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Title row
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("SHOPPING LIST")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(COLOR_TEXT_SECONDARY)
                        .kerning(1)
                    Text("Shopping List")
                        .font(.system(size: 34, weight: .bold))
                        .foregroundColor(COLOR_TEXT_PRIMARY)
                }
                Spacer()
                // Item count badge
                let total = shoppingList.items.count
                let checked = shoppingList.items.filter { $0.isChecked }.count
                VStack(alignment: .trailing, spacing: 2) {
                    Text("\(total) item\(total == 1 ? "" : "s")")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(COLOR_TEXT_PRIMARY)
                    if checked > 0 {
                        Text("\(checked) checked")
                            .font(.system(size: 11))
                            .foregroundColor(COLOR_WARM_AMBER)
                    }
                }
            }

            // Action buttons
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    Button(action: { showingAddItem = true }) {
                        HStack(spacing: 6) {
                            Image(systemName: "plus.circle.fill").font(.system(size: 13, weight: .semibold))
                            Text("Add Item").font(.system(size: 13, weight: .semibold))
                        }
                        .foregroundColor(COLOR_CHARCOAL)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 9)
                        .background(COLOR_WARM_AMBER)
                        .cornerRadius(20)
                    }

                    Button(action: { shoppingList.generateFromAlmostThere() }) {
                        HStack(spacing: 6) {
                            Image(systemName: "wand.and.stars").font(.system(size: 13, weight: .semibold))
                            Text("Add Missing").font(.system(size: 13, weight: .semibold))
                        }
                        .foregroundColor(COLOR_TEXT_PRIMARY)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 9)
                        .background(Color.white.opacity(0.07))
                        .cornerRadius(20)
                    }

                    Button(action: { showingShareSheet = true }) {
                        HStack(spacing: 6) {
                            Image(systemName: "square.and.arrow.up").font(.system(size: 13, weight: .semibold))
                            Text("Share").font(.system(size: 13, weight: .semibold))
                        }
                        .foregroundColor(COLOR_TEXT_PRIMARY)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 9)
                        .background(Color.white.opacity(0.07))
                        .cornerRadius(20)
                    }

                    Button(action: { showingClearConfirmation = true }) {
                        HStack(spacing: 6) {
                            Image(systemName: "trash").font(.system(size: 13, weight: .semibold))
                            Text("Clear").font(.system(size: 13, weight: .semibold))
                        }
                        .foregroundColor(COLOR_TEXT_SECONDARY)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 9)
                        .background(Color.white.opacity(0.07))
                        .cornerRadius(20)
                    }
                }
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 28)
        .padding(.bottom, 16)
    }
}

// MARK: - Shopping List Item Row
struct ShoppingListItemRow: View {
    @StateObject private var shoppingList = ShoppingListManager.shared
    let item: ShoppingListItem

    var body: some View {
        HStack(spacing: 16) {
            // Checkbox
            Button(action: { shoppingList.toggleChecked(item: item) }) {
                Image(systemName: item.isChecked ? "checkmark.circle.fill" : "circle")
                    .font(.system(size: 22))
                    .foregroundColor(item.isChecked ? COLOR_WARM_AMBER : COLOR_TEXT_SECONDARY)
            }

            // Content
            VStack(alignment: .leading, spacing: 4) {
                Text(item.ingredient)
                    .font(.system(size: 15, weight: .medium))
                    .foregroundColor(item.isChecked ? COLOR_TEXT_SECONDARY : COLOR_TEXT_PRIMARY)
                    .strikethrough(item.isChecked)

                if !item.cocktails.isEmpty {
                    Text("For: \(item.cocktails.prefix(2).joined(separator: ", "))\(item.cocktails.count > 2 ? " +\(item.cocktails.count - 2)" : "")")
                        .font(.system(size: 12))
                        .foregroundColor(COLOR_TEXT_SECONDARY)
                }
            }

            Spacer()

            // Delete button
            Button(action: { withAnimation { shoppingList.removeItem(item: item) } }) {
                Image(systemName: "xmark.circle.fill")
                    .font(.system(size: 18))
                    .foregroundColor(COLOR_TEXT_SECONDARY.opacity(0.5))
            }
        }
        .padding(16)
        .background(COLOR_CHARCOAL_LIGHT)
        .cornerRadius(12)
    }
}

// MARK: - Empty State
struct EmptyShoppingListView: View {
    @StateObject private var shoppingList = ShoppingListManager.shared
    @State private var showingAddItem = false

    var body: some View {
        VStack(spacing: 24) {
            Spacer(minLength: 60)

            Image(systemName: "cart")
                .font(.system(size: 48))
                .foregroundColor(COLOR_TEXT_SECONDARY)

            VStack(spacing: 8) {
                Text("Your Shopping List is Empty")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(COLOR_TEXT_PRIMARY)

                Text("Add missing ingredients from almost-there cocktails,\nor add items manually.")
                    .font(.system(size: 14))
                    .foregroundColor(COLOR_TEXT_SECONDARY)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
            }

            VStack(spacing: 12) {
                Button(action: { shoppingList.generateFromAlmostThere() }) {
                    HStack(spacing: 8) {
                        Image(systemName: "wand.and.stars")
                        Text("Add Missing Ingredients")
                    }
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(COLOR_CHARCOAL)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(COLOR_WARM_AMBER)
                    .cornerRadius(14)
                }

                Button(action: { showingAddItem = true }) {
                    Text("Add Item Manually")
                        .font(.system(size: 15, weight: .medium))
                        .foregroundColor(COLOR_TEXT_PRIMARY)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(COLOR_CHARCOAL_LIGHT)
                        .cornerRadius(14)
                }
            }
            .padding(.horizontal, 40)

            Spacer(minLength: 60)
        }
        .sheet(isPresented: $showingAddItem) {
            AddShoppingItemSheet(isPresented: $showingAddItem)
        }
    }
}

// MARK: - Add Item Sheet
struct AddShoppingItemSheet: View {
    @StateObject private var shoppingList = ShoppingListManager.shared
    @Binding var isPresented: Bool
    @State private var itemName = ""

    var body: some View {
        NavigationView {
            ZStack {
                COLOR_CHARCOAL.ignoresSafeArea()

                VStack(spacing: 24) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("INGREDIENT NAME")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundColor(COLOR_TEXT_SECONDARY)
                            .kerning(1)

                        TextField("e.g., Lime juice", text: $itemName)
                            .font(.system(size: 16))
                            .foregroundColor(COLOR_TEXT_PRIMARY)
                            .tint(COLOR_WARM_AMBER)
                            .padding(14)
                            .background(Color.white.opacity(0.07))
                            .cornerRadius(13)
                            .autocapitalization(.words)
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 32)

                    Button(action: {
                        if !itemName.isEmpty {
                            shoppingList.addItem(ingredient: itemName)
                            isPresented = false
                        }
                    }) {
                        Text("Add to List")
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundColor(itemName.isEmpty ? COLOR_TEXT_SECONDARY : COLOR_CHARCOAL)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(itemName.isEmpty ? Color.white.opacity(0.07) : COLOR_WARM_AMBER)
                            .cornerRadius(14)
                    }
                    .disabled(itemName.isEmpty)
                    .padding(.horizontal, 20)

                    Spacer()
                }
            }
            .navigationTitle("Add Item")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(COLOR_CHARCOAL, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
        }
    }
}

#Preview {
    ShoppingListView()
}
