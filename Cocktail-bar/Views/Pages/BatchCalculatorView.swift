//
//  BatchCalculatorView.swift
//  Cocktail-bar
//

import SwiftUI

// MARK: - Batch Calculator View
struct BatchCalculatorView: View {
    let drink: DrinkDetails
    @StateObject private var calculator = BatchCalculatorManager.shared
    @State private var selectedMultiplier: Double = 1.0
    @State private var selectedUnit: VolumeUnit = .oz
    @State private var showSavePreset = false
    @State private var presetName = ""
    @State private var showPartyMode = false
    @Environment(\.dismiss) var dismiss

    private let quickMultipliers: [Double] = [1, 2, 4, 6, 8, 10, 15, 20]

    var scaledIngredients: [ScaledIngredient] {
        calculator.scaleRecipe(drink: drink, multiplier: selectedMultiplier, targetUnit: selectedUnit)
    }

    var body: some View {
        NavigationView {
            ZStack {
                COLOR_BACKGROUND.ignoresSafeArea()
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 32) {
                        headerSection
                        servingsSection
                        unitSection
                        ingredientsSection
                        actionsSection
                        if !calculator.savedPresets.filter({ $0.drinkId == drink.idDrink }).isEmpty {
                            presetsSection
                        }
                        Spacer(minLength: 48)
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 28)
                }
            }
            .navigationTitle("Batch Calculator")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(COLOR_CHARCOAL, for: .navigationBar)
        }
        .sheet(isPresented: $showSavePreset) {
            SavePresetSheet(presetName: $presetName) {
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
        }
        .sheet(isPresented: $showPartyMode) {
            PartyModeView(drink: drink, initialMultiplier: selectedMultiplier, initialUnit: selectedUnit)
        }
        .onAppear { selectedUnit = calculator.preferredUnit }
    }

    // MARK: - Header

    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(drink.strDrink)
                .font(.system(size: 28, weight: .bold))
                .foregroundColor(COLOR_TEXT_PRIMARY)
            if let category = drink.strCategory {
                Text(category)
                    .font(.system(size: 14))
                    .foregroundColor(COLOR_TEXT_SECONDARY)
            }
            HStack(spacing: 10) {
                BatchInfoPill(icon: "person.2.fill", text: servingsText)
                BatchInfoPill(icon: "drop.fill", text: totalVolumeText)
            }
            .padding(.top, 4)
        }
    }

    private var servingsText: String {
        let n = Int(selectedMultiplier)
        return "\(n) serving\(n == 1 ? "" : "s")"
    }

    private var totalVolumeText: String {
        let total = scaledIngredients
            .filter { $0.parsedOriginalAmount != nil }
            .reduce(0.0) { $0 + $1.scaledAmount }
        return String(format: "%.1f %@", total, selectedUnit.rawValue)
    }

    // MARK: - Servings

    private var servingsSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("SERVINGS")
                .font(.system(size: 11, weight: .semibold))
                .foregroundColor(COLOR_TEXT_SECONDARY)
                .kerning(1)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(quickMultipliers, id: \.self) { m in
                        BatchMultiplierChip(label: "\(Int(m))x", isSelected: selectedMultiplier == m) {
                            selectedMultiplier = m
                        }
                    }
                }
                .padding(.vertical, 2)
            }

            HStack(spacing: 0) {
                Button {
                    if selectedMultiplier > 1 { selectedMultiplier -= 1 }
                } label: {
                    Image(systemName: "minus")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(selectedMultiplier > 1 ? COLOR_WARM_AMBER : COLOR_TEXT_SECONDARY.opacity(0.3))
                        .frame(width: 56, height: 56)
                        .contentShape(Rectangle())
                }
                .disabled(selectedMultiplier <= 1)

                Spacer()

                VStack(spacing: 2) {
                    Text("\(Int(selectedMultiplier))")
                        .font(.system(size: 40, weight: .bold))
                        .foregroundColor(COLOR_TEXT_PRIMARY)
                        .monospacedDigit()
                    Text("servings")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(COLOR_TEXT_SECONDARY)
                }

                Spacer()

                Button {
                    if selectedMultiplier < 50 { selectedMultiplier += 1 }
                } label: {
                    Image(systemName: "plus")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(selectedMultiplier < 50 ? COLOR_WARM_AMBER : COLOR_TEXT_SECONDARY.opacity(0.3))
                        .frame(width: 56, height: 56)
                        .contentShape(Rectangle())
                }
                .disabled(selectedMultiplier >= 50)
            }
            .padding(.vertical, 8)
            .background(COLOR_CHARCOAL_LIGHT)
            .cornerRadius(14)
        }
    }

    // MARK: - Units

    private var unitSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("UNITS")
                .font(.system(size: 11, weight: .semibold))
                .foregroundColor(COLOR_TEXT_SECONDARY)
                .kerning(1)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(VolumeUnit.allCases, id: \.self) { unit in
                        BatchMultiplierChip(label: unit.rawValue, isSelected: selectedUnit == unit) {
                            selectedUnit = unit
                            calculator.setPreferredUnit(unit)
                        }
                    }
                }
                .padding(.vertical, 2)
            }
        }
    }

    // MARK: - Ingredients

    private var ingredientsSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("INGREDIENTS")
                .font(.system(size: 11, weight: .semibold))
                .foregroundColor(COLOR_TEXT_SECONDARY)
                .kerning(1)

            VStack(spacing: 0) {
                ForEach(Array(scaledIngredients.enumerated()), id: \.element.id) { index, ingredient in
                    BatchIngredientRow(ingredient: ingredient, isLast: index == scaledIngredients.count - 1)
                }
            }
            .background(COLOR_CHARCOAL_LIGHT)
            .cornerRadius(14)
        }
    }

    // MARK: - Actions

    private var actionsSection: some View {
        VStack(spacing: 12) {
            Button { showPartyMode = true } label: {
                HStack(spacing: 8) {
                    Image(systemName: "chart.bar.fill")
                    Text("Party Mode")
                }
                .font(.system(size: 15, weight: .semibold))
                .foregroundColor(.black)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(COLOR_WARM_AMBER)
                .cornerRadius(14)
            }

            HStack(spacing: 12) {
                Button { showSavePreset = true } label: {
                    HStack(spacing: 6) {
                        Image(systemName: "bookmark")
                        Text("Save Preset")
                    }
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(COLOR_WARM_AMBER)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(COLOR_CHARCOAL_LIGHT)
                    .cornerRadius(14)
                }
                Button { shareRecipe() } label: {
                    HStack(spacing: 6) {
                        Image(systemName: "square.and.arrow.up")
                        Text("Share")
                    }
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(COLOR_WARM_AMBER)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(COLOR_CHARCOAL_LIGHT)
                    .cornerRadius(14)
                }
            }
        }
    }

    // MARK: - Presets

    private var presetsSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("SAVED PRESETS")
                .font(.system(size: 11, weight: .semibold))
                .foregroundColor(COLOR_TEXT_SECONDARY)
                .kerning(1)

            VStack(spacing: 0) {
                let drinkPresets = calculator.savedPresets.filter { $0.drinkId == drink.idDrink }
                ForEach(Array(drinkPresets.enumerated()), id: \.element.id) { index, preset in
                    BatchPresetRow(
                        preset: preset,
                        isLast: index == drinkPresets.count - 1,
                        onLoad: { selectedMultiplier = preset.multiplier },
                        onDelete: { calculator.deletePreset(preset) }
                    )
                }
            }
            .background(COLOR_CHARCOAL_LIGHT)
            .cornerRadius(14)
        }
    }

    // MARK: - Share

    private func shareRecipe() {
        var text = "\(drink.strDrink) - Batch Recipe (\(Int(selectedMultiplier))x)\n\nIngredients:\n"
        for ingredient in scaledIngredients {
            text += ingredient.parsedOriginalAmount != nil
                ? "• \(ingredient.displayAmount) \(ingredient.name)\n"
                : "• \(ingredient.originalAmount) \(ingredient.name)\n"
        }
        let vc = UIActivityViewController(activityItems: [text], applicationActivities: nil)
        if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let root = scene.windows.first?.rootViewController {
            root.present(vc, animated: true)
        }
    }
}

