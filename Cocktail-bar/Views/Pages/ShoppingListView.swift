//
//  ShoppingListView.swift
//  Cocktail-bar
//
//  Created by Kendall Lewis on 12/30/25.
//

import SwiftUI

struct ShoppingListView: View {
    @Environment(\.colorScheme) var colorScheme
    @StateObject private var shoppingList = ShoppingListManager.shared
    @State private var showingAddItem = false
    @State private var newItemName = ""
    @State private var showingShareSheet = false
    @State private var showingClearConfirmation = false
    @State private var selectedFormat: ExportFormat = .text
    
    var body: some View {
        ZStack {
            LinearGradient(
                gradient: colorScheme == .dark ?
                    Gradient(colors: [LINEAR_BOTTOM, LINEAR_BOTTOM]) :
                    Gradient(colors: [LIGHT_LINEAR_BOTTOM, LIGHT_LINEAR_BOTTOM]),
                startPoint: .topTrailing,
                endPoint: .leading
            )
            .edgesIgnoringSafeArea(.all)
            
            if shoppingList.items.isEmpty {
                EmptyShoppingListView()
            } else {
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 24) {
                        // Header
                        VStack(alignment: .leading, spacing: 12) {
                            HStack(spacing: 12) {
                                Image(systemName: "cart.fill")
                                    .font(.system(size: 32))
                                    .foregroundColor(COLOR_WARM_AMBER)
                                Text("Shopping List")
                                    .font(.cocktailTitle)
                                    .foregroundColor(COLOR_TEXT_PRIMARY)
                            }
                            
                            HStack {
                                Text("\(shoppingList.items.count) item\(shoppingList.items.count == 1 ? "" : "s")")
                                    .font(.bodyText)
                                    .foregroundColor(COLOR_TEXT_SECONDARY)
                                
                                let checkedCount = shoppingList.items.filter { $0.isChecked }.count
                                if checkedCount > 0 {
                                    Text("•")
                                        .foregroundColor(COLOR_TEXT_SECONDARY)
                                    Text("\(checkedCount) checked")
                                        .font(.bodyText)
                                        .foregroundColor(COLOR_WARM_AMBER)
                                }
                            }
                        }
                        .padding(.horizontal)
                        .padding(.top, 20)
                        
                        // Action Buttons
                        HStack(spacing: 12) {
                            Button(action: { showingAddItem = true }) {
                                Label("Add Item", systemImage: "plus.circle.fill")
                                    .font(.bodyText)
                                    .foregroundColor(COLOR_CHARCOAL)
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 10)
                                    .background(COLOR_WARM_AMBER)
                                    .cornerRadius(20)
                            }
                            
                            Button(action: { showingShareSheet = true }) {
                                Label("Share", systemImage: "square.and.arrow.up")
                                    .font(.bodyText)
                                    .foregroundColor(COLOR_TEXT_PRIMARY)
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 10)
                                    .background(COLOR_CHARCOAL)
                                    .cornerRadius(20)
                            }
                            
                            Button(action: { showingClearConfirmation = true }) {
                                Label("Clear", systemImage: "trash")
                                    .font(.bodyText)
                                    .foregroundColor(COLOR_TEXT_PRIMARY)
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 10)
                                    .background(COLOR_CHARCOAL)
                                    .cornerRadius(20)
                            }
                        }
                        .padding(.horizontal)
                        
                        // Grouped Items
                        ForEach(shoppingList.groupedItems(), id: \.category) { group in
                            VStack(alignment: .leading, spacing: 12) {
                                Text(group.category.rawValue)
                                    .font(.sectionHeader)
                                    .foregroundColor(COLOR_WARM_AMBER)
                                    .padding(.horizontal)
                                
                                VStack(spacing: 8) {
                                    ForEach(group.items) { item in
                                        ShoppingListItemRow(item: item)
                                    }
                                }
                                .padding(.horizontal)
                            }
                        }
                        
                        Spacer(minLength: 60)
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
            Button("Clear All", role: .destructive) {
                shoppingList.clearAll()
            }
            Button("Clear Checked Only", role: .destructive) {
                shoppingList.removeCheckedItems()
            }
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("This action cannot be undone.")
        }
    }
}

// MARK: - Shopping List Item Row
struct ShoppingListItemRow: View {
    @StateObject private var shoppingList = ShoppingListManager.shared
    let item: ShoppingListItem
    
