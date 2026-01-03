//
//  ShareManager.swift
//  Cocktail-bar
//
//  Created by Kendall Lewis on 1/1/26.
//

import SwiftUI
import UIKit

// MARK: - Share Content Types
enum ShareContentType {
    case cocktailRecipe(DrinkDetails)
    case collection(CocktailCollection, [DrinkDetails])
    case shoppingList(ShoppingList)
    case multipleRecipes([DrinkDetails])
}

// MARK: - Export Format
enum ExportFormat: String, CaseIterable {
    case text = "Text"
    case pdf = "PDF"
    case image = "Image"
    case json = "JSON"
    
    var icon: String {
        switch self {
        case .text: return "doc.text"
        case .pdf: return "doc.richtext"
        case .image: return "photo"
        case .json: return "curlybraces"
        }
    }
    
    var fileExtension: String {
        switch self {
        case .text: return "txt"
        case .pdf: return "pdf"
        case .image: return "png"
        case .json: return "json"
        }
    }
}

// MARK: - Share Manager
@MainActor
class ShareManager: ObservableObject {
    static let shared = ShareManager()
    
    private init() {}
    
    // MARK: - Text Export
    
    func exportCocktailAsText(_ cocktail: DrinkDetails) -> String {
        var text = ""
        
        // Title
        text += "🍸 \(cocktail.strDrink)\n"
        text += String(repeating: "=", count: cocktail.strDrink.count + 3) + "\n\n"
        
        // Basic Info
        if let category = cocktail.strCategory {
            text += "Category: \(category)\n"
        }
        if let glass = cocktail.strGlass {
            text += "Glass: \(glass)\n"
        }
        text += "Type: \(cocktail.strAlcoholic)\n"
        text += "\n"
        
        // Ingredients
        text += "INGREDIENTS:\n"
        text += String(repeating: "-", count: 12) + "\n"
        let ingredients = cocktail.getIngredients()
        for i in 0..<ingredients.count {
            let ingredient = ingredients[i]
            let measure = getMeasure(for: cocktail, at: i)
            if !measure.isEmpty {
                text += "• \(measure) \(ingredient)\n"
            } else {
                text += "• \(ingredient)\n"
            }
        }
        text += "\n"
        
        // Instructions
        if let instructions = cocktail.strInstructions {
            text += "INSTRUCTIONS:\n"
            text += String(repeating: "-", count: 13) + "\n"
            text += instructions + "\n"
        }
        
        text += "\n---\n"
        text += "Shared from Cabinet Cocktails\n"
        
        return text
    }
    
    func exportCollectionAsText(_ collection: CocktailCollection, cocktails: [DrinkDetails]) -> String {
        var text = ""
        
        // Collection Header
        text += "📚 \(collection.name)\n"
        text += String(repeating: "=", count: collection.name.count + 3) + "\n\n"
        
        if let description = collection.description, !description.isEmpty {
            text += "\(description)\n\n"
        }
        
        text += "\(cocktails.count) Cocktails\n"
        text += "Created: \(formatDate(collection.createdDate))\n\n"
        text += String(repeating: "=", count: 40) + "\n\n"
        
        // List all cocktails
        for (index, cocktail) in cocktails.enumerated() {
            text += "\(index + 1). \(cocktail.strDrink)\n"
            if let category = cocktail.strCategory {
                text += "   Category: \(category)\n"
            }
            text += "\n"
        }
        
        text += "---\n"
        text += "Shared from Cabinet Cocktails\n"
        
        return text
    }
    
