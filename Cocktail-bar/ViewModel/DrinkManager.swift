//
//  DrinkManager.swift
//  Cocktail-bar
//
//  Created by Kendall Lewis on 3/30/24.
//

import Foundation

@MainActor
class DrinkManager: ObservableObject {
    static let shared = DrinkManager()
    
    var allDrinks: [DrinkDetails]? // Variable to store all drinks
    var myDrinkPossibilities: [DrinkDetails]? // Variable to store all drinks
    var temporaryPossibilities: [DrinkDetails]? // Variable to store all drinks
    var allIngredients: [Ingredient]? // Variable to store all drinks
    var allIngredientCombinations: [String: [String: [DrinkDetails]]] = [:]
    var ingredients = LocalStorageManager.shared.retrieveTopShelfItems()
    var tempDrinks: [DrinkDetails] = []
    var signatureCocktails = LocalStorageManager.shared.retrieveFavoriteItems()
    var selectedCocktail: Ingredient?
    var showPopover: Bool = false
    
    // Cache for expensive operations
    private var ingredientSetCache: [String: Set<String>] = [:]
    private var isDrinksLoading = false
    private var cachedCategories: Set<String>?
    
    //Initial set up
    func setUp() {
        Task {
            await fetchAllDrinks() //get all drinks
            getAllUniqueIngredients() //get all ingredients
            onlyYourIngredients() //get initial drinks
        }
    }
    
