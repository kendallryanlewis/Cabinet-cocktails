//
//  EducationalContentView.swift
//  Cocktail-bar
//
//  Created by Kendall Lewis on 1/2/26.
//

import SwiftUI

struct EducationalContentView: View {
    @StateObject private var contentManager = EducationalContentManager.shared
    @State private var selectedCategory: BartendingTip.TipCategory?
    @State private var selectedTab = 0
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Tab Selector
                Picker("Content Type", selection: $selectedTab) {
                    Text("Tips").tag(0)
                    Text("Ingredients").tag(1)
                    Text("Stories").tag(2)
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding()
                
                // Content
                TabView(selection: $selectedTab) {
                    TipsListView(selectedCategory: $selectedCategory)
                        .tag(0)
                    
                    IngredientGuidesView()
                        .tag(1)
                    
                    CocktailStoriesView()
                        .tag(2)
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
            }
            .navigationTitle("Learn Bartending")
            .navigationBarTitleDisplayMode(.large)
        }
    }
}

// MARK: - Tips List View
struct TipsListView: View {
    @StateObject private var contentManager = EducationalContentManager.shared
    @Binding var selectedCategory: BartendingTip.TipCategory?
    
    var filteredTips: [BartendingTip] {
        if let category = selectedCategory {
            return contentManager.getTipsForCategory(category)
        }
        return contentManager.tips
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Category Filter
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    CategoryChip(title: "All", isSelected: selectedCategory == nil) {
                        selectedCategory = nil
                    }
                    
                    ForEach(BartendingTip.TipCategory.allCases, id: \.self) { category in
                        CategoryChip(title: category.rawValue, isSelected: selectedCategory == category) {
                            selectedCategory = category
                        }
                    }
                }
                .padding()
            }
            
            // Tips List
            ScrollView {
                LazyVStack(spacing: 16) {
                    ForEach(filteredTips) { tip in
                        NavigationLink(destination: TipDetailView(tip: tip)) {
                            TipCard(tip: tip)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
                .padding()
            }
        }
    }
}

// MARK: - Tip Card
struct TipCard: View {
    let tip: BartendingTip
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: difficultyIcon(tip.difficulty))
                    .foregroundColor(difficultyColor(tip.difficulty))
                
                Text(tip.title)
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .foregroundColor(.gray)
                    .font(.system(size: 12))
            }
            
            Text(tip.description)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .lineLimit(2)
            
            HStack {
                Text(tip.category.rawValue)
                    .font(.caption)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.blue.opacity(0.1))
                    .foregroundColor(.blue)
                    .cornerRadius(4)
                
                Spacer()
                
                Text(tip.difficulty.rawValue)
                    .font(.caption)
                    .foregroundColor(difficultyColor(tip.difficulty))
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
    }
    
    func difficultyIcon(_ difficulty: DifficultyLevel) -> String {
        switch difficulty {
        case .beginner: return "star.fill"
        case .intermediate: return "star.leadinghalf.filled"
        case .advanced: return "sparkles"
        case .expert: return "crown.fill"
        }
    }
    
    func difficultyColor(_ difficulty: DifficultyLevel) -> Color {
        return Color(hex: difficulty.color)
    }
}

// MARK: - Tip Detail View
struct TipDetailView: View {
    let tip: BartendingTip
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Header
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Image(systemName: difficultyIcon(tip.difficulty))
                            .font(.title)
                            .foregroundColor(difficultyColor(tip.difficulty))
                        
                        Text(tip.difficulty.rawValue)
                            .font(.headline)
                            .foregroundColor(difficultyColor(tip.difficulty))
                        
                        Spacer()
                        
                        Text(tip.category.rawValue)
                            .font(.subheadline)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(Color.blue.opacity(0.1))
                            .foregroundColor(.blue)
                            .cornerRadius(8)
                    }
                    
                    Text(tip.title)
                        .font(.title2)
                        .fontWeight(.bold)
                }
                .padding()
                .background(Color(.secondarySystemBackground))
                .cornerRadius(12)
                
                // Description
                VStack(alignment: .leading, spacing: 12) {
                    Text("Description")
                        .font(.headline)
                    
                    Text(tip.description)
                        .font(.body)
                        .foregroundColor(.secondary)
                }
                .padding()
                .background(Color(.systemBackground))
                .cornerRadius(12)
            }
            .padding()
        }
        .navigationTitle("Bartending Tip")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    func difficultyIcon(_ difficulty: DifficultyLevel) -> String {
        switch difficulty {
        case .beginner: return "star.fill"
        case .intermediate: return "star.leadinghalf.filled"
        case .advanced: return "sparkles"
        case .expert: return "crown.fill"
        }
    }
    
    func difficultyColor(_ difficulty: DifficultyLevel) -> Color {
        return Color(hex: difficulty.color)
    }
}

