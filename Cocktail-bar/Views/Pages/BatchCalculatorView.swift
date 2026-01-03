//
//  BatchCalculatorView.swift
//  Cocktail-bar
//
//  Created by GitHub Copilot on 12/30/25.
//

import SwiftUI

struct BatchCalculatorView: View {
    let drink: DrinkDetails
    @StateObject private var calculator = BatchCalculatorManager.shared
    @State private var selectedMultiplier: Double = 1.0
    @State private var selectedUnit: VolumeUnit = .oz
    @State private var showSavePreset = false
    @State private var presetName = ""
    @State private var showPartyMode = false
    @State private var showUnitPicker = false
    @Environment(\.dismiss) var dismiss
    @Environment(\.colorScheme) var colorScheme
    
    var scaledIngredients: [ScaledIngredient] {
        calculator.scaleRecipe(drink: drink, multiplier: selectedMultiplier, targetUnit: selectedUnit)
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                COLOR_CHARCOAL.ignoresSafeArea()
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 24) {
                        // Header
                        headerSection
                        
                        // Multiplier Selection
                        multiplierSection
                        
                        // Unit Selection
                        unitSection
                        
                        // Scaled Ingredients
                        ingredientsSection
                        
                        // Actions
                        actionsSection
                        
                        // Saved Presets
                        if !calculator.savedPresets.isEmpty {
                            presetsSection
                        }
                    }
                    .padding(20)
                }
            }
            .navigationTitle("Batch Calculator")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .foregroundColor(COLOR_WARM_AMBER)
                }
            }
        }
        .sheet(isPresented: $showSavePreset) {
            SavePresetSheet(
                presetName: $presetName,
                onSave: {
                    let preset = BatchPreset(
                        name: presetName,
                        multiplier: selectedMultiplier,
                        drinkId: drink.idDrink,
                        drinkName: drink.strDrink
                    )
                    calculator.savePreset(preset)
                    showSavePreset = false
                    presetName = ""
                }
            )
        }
        .sheet(isPresented: $showPartyMode) {
            PartyModeView(drink: drink, initialMultiplier: selectedMultiplier, initialUnit: selectedUnit)
        }
        .onAppear {
            selectedUnit = calculator.preferredUnit
        }
    }
    
    // MARK: - Header Section
    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(drink.strDrink)
                .font(.system(size: 28, weight: .bold))
                .foregroundColor(.white)
            
            if let category = drink.strCategory {
                Text(category)
                    .font(.system(size: 16))
                    .foregroundColor(COLOR_TEXT_SECONDARY)
            }
            
            HStack(spacing: 16) {
                InfoPill(
                    icon: "person.2.fill",
                    text: servingsText,
                    color: COLOR_WARM_AMBER
                )
                
                InfoPill(
                    icon: "drop.fill",
                    text: totalVolumeText,
                    color: COLOR_WARM_AMBER
                )
            }
        }
    }
    
    private var servingsText: String {
        let servings = Int(selectedMultiplier)
        return "\(servings) serving\(servings == 1 ? "" : "s")"
    }
    
    private var totalVolumeText: String {
        let total = scaledIngredients
            .filter { $0.parsedOriginalAmount != nil }
            .reduce(0.0) { $0 + $1.scaledAmount }
        return String(format: "%.1f %@", total, selectedUnit.rawValue)
    }
    
    // MARK: - Multiplier Section
    private var multiplierSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Servings")
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(.white)
            
            // Quick multipliers
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(BatchCalculatorManager.quickMultipliers, id: \.self) { multiplier in
                        MultiplierButton(
                            multiplier: multiplier,
                            isSelected: selectedMultiplier == multiplier,
                            action: { selectedMultiplier = multiplier }
                        )
                    }
                }
            }
            
            // Custom multiplier slider
            VStack(spacing: 8) {
                HStack {
                    Text("Custom")
                        .font(.system(size: 14))
                        .foregroundColor(COLOR_TEXT_SECONDARY)
                    
                    Spacer()
                    
                    Text(String(format: "%.1fx", selectedMultiplier))
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(COLOR_WARM_AMBER)
                }
                
                Slider(value: $selectedMultiplier, in: 1...20, step: 0.5)
                    .accentColor(COLOR_WARM_AMBER)
            }
            .padding(12)
            .background(COLOR_CHARCOAL_LIGHT)
            .cornerRadius(12)
        }
    }
    
    // MARK: - Unit Section
    private var unitSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Units")
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(.white)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(VolumeUnit.allCases, id: \.self) { unit in
                        UnitButton(
                            unit: unit,
                            isSelected: selectedUnit == unit,
                            action: {
                                selectedUnit = unit
                                calculator.setPreferredUnit(unit)
                            }
                        )
                    }
                }
            }
        }
    }
    
    // MARK: - Ingredients Section
    private var ingredientsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Ingredients")
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(.white)
            
            VStack(spacing: 8) {
                ForEach(scaledIngredients) { ingredient in
                    IngredientRow(ingredient: ingredient)
                }
            }
        }
    }
    
    // MARK: - Actions Section
    private var actionsSection: some View {
        VStack(spacing: 12) {
            Button(action: { showPartyMode = true }) {
                HStack {
                    Image(systemName: "chart.bar.fill")
                    Text("Party Mode (Running Tally)")
                }
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(COLOR_WARM_AMBER)
                .cornerRadius(12)
            }
            
            Button(action: { showSavePreset = true }) {
                HStack {
                    Image(systemName: "bookmark.fill")
                    Text("Save as Preset")
                }
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(COLOR_WARM_AMBER)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(COLOR_CHARCOAL_LIGHT)
                .cornerRadius(12)
            }
            
            Button(action: shareRecipe) {
                HStack {
                    Image(systemName: "square.and.arrow.up")
                    Text("Share Recipe")
                }
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(COLOR_WARM_AMBER)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(COLOR_CHARCOAL_LIGHT)
                .cornerRadius(12)
            }
        }
    }
    
    // MARK: - Presets Section
    private var presetsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Saved Presets")
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(.white)
            
            ForEach(calculator.savedPresets.filter { $0.drinkId == drink.idDrink }) { preset in
                PresetRow(
                    preset: preset,
                    onLoad: {
                        selectedMultiplier = preset.multiplier
                    },
                    onDelete: {
                        calculator.deletePreset(preset)
                    }
                )
            }
        }
    }
    
    // MARK: - Helper Functions
    private func shareRecipe() {
        var text = "\(drink.strDrink) - Batch Recipe (\(Int(selectedMultiplier))x)\n\n"
        text += "Ingredients:\n"
        for ingredient in scaledIngredients {
            if ingredient.parsedOriginalAmount != nil {
                text += "• \(ingredient.displayAmount) \(ingredient.name)\n"
            } else {
                text += "• \(ingredient.originalAmount) \(ingredient.name)\n"
            }
        }
        
        let activityVC = UIActivityViewController(activityItems: [text], applicationActivities: nil)
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let rootVC = windowScene.windows.first?.rootViewController {
            rootVC.present(activityVC, animated: true)
        }
    }
}