    func exportShoppingListAsText(_ shoppingList: ShoppingList) -> String {
        var text = ""
        
        text += "🛒 Shopping List\n"
        text += String(repeating: "=", count: 15) + "\n\n"
        
        text += "Created: \(formatDate(shoppingList.createdDate))\n"
        text += "Last Updated: \(formatDate(shoppingList.lastUpdated))\n\n"
        
        let uncheckedItems = shoppingList.items.filter { !$0.isChecked }
        let checkedItems = shoppingList.items.filter { $0.isChecked }
        
        if !uncheckedItems.isEmpty {
            text += "TO BUY (\(uncheckedItems.count)):\n"
            text += String(repeating: "-", count: 10) + "\n"
            for item in uncheckedItems.sorted(by: { $0.ingredient < $1.ingredient }) {
                text += "☐ \(item.ingredient)"
                if !item.cocktails.isEmpty {
                    text += " (for \(item.cocktails.joined(separator: ", ")))" 
                }
                text += "\n"
            }
            text += "\n"
        }
        
        if !checkedItems.isEmpty {
            text += "PURCHASED (\(checkedItems.count)):\n"
            text += String(repeating: "-", count: 15) + "\n"
            for item in checkedItems.sorted(by: { $0.ingredient < $1.ingredient }) {
                text += "☑ \(item.ingredient)"
                text += "\n"
            }
            text += "\n"
        }
        
        text += "---\n"
        text += "Shared from Cabinet Cocktails\n"
        
        return text
    }
    
    // MARK: - JSON Export
    
    func exportCocktailAsJSON(_ cocktail: DrinkDetails) -> String? {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        
        guard let data = try? encoder.encode(cocktail),
              let jsonString = String(data: data, encoding: .utf8) else {
            return nil
        }
        
        return jsonString
    }
    
    func exportCollectionAsJSON(_ collection: CocktailCollection, cocktails: [DrinkDetails]) -> String? {
        let exportData: [String: Any] = [
            "collection": [
                "id": collection.id.uuidString,
                "name": collection.name,
                "description": collection.description,
                "colorHex": collection.colorHex,
                "createdDate": ISO8601DateFormatter().string(from: collection.createdDate),
                "cocktailCount": cocktails.count
            ],
            "cocktails": cocktails.map { cocktail in
                return [
                    "id": cocktail.idDrink,
                    "name": cocktail.strDrink,
                    "category": cocktail.strCategory ?? "",
                    "glass": cocktail.strGlass ?? "",
                    "alcoholic": cocktail.strAlcoholic ?? "",
                    "ingredients": cocktail.getIngredients()
                ]
            }
        ]
        
        guard let data = try? JSONSerialization.data(withJSONObject: exportData, options: [.prettyPrinted, .sortedKeys]),
              let jsonString = String(data: data, encoding: .utf8) else {
            return nil
        }
        
        return jsonString
    }
    
    // MARK: - PDF Export
    
