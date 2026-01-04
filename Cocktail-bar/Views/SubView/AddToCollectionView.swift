//
//  AddToCollectionView.swift
//  Cocktail-bar
//
//  Created on 1/1/26.
//

import SwiftUI

struct AddToCollectionView: View {
    @Environment(\.presentationMode) var presentationMode
    @StateObject private var collectionManager = CollectionManager.shared
    
    let drinkId: String
    let drinkName: String
    let drinkThumb: String?
    
    @State private var selectedCollections: Set<UUID> = []
    @State private var showCreateCollection = false
    @State private var notes = ""
    
    var body: some View {
        NavigationView {
            ZStack {
                COLOR_CHARCOAL.ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Cocktail Info
                    cocktailInfoSection
                    
                    Divider()
                        .background(Color.gray.opacity(0.3))
                        .padding(.vertical, 8)
                    
                    if collectionManager.collections.isEmpty {
                        emptyStateView
                    } else {
                        collectionsList
                    }
                }
            }
            .navigationTitle("Add to Collection")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        presentationMode.wrappedValue.dismiss()
                    }
                    .foregroundColor(COLOR_WARM_AMBER)
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Add") {
                        addToSelectedCollections()
                        presentationMode.wrappedValue.dismiss()
                    }
                    .disabled(selectedCollections.isEmpty)
                    .foregroundColor(selectedCollections.isEmpty ? .gray : COLOR_WARM_AMBER)
                }
            }
            .onAppear {
                loadExistingCollections()
            }
            .sheet(isPresented: $showCreateCollection) {
                CreateCollectionView()
            }
        }
    }
    
    private var cocktailInfoSection: some View {
        HStack(spacing: 12) {
            if let thumbURL = drinkThumb, let url = URL(string: thumbURL) {
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
                    .background(COLOR_CHARCOAL_LIGHT)
                    .cornerRadius(8)
            }
            
            Text(drinkName)
                .font(.headline)
                .foregroundColor(.white)
            
            Spacer()
        }
        .padding()
        .background(COLOR_CHARCOAL_LIGHT)
    }
    
    private var collectionsList: some View {
        ScrollView {
            VStack(spacing: 12) {
                // Create New Collection Button
                Button(action: { showCreateCollection = true }) {
                    HStack {
                        Image(systemName: "plus.circle.fill")
                            .foregroundColor(COLOR_WARM_AMBER)
                        
                        Text("Create New Collection")
                            .fontWeight(.medium)
                            .foregroundColor(.white)
                        
                        Spacer()
                    }
                    .padding()
                    .background(COLOR_CHARCOAL_LIGHT)
                    .cornerRadius(12)
                }
                .padding(.horizontal, 20)
                
                // Existing Collections
                ForEach(collectionManager.collections) { collection in
                    CollectionSelectRow(
                        collection: collection,
                        isSelected: selectedCollections.contains(collection.id),
                        alreadyContains: collectionManager.isCocktailInCollection(drinkId, collectionId: collection.id),
                        onToggle: {
                            if selectedCollections.contains(collection.id) {
                                selectedCollections.remove(collection.id)
                            } else {
                                selectedCollections.insert(collection.id)
                            }
                        }
                    )
                }
            }
            .padding()
        }
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 20) {
            Image(systemName: "folder.badge.plus")
                .font(.iconLarge)
                .foregroundColor(.gray)
            
            Text("No Collections")
                .font(.title3)
                .fontWeight(.semibold)
                .foregroundColor(.white)
            
            Text("Create a collection to organize your cocktails")
                .font(.body)
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
            
            Button(action: { showCreateCollection = true }) {
                Text("Create Collection")
                    .fontWeight(.semibold)
                    .foregroundColor(COLOR_CHARCOAL)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 12)
                    .background(COLOR_WARM_AMBER)
                    .cornerRadius(12)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private func loadExistingCollections() {
        // Pre-select collections that already contain this cocktail
        selectedCollections = Set(
            collectionManager.getCollectionsContaining(drinkId: drinkId).map { $0.id }
        )
    }
    
    private func addToSelectedCollections() {
        for collectionId in selectedCollections {
            collectionManager.addCocktail(
                to: collectionId,
                drinkId: drinkId,
                drinkName: drinkName,
                drinkThumb: drinkThumb,
                notes: notes.isEmpty ? nil : notes
            )
        }
    }
}

// MARK: - Collection Select Row
struct CollectionSelectRow: View {
    let collection: CocktailCollection
    let isSelected: Bool
    let alreadyContains: Bool
    let onToggle: () -> Void
    
    var body: some View {
        Button(action: {
            if !alreadyContains {
                onToggle()
            }
        }) {
            HStack(spacing: 12) {
                // Selection Indicator
                Image(systemName: alreadyContains ? "checkmark.circle.fill" : (isSelected ? "checkmark.circle.fill" : "circle"))
                    .foregroundColor(alreadyContains ? .green : (isSelected ? COLOR_WARM_AMBER : .gray))
                    .font(.title3)
                
                // Icon
                ZStack {
                    Circle()
                        .fill(collection.displayColor.opacity(0.2))
                        .frame(width: 40, height: 40)
                    
                    Image(systemName: collection.iconName)
                        .font(.body)
                        .foregroundColor(collection.displayColor)
                }
                
                // Info
                VStack(alignment: .leading, spacing: 4) {
                    Text(collection.name)
                        .font(.body)
                        .fontWeight(.medium)
                        .foregroundColor(.white)
                    
                    HStack(spacing: 8) {
                        Label("\(collection.cocktailCount)", systemImage: "wineglass")
                            .font(.caption)
                            .foregroundColor(.gray)
                        
                        if alreadyContains {
                            Text("• Already added")
                                .font(.caption)
                                .foregroundColor(.green)
                        }
                    }
                }
                
                Spacer()
            }
            .padding()
            .background(COLOR_CHARCOAL_LIGHT)
            .cornerRadius(12)
            .opacity(alreadyContains ? 0.6 : 1.0)
        }
        .disabled(alreadyContains)
    }
}
