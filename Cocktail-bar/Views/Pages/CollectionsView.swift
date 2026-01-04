//
//  CollectionsView.swift
//  Cocktail-bar
//
//  Created on 1/1/26.
//

import SwiftUI

// MARK: - Collections View
struct CollectionsView: View {
    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject var premiumManager: PremiumManager
    @StateObject private var collectionManager = CollectionManager.shared
    @State private var showCreateCollection = false
    @State private var showTagManager = false
    @State private var searchText = ""
    @State private var selectedFilter: FilterOption = .all
    @State private var selectedCollection: CocktailCollection?
    @State private var showCollectionDetail = false
    @State private var showPaywall = false
    
    enum FilterOption: String, CaseIterable {
        case all = "All"
        case favorites = "Favorites"
        case recent = "Recent"
    }
    
    var filteredCollections: [CocktailCollection] {
        var result = collectionManager.collections
        
        // Apply filter
        switch selectedFilter {
        case .all:
            result = collectionManager.collections
        case .favorites:
            result = collectionManager.getFavoriteCollections()
        case .recent:
            result = collectionManager.getRecentCollections(limit: 10)
        }
        
        // Apply search
        if !searchText.isEmpty {
            result = result.filter { collection in
                collection.name.lowercased().contains(searchText.lowercased()) ||
                collection.description?.lowercased().contains(searchText.lowercased()) == true
            }
        }
        
        return result.sorted { $0.modifiedDate > $1.modifiedDate }
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                AppBackground()
                
                VStack(spacing: 0) {
                    // Search Bar
                    SearchBarView(text: $searchText, placeholder: "Search collections...")
                        .padding()
                    
                    // Filter Tabs
                    filterTabs
                    
                    if filteredCollections.isEmpty {
                        emptyStateView
                    } else {
                        collectionsList
                    }
                }
            }
            .navigationTitle("Collections")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu {
                        Button(action: {
                            if premiumManager.canCreateCollection(currentCount: collectionManager.collections.count) {
                                showCreateCollection = true
                            } else {
                                showPaywall = true
                            }
                        }) {
                            Label("New Collection", systemImage: "folder.badge.plus")
                        }
                        
                        Button(action: { showTagManager = true }) {
                            Label("Manage Tags", systemImage: "tag")
                        }
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .foregroundColor(COLOR_WARM_AMBER)
                            .font(.title3)
                    }
                }
            }
            .sheet(isPresented: $showCreateCollection) {
                CreateCollectionView()
            }
            .sheet(isPresented: $showTagManager) {
                TagManagerView()
            }
            .sheet(item: $selectedCollection) { collection in
                CollectionDetailView(collection: collection)
            }
            .sheet(isPresented: $showPaywall) {
                PaywallView(feature: .unlimitedCollections, source: "collections")
                    .environmentObject(premiumManager)
            }
        }
    }
    
    private var filterTabs: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(FilterOption.allCases, id: \.self) { option in
                    FilterButton(
                        title: option.rawValue,
                        isSelected: selectedFilter == option,
                        action: { selectedFilter = option }
                    )
                }
            }
            .padding(.horizontal, 20)
        }
        .padding(.bottom, 8)
    }
    
    private var collectionsList: some View {
        ScrollView {
            LazyVStack(spacing: 16) {
                ForEach(filteredCollections) { collection in
                    CollectionCard(collection: collection)
                        .onTapGesture {
                            selectedCollection = collection
                            showCollectionDetail = true
                        }
                }
            }
            .padding()
        }
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 20) {
            Image(systemName: "folder.badge.plus")
                .font(.system(size: 70, design: .rounded))
                .foregroundColor(COLOR_WARM_AMBER.opacity(0.5))
            
            Text(searchText.isEmpty ? "No Collections Yet" : "No Results")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.white)
            
            Text(searchText.isEmpty ?
                 "Create collections to organize your favorite cocktails" :
                 "Try a different search term")
                .font(.body)
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
            
            if searchText.isEmpty {
                Button(action: { showCreateCollection = true }) {
                    Text("Create Collection")
                        .fontWeight(.semibold)
                        .foregroundColor(COLOR_CHARCOAL)
                        .padding(.horizontal, 24)
                        .padding(.vertical, 12)
                        .background(COLOR_WARM_AMBER)
                        .cornerRadius(12)
                }
                .padding(.top, 8)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

// MARK: - Collection Card
struct CollectionCard: View {
    let collection: CocktailCollection
    @StateObject private var collectionManager = CollectionManager.shared
    
    var body: some View {
        HStack(spacing: 16) {
            // Icon
            ZStack {
                Circle()
                    .fill(collection.displayColor.opacity(0.2))
                    .frame(width: 60, height: 60)
                
                Image(systemName: collection.iconName)
                    .font(.title2)
                    .foregroundColor(collection.displayColor)
            }
            
            // Info
            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Text(collection.name)
                        .font(.headline)
                        .foregroundColor(.white)
                    
                    if collection.isFavorite {
                        Image(systemName: "star.fill")
                            .font(.caption)
                            .foregroundColor(COLOR_WARM_AMBER)
                    }
                }
                
                if let description = collection.description, !description.isEmpty {
                    Text(description)
                        .font(.caption)
                        .foregroundColor(.gray)
                        .lineLimit(1)
                }
                
                HStack(spacing: 12) {
                    Label("\(collection.cocktailCount)", systemImage: "wineglass")
                        .font(.caption)
                        .foregroundColor(.gray)
                    
                    if !collection.tags.isEmpty {
                        Label("\(collection.tags.count) tags", systemImage: "tag")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                }
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .foregroundColor(.gray)
                .font(.caption)
        }
        .padding()
        .background(COLOR_CHARCOAL_LIGHT)
        .cornerRadius(12)
    }
}

// MARK: - Filter Button
struct FilterButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.subheadline)
                .fontWeight(isSelected ? .semibold : .regular)
                .foregroundColor(isSelected ? COLOR_CHARCOAL : .gray)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(isSelected ? COLOR_WARM_AMBER : COLOR_CHARCOAL_LIGHT)
                .cornerRadius(20)
        }
    }
}