// MARK: - Category Chip
struct CategoryChip: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.subheadline)
                .fontWeight(isSelected ? .semibold : .regular)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(isSelected ? Color.blue : Color(.systemGray5))
                .foregroundColor(isSelected ? .white : .primary)
                .cornerRadius(20)
        }
    }
}

// MARK: - Ingredient Guides View
struct IngredientGuidesView: View {
    @StateObject private var contentManager = EducationalContentManager.shared
    
    var body: some View {
        ScrollView {
            LazyVStack(spacing: 16) {
                ForEach(contentManager.guides) { guide in
                    NavigationLink(destination: IngredientGuideDetailView(guide: guide)) {
                        IngredientGuideCard(guide: guide)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
            .padding()
        }
    }
}

// MARK: - Ingredient Guide Card
struct IngredientGuideCard: View {
    let guide: IngredientGuide
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(guide.name)
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .foregroundColor(.gray)
                    .font(.system(size: 12))
            }
            
            Text(guide.description)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .lineLimit(2)
            
            Text(guide.type)
                .font(.caption)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(Color.green.opacity(0.1))
                .foregroundColor(.green)
                .cornerRadius(4)
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
    }
}

// MARK: - Ingredient Guide Detail View
struct IngredientGuideDetailView: View {
    let guide: IngredientGuide
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Header
                VStack(alignment: .leading, spacing: 8) {
                    Text(guide.name)
                        .font(.title)
                        .fontWeight(.bold)
                    
                    Text(guide.type)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color(.secondarySystemBackground))
                .cornerRadius(12)
                
                // Description
                InfoSection(title: "About", content: guide.description)
                
                // Flavor Profile
                InfoSection(title: "Flavor Profile", content: guide.flavor)
                
                // Common Uses
                InfoSection(title: "Common Uses", content: guide.uses.joined(separator: ", "))
                
                // Substitutes
                InfoSection(title: "Substitutes", content: guide.substitutes.joined(separator: ", "))
                
                // Storage
                InfoSection(title: "Storage Tips", content: guide.storage)
            }
            .padding()
        }
        .navigationTitle("Ingredient Guide")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - Info Section
struct InfoSection: View {
    let title: String
    let content: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.headline)
            
            Text(content)
                .font(.body)
                .foregroundColor(.secondary)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.systemBackground))
        .cornerRadius(12)
    }
}

// MARK: - Cocktail Stories View
struct CocktailStoriesView: View {
    @StateObject private var contentManager = EducationalContentManager.shared
    
    var body: some View {
        ScrollView {
            LazyVStack(spacing: 16) {
                ForEach(contentManager.stories) { story in
                    NavigationLink(destination: CocktailStoryDetailView(story: story)) {
                        CocktailStoryCard(story: story)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
            .padding()
        }
    }
}

// MARK: - Cocktail Story Card
struct CocktailStoryCard: View {
    let story: CocktailStory
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(story.cocktailName)
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Spacer()
                
                Text(story.year)
                    .font(.caption)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.purple.opacity(0.1))
                    .foregroundColor(.purple)
                    .cornerRadius(4)
                
                Image(systemName: "chevron.right")
                    .foregroundColor(.gray)
                    .font(.system(size: 12))
            }
            
            Text(story.origin)
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            Text(story.story)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .lineLimit(3)
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
    }
}

// MARK: - Cocktail Story Detail View
struct CocktailStoryDetailView: View {
    let story: CocktailStory
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Header
                VStack(alignment: .leading, spacing: 8) {
                    Text(story.cocktailName)
                        .font(.title)
                        .fontWeight(.bold)
                    
                    HStack {
                        Text(story.origin)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        
                        Text("•")
                            .foregroundColor(.secondary)
                        
                        Text(story.year)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color(.secondarySystemBackground))
                .cornerRadius(12)
                
                // Story
                VStack(alignment: .leading, spacing: 12) {
                    Text("The Story")
                        .font(.headline)
                    
                    Text(story.story)
                        .font(.body)
                        .foregroundColor(.secondary)
                }
                .padding()
                .background(Color(.systemBackground))
                .cornerRadius(12)
                
                // Fun Facts
                if !story.funFacts.isEmpty {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Fun Facts")
                            .font(.headline)
                        
                        ForEach(Array(story.funFacts.enumerated()), id: \.offset) { index, fact in
                            HStack(alignment: .top, spacing: 8) {
                                Text("•")
                                    .foregroundColor(.blue)
                                Text(fact)
                                    .font(.body)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                    .padding()
                    .background(Color(.systemBackground))
                    .cornerRadius(12)
                }
            }
            .padding()
        }
        .navigationTitle("Story")
        .navigationBarTitleDisplayMode(.inline)
    }
}