    var body: some View {
        HStack(spacing: 16) {
            // Checkbox
            Button(action: {
                shoppingList.toggleChecked(item: item)
            }) {
                Image(systemName: item.isChecked ? "checkmark.circle.fill" : "circle")
                    .font(.system(size: 24))
                    .foregroundColor(item.isChecked ? COLOR_WARM_AMBER : COLOR_TEXT_SECONDARY)
            }
            
            // Content
            VStack(alignment: .leading, spacing: 4) {
                Text(item.ingredient)
                    .font(.bodyText)
                    .foregroundColor(item.isChecked ? COLOR_TEXT_SECONDARY : COLOR_TEXT_PRIMARY)
                    .strikethrough(item.isChecked)
                
                if !item.cocktails.isEmpty {
                    Text("For: \(item.cocktails.prefix(2).joined(separator: ", "))\(item.cocktails.count > 2 ? " +\(item.cocktails.count - 2)" : "")")
                        .font(.ingredientText)
                        .foregroundColor(COLOR_TEXT_SECONDARY)
                }
            }
            
            Spacer()
            
            // Delete button
            Button(action: {
                withAnimation {
                    shoppingList.removeItem(item: item)
                }
            }) {
                Image(systemName: "xmark.circle.fill")
                    .font(.system(size: 20))
                    .foregroundColor(COLOR_TEXT_SECONDARY)
            }
        }
        .padding(16)
        .background(COLOR_CHARCOAL)
        .cornerRadius(12)
    }
}

// MARK: - Empty State
struct EmptyShoppingListView: View {
    @StateObject private var shoppingList = ShoppingListManager.shared
    @State private var showingAddItem = false
    
    var body: some View {
        VStack(spacing: 24) {
            Image(systemName: "cart")
                .font(.system(size: 64))
                .foregroundColor(COLOR_TEXT_SECONDARY)
            
            VStack(spacing: 8) {
                Text("Your Shopping List is Empty")
                    .font(.sectionHeader)
                    .foregroundColor(COLOR_TEXT_PRIMARY)
                
                Text("Add ingredients you need or generate from almost-there cocktails")
                    .font(.bodyText)
                    .foregroundColor(COLOR_TEXT_SECONDARY)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
            }
            
            VStack(spacing: 12) {
                Button(action: {
                    shoppingList.generateFromAlmostThere()
                }) {
                    Text("Generate from Almost There")
                        .font(.bodyText)
                        .fontWeight(.semibold)
                        .foregroundColor(COLOR_CHARCOAL)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(COLOR_WARM_AMBER)
                        .cornerRadius(12)
                }
                
                Button(action: { showingAddItem = true }) {
                    Text("Add Item Manually")
                        .font(.bodyText)
                        .foregroundColor(COLOR_TEXT_PRIMARY)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(COLOR_CHARCOAL)
                        .cornerRadius(12)
                }
            }
            .padding(.horizontal, 40)
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
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        NavigationView {
            ZStack {
                LinearGradient(
                    gradient: colorScheme == .dark ?
                        Gradient(colors: [LINEAR_BOTTOM, LINEAR_BOTTOM]) :
                        Gradient(colors: [LIGHT_LINEAR_BOTTOM, LIGHT_LINEAR_BOTTOM]),
                    startPoint: .topTrailing,
                    endPoint: .leading
                )
                .edgesIgnoringSafeArea(.all)
                
                VStack(spacing: 24) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Ingredient Name")
                            .font(.ingredientText)
                            .foregroundColor(COLOR_TEXT_SECONDARY)
                        
                        TextField("e.g., Lime juice", text: $itemName)
                            .font(.bodyText)
                            .foregroundColor(COLOR_TEXT_PRIMARY)
                            .padding(12)
                            .background(COLOR_CHARCOAL_LIGHT)
                            .cornerRadius(8)
                            .autocapitalization(.words)
                    }
                    .padding(.horizontal)
                    .padding(.top, 40)
                    
                    Button(action: {
                        if !itemName.isEmpty {
                            shoppingList.addItem(ingredient: itemName)
                            isPresented = false
                        }
                    }) {
                        Text("Add to List")
                            .font(.bodyText)
                            .fontWeight(.semibold)
                            .foregroundColor(itemName.isEmpty ? COLOR_TEXT_SECONDARY : COLOR_CHARCOAL)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(itemName.isEmpty ? COLOR_CHARCOAL : COLOR_WARM_AMBER)
                            .cornerRadius(12)
                    }
                    .disabled(itemName.isEmpty)
                    .padding(.horizontal)
                    
                    Spacer()
                }
            }
            .navigationTitle("Add Item")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        isPresented = false
                    }
                    .foregroundColor(COLOR_WARM_AMBER)
                }
            }
        }
    }
}

#Preview {
    ShoppingListView()
}