// MARK: - Supporting Views

struct InfoPill: View {
    let icon: String
    let text: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: icon)
                .font(.system(size: 12))
            Text(text)
                .font(.system(size: 14, weight: .medium))
        }
        .foregroundColor(color)
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(color.opacity(0.15))
        .cornerRadius(8)
    }
}

struct MultiplierButton: View {
    let multiplier: Double
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Text("\(Int(multiplier))")
                    .font(.system(size: 24, weight: .bold))
                Text("serving\(Int(multiplier) == 1 ? "" : "s")")
                    .font(.system(size: 12))
            }
            .foregroundColor(isSelected ? COLOR_CHARCOAL : .white)
            .frame(width: 80, height: 70)
            .background(isSelected ? COLOR_WARM_AMBER : COLOR_CHARCOAL_LIGHT)
            .cornerRadius(12)
        }
    }
}

struct UnitButton: View {
    let unit: VolumeUnit
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(unit.rawValue)
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(isSelected ? COLOR_CHARCOAL : .white)
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
                .background(isSelected ? COLOR_WARM_AMBER : COLOR_CHARCOAL_LIGHT)
                .cornerRadius(8)
        }
    }
}

struct IngredientRow: View {
    let ingredient: ScaledIngredient
    
    var body: some View {
        HStack {
            Text(ingredient.name)
                .font(.system(size: 16))
                .foregroundColor(.white)
            
            Spacer()
            
            if let _ = ingredient.parsedOriginalAmount {
                Text(ingredient.displayAmount)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(COLOR_WARM_AMBER)
            } else {
                Text(ingredient.originalAmount)
                    .font(.system(size: 14))
                    .foregroundColor(COLOR_TEXT_SECONDARY)
            }
        }
        .padding(12)
        .background(COLOR_CHARCOAL_LIGHT)
        .cornerRadius(8)
    }
}