    func exportCocktailAsPDF(_ cocktail: DrinkDetails) -> URL? {
        let pageRect = CGRect(x: 0, y: 0, width: 612, height: 792) // US Letter
        let renderer = UIGraphicsPDFRenderer(bounds: pageRect)
        
        let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent("\(cocktail.strDrink).pdf")
        
        do {
            try renderer.writePDF(to: tempURL) { context in
                context.beginPage()
                
                var yPosition: CGFloat = 40
                let leftMargin: CGFloat = 40
                let rightMargin: CGFloat = pageRect.width - 40
                let contentWidth = rightMargin - leftMargin
                
                // Title
                let titleFont = UIFont.boldSystemFont(ofSize: 28)
                let titleAttributes: [NSAttributedString.Key: Any] = [
                    .font: titleFont,
                    .foregroundColor: UIColor(COLOR_WARM_AMBER)
                ]
                let titleString = "🍸 \(cocktail.strDrink)"
                titleString.draw(at: CGPoint(x: leftMargin, y: yPosition), withAttributes: titleAttributes)
                yPosition += 45
                
                // Basic Info
                let infoFont = UIFont.systemFont(ofSize: 12)
                let infoAttributes: [NSAttributedString.Key: Any] = [
                    .font: infoFont,
                    .foregroundColor: UIColor.darkGray
                ]
                
                var infoLines: [String] = []
                if let category = cocktail.strCategory { infoLines.append("Category: \(category)") }
                if let glass = cocktail.strGlass { infoLines.append("Glass: \(glass)") }
                infoLines.append("Type: \(cocktail.strAlcoholic)")
                
                for line in infoLines {
                    line.draw(at: CGPoint(x: leftMargin, y: yPosition), withAttributes: infoAttributes)
                    yPosition += 18
                }
                yPosition += 20
                
                // Ingredients Section
                let sectionFont = UIFont.boldSystemFont(ofSize: 18)
                let sectionAttributes: [NSAttributedString.Key: Any] = [
                    .font: sectionFont,
                    .foregroundColor: UIColor.black
                ]
                "INGREDIENTS".draw(at: CGPoint(x: leftMargin, y: yPosition), withAttributes: sectionAttributes)
                yPosition += 30
                
                let ingredientFont = UIFont.systemFont(ofSize: 14)
                let ingredientAttributes: [NSAttributedString.Key: Any] = [
                    .font: ingredientFont,
                    .foregroundColor: UIColor.black
                ]
                
                let ingredients = cocktail.getIngredients()
                for i in 0..<ingredients.count {
                    let ingredient = ingredients[i]
                    let measure = getMeasure(for: cocktail, at: i)
                    let text = measure.isEmpty ? "• \(ingredient)" : "• \(measure) \(ingredient)"
                    text.draw(at: CGPoint(x: leftMargin + 10, y: yPosition), withAttributes: ingredientAttributes)
                    yPosition += 22
                }
                yPosition += 20
                
                // Instructions Section
                if let instructions = cocktail.strInstructions {
                    "INSTRUCTIONS".draw(at: CGPoint(x: leftMargin, y: yPosition), withAttributes: sectionAttributes)
                    yPosition += 30
                    
                    let paragraphStyle = NSMutableParagraphStyle()
                    paragraphStyle.lineSpacing = 4
                    let instructionAttributes: [NSAttributedString.Key: Any] = [
                        .font: ingredientFont,
                        .foregroundColor: UIColor.black,
                        .paragraphStyle: paragraphStyle
                    ]
                    
                    let instructionRect = CGRect(x: leftMargin, y: yPosition, width: contentWidth, height: pageRect.height - yPosition - 60)
                    instructions.draw(in: instructionRect, withAttributes: instructionAttributes)
                }
                
                // Footer
                let footerFont = UIFont.systemFont(ofSize: 10)
                let footerAttributes: [NSAttributedString.Key: Any] = [
                    .font: footerFont,
                    .foregroundColor: UIColor.gray
                ]
                let footerText = "Shared from Cabinet Cocktails"
                footerText.draw(at: CGPoint(x: leftMargin, y: pageRect.height - 40), withAttributes: footerAttributes)
            }
            
            return tempURL
        } catch {
            print("Error creating PDF: \(error)")
            return nil
        }
    }
    