// MARK: - Search Bar View
struct SearchBarView: View {
    @Binding var text: String
    let placeholder: String
    
    var body: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.gray)
            
            TextField(placeholder, text: $text)
                .foregroundColor(.white)
            
            if !text.isEmpty {
                Button(action: { text = "" }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.gray)
                }
            }
        }
        .padding(12)
        .background(COLOR_CHARCOAL_LIGHT)
        .cornerRadius(12)
    }
}

// MARK: - Create Collection View
struct CreateCollectionView: View {
    @Environment(\.presentationMode) var presentationMode
    @StateObject private var collectionManager = CollectionManager.shared
    
    @State private var name = ""
    @State private var description = ""
    @State private var selectedIcon = "folder.fill"
    @State private var selectedColor = "#D4A574"
    @State private var selectedTags: Set<UUID> = []
    
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
                            
                            TextField("e.g., Date Night Drinks", text: $name)
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
            .navigationTitle("New Collection")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        presentationMode.wrappedValue.dismiss()
                    }
                    .foregroundColor(COLOR_WARM_AMBER)
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Create") {
                        collectionManager.createCollection(
                            name: name,
                            description: description.isEmpty ? nil : description,
                            iconName: selectedIcon,
                            colorHex: selectedColor,
                            tags: Array(selectedTags)
                        )
                        presentationMode.wrappedValue.dismiss()
                    }
                    .disabled(name.isEmpty)
                    .foregroundColor(name.isEmpty ? .gray : COLOR_WARM_AMBER)
                }
            }
        }
    }
}

// MARK: - Tag Chip
struct TagChip: View {
    let tag: CocktailTag
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 6) {
                Circle()
                    .fill(tag.displayColor)
                    .frame(width: 8, height: 8)
                
                Text(tag.name)
                    .font(.caption)
                    .fontWeight(isSelected ? .semibold : .regular)
            }
            .foregroundColor(isSelected ? .white : .gray)
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(isSelected ? tag.displayColor.opacity(0.3) : COLOR_CHARCOAL_LIGHT)
            .cornerRadius(16)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(isSelected ? tag.displayColor : Color.clear, lineWidth: 1)
            )
        }
    }
}

