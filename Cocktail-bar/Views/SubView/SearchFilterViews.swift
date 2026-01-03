//
//  SearchFilterViews.swift
//  Cocktail-bar
//
//  Created on 1/1/26.
//

import SwiftUI

// MARK: - Filter Options View
struct FilterOptionsView: View {
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject var filterManager: SearchFilterManager
    @Binding var filter: SearchFilter
    
    let availableCategories: [String]
    let availableGlasses: [String]
    let availableAlcoholicTypes: [String]
    let availableIngredients: [String]
    
    var body: some View {
        NavigationView {
            ZStack {
                COLOR_CHARCOAL.ignoresSafeArea()
                
                List {
                    // Category Section
                    if !availableCategories.isEmpty {
                        Section {
                            ForEach(availableCategories, id: \.self) { category in
                                FilterCheckRow(
                                    title: category,
                                    isSelected: filter.categories.contains(category),
                                    onToggle: {
                                        toggleSelection(in: &filter.categories, item: category)
                                    }
                                )
                            }
                        } header: {
                            Text("Category")
                                .foregroundColor(COLOR_WARM_AMBER)
                        }
                        .listRowBackground(COLOR_CHARCOAL_LIGHT)
                    }
                    
                    // Glass Type Section
                    if !availableGlasses.isEmpty {
                        Section {
                            ForEach(availableGlasses, id: \.self) { glass in
                                FilterCheckRow(
                                    title: glass,
                                    isSelected: filter.glassTypes.contains(glass),
                                    onToggle: {
                                        toggleSelection(in: &filter.glassTypes, item: glass)
                                    }
                                )
                            }
                        } header: {
                            Text("Glass Type")
                                .foregroundColor(COLOR_WARM_AMBER)
                        }
                        .listRowBackground(COLOR_CHARCOAL_LIGHT)
                    }
                    
                    // Alcoholic Type Section
                    if !availableAlcoholicTypes.isEmpty {
                        Section {
                            ForEach(availableAlcoholicTypes, id: \.self) { type in
                                FilterCheckRow(
                                    title: type,
                                    isSelected: filter.alcoholicTypes.contains(type),
                                    onToggle: {
                                        toggleSelection(in: &filter.alcoholicTypes, item: type)
                                    }
                                )
                            }
                        } header: {
                            Text("Type")
                                .foregroundColor(COLOR_WARM_AMBER)
                        }
                        .listRowBackground(COLOR_CHARCOAL_LIGHT)
                    }
                }
                .scrollContentBackground(.hidden)
            }
            .navigationTitle("Filters")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Clear") {
                        filter.clear()
                    }
                    .foregroundColor(filter.isActive ? COLOR_WARM_AMBER : .gray)
                    .disabled(!filter.isActive)
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Apply") {
                        filterManager.applyFilter(filter)
                        presentationMode.wrappedValue.dismiss()
                    }
                    .foregroundColor(COLOR_WARM_AMBER)
                }
            }
        }
    }
    
    private func toggleSelection<T: Hashable>(in set: inout Set<T>, item: T) {
        if set.contains(item) {
            set.remove(item)
        } else {
            set.insert(item)
        }
    }
}

// MARK: - Filter Check Row
struct FilterCheckRow: View {
    let title: String
    let isSelected: Bool
    let onToggle: () -> Void
    
    var body: some View {
        Button(action: onToggle) {
            HStack {
                Text(title)
                    .foregroundColor(.white)
                
                Spacer()
                
                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .foregroundColor(isSelected ? COLOR_WARM_AMBER : .gray)
            }
        }
    }
}

// MARK: - Sort Options View
struct SortOptionsView: View {
    @Environment(\.presentationMode) var presentationMode
    @Binding var selectedSort: SortOption
    
