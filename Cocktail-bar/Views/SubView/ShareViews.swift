//
//  ShareViews.swift
//  Cocktail-bar
//
//  Created by Kendall Lewis on 1/1/26.
//

import SwiftUI
import UIKit

// MARK: - Share Sheet Wrapper
struct ShareSheet: UIViewControllerRepresentable {
    let items: [Any]
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        let controller = UIActivityViewController(activityItems: items, applicationActivities: nil)
        return controller
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

// MARK: - Export Format Selector
struct ExportFormatSelector: View {
    let contentType: ShareContentType
    @Binding var selectedFormat: ExportFormat
    @Binding var isPresented: Bool
    @State private var showShareSheet = false
    @State private var shareItems: [Any] = []
    
    var availableFormats: [ExportFormat] {
        switch contentType {
        case .cocktailRecipe:
            return [.text, .pdf, .image, .json]
        case .collection:
            return [.text, .json]
        case .shoppingList:
            return [.text, .pdf]
        case .multipleRecipes:
            return [.text]
        }
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                COLOR_CHARCOAL.ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Header
                    VStack(spacing: 8) {
                        Image(systemName: "square.and.arrow.up")
                            .font(.displayLarge)
                            .foregroundColor(COLOR_WARM_AMBER)
                        
                        Text("Choose Export Format")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(COLOR_TEXT_PRIMARY)
                        
                        Text("Select how you'd like to share")
                            .font(.subheadline)
                            .foregroundColor(COLOR_TEXT_SECONDARY)
                    }
                    .padding(.top, 30)
                    .padding(.bottom, 40)
                    
                    // Format Options
                    ScrollView {
                        VStack(spacing: 12) {
                            ForEach(availableFormats, id: \.self) { format in
                                FormatOptionButton(
                                    format: format,
                                    isSelected: selectedFormat == format,
                                    action: {
                                        selectedFormat = format
                                        prepareShare(format: format)
                                    }
                                )
                            }
                        }
                        .padding(.horizontal, 20)
                    }
                    
                    Spacer()
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        isPresented = false
                    }
                    .foregroundColor(COLOR_TEXT_SECONDARY)
                }
            }
        }
        .sheet(isPresented: $showShareSheet) {
            ShareSheet(items: shareItems)
        }
    }
    
    private func prepareShare(format: ExportFormat) {
        let items = ShareManager.shared.createShareItems(for: contentType, format: format)
        if !items.isEmpty {
            shareItems = items
            showShareSheet = true
            
            // Delay dismissal to allow share sheet to present
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                isPresented = false
            }
        }
    }
}

// MARK: - Format Option Button
struct FormatOptionButton: View {
    let format: ExportFormat
    let isSelected: Bool
    let action: () -> Void
    
    var description: String {
        switch format {
        case .text:
            return "Plain text format, compatible with any app"
        case .pdf:
            return "Professional PDF document"
        case .image:
            return "Shareable image for social media"
        case .json:
            return "Structured data format for developers"
        }
    }
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                // Icon
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(isSelected ? COLOR_WARM_AMBER.opacity(0.2) : COLOR_CHARCOAL_LIGHT)
                        .frame(width: 56, height: 56)
                    
                    Image(systemName: format.icon)
                        .font(.iconMini)
                        .foregroundColor(isSelected ? COLOR_WARM_AMBER : COLOR_TEXT_SECONDARY)
                }
                
                // Text
                VStack(alignment: .leading, spacing: 4) {
                    Text(format.rawValue)
                        .font(.headline)
                        .foregroundColor(COLOR_TEXT_PRIMARY)
                    
                    Text(description)
                        .font(.caption)
                        .foregroundColor(COLOR_TEXT_SECONDARY)
                        .lineLimit(2)
                }
                
                Spacer()
                
                // Checkmark
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.iconMini)
                        .foregroundColor(COLOR_WARM_AMBER)
                }
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(COLOR_CHARCOAL_LIGHT)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(isSelected ? COLOR_WARM_AMBER : Color.clear, lineWidth: 2)
                    )
            )
        }
    }
}

// MARK: - Quick Share Button (for toolbars)
struct QuickShareButton: View {
    let contentType: ShareContentType
    @State private var showFormatSelector = false
    @State private var selectedFormat: ExportFormat = .text
    
    var body: some View {
        Button(action: {
            showFormatSelector = true
        }) {
            Image(systemName: "square.and.arrow.up")
                .font(.bodyLarge)
                .foregroundColor(COLOR_WARM_AMBER)
        }
        .sheet(isPresented: $showFormatSelector) {
            ExportFormatSelector(
                contentType: contentType,
                selectedFormat: $selectedFormat,
                isPresented: $showFormatSelector
            )
        }
    }
}

