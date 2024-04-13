//
//  Details.swift
//  VisAG
//
//  Created by Kendall Lewis on 10/11/23.
//

import Foundation

struct Ingredient: Identifiable, Encodable, Decodable, Hashable {
    var id = UUID()
    let name: String
    let type: IngredientType
    var image: String?
    
    init(name: String, image: String?, type: IngredientType) {
        self.name = name
        self.type = type
        self.image = image
    }
}


enum IngredientType: String, Codable {
    case mixer
    case alcohol
    case nonAlcohol
    case garnish
}

struct CocktailDBResponse: Decodable {
 let drinks: [Drink]
 
 private enum CodingKeys: String, CodingKey {
     case drinks
 }
 
 init(from decoder: Decoder) throws {
     let container = try decoder.container(keyedBy: CodingKeys.self)
     drinks = try container.decode([Drink].self, forKey: .drinks)
 }
}

struct CocktailDetailDBResponse: Decodable {
 let drinks: [DrinkDetails]
 
 private enum CodingKeys: String, CodingKey {
     case drinks
 }
 
 init(from decoder: Decoder) throws {
     let container = try decoder.container(keyedBy: CodingKeys.self)
     drinks = try container.decode([DrinkDetails].self, forKey: .drinks)
 }
}

struct Drink: Decodable {
    let strDrink: String
    let strDrinkThumb: String
    let strInstructions: String? // Make strInstructions optional
    
    private enum CodingKeys: String, CodingKey {
        case strDrink, strDrinkThumb, strInstructions
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        strDrink = try container.decode(String.self, forKey: .strDrink)
        strDrinkThumb = try container.decode(String.self, forKey: .strDrinkThumb)
        strInstructions = try container.decodeIfPresent(String.self, forKey: .strInstructions) // Decode if present
    }
}

struct DrinkDetails: Decodable, Identifiable, Hashable{
    var id = UUID() // Using UUID for unique identification
    
    let idDrink: String
    let strDrink: String
    let strDrinkAlternate: String?
    let strTags: String?
    let strVideo: String?
    let strCategory: String?
    let strIBA: String?
    let strAlcoholic: String
    let strGlass: String?
    let strInstructions: String?
    let strInstructionsES: String?
    let strInstructionsDE: String?
    let strInstructionsFR: String?
    let strInstructionsIT: String?
    let strInstructionsZH_HANS: String?
    let strInstructionsZH_HANT: String?
    let strDrinkThumb: String?
    let strIngredient1: String?
    let strIngredient2: String?
    let strIngredient3: String?
    let strIngredient4: String?
    let strIngredient5: String?
    let strIngredient6: String?
    let strIngredient7: String?
    let strIngredient8: String?
    let strIngredient9: String?
    let strIngredient10: String?
    let strIngredient11: String?
    let strIngredient12: String?
    let strIngredient13: String?
    let strIngredient14: String?
    let strIngredient15: String?
    let strMeasure1: String?
    let strMeasure2: String?
    let strMeasure3: String?
    let strMeasure4: String?
    let strMeasure5: String?
    let strMeasure6: String?
    let strMeasure7: String?
    let strMeasure8: String?
    let strMeasure9: String?
    let strMeasure10: String?
    let strMeasure11: String?
    let strMeasure12: String?
    let strMeasure13: String?
    let strMeasure14: String?
    let strMeasure15: String?
    let strImageSource: String?
    let strImageAttribution: String?
    let strCreativeCommonsConfirmed: String
    let dateModified: String?