// MARK: - Batch Info Pill
struct BatchInfoPill: View {
    let icon: String
    let text: String
    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: icon).font(.system(size: 11))
            Text(text).font(.system(size: 12, weight: .medium))
        }
        .foregroundColor(COLOR_WARM_AMBER)
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(COLOR_WARM_AMBER.opacity(0.12))
        .cornerRadius(20)
    }
}

// MARK: - Batch Multiplier Chip
struct BatchMultiplierChip: View {
    let label: String
    let isSelected: Bool
    let action: () -> Void
    var body: some View {
        Button(action: action) {
            Text(label)
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(isSelected ? .black : COLOR_TEXT_SECONDARY)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(isSelected ? COLOR_WARM_AMBER : Color.white.opacity(0.07))
                .cornerRadius(20)
        }
    }
}

// MARK: - Batch Ingredient Row
struct BatchIngredientRow: View {
    let ingredient: ScaledIngredient
    var isLast: Bool = false
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text(ingredient.name)
                    .font(.system(size: 15))
                    .foregroundColor(COLOR_TEXT_PRIMARY)
                Spacer()
                if ingredient.parsedOriginalAmount != nil {
                    Text(ingredient.displayAmount)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(COLOR_WARM_AMBER)
                } else {
                    Text(ingredient.originalAmount)
                        .font(.system(size: 13))
                        .foregroundColor(COLOR_TEXT_SECONDARY)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
            if !isLast {
                Rectangle().fill(Color.white.opacity(0.08)).frame(height: 1).padding(.leading, 16)
            }
        }
    }
}