// MARK: - Share Success Toast
struct ShareSuccessToast: View {
    let message: String
    @Binding var isPresented: Bool
    
    var body: some View {
        VStack {
            Spacer()
            
            HStack(spacing: 12) {
                Image(systemName: "checkmark.circle.fill")
                    .font(.navTitle)
                    .foregroundColor(.green)
                
                Text(message)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(COLOR_TEXT_PRIMARY)
                
                Spacer()
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(COLOR_CHARCOAL_LIGHT)
                    .shadow(color: .black.opacity(0.3), radius: 10, x: 0, y: 5)
            )
            .padding(.horizontal, 20)
            .padding(.bottom, 20)
        }
        .transition(.move(edge: .bottom).combined(with: .opacity))
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                withAnimation {
                    isPresented = false
                }
            }
        }
    }
}

// MARK: - Batch Share View (for multiple cocktails)
struct BatchShareView: View {
    let cocktails: [DrinkDetails]
    @Binding var isPresented: Bool
    @State private var selectedCocktails: Set<String> = []
    @State private var showFormatSelector = false
    @State private var selectedFormat: ExportFormat = .text
    
    var body: some View {
        NavigationView {
            ZStack {
                COLOR_CHARCOAL.ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Header
                    VStack(spacing: 8) {
                        Image(systemName: "square.and.arrow.up.on.square")
                            .font(.displayLarge)
                            .foregroundColor(COLOR_WARM_AMBER)
                        
                        Text("Share Multiple Recipes")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(COLOR_TEXT_PRIMARY)
                        
                        Text("Select cocktails to share together")
                            .font(.subheadline)
                            .foregroundColor(COLOR_TEXT_SECONDARY)
                    }
                    .padding(.top, 24)
                    .padding(.bottom, 30)
                    
                    // Selection Controls
                    HStack {
                        Button(action: {
                            selectedCocktails = Set(cocktails.map { $0.idDrink })
                        }) {
                            Text("Select All")
                                .font(.subheadline)
                                .foregroundColor(COLOR_WARM_AMBER)
                        }
                        
                        Spacer()
                        
                        Text("\(selectedCocktails.count) selected")
                            .font(.subheadline)
                            .foregroundColor(COLOR_TEXT_SECONDARY)
                        
                        Spacer()
                        
                        Button(action: {
                            selectedCocktails.removeAll()
                        }) {
                            Text("Clear")
                                .font(.subheadline)
                                .foregroundColor(COLOR_TEXT_SECONDARY)
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 16)
                    
                    // Cocktail List
                    ScrollView {
                        VStack(spacing: 12) {
                            ForEach(cocktails, id: \.idDrink) { cocktail in
                                CocktailSelectRow(
                                    cocktail: cocktail,
                                    isSelected: selectedCocktails.contains(cocktail.idDrink),
                                    onToggle: {
                                        if selectedCocktails.contains(cocktail.idDrink) {
                                            selectedCocktails.remove(cocktail.idDrink)
                                        } else {
                                            selectedCocktails.insert(cocktail.idDrink)
                                        }
                                    }
                                )
                            }
                        }
                        .padding(.horizontal, 20)
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        isPresented = false
                    }
                    .foregroundColor(COLOR_TEXT_SECONDARY)
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Share") {
                        showFormatSelector = true
                    }
                    .foregroundColor(COLOR_WARM_AMBER)
                    .fontWeight(.semibold)
                    .disabled(selectedCocktails.isEmpty)
                }
            }
        }
        .sheet(isPresented: $showFormatSelector) {
            let selectedItems = cocktails.filter { selectedCocktails.contains($0.idDrink) }
            ExportFormatSelector(
                contentType: .multipleRecipes(selectedItems),
                selectedFormat: $selectedFormat,
                isPresented: $showFormatSelector
            )
        }
    }
}

// MARK: - Cocktail Select Row
struct CocktailSelectRow: View {
    let cocktail: DrinkDetails
    let isSelected: Bool
    let onToggle: () -> Void
    
    var body: some View {
        Button(action: onToggle) {
            HStack(spacing: 12) {
                // Selection Indicator
                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .font(.iconMini)
                    .foregroundColor(isSelected ? COLOR_WARM_AMBER : COLOR_TEXT_SECONDARY)
                
                // Cocktail Info
                VStack(alignment: .leading, spacing: 4) {
                    Text(cocktail.strDrink)
                        .font(.headline)
                        .foregroundColor(COLOR_TEXT_PRIMARY)
                    
                    if let category = cocktail.strCategory {
                        Text(category)
                            .font(.caption)
                            .foregroundColor(COLOR_TEXT_SECONDARY)
                    }
                }
                
                Spacer()
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isSelected ? COLOR_WARM_AMBER.opacity(0.1) : COLOR_CHARCOAL_LIGHT)
            )
        }
    }
}