    func exportShoppingListAsPDF(_ shoppingList: ShoppingList) -> URL? {
        let pageRect = CGRect(x: 0, y: 0, width: 612, height: 792)
        let renderer = UIGraphicsPDFRenderer(bounds: pageRect)
        
        let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent("ShoppingList.pdf")
        
        do {
            try renderer.writePDF(to: tempURL) { context in
                context.beginPage()
                
                var yPosition: CGFloat = 40
                let leftMargin: CGFloat = 40
                
                // Title
                let titleFont = UIFont.boldSystemFont(ofSize: 28)
                let titleAttributes: [NSAttributedString.Key: Any] = [
                    .font: titleFont,
                    .foregroundColor: UIColor(COLOR_WARM_AMBER)
                ]
                "🛒 Shopping List".draw(at: CGPoint(x: leftMargin, y: yPosition), withAttributes: titleAttributes)
                yPosition += 45
                
                // Date info
                let infoFont = UIFont.systemFont(ofSize: 12)
                let infoAttributes: [NSAttributedString.Key: Any] = [
                    .font: infoFont,
                    .foregroundColor: UIColor.darkGray
                ]
                "Last Updated: \(formatDate(shoppingList.lastUpdated))".draw(at: CGPoint(x: leftMargin, y: yPosition), withAttributes: infoAttributes)
                yPosition += 30
                
                let itemFont = UIFont.systemFont(ofSize: 14)
                let itemAttributes: [NSAttributedString.Key: Any] = [
                    .font: itemFont,
                    .foregroundColor: UIColor.black
                ]
                
                let uncheckedItems = shoppingList.items.filter { !$0.isChecked }.sorted(by: { $0.ingredient < $1.ingredient })
                let checkedItems = shoppingList.items.filter { $0.isChecked }.sorted(by: { $0.ingredient < $1.ingredient })
                
                if !uncheckedItems.isEmpty {
                    let sectionFont = UIFont.boldSystemFont(ofSize: 18)
                    let sectionAttributes: [NSAttributedString.Key: Any] = [
                        .font: sectionFont,
                        .foregroundColor: UIColor.black
                    ]
                    "TO BUY (\(uncheckedItems.count))".draw(at: CGPoint(x: leftMargin, y: yPosition), withAttributes: sectionAttributes)
                    yPosition += 30
                    
                    for item in uncheckedItems {
                        let text = "☐ \(item.ingredient)"
                        text.draw(at: CGPoint(x: leftMargin + 10, y: yPosition), withAttributes: itemAttributes)
                        yPosition += 22
                    }
                    yPosition += 20
                }
                
                if !checkedItems.isEmpty {
                    let sectionFont = UIFont.boldSystemFont(ofSize: 18)
                    let sectionAttributes: [NSAttributedString.Key: Any] = [
                        .font: sectionFont,
                        .foregroundColor: UIColor.black
                    ]
                    "PURCHASED (\(checkedItems.count))".draw(at: CGPoint(x: leftMargin, y: yPosition), withAttributes: sectionAttributes)
                    yPosition += 30
                    
                    for item in checkedItems {
                        let text = "☑ \(item.ingredient)"
                        text.draw(at: CGPoint(x: leftMargin + 10, y: yPosition), withAttributes: itemAttributes)
                        yPosition += 22
                    }
                }
                
                // Footer
                let footerFont = UIFont.systemFont(ofSize: 10)
                let footerAttributes: [NSAttributedString.Key: Any] = [
                    .font: footerFont,
                    .foregroundColor: UIColor.gray
                ]
                "Shared from Cabinet Cocktails".draw(at: CGPoint(x: leftMargin, y: pageRect.height - 40), withAttributes: footerAttributes)
            }
            
            return tempURL
        } catch {
            print("Error creating PDF: \(error)")
            return nil
        }
    }
    
    // MARK: - Image Export
    
