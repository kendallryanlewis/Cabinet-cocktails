//
//  CollectionDetailView.swift
//  Cocktail-bar
//
//  Created on 1/1/26.
//

import SwiftUI

struct CollectionDetailView: View {
    @Environment(\.presentationMode) var presentationMode
    @StateObject private var collectionManager = CollectionManager.shared
    let collection: CocktailCollection
    
    @State private var showEditCollection = false
    @State private var showAddCocktails = false
    @State private var showDeleteAlert = false
    @State private var showShareSheet = false
    @State private var selectedFormat: ExportFormat = .text
    
    var currentCollection: CocktailCollection? {
        collectionManager.collections.first(where: { $0.id == collection.id })
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                LinearGradient(colors: [LINEAR_TOP, LINEAR_BOTTOM], startPoint: .top, endPoint: .bottom)
                    .ignoresSafeArea()
                
                if let collection = currentCollection {
                    ScrollView {
                        VStack(alignment: .leading, spacing: 20) {
                            // Header
                            collectionHeader(collection)
                            
                            // Tags
                            if !collection.tags.isEmpty {
                                tagsSection(collection)
                            }
                            
                            // Cocktails
                            cocktailsSection(collection)
                        }
                        .padding()
                    }
                } else {
                    Text("Collection not found")
                        .foregroundColor(.gray)
                }
            }
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Done") {
                        presentationMode.wrappedValue.dismiss()
                    }
                    .foregroundColor(COLOR_WARM_AMBER)
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    if currentCollection != nil {
                        Menu {
                            Button(action: { showEditCollection = true }) {
                                Label("Edit Collection", systemImage: "pencil")
                            }
                            
                            Button(action: {
                                collectionManager.toggleCollectionFavorite(collection)
                            }) {
                                Label(
                                    collection.isFavorite ? "Remove from Favorites" : "Add to Favorites",
                                    systemImage: collection.isFavorite ? "star.slash" : "star"
                                )
                            }
                            
                            Divider()
                            
                            Button(action: { showShareSheet = true }) {
                                Label("Share Collection", systemImage: "square.and.arrow.up")
                            }
                            
                            Divider()
                            
                            Button(role: .destructive, action: { showDeleteAlert = true }) {
                                Label("Delete Collection", systemImage: "trash")
                            }
                        } label: {
                            Image(systemName: "ellipsis.circle")
                                .foregroundColor(COLOR_WARM_AMBER)
                        }
                    }
                }
            }
            .sheet(isPresented: $showEditCollection) {
                if let collection = currentCollection {
                    EditCollectionView(collection: collection)
                }
            }
            .sheet(isPresented: $showShareSheet) {
                if let collection = currentCollection {
                    let cocktails = (DrinkManager.shared.allDrinks ?? []).filter { drink in
                        collection.cocktails.contains(where: { $0.drinkId == drink.idDrink })
                    }
                    ExportFormatSelector(
                        contentType: .collection(collection, cocktails),
                        selectedFormat: $selectedFormat,
                        isPresented: $showShareSheet
                    )
                }
            }
            .alert("Delete Collection", isPresented: $showDeleteAlert) {
                Button("Cancel", role: .cancel) {}
                Button("Delete", role: .destructive) {
                    collectionManager.deleteCollection(collection)
                    presentationMode.wrappedValue.dismiss()
                }
            } message: {
                Text("Are you sure you want to delete this collection? This action cannot be undone.")
            }
        }
    }
    
    private func collectionHeader(_ collection: CocktailCollection) -> some View {
        VStack(spacing: 16) {
            // Icon and Title
            HStack(spacing: 16) {
                ZStack {
                    Circle()
                        .fill(collection.displayColor.opacity(0.2))
                        .frame(width: 80, height: 80)
                    
                    Image(systemName: collection.iconName)
                        .font(.system(size: 36))
                        .foregroundColor(collection.displayColor)
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text(collection.name)
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                        
                        if collection.isFavorite {
                            Image(systemName: "star.fill")
                                .foregroundColor(COLOR_WARM_AMBER)
                        }
                    }
                    
                    HStack(spacing: 16) {
                        Label("\(collection.cocktailCount) cocktails", systemImage: "wineglass")
                            .font(.caption)
                            .foregroundColor(.gray)
                        
                        Label(formatDate(collection.modifiedDate), systemImage: "calendar")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                }
                
                Spacer()
            }
            
            // Description
            if let description = collection.description, !description.isEmpty {
                Text(description)
                    .font(.body)
                    .foregroundColor(.gray)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .padding()
        .background(COLOR_CHARCOAL_LIGHT)
        .cornerRadius(16)
    }
    
    private func tagsSection(_ collection: CocktailCollection) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Tags")
                .font(.headline)
                .foregroundColor(.white)
            
            FlowLayout(spacing: 8) {
                ForEach(collectionManager.getTags(for: collection)) { tag in
                    HStack(spacing: 6) {
                        Circle()
                            .fill(tag.displayColor)
                            .frame(width: 8, height: 8)
                        
                        Text(tag.name)
                            .font(.caption)
                    }
                    .foregroundColor(.white)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(tag.displayColor.opacity(0.3))
                    .cornerRadius(16)
                }
            }
        }
    }
    
    private func cocktailsSection(_ collection: CocktailCollection) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Cocktails")
                    .font(.headline)
                    .foregroundColor(.white)
                
                Spacer()
                
                Button(action: { showAddCocktails = true }) {
                    HStack(spacing: 4) {
                        Image(systemName: "plus")
                        Text("Add")
                    }
                    .font(.caption)
                    .foregroundColor(COLOR_WARM_AMBER)
                }
            }
            
            if collection.cocktails.isEmpty {
                VStack(spacing: 16) {
                    Image(systemName: "wineglass")
                        .font(.system(size: 50))
                        .foregroundColor(.gray)
                    
                    Text("No cocktails yet")
                        .font(.body)
                        .foregroundColor(.gray)
                    
                    Text("Add cocktails from the Details view or tap the + button above")
                        .font(.caption)
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 40)
            } else {
                LazyVStack(spacing: 12) {
                    ForEach(collection.cocktails) { cocktail in
                        CollectionCocktailRow(
                            cocktail: cocktail,
                            collectionId: collection.id
                        )
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

// MARK: - Collection Cocktail Row
struct CollectionCocktailRow: View {
    let cocktail: CollectionCocktail
    let collectionId: UUID
    @StateObject private var collectionManager = CollectionManager.shared
    @State private var showDeleteAlert = false
    
    var body: some View {
        HStack(spacing: 12) {
            // Thumbnail
            if let thumbURL = cocktail.drinkThumb, let url = URL(string: thumbURL) {
                CachedAsyncImage(url: url) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                } placeholder: {
                    Color.gray
                }
                .frame(width: 60, height: 60)
                .cornerRadius(8)
            } else {
                Image(systemName: "wineglass.fill")
                    .font(.title2)
                    .foregroundColor(.gray)
                    .frame(width: 60, height: 60)
                    .background(COLOR_CHARCOAL)
                    .cornerRadius(8)
            }
            
            // Info
            VStack(alignment: .leading, spacing: 4) {
                Text(cocktail.drinkName)
                    .font(.body)
                    .fontWeight(.medium)
                    .foregroundColor(.white)
                
                if let notes = cocktail.notes, !notes.isEmpty {
                    Text(notes)
                        .font(.caption)
                        .foregroundColor(.gray)
                        .lineLimit(2)
                }
                
                Text("Added \(formatDate(cocktail.addedDate))")
                    .font(.caption2)
                    .foregroundColor(.gray)
            }
            
            Spacer()
            
            Button(action: { showDeleteAlert = true }) {
                Image(systemName: "xmark.circle.fill")
                    .foregroundColor(.gray)
            }
        }
        .padding()
        .background(COLOR_CHARCOAL_LIGHT)
        .cornerRadius(12)
        .alert("Remove Cocktail", isPresented: $showDeleteAlert) {
            Button("Cancel", role: .cancel) {}
            Button("Remove", role: .destructive) {
                collectionManager.removeCocktail(from: collectionId, cocktailId: cocktail.id)
            }
        } message: {
            Text("Remove \(cocktail.drinkName) from this collection?")
        }
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: date, relativeTo: Date())
    }
}

// MARK: - Edit Collection View
struct EditCollectionView: View {
    @Environment(\.presentationMode) var presentationMode
    @StateObject private var collectionManager = CollectionManager.shared
    
    let collection: CocktailCollection
    
    @State private var name: String
    @State private var description: String
    @State private var selectedIcon: String
    @State private var selectedColor: String
    @State private var selectedTags: Set<UUID>
    
    init(collection: CocktailCollection) {
        self.collection = collection
        _name = State(initialValue: collection.name)
        _description = State(initialValue: collection.description ?? "")
        _selectedIcon = State(initialValue: collection.iconName)
        _selectedColor = State(initialValue: collection.colorHex)
        _selectedTags = State(initialValue: Set(collection.tags))
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                COLOR_CHARCOAL.ignoresSafeArea()
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 24) {
                        // Name
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Collection Name")
                                .font(.headline)
                                .foregroundColor(.white)
                            
                            TextField("Collection name", text: $name)
                                .foregroundColor(.white)
                                .padding()
                                .background(COLOR_CHARCOAL_LIGHT)
                                .cornerRadius(12)
                        }
                        
                        // Description
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Description (Optional)")
                                .font(.headline)
                                .foregroundColor(.white)
                            
                            TextField("Add a description...", text: $description)
                                .foregroundColor(.white)
                                .padding()
                                .background(COLOR_CHARCOAL_LIGHT)
                                .cornerRadius(12)
                        }
                        
                        // Icon Selection
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Icon")
                                .font(.headline)
                                .foregroundColor(.white)
                            
                            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 6), spacing: 12) {
                                ForEach(CocktailCollection.collectionIcons, id: \.self) { icon in
                                    Button(action: { selectedIcon = icon }) {
                                        Image(systemName: icon)
                                            .font(.title2)
                                            .foregroundColor(selectedIcon == icon ? Color(hex: selectedColor) : .gray)
                                            .frame(width: 50, height: 50)
                                            .background(selectedIcon == icon ? COLOR_CHARCOAL : COLOR_CHARCOAL_LIGHT)
                                            .cornerRadius(10)
                                    }
                                }
                            }
                        }
                        
                        // Color Selection
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Color")
                                .font(.headline)
                                .foregroundColor(.white)
                            
                            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 6), spacing: 12) {
                                ForEach(Array(CocktailCollection.collectionColors.values), id: \.self) { color in
                                    Button(action: { selectedColor = color }) {
                                        Circle()
                                            .fill(Color(hex: color) ?? .gray)
                                            .frame(width: 40, height: 40)
                                            .overlay(
                                                Circle()
                                                    .stroke(selectedColor == color ? Color.white : Color.clear, lineWidth: 3)
                                            )
                                    }
                                }
                            }
                        }
                        
                        // Tags
                        if !collectionManager.tags.isEmpty {
                            VStack(alignment: .leading, spacing: 12) {
                                Text("Tags (Optional)")
                                    .font(.headline)
                                    .foregroundColor(.white)
                                
                                FlowLayout(spacing: 8) {
                                    ForEach(collectionManager.tags) { tag in
                                        TagChip(
                                            tag: tag,
                                            isSelected: selectedTags.contains(tag.id),
                                            onTap: {
                                                if selectedTags.contains(tag.id) {
                                                    selectedTags.remove(tag.id)
                                                } else {
                                                    selectedTags.insert(tag.id)
                                                }
                                            }
                                        )
                                    }
                                }
                            }
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle("Edit Collection")
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
                        var updated = collection
                        updated.name = name
                        updated.description = description.isEmpty ? nil : description
                        updated.iconName = selectedIcon
                        updated.colorHex = selectedColor
                        updated.tags = Array(selectedTags)
                        
                        collectionManager.updateCollection(updated)
                        presentationMode.wrappedValue.dismiss()
                    }
                    .disabled(name.isEmpty)
                    .foregroundColor(name.isEmpty ? .gray : COLOR_WARM_AMBER)
                }
            }
        }
    }
}