// MARK: - Flow Layout
struct FlowLayout: Layout {
    var spacing: CGFloat = 8
    
    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let result = FlowResult(
            in: proposal.replacingUnspecifiedDimensions().width,
            subviews: subviews,
            spacing: spacing
        )
        return result.size
    }
    
    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let result = FlowResult(
            in: bounds.width,
            subviews: subviews,
            spacing: spacing
        )
        for (index, subview) in subviews.enumerated() {
            subview.place(at: CGPoint(x: bounds.minX + result.positions[index].x, y: bounds.minY + result.positions[index].y), proposal: .unspecified)
        }
    }
    
    struct FlowResult {
        var size: CGSize = .zero
        var positions: [CGPoint] = []
        
        init(in maxWidth: CGFloat, subviews: Subviews, spacing: CGFloat) {
            var x: CGFloat = 0
            var y: CGFloat = 0
            var lineHeight: CGFloat = 0
            
            for subview in subviews {
                let size = subview.sizeThatFits(.unspecified)
                
                if x + size.width > maxWidth && x > 0 {
                    x = 0
                    y += lineHeight + spacing
                    lineHeight = 0
                }
                
                positions.append(CGPoint(x: x, y: y))
                lineHeight = max(lineHeight, size.height)
                x += size.width + spacing
            }
            
            self.size = CGSize(width: maxWidth, height: y + lineHeight)
        }
    }
}

// MARK: - Tag Manager View
struct TagManagerView: View {
    @Environment(\.presentationMode) var presentationMode
    @StateObject private var collectionManager = CollectionManager.shared
    @State private var showCreateTag = false
    @State private var newTagName = ""
    @State private var newTagColor = "#D4A574"
    
    var body: some View {
        NavigationView {
            ZStack {
                COLOR_CHARCOAL.ignoresSafeArea()
                
                VStack {
                    if collectionManager.tags.isEmpty {
                        VStack(spacing: 16) {
                            Image(systemName: "tag")
                                .font(.iconLarge)
                                .foregroundColor(.gray)
                            
                            Text("No Tags Yet")
                                .font(.title3)
                                .foregroundColor(.white)
                            
                            Text("Create tags to organize your collections")
                                .font(.body)
                                .foregroundColor(.gray)
                        }
                    } else {
                        List {
                            ForEach(collectionManager.tags) { tag in
                                HStack {
                                    Circle()
                                        .fill(tag.displayColor)
                                        .frame(width: 24, height: 24)
                                    
                                    Text(tag.name)
                                        .foregroundColor(.white)
                                    
                                    Spacer()
                                }
                                .listRowBackground(COLOR_CHARCOAL_LIGHT)
                            }
                            .onDelete(perform: deleteTags)
                        }
                        .scrollContentBackground(.hidden)
                    }
                }
            }
            .navigationTitle("Manage Tags")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Done") {
                        presentationMode.wrappedValue.dismiss()
                    }
                    .foregroundColor(COLOR_WARM_AMBER)
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showCreateTag = true }) {
                        Image(systemName: "plus.circle.fill")
                            .foregroundColor(COLOR_WARM_AMBER)
                    }
                }
            }
            .sheet(isPresented: $showCreateTag) {
                CreateTagView()
            }
        }
    }
    
    private func deleteTags(at offsets: IndexSet) {
        for index in offsets {
            let tag = collectionManager.tags[index]
            collectionManager.deleteTag(tag)
        }
    }
}

// MARK: - Create Tag View
struct CreateTagView: View {
    @Environment(\.presentationMode) var presentationMode
    @StateObject private var collectionManager = CollectionManager.shared
    
    @State private var name = ""
    @State private var selectedColor = "#D4A574"
    
    var body: some View {
        NavigationView {
            ZStack {
                COLOR_CHARCOAL.ignoresSafeArea()
                
                VStack(alignment: .leading, spacing: 24) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Tag Name")
                            .font(.headline)
                            .foregroundColor(.white)
                        
                        TextField("e.g., Summer", text: $name)
                            .foregroundColor(.white)
                            .padding()
                            .background(COLOR_CHARCOAL_LIGHT)
                            .cornerRadius(12)
                    }
                    
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Color")
                            .font(.headline)
                            .foregroundColor(.white)
                        
                        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 6), spacing: 12) {
                            ForEach(Array(CocktailTag.tagColors.values), id: \.self) { color in
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
                    
                    Spacer()
                }
                .padding()
            }
            .navigationTitle("New Tag")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        presentationMode.wrappedValue.dismiss()
                    }
                    .foregroundColor(COLOR_WARM_AMBER)
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Create") {
                        collectionManager.createTag(name: name, color: selectedColor)
                        presentationMode.wrappedValue.dismiss()
                    }
                    .disabled(name.isEmpty)
                    .foregroundColor(name.isEmpty ? .gray : COLOR_WARM_AMBER)
                }
            }
        }
    }
}