    private enum CodingKeys: String, CodingKey {
        case idDrink, strDrink, strDrinkAlternate, strTags, strVideo, strCategory, strIBA, strAlcoholic, strGlass, strInstructions, strInstructionsES, strInstructionsDE, strInstructionsFR, strInstructionsIT, strInstructionsZH_HANS, strInstructionsZH_HANT, strDrinkThumb, strIngredient1, strIngredient2, strIngredient3, strIngredient4, strIngredient5, strIngredient6, strIngredient7, strIngredient8, strIngredient9, strIngredient10, strIngredient11, strIngredient12, strIngredient13, strIngredient14, strIngredient15, strMeasure1, strMeasure2, strMeasure3, strMeasure4, strMeasure5, strMeasure6, strMeasure7, strMeasure8, strMeasure9, strMeasure10, strMeasure11, strMeasure12, strMeasure13, strMeasure14, strMeasure15, strImageSource, strImageAttribution, strCreativeCommonsConfirmed, dateModified
    }
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        idDrink = try container.decode(String.self, forKey: .idDrink)
        strDrink = try container.decode(String.self, forKey: .strDrink)
        strDrinkAlternate = try container.decodeIfPresent(String.self, forKey: .strDrinkAlternate)
        strTags = try container.decodeIfPresent(String.self, forKey: .strTags)
        strVideo = try container.decodeIfPresent(String.self, forKey: .strVideo)
        strCategory = try container.decode(String.self, forKey: .strCategory)
        strIBA = try container.decodeIfPresent(String.self, forKey: .strIBA)
        strAlcoholic = try container.decode(String.self, forKey: .strAlcoholic)
        strGlass = try container.decode(String.self, forKey: .strGlass)
        strInstructions = try container.decodeIfPresent(String.self, forKey: .strInstructions)
        strInstructionsES = try container.decodeIfPresent(String.self, forKey: .strInstructionsES)
        strInstructionsDE = try container.decodeIfPresent(String.self, forKey: .strInstructionsDE)
        strInstructionsFR = try container.decodeIfPresent(String.self, forKey: .strInstructionsFR)
        strInstructionsIT = try container.decodeIfPresent(String.self, forKey: .strInstructionsIT)
        strInstructionsZH_HANS = try container.decodeIfPresent(String.self, forKey: .strInstructionsZH_HANS)
        strInstructionsZH_HANT = try container.decodeIfPresent(String.self, forKey: .strInstructionsZH_HANT)
        strDrinkThumb = try container.decode(String.self, forKey: .strDrinkThumb)
        strIngredient1 = try container.decodeIfPresent(String.self, forKey: .strIngredient1)
        strIngredient2 = try container.decodeIfPresent(String.self, forKey: .strIngredient2)
        strIngredient3 = try container.decodeIfPresent(String.self, forKey: .strIngredient3)
        strIngredient4 = try container.decodeIfPresent(String.self, forKey: .strIngredient4)
        strIngredient5 = try container.decodeIfPresent(String.self, forKey: .strIngredient5)
        strIngredient6 = try container.decodeIfPresent(String.self, forKey: .strIngredient6)
        strIngredient7 = try container.decodeIfPresent(String.self, forKey: .strIngredient7)
        strIngredient8 = try container.decodeIfPresent(String.self, forKey: .strIngredient8)
        strIngredient9 = try container.decodeIfPresent(String.self, forKey: .strIngredient9)
        strIngredient10 = try container.decodeIfPresent(String.self, forKey: .strIngredient10)
        strIngredient11 = try container.decodeIfPresent(String.self, forKey: .strIngredient11)
        strIngredient12 = try container.decodeIfPresent(String.self, forKey: .strIngredient12)
        strIngredient13 = try container.decodeIfPresent(String.self, forKey: .strIngredient13)
        strIngredient14 = try container.decodeIfPresent(String.self, forKey: .strIngredient14)
        strIngredient15 = try container.decodeIfPresent(String.self, forKey: .strIngredient15)
        strMeasure1 = try container.decodeIfPresent(String.self, forKey: .strMeasure1)
        strMeasure2 = try container.decodeIfPresent(String.self, forKey: .strMeasure2)
        strMeasure3 = try container.decodeIfPresent(String.self, forKey: .strMeasure3)
        strMeasure4 = try container.decodeIfPresent(String.self, forKey: .strMeasure4)
        strMeasure5 = try container.decodeIfPresent(String.self, forKey: .strMeasure5)
        strMeasure6 = try container.decodeIfPresent(String.self, forKey: .strMeasure6)
        strMeasure7 = try container.decodeIfPresent(String.self, forKey: .strMeasure7)
        strMeasure8 = try container.decodeIfPresent(String.self, forKey: .strMeasure8)
        strMeasure9 = try container.decodeIfPresent(String.self, forKey: .strMeasure9)
        strMeasure10 = try container.decodeIfPresent(String.self, forKey: .strMeasure10)
        strMeasure11 = try container.decodeIfPresent(String.self, forKey: .strMeasure11)
        strMeasure12 = try container.decodeIfPresent(String.self, forKey: .strMeasure12)
        strMeasure13 = try container.decodeIfPresent(String.self, forKey: .strMeasure13)
        strMeasure14 = try container.decodeIfPresent(String.self, forKey: .strMeasure14)
        strMeasure15 = try container.decodeIfPresent(String.self, forKey: .strMeasure15)
        strImageSource = try container.decodeIfPresent(String.self, forKey: .strImageSource)
        strImageAttribution = try container.decodeIfPresent(String.self, forKey: .strImageAttribution)
        strCreativeCommonsConfirmed = try container.decode(String.self, forKey: .strCreativeCommonsConfirmed)
        dateModified = try container.decodeIfPresent(String.self, forKey: .dateModified)
    }
    
    func getIngredients() -> [String] {
        // This gathers all non-nil, non-empty ingredient strings into an array
        let ingredientsList = [strIngredient1, strIngredient2, strIngredient3, strIngredient4, strIngredient5, strIngredient6, strIngredient7, strIngredient8, strIngredient9, strIngredient10, strIngredient11, strIngredient12, strIngredient13, strIngredient14, strIngredient15].compactMap { $0 }.filter { !$0.isEmpty }
        
        return ingredientsList
    }
}