    var body: some View {
        NavigationView {
            ZStack {
                COLOR_CHARCOAL.ignoresSafeArea()
                
                List {
                    ForEach(SortOption.allCases, id: \.self) { option in
                        Button(action: {
                            selectedSort = option
                            presentationMode.wrappedValue.dismiss()
                        }) {
                            HStack {
                                Image(systemName: option.icon)
                                    .foregroundColor(COLOR_WARM_AMBER)
                                    .frame(width: 24)
                                
                                Text(option.rawValue)
                                    .foregroundColor(.white)
                                
                                Spacer()
                                
                                if selectedSort == option {
                                    Image(systemName: "checkmark")
                                        .foregroundColor(COLOR_WARM_AMBER)
                                }
                            }
                        }
                        .listRowBackground(COLOR_CHARCOAL_LIGHT)
                    }
                }
                .scrollContentBackground(.hidden)
            }
            .navigationTitle("Sort By")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        presentationMode.wrappedValue.dismiss()
                    }
                    .foregroundColor(COLOR_WARM_AMBER)
                }
            }
        }
    }
}

// MARK: - Search History View
struct SearchHistoryView: View {
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject var filterManager: SearchFilterManager
    let onSelectHistory: (String) -> Void
    
    var body: some View {
        NavigationView {
            ZStack {
                COLOR_CHARCOAL.ignoresSafeArea()
                
                if filterManager.searchHistory.isEmpty {
                    VStack(spacing: 16) {
                        Image(systemName: "clock.arrow.circlepath")
                            .font(.system(size: 60))
                            .foregroundColor(.gray)
                        
                        Text("No Search History")
                            .font(.title3)
                            .foregroundColor(.white)
                        
                        Text("Your recent searches will appear here")
                            .font(.body)
                            .foregroundColor(.gray)
                    }
                } else {
                    List {
                        ForEach(filterManager.searchHistory) { item in
                            Button(action: {
                                onSelectHistory(item.query)
                                presentationMode.wrappedValue.dismiss()
                            }) {
                                HStack {
                                    Image(systemName: "clock")
                                        .foregroundColor(.gray)
                                    
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(item.query)
                                            .foregroundColor(.white)
                                        
                                        Text("\(item.resultCount) result\(item.resultCount == 1 ? "" : "s") • \(formatDate(item.timestamp))")
                                            .font(.caption)
                                            .foregroundColor(.gray)
                                    }
                                    
                                    Spacer()
                                }
                            }
                            .listRowBackground(COLOR_CHARCOAL_LIGHT)
                            .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                                Button(role: .destructive) {
                                    filterManager.removeFromHistory(item)
                                } label: {
                                    Label("Delete", systemImage: "trash")
                                }
                            }
                        }
                    }
                    .scrollContentBackground(.hidden)
                }
            }
            .navigationTitle("Search History")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Done") {
                        presentationMode.wrappedValue.dismiss()
                    }
                    .foregroundColor(COLOR_WARM_AMBER)
                }
                
                if !filterManager.searchHistory.isEmpty {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button(role: .destructive) {
                            filterManager.clearHistory()
                        } label: {
                            Text("Clear All")
                        }
                        .foregroundColor(.red)
                    }
                }
            }
        }
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: date, relativeTo: Date())
    }
}

// MARK: - Saved Searches View
struct SavedSearchesView: View {
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject var filterManager: SearchFilterManager
    let onSelectSearch: (SavedSearch) -> Void
    
    @State private var showingSaveSheet = false
    