    func exportCocktailAsImage(_ cocktail: DrinkDetails) -> UIImage? {
        let width: CGFloat = 600
        let height: CGFloat = 800
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: width, height: height))
        
        return renderer.image { context in
            // Background
            UIColor(COLOR_CHARCOAL).setFill()
            context.fill(CGRect(x: 0, y: 0, width: width, height: height))
            
            var yPosition: CGFloat = 40
            let leftMargin: CGFloat = 30
            let rightMargin: CGFloat = width - 30
            let contentWidth = rightMargin - leftMargin
            
            // Title
            let titleFont = UIFont.boldSystemFont(ofSize: 32)
            let titleAttributes: [NSAttributedString.Key: Any] = [
                .font: titleFont,
                .foregroundColor: UIColor(COLOR_WARM_AMBER)
            ]
            let titleString = "🍸 \(cocktail.strDrink)"
            let titleSize = titleString.size(withAttributes: titleAttributes)
            titleString.draw(at: CGPoint(x: leftMargin, y: yPosition), withAttributes: titleAttributes)
            yPosition += titleSize.height + 20
            
            // Info
            let infoFont = UIFont.systemFont(ofSize: 14)
            let infoAttributes: [NSAttributedString.Key: Any] = [
                .font: infoFont,
                .foregroundColor: UIColor.lightGray
            ]
            
            var infoText = ""
            if let category = cocktail.strCategory { infoText += category + " • " }
            if let glass = cocktail.strGlass { infoText += glass + " • " }
            infoText += cocktail.strAlcoholic
            
            infoText.draw(at: CGPoint(x: leftMargin, y: yPosition), withAttributes: infoAttributes)
            yPosition += 40
            
            // Ingredients
            let sectionFont = UIFont.boldSystemFont(ofSize: 20)
            let sectionAttributes: [NSAttributedString.Key: Any] = [
                .font: sectionFont,
                .foregroundColor: UIColor.white
            ]
            "INGREDIENTS".draw(at: CGPoint(x: leftMargin, y: yPosition), withAttributes: sectionAttributes)
            yPosition += 35
            
            let ingredientFont = UIFont.systemFont(ofSize: 16)
            let ingredientAttributes: [NSAttributedString.Key: Any] = [
                .font: ingredientFont,
                .foregroundColor: UIColor.white
            ]
            
            let ingredients = cocktail.getIngredients()
            for i in 0..<ingredients.count {
                let ingredient = ingredients[i]
                let measure = getMeasure(for: cocktail, at: i)
                let text = measure.isEmpty ? "• \(ingredient)" : "• \(measure) \(ingredient)"
                text.draw(at: CGPoint(x: leftMargin + 15, y: yPosition), withAttributes: ingredientAttributes)
                yPosition += 26
            }
            
            // Footer
            yPosition = height - 50
            let footerFont = UIFont.systemFont(ofSize: 12)
            let footerAttributes: [NSAttributedString.Key: Any] = [
                .font: footerFont,
                .foregroundColor: UIColor.gray
            ]
            "Shared from Cabinet Cocktails".draw(at: CGPoint(x: leftMargin, y: yPosition), withAttributes: footerAttributes)
        }
    }
    
    // MARK: - Share Items Creation
    
    func createShareItems(for contentType: ShareContentType, format: ExportFormat) -> [Any] {
        switch (contentType, format) {
        case (.cocktailRecipe(let cocktail), .text):
            return [exportCocktailAsText(cocktail)]
            
        case (.cocktailRecipe(let cocktail), .json):
            if let json = exportCocktailAsJSON(cocktail) {
                return [json]
            }
            return []
            
        case (.cocktailRecipe(let cocktail), .pdf):
            if let pdfURL = exportCocktailAsPDF(cocktail) {
                return [pdfURL]
            }
            return []
            
        case (.cocktailRecipe(let cocktail), .image):
            if let image = exportCocktailAsImage(cocktail) {
                return [image]
            }
            return []
            
        case (.collection(let collection, let cocktails), .text):
            return [exportCollectionAsText(collection, cocktails: cocktails)]
            
        case (.collection(let collection, let cocktails), .json):
            if let json = exportCollectionAsJSON(collection, cocktails: cocktails) {
                return [json]
            }
            return []
            
        case (.shoppingList(let shoppingList), .text):
            return [exportShoppingListAsText(shoppingList)]
            
        case (.shoppingList(let shoppingList), .pdf):
            if let pdfURL = exportShoppingListAsPDF(shoppingList) {
                return [pdfURL]
            }
            return []
            
        case (.multipleRecipes(let cocktails), .text):
            let allText = cocktails.map { exportCocktailAsText($0) }.joined(separator: "\n\n" + String(repeating: "=", count: 40) + "\n\n")
            return [allText]
            
        default:
            return []
        }
    }
    
    // MARK: - Helper Methods
    
    private func getMeasure(for cocktail: DrinkDetails, at index: Int) -> String {
        switch index {
        case 0: return cocktail.strMeasure1 ?? ""
        case 1: return cocktail.strMeasure2 ?? ""
        case 2: return cocktail.strMeasure3 ?? ""
        case 3: return cocktail.strMeasure4 ?? ""
        case 4: return cocktail.strMeasure5 ?? ""
        case 5: return cocktail.strMeasure6 ?? ""
        case 6: return cocktail.strMeasure7 ?? ""
        case 7: return cocktail.strMeasure8 ?? ""
        case 8: return cocktail.strMeasure9 ?? ""
        case 9: return cocktail.strMeasure10 ?? ""
        case 10: return cocktail.strMeasure11 ?? ""
        case 11: return cocktail.strMeasure12 ?? ""
        case 12: return cocktail.strMeasure13 ?? ""
        case 13: return cocktail.strMeasure14 ?? ""
        case 14: return cocktail.strMeasure15 ?? ""
        default: return ""
        }
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter.string(from: date)
    }
}