    // Function to fetch all drinks from the API and store them locally with async/await
    func fetchAllDrinks() async {
        guard !isDrinksLoading else { return }
        isDrinksLoading = true
        defer { isDrinksLoading = false }
        
        let urlString = "\(API_URL)/search.php?s="
        
        guard let url = URL(string: urlString) else {
            print("Invalid URL")
            return
        }
        
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            let decoder = JSONDecoder()
            let result = try decoder.decode([String: [DrinkDetails]].self, from: data)
            let drinks = result["drinks"] ?? []
            
            // Update the allDrinks variable with the fetched drinks
            self.allDrinks = drinks
            
            // Pre-cache ingredient sets for performance
            precomputeIngredientSets()
        } catch {
            print("Error fetching/decoding drinks: \(error.localizedDescription)")
        }
    }
    
    // Precompute ingredient sets for faster lookups
    private func precomputeIngredientSets() {
        guard let drinks = allDrinks else { return }
        ingredientSetCache.removeAll()
        for drink in drinks {
            let ingredients = Set(drink.getIngredients().map { $0.lowercased() })
            ingredientSetCache[drink.idDrink] = ingredients
        }
    }

    // Function to filter drinks based on ingredients
    func filterDrinks(withIngredients ingredients: [String]) -> [DrinkDetails]? {
       guard let allDrinks = allDrinks else { return nil }
       // Filter drinks based on provided ingredients
       let filteredDrinks = allDrinks.filter { drink in
           // Check if the drink contains all provided ingredients
           return ingredients.allSatisfy { ingredient in
               // Check if the drink's ingredient properties contain the provided ingredient
               return drink.containsIngredient(ingredient)
           }
       }
       return filteredDrinks
    }
    
    // Function to get drinks that can be made with your ingredients - optimized
    func onlyYourIngredients() {
        let ingredients = LocalStorageManager.shared.retrieveTopShelfItems()
        
        // Performance: Early return if no ingredients or drinks
        guard !ingredients.isEmpty, let allDrinks = DrinkManager.shared.allDrinks, !allDrinks.isEmpty else {
            self.myDrinkPossibilities = nil
            return
        }
        
        // Convert to lowercase set for efficient comparison
        let targetIngredientsSet = Set(ingredients.map { $0.lowercased().trimmingCharacters(in: .whitespaces) }.filter { !$0.isEmpty })
        
        // Use cached ingredient sets if available, otherwise compute
        let matchingDrinks = allDrinks.filter { drink in
            let drinkIngredients: Set<String>
            if let cached = ingredientSetCache[drink.idDrink] {
                drinkIngredients = cached
            } else {
                drinkIngredients = Set(drink.getIngredients().map { $0.lowercased() })
            }
            return drinkIngredients.isSubset(of: targetIngredientsSet)
        }
        
        myDrinkPossibilities = matchingDrinks
        //print(matchingDrinks.map { $0.strDrink }) // Print drink names for readability
    }
    
    func getQuickDrinkPossibilities(ingredients: [Ingredient]) -> [DrinkDetails]? {
        guard let allDrinks = DrinkManager.shared.allDrinks, !allDrinks.isEmpty else { return nil }
        
        let targetIngredientsSet = Set(ingredients.map { $0.name.lowercased() })
        
        // Use cached ingredient sets and filter efficiently
        let matchingDrinks = allDrinks.filter { drink in
            let drinkIngredients: Set<String>
            if let cached = ingredientSetCache[drink.idDrink] {
                drinkIngredients = cached
            } else {
                drinkIngredients = Set(drink.getIngredients().map { $0.lowercased() })
            }
            return drinkIngredients.isSubset(of: targetIngredientsSet)
        }
        
        return matchingDrinks.isEmpty ? nil : matchingDrinks
    }

    
    // Function to search drinks by ingredients - optimized with cache
    func searchIngredients(ingredients: [Ingredient]) -> [DrinkDetails]? {
        guard let allDrinks = DrinkManager.shared.allDrinks else { return nil }
        
        let searchIngredientNames = Set(ingredients.map { $0.name.lowercased() })
        
        let filteredDrinks = allDrinks.filter { drink in
            let drinkIngredients: Set<String>
            if let cached = ingredientSetCache[drink.idDrink] {
                drinkIngredients = cached
            } else {
                drinkIngredients = Set(drink.getIngredients().map { $0.lowercased() })
            }
            return searchIngredientNames.isSubset(of: drinkIngredients)
        }
        
        return filteredDrinks.isEmpty ? nil : filteredDrinks
    }



    // Assuming IngredientType and DrinkDetails are defined elsewhere
    func getAllUniqueIngredients() {
         // Performance: Return early if already cached
         if allIngredients != nil { return }
         
         guard let allDrinks = allDrinks else {
             self.allIngredients = nil
             return
         }
         
         // Use Set directly instead of intermediate arrays for better performance
         var uniqueIngredientNames = Set<String>()
         
         for drink in allDrinks {
             let ingredients = drink.getIngredients()
             for ingredient in ingredients where !ingredient.isEmpty {
                 // Normalize: trim whitespace and capitalize first letter only
                 let normalized = ingredient.trimmingCharacters(in: .whitespaces)
                 if !normalized.isEmpty {
                     let capitalized = normalized.prefix(1).uppercased() + normalized.dropFirst().lowercased()
                     uniqueIngredientNames.insert(capitalized)
                 }
             }
         }
         
         // Convert to Ingredient objects
         let uniqueIngredients = uniqueIngredientNames.map { name -> Ingredient in
             Ingredient(name: name, image: nil, type: .alcohol)
         }
         
         self.allIngredients = uniqueIngredients.sorted { $0.name < $1.name }
    }
    
    //find combinations for single drink
    func generateCombinations(mainIngredient: String) -> [[String]] {
        var combinations: [[String]] = [[mainIngredient]]
        
        for (index, firstIngredient) in ingredients.enumerated() {
            combinations.append([mainIngredient, firstIngredient])
            for i in index+1..<ingredients.count {
                let secondIngredient = ingredients[i]
                combinations.append([mainIngredient, firstIngredient, secondIngredient])
            }
        }
        
        if !ingredients.isEmpty {
            combinations.append([mainIngredient] + ingredients)
        }
        
        return combinations
    }
    
    func findDrinksForCombinations(mainIngredient: String) -> [String: [String: [DrinkDetails]]] {
        ingredients = LocalStorageManager.shared.retrieveTopShelfItems()
        var tempDrinkList: [String: [String: [DrinkDetails]]] = [:]
        var drinkAppearanceTracker: [String: (combinationKey: String, ingredientCount: Int)] = [:]

        let combinations = generateCombinations(mainIngredient: mainIngredient)
        guard let allDrinks = allDrinks else { return tempDrinkList }

        for combination in combinations {
            let combinationKey = capitalizeFirstWordOnly(in: combination).joined(separator: ", ")
            var drinksForThisCombination: [String: [DrinkDetails]] = [:]

            for drink in allDrinks {
                let drinkIngredients = capitalizeFirstWordOnly(in: drink.getIngredients())

                if combination.allSatisfy(drinkIngredients.contains) {
                    let category = drink.strCategory ?? "Unknown"
                    drinksForThisCombination[category, default: []].append(drink)

                    let currentInfo = drinkAppearanceTracker[drink.idDrink]
                    let currentMaxIngredients = currentInfo?.ingredientCount ?? -1
                    if combination.count > currentMaxIngredients {
                        drinkAppearanceTracker[drink.idDrink] = (combinationKey, combination.count)
                    }
                }
            }

            // Add initial entries for each combination
            if !drinksForThisCombination.isEmpty {
                tempDrinkList[combinationKey] = drinksForThisCombination
            }
        }

        // Filter out duplicates by ensuring drinks only appear in their max ingredient count combination
        for (drinkID, info) in drinkAppearanceTracker {
            for (combinationKey, categories) in tempDrinkList {
                for (category, _) in categories {
                    if combinationKey != info.combinationKey,
                       let index = tempDrinkList[combinationKey]?[category]?.firstIndex(where: { $0.idDrink == drinkID }) {
                        tempDrinkList[combinationKey]?[category]?.remove(at: index)
                    }
                }
            }
        }

        // Clean up any categories or combination keys that might have become empty after removal
        for (combinationKey, categories) in tempDrinkList {
            for (category, drinks) in categories {
                if drinks.isEmpty {
                    tempDrinkList[combinationKey]?.removeValue(forKey: category)
                }
            }
            if categories.isEmpty || categories.values.allSatisfy({ $0.isEmpty }) {
                tempDrinkList.removeValue(forKey: combinationKey)
            }
        }
        
        // After cleaning up duplicates and empty categories
        let uniqueDrinks: [DrinkDetails] = tempDrinkList
            .flatMap { $0.value } // Flatten to [[DrinkDetails]]
            .flatMap { $0.value } // Flatten to [DrinkDetails]

        // Assuming `tempDrinks` is meant to store this flattened list
        tempDrinks = uniqueDrinks
        
        return tempDrinkList
    }

    func findDrinkByName(name: String) -> DrinkDetails? {
        // Use the first(where:) method to find the first drink that matches the provided name.
        return allDrinks!.first { $0.strDrink.caseInsensitiveCompare(name) == .orderedSame }
    }
    
    private func capitalizeFirstWordOnly(in array: [String])-> [String] {
        array.map { element -> String in
            let words = element.split(separator: " ").enumerated().map { index, word -> String in
                if index == 0 {
                    // Capitalize the first letter of the first word
                    return word.prefix(1).capitalized + word.dropFirst().lowercased()
                } else {
                    // Ensure all other words are in lowercase
                    return word.lowercased()
                }
            }
            // Join the words back into a single string
            return words.joined(separator: " ")
        }
    }
}