    var body: some View {
        NavigationView {
            ZStack {
                COLOR_CHARCOAL.ignoresSafeArea()
                
                if filterManager.savedSearches.isEmpty {
                    VStack(spacing: 16) {
                        Image(systemName: "bookmark")
                            .font(.system(size: 60))
                            .foregroundColor(.gray)
                        
                        Text("No Saved Searches")
                            .font(.title3)
                            .foregroundColor(.white)
                        
                        Text("Save your favorite search combinations for quick access")
                            .font(.body)
                            .foregroundColor(.gray)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 40)
                    }
                } else {
                    List {
                        ForEach(filterManager.savedSearches) { search in
                            Button(action: {
                                filterManager.markSavedSearchAsUsed(search.id)
                                onSelectSearch(search)
                                presentationMode.wrappedValue.dismiss()
                            }) {
                                VStack(alignment: .leading, spacing: 8) {
                                    HStack {
                                        Image(systemName: "bookmark.fill")
                                            .foregroundColor(COLOR_WARM_AMBER)
                                        
                                        Text(search.name)
                                            .font(.headline)
                                            .foregroundColor(.white)
                                    }
                                    
                                    if !search.query.isEmpty {
                                        Text("Query: \(search.query)")
                                            .font(.caption)
                                            .foregroundColor(.gray)
                                    }
                                    
                                    if search.filter.isActive {
                                        Text("\(search.filter.activeCount) filter\(search.filter.activeCount == 1 ? "" : "s") applied")
                                            .font(.caption)
                                            .foregroundColor(COLOR_WARM_AMBER)
                                    }
                                    
                                    Text("Last used \(formatDate(search.lastUsedDate))")
                                        .font(.caption2)
                                        .foregroundColor(.gray)
                                }
                                .padding(.vertical, 4)
                            }
                            .listRowBackground(COLOR_CHARCOAL_LIGHT)
                            .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                                Button(role: .destructive) {
                                    filterManager.deleteSavedSearch(search)
                                } label: {
                                    Label("Delete", systemImage: "trash")
                                }
                            }
                        }
                    }
                    .scrollContentBackground(.hidden)
                }
            }
            .navigationTitle("Saved Searches")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Done") {
                        presentationMode.wrappedValue.dismiss()
                    }
                    .foregroundColor(COLOR_WARM_AMBER)
                }
            }
        }
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: date, relativeTo: Date())
    }
}

// MARK: - Save Search Sheet
struct SaveSearchSheet: View {
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject var filterManager: SearchFilterManager
    
    let query: String
    let filter: SearchFilter
    
    @State private var searchName = ""
    
    var body: some View {
        NavigationView {
            ZStack {
                COLOR_CHARCOAL.ignoresSafeArea()
                
                VStack(alignment: .leading, spacing: 24) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Search Name")
                            .font(.headline)
                            .foregroundColor(.white)
                        
                        TextField("e.g., Whiskey Cocktails", text: $searchName)
                            .foregroundColor(.white)
                            .padding()
                            .background(COLOR_CHARCOAL_LIGHT)
                            .cornerRadius(12)
                    }
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Search Details")
                            .font(.headline)
                            .foregroundColor(.white)
                        
                        VStack(alignment: .leading, spacing: 12) {
                            if !query.isEmpty {
                                HStack {
                                    Text("Query:")
                                        .foregroundColor(.gray)
                                    Text(query)
                                        .foregroundColor(.white)
                                }
                                .font(.body)
                            }
                            
                            if filter.isActive {
                                HStack {
                                    Text("Filters:")
                                        .foregroundColor(.gray)
                                    Text("\(filter.activeCount) active")
                                        .foregroundColor(COLOR_WARM_AMBER)
                                }
                                .font(.body)
                            }
                        }
                        .padding()
                        .background(COLOR_CHARCOAL_LIGHT)
                        .cornerRadius(12)
                    }
                    
                    Spacer()
                }
                .padding()
            }
            .navigationTitle("Save Search")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        presentationMode.wrappedValue.dismiss()
                    }
                    .foregroundColor(COLOR_WARM_AMBER)
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        filterManager.saveSearch(name: searchName, query: query, filter: filter)
                        presentationMode.wrappedValue.dismiss()
                    }
                    .disabled(searchName.isEmpty)
                    .foregroundColor(searchName.isEmpty ? .gray : COLOR_WARM_AMBER)
                }
            }
        }
    }
}