// MARK: - Batch Preset Row
struct BatchPresetRow: View {
    let preset: BatchPreset
    var isLast: Bool = false
    let onLoad: () -> Void
    let onDelete: () -> Void
    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 12) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(preset.name)
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(COLOR_TEXT_PRIMARY)
                    Text("\(Int(preset.multiplier))x servings")
                        .font(.system(size: 12))
                        .foregroundColor(COLOR_TEXT_SECONDARY)
                }
                Spacer()
                Button(action: onLoad) {
                    Text("Load")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(COLOR_WARM_AMBER)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 6)
                        .background(COLOR_WARM_AMBER.opacity(0.12))
                        .cornerRadius(8)
                }
                Button(action: onDelete) {
                    Image(systemName: "trash").font(.system(size: 14)).foregroundColor(.red.opacity(0.8))
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
            if !isLast {
                Rectangle().fill(Color.white.opacity(0.08)).frame(height: 1).padding(.leading, 16)
            }
        }
    }
}

// MARK: - Save Preset Sheet
struct SavePresetSheet: View {
    @Binding var presetName: String
    let onSave: () -> Void
    @Environment(\.dismiss) var dismiss
    var body: some View {
        NavigationView {
            ZStack {
                COLOR_BACKGROUND.ignoresSafeArea()
                VStack(alignment: .leading, spacing: 20) {
                    Text("NAME YOUR PRESET")
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundColor(COLOR_TEXT_SECONDARY)
                        .kerning(1)
                    TextField("e.g. Party Mix", text: $presetName)
                        .font(.system(size: 16))
                        .foregroundColor(COLOR_TEXT_PRIMARY)
                        .padding(16)
                        .background(Color.white.opacity(0.07))
                        .cornerRadius(13)
                    Spacer()
                }
                .padding(.horizontal, 20)
                .padding(.top, 28)
            }
            .navigationTitle("Save Preset")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(COLOR_CHARCOAL, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") { onSave(); dismiss() }
                        .foregroundColor(COLOR_WARM_AMBER).disabled(presetName.isEmpty)
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
    @State private var batchesMade: Int = 0
    @Environment(\.dismiss) var dismiss

    var totalServings: Int { Int(initialMultiplier) * batchesMade }

    var body: some View {
        NavigationView {
            ZStack {
                COLOR_BACKGROUND.ignoresSafeArea()
                VStack(spacing: 0) {
                    Spacer()
                    VStack(spacing: 8) {
                        Text(drink.strDrink)
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(COLOR_TEXT_SECONDARY)
                            .multilineTextAlignment(.center)
                        Text("\(batchesMade)")
                            .font(.system(size: 96, weight: .bold, design: .rounded))
                            .foregroundColor(COLOR_WARM_AMBER)
                            .monospacedDigit()
                        Text("batches made")
                            .font(.system(size: 14))
                            .foregroundColor(COLOR_TEXT_SECONDARY)
                        Text("\(totalServings) total servings")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(COLOR_TEXT_PRIMARY)
                            .padding(.top, 4)
                    }
                    .padding(32)
                    .frame(maxWidth: .infinity)
                    .background(COLOR_CHARCOAL_LIGHT)
                    .cornerRadius(20)
                    .padding(.horizontal, 20)

                    Spacer()

                    HStack(spacing: 40) {
                        Button { if batchesMade > 0 { batchesMade -= 1 } } label: {
                            ZStack {
                                Circle()
                                    .fill(batchesMade > 0 ? COLOR_WARM_AMBER.opacity(0.15) : Color.white.opacity(0.04))
                                    .frame(width: 72, height: 72)
                                Image(systemName: "minus")
                                    .font(.system(size: 24, weight: .bold))
                                    .foregroundColor(batchesMade > 0 ? COLOR_WARM_AMBER : COLOR_TEXT_SECONDARY.opacity(0.3))
                            }
                        }
                        .disabled(batchesMade == 0)

                        Button { batchesMade += 1 } label: {
                            ZStack {
                                Circle().fill(COLOR_WARM_AMBER).frame(width: 72, height: 72)
                                Image(systemName: "plus")
                                    .font(.system(size: 24, weight: .bold))
                                    .foregroundColor(.black)
                            }
                        }
                    }

                    Button { batchesMade = 0 } label: {
                        Text("Reset")
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundColor(COLOR_TEXT_SECONDARY)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(COLOR_CHARCOAL_LIGHT)
                            .cornerRadius(14)
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 32)
                    .padding(.bottom, 48)
                }
            }
            .navigationTitle("Party Mode")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(COLOR_CHARCOAL, for: .navigationBar)
        }
    }
}

// MARK: - Legacy stubs
struct InfoPill: View {
    let icon: String; let text: String; let color: Color
    var body: some View { BatchInfoPill(icon: icon, text: text) }
}
struct MultiplierButton: View {
    let multiplier: Double; let isSelected: Bool; let action: () -> Void
    var body: some View { BatchMultiplierChip(label: "\(Int(multiplier))x", isSelected: isSelected, action: action) }
}
struct UnitButton: View {
    let unit: VolumeUnit; let isSelected: Bool; let action: () -> Void
    var body: some View { BatchMultiplierChip(label: unit.rawValue, isSelected: isSelected, action: action) }
}
struct IngredientRow: View {
    let ingredient: ScaledIngredient
    var body: some View { BatchIngredientRow(ingredient: ingredient) }
}
struct PresetRow: View {
    let preset: BatchPreset; let onLoad: () -> Void; let onDelete: () -> Void
    var body: some View { BatchPresetRow(preset: preset, onLoad: onLoad, onDelete: onDelete) }
}
