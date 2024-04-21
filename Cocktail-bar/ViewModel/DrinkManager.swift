//
//  DrinkManager.swift
//  Cocktail-bar
//
//  Created by Kendall Lewis on 3/30/24.
//

import Foundation

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
    
    //Inital set up
    func setUp(){
        fetchAllDrinks() //get all drinks
        getAllUniqueIngredients() //get all ingredients
        onlyYourIngredients() //get intial drinks
    }
    
    // Function to fetch all drinks from the API and store them locally
    func fetchAllDrinks() {
        let urlString = "\(API_URL)/search.php?s="
        
        guard let url = URL(string: urlString) else {
            print("Invalid URL")
            return
        }
        
        let task = URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            DispatchQueue.main.async { // Ensure UI updates are performed on the main thread.
                guard let data = data, error == nil else {
                    print("Error fetching data: \(error?.localizedDescription ?? "Unknown error")")
                    return
                }
                
                do {
                    let decoder = JSONDecoder()
                    let result = try decoder.decode([String: [DrinkDetails]].self, from: data)
                    let drinks = result["drinks"] ?? []
                    
                    // Update the allDrinks variable with the fetched drinks
                    self?.allDrinks = drinks
                } catch {
                    print("Error decoding JSON: \(error)")
                }
            }
        }
        
        task.resume()
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
    
    // Function to get get drink that can be made with your ingredients
    func onlyYourIngredients() {
        let ingredients = LocalStorageManager.shared.retrieveTopShelfItems()
        
        guard let allDrinks = DrinkManager.shared.allDrinks else {
            self.allIngredients = nil // Assuming this is meant to clear some state
            return
        }
        
        // Convert the target ingredients to a Set for efficient subset checks
        let targetIngredientsSet = Set(capitalizeFirstWordOnly(in: ingredients).filter { !$0.isEmpty })
        
        var matchingDrinks: [DrinkDetails] = []

        for drink in allDrinks {
            // Convert the drink's ingredients to a Set
            let drinkIngredientsSet = Set(capitalizeFirstWordOnly(in: drink.getIngredients()))
            
            // Check if all of the drink's ingredients are in the set of target ingredients
            if drinkIngredientsSet.isSubset(of: targetIngredientsSet) {
                matchingDrinks.append(drink) // Append the whole drink object, not just its name
            }
        }
        myDrinkPossibilities = matchingDrinks // Ensure this variable is correctly typed to [DrinkDetails]
        //print(matchingDrinks.map { $0.strDrink }) // Print drink names for readability
    }
    
    func getQuickDrinkPossibilities(ingredients: [Ingredient]) -> [DrinkDetails]? {
        // Ensure that there are drinks to search through
        guard let allDrinks = DrinkManager.shared.allDrinks, !allDrinks.isEmpty else { return nil }
        
        // Prepare the set of target ingredients with the desired capitalization
        let targetIngredientsSet = Set(ingredients.map { $0.name.lowercased() })

        // Debugging: Print the target ingredients to the console
        print(targetIngredientsSet)
        
        // Initialize an array to store matching drinks
        var matchingDrinks: [DrinkDetails] = []

        // Iterate through all drinks
        for drink in allDrinks {
            // Prepare the set of the drink's ingredients with the same capitalization rules
            let drinkIngredientsSet = Set(drink.getIngredients().map { $0.lowercased() })
            
            // Check if the drink's ingredients are a subset of the target ingredients
            if drinkIngredientsSet.isSubset(of: targetIngredientsSet) {
                matchingDrinks.append(drink)
            }
        }

        // Debugging: Print the matching drinks to the console
        print(matchingDrinks)
        
        // Return the matching drinks if any, or nil if there are none
        return matchingDrinks.isEmpty ? nil : matchingDrinks
    }

    
    // Function to get get drink that can be made with your ingredients
    func searchIngredients(ingredients: [Ingredient]) -> [DrinkDetails]? {
        guard let allDrinks = DrinkManager.shared.allDrinks else { return nil }
        
        let searchIngredientNames = Set(ingredients.map { $0.name.lowercased() })
        
        let filteredDrinks = allDrinks.filter { drink in
            let drinkIngredients = Set(drink.getIngredients().map { $0.lowercased() })
            // Check if all search ingredients are contained within a drink's ingredients
            return searchIngredientNames.isSubset(of: drinkIngredients)
        }
        
        return filteredDrinks.isEmpty ? nil : filteredDrinks
    }



    // Assuming IngredientType and DrinkDetails are defined elsewhere
    func getAllUniqueIngredients() {
         guard let allDrinks = allDrinks else {
             self.allIngredients = nil // or [] if you prefer an empty array over nil
             return
         }
         
         var uniqueIngredientNames = Set<String>()
         
         for drink in allDrinks {
             let ingredients = drink.getIngredients()
             let transformedString = capitalizeFirstWordOnly(in: ingredients).filter { !$0.isEmpty }
             uniqueIngredientNames.formUnion(transformedString)
         }
         
         // Assuming a method to determine the type and optionally an image URL for each ingredient name
         // For simplicity, default values are used for type and image here
         let uniqueIngredients = uniqueIngredientNames.map { name -> Ingredient in
             Ingredient(name: name, image: nil, type: .alcohol) // Adjust .someDefaultType as needed
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
                for (category, drinks) in categories {
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