struct PresetRow: View {
    let preset: BatchPreset
    let onLoad: () -> Void
    let onDelete: () -> Void
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(preset.name)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white)
                
                Text("\(Int(preset.multiplier))x servings")
                    .font(.system(size: 14))
                    .foregroundColor(COLOR_TEXT_SECONDARY)
            }
            
            Spacer()
            
            Button(action: onLoad) {
                Text("Load")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(COLOR_WARM_AMBER)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(COLOR_WARM_AMBER.opacity(0.15))
                    .cornerRadius(6)
            }
            
            Button(action: onDelete) {
                Image(systemName: "trash")
                    .foregroundColor(.red)
            }
        }
        .padding(12)
        .background(COLOR_CHARCOAL_LIGHT)
        .cornerRadius(8)
    }
}

struct SavePresetSheet: View {
    @Binding var presetName: String
    let onSave: () -> Void
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            ZStack {
                COLOR_CHARCOAL.ignoresSafeArea()
                
                VStack(spacing: 20) {
                    TextField("Preset name (e.g., 'Party Mix')", text: $presetName)
                        .font(.system(size: 16))
                        .foregroundColor(.white)
                        .padding(16)
                        .background(COLOR_CHARCOAL_LIGHT)
                        .cornerRadius(12)
                    
                    Spacer()
                }
                .padding(20)
            }
            .navigationTitle("Save Preset")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(COLOR_TEXT_SECONDARY)
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        onSave()
                        dismiss()
                    }
                    .foregroundColor(COLOR_WARM_AMBER)
                    .disabled(presetName.isEmpty)
                }
            }
        }
    }
}

// MARK: - Party Mode View
struct PartyModeView: View {
    let drink: DrinkDetails
    let initialMultiplier: Double
    let initialUnit: VolumeUnit
    
    @StateObject private var calculator = BatchCalculatorManager.shared
    @State private var batchesMade: Int = 0
    @Environment(\.dismiss) var dismiss
    
    var totalServings: Int {
        Int(initialMultiplier) * batchesMade
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                COLOR_CHARCOAL.ignoresSafeArea()
                
                VStack(spacing: 32) {
                    Spacer()
                    
                    // Counter Display
                    VStack(spacing: 16) {
                        Text(drink.strDrink)
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(.white)
                            .multilineTextAlignment(.center)
                        
                        Text("\(batchesMade)")
                            .font(.system(size: 80, weight: .bold))
                            .foregroundColor(COLOR_WARM_AMBER)
                        
                        Text("batches made")
                            .font(.system(size: 18))
                            .foregroundColor(COLOR_TEXT_SECONDARY)
                        
                        Text("\(totalServings) total servings")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.white)
                    }
                    
                    Spacer()
                    
                    // Controls
                    HStack(spacing: 20) {
                        Button(action: {
                            if batchesMade > 0 {
                                batchesMade -= 1
                            }
                        }) {
                            Image(systemName: "minus.circle.fill")
                                .font(.system(size: 60))
                                .foregroundColor(batchesMade > 0 ? COLOR_WARM_AMBER : COLOR_TEXT_SECONDARY)
                        }
                        .disabled(batchesMade == 0)
                        
                        Button(action: {
                            batchesMade += 1
                        }) {
                            Image(systemName: "plus.circle.fill")
                                .font(.system(size: 60))
                                .foregroundColor(COLOR_WARM_AMBER)
                        }
                    }
                    
                    Button(action: {
                        batchesMade = 0
                    }) {
                        Text("Reset")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(COLOR_CHARCOAL_LIGHT)
                            .cornerRadius(12)
                    }
                    .padding(.horizontal, 40)
                }
                .padding(20)
            }
            .navigationTitle("Party Mode")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .foregroundColor(COLOR_WARM_AMBER)
                }
            }
        }
    }
}
