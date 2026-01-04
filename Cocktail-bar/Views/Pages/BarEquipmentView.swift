//
//  BarEquipmentView.swift
//  Cocktail-bar
//
//  Created by Kendall Lewis on 1/2/26.
//

import SwiftUI

struct BarEquipmentView: View {
    @Environment(\.colorScheme) var colorScheme
    @StateObject private var equipmentManager = BarEquipmentManager.shared
    @State private var selectedCategory: EquipmentCategory?
    @State private var showingAddEquipment = false
    @State private var selectedTab = 0
    
    var body: some View {
        NavigationView {
            ZStack {
                AppBackground()
                
                VStack(spacing: 0) {
                    // Tab Selector
                    Picker("View Mode", selection: $selectedTab) {
                        Text("All").tag(0)
                        Text("Owned").tag(1)
                        Text("Essentials").tag(2)
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .padding()
                    
                    // Progress Bar
                    EquipmentProgressBar()
                        .padding(.horizontal, 20)
                    
                    // Content
                    TabView(selection: $selectedTab) {
                        AllEquipmentView(selectedCategory: $selectedCategory)
                            .tag(0)
                        
                        OwnedEquipmentView()
                            .tag(1)
                        
                        EssentialsChecklistView()
                            .tag(2)
                    }
                    .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                }
            }
            .navigationTitle("Bar Equipment")
            .navigationBarTitleDisplayMode(.large)
            .toolbarBackground(AdaptiveColors.background(for: colorScheme), for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingAddEquipment = true }) {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingAddEquipment) {
                AddEquipmentView()
            }
        }
    }
}

// MARK: - Equipment Progress Bar
struct EquipmentProgressBar: View {
    @StateObject private var equipmentManager = BarEquipmentManager.shared
    
    var progress: Double {
        equipmentManager.getCompletionPercentage()
    }
    
    var missingCount: Int {
        equipmentManager.getMissingEssentials().count
    }
    
    var body: some View {
        VStack(spacing: 8) {
            HStack {
                Text("Essential Equipment")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                Text("\(Int(progress * 100))% Complete")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(progressColor)
            }
            
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    Rectangle()
                        .foregroundColor(Color(.systemGray5))
                        .cornerRadius(10)
                    
                    Rectangle()
                        .foregroundColor(progressColor)
                        .frame(width: geometry.size.width * CGFloat(progress))
                        .cornerRadius(10)
                }
            }
            .frame(height: 8)
            
            if missingCount > 0 {
                Text("\(missingCount) essential item\(missingCount == 1 ? "" : "s") missing")
                    .font(.caption)
                    .foregroundColor(.orange)
            }
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(12)
    }
    
    var progressColor: Color {
        if progress >= 1.0 {
            return .green
        } else if progress >= 0.5 {
            return .blue
        } else {
            return .orange
        }
    }
}

// MARK: - All Equipment View
struct AllEquipmentView: View {
    @StateObject private var equipmentManager = BarEquipmentManager.shared
    @Binding var selectedCategory: EquipmentCategory?
    
    var filteredEquipment: [BarEquipment] {
        if let category = selectedCategory {
            return equipmentManager.getEquipmentByCategory(category)
        }
        return equipmentManager.equipment
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Category Filter
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    CategoryFilterChip(title: "All", isSelected: selectedCategory == nil) {
                        selectedCategory = nil
                    }
                    
                    ForEach(EquipmentCategory.allCases, id: \.self) { category in
                        CategoryFilterChip(
                            title: category.rawValue,
                            icon: category.icon,
                            isSelected: selectedCategory == category
                        ) {
                            selectedCategory = category
                        }
                    }
                }
                .padding()
            }
            
            // Equipment List
            List {
                ForEach(filteredEquipment) { item in
                    EquipmentRow(equipment: item)
                }
            }
        }
    }
}

// MARK: - Category Filter Chip
struct CategoryFilterChip: View {
    let title: String
    var icon: String? = nil
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                if let icon = icon {
                    Image(systemName: icon)
                }
                Text(title)
            }
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

// MARK: - Equipment Row
struct EquipmentRow: View {
    @StateObject private var equipmentManager = BarEquipmentManager.shared
    let equipment: BarEquipment
    
    var body: some View {
        HStack(spacing: 12) {
            // Checkbox
            Button(action: toggleOwned) {
                Image(systemName: equipment.isOwned ? "checkmark.circle.fill" : "circle")
                    .font(.title2)
                    .foregroundColor(equipment.isOwned ? .green : .gray)
            }
            .buttonStyle(PlainButtonStyle())
            
            // Icon
            Image(systemName: equipment.category.icon)
                .font(.title3)
                .foregroundColor(.blue)
                .frame(width: 30)
            
            // Info
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(equipment.name)
                        .font(.subheadline)
                        .fontWeight(.medium)
                    
                    if equipment.isEssential {
                        Image(systemName: "star.fill")
                            .font(.caption)
                            .foregroundColor(.orange)
                    }
                }
                
                Text(equipment.description)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(2)
                
                if let cost = equipment.cost {
                    Text("$\(cost, specifier: "%.2f")")
                        .font(.caption)
                        .foregroundColor(.green)
                }
            }
        }
        .padding(.vertical, 4)
        .contentShape(Rectangle())
        .onTapGesture {
            toggleOwned()
        }
    }
    
    func toggleOwned() {
        var updated = equipment
        updated.isOwned.toggle()
        if updated.isOwned && updated.purchaseDate == nil {
            updated.purchaseDate = Date()
        }
        equipmentManager.updateEquipment(updated)
    }
}

// MARK: - Owned Equipment View
struct OwnedEquipmentView: View {
    @StateObject private var equipmentManager = BarEquipmentManager.shared
    
    var ownedEquipment: [BarEquipment] {
        equipmentManager.getOwnedEquipment()
    }
    
    var groupedEquipment: [EquipmentCategory: [BarEquipment]] {
        Dictionary(grouping: ownedEquipment, by: { $0.category })
    }
    
    var body: some View {
        if ownedEquipment.isEmpty {
            VStack(spacing: 20) {
                Image(systemName: "tray")
                    .font(.iconLarge)
                    .foregroundColor(.gray)
                
                Text("No Equipment Owned")
                    .font(.title2)
                    .fontWeight(.semibold)
                
                Text("Mark equipment as owned to\ntrack your bar inventory")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            .padding()
        } else {
            List {
                ForEach(EquipmentCategory.allCases, id: \.self) { category in
                    if let items = groupedEquipment[category], !items.isEmpty {
                        Section(header: HStack {
                            Image(systemName: category.icon)
                            Text(category.rawValue)
                        }) {
                            ForEach(items) { item in
                                EquipmentDetailRow(equipment: item)
                            }
                        }
                    }
                }
            }
        }
    }
}

// MARK: - Equipment Detail Row
struct EquipmentDetailRow: View {
    let equipment: BarEquipment
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(equipment.name)
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                if equipment.isEssential {
                    Image(systemName: "star.fill")
                        .font(.caption)
                        .foregroundColor(.orange)
                }
            }
            
            Text(equipment.description)
                .font(.caption)
                .foregroundColor(.secondary)
            
            HStack {
                if let purchaseDate = equipment.purchaseDate {
                    Text(purchaseDate.formatted(date: .abbreviated, time: .omitted))
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                if let cost = equipment.cost {
                    Label("$\(cost, specifier: "%.2f")", systemImage: "dollarsign.circle")
                        .font(.caption)
                        .foregroundColor(.green)
                }
                
                if let location = equipment.storageLocation {
                    Label(location, systemImage: "location")
                        .font(.caption)
                        .foregroundColor(.blue)
                }
            }
        }
        .padding(.vertical, 4)
    }
}

// MARK: - Essentials Checklist View
struct EssentialsChecklistView: View {
    @StateObject private var equipmentManager = BarEquipmentManager.shared
    
    var essentialEquipment: [BarEquipment] {
        equipmentManager.getEssentialEquipment()
    }
    
    var missingEssentials: [BarEquipment] {
        equipmentManager.getMissingEssentials()
    }
    
    var body: some View {
        List {
            Section(header: Text("Missing Essentials (\(missingEssentials.count))"),
                    footer: Text("These items are essential for making most cocktails.")) {
                if missingEssentials.isEmpty {
                    HStack {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.green)
                        Text("You have all essential equipment!")
                            .foregroundColor(.secondary)
                    }
                } else {
                    ForEach(missingEssentials) { item in
                        EquipmentRow(equipment: item)
                    }
                }
            }
            
            Section(header: Text("Owned Essentials")) {
                ForEach(essentialEquipment.filter { $0.isOwned }) { item in
                    EquipmentRow(equipment: item)
                }
            }
        }
    }
}

// MARK: - Add Equipment View
struct AddEquipmentView: View {
    @StateObject private var equipmentManager = BarEquipmentManager.shared
    @Environment(\.presentationMode) var presentationMode
    
    @State private var name = ""
    @State private var description = ""
    @State private var selectedCategory: EquipmentCategory = .tools
    @State private var cost = ""
    @State private var storageLocation = ""
    @State private var isEssential = false
    @State private var isOwned = false
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Basic Information")) {
                    TextField("Equipment Name", text: $name)
                    
                    Picker("Category", selection: $selectedCategory) {
                        ForEach(EquipmentCategory.allCases, id: \.self) { category in
                            HStack {
                                Image(systemName: category.icon)
                                Text(category.rawValue)
                            }
                            .tag(category)
                        }
                    }
                    
                    TextField("Description", text: $description)
                }
                
                Section(header: Text("Cost (Optional)")) {
                    HStack {
                        Text("$")
                            .foregroundColor(.secondary)
                        TextField("0.00", text: $cost)
                            .keyboardType(.decimalPad)
                    }
                }
                
                Section(header: Text("Storage Location (Optional)")) {
                    TextField("e.g., Kitchen Cabinet", text: $storageLocation)
                }
                
                Section {
                    Toggle("Mark as Essential", isOn: $isEssential)
                    Toggle("I Own This", isOn: $isOwned)
                }
            }
            .navigationTitle("Add Equipment")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        saveEquipment()
                    }
                    .disabled(!isValid)
                }
            }
        }
    }
    
    var isValid: Bool {
        !name.isEmpty && !description.isEmpty
    }
    
    func saveEquipment() {
        let costValue = Double(cost)
        
        let equipment = BarEquipment(
            name: name,
            category: selectedCategory,
            description: description,
            isOwned: isOwned,
            purchaseDate: isOwned ? Date() : nil,
            cost: costValue,
            storageLocation: storageLocation.isEmpty ? nil : storageLocation,
            isEssential: isEssential
        )
        
        equipmentManager.addEquipment(equipment)
        presentationMode.wrappedValue.dismiss()
    }
}

// MARK: - Equipment Required View (for cocktail details)
struct EquipmentRequiredView: View {
    @StateObject private var equipmentManager = BarEquipmentManager.shared
    let cocktail: DrinkDetails
    
    var requiredEquipment: [String] {
        equipmentManager.getRequiredEquipmentFor(cocktail)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Equipment Needed")
                .font(.headline)
            
            ForEach(requiredEquipment, id: \.self) { equipmentName in
                HStack {
                    Image(systemName: isOwned(equipmentName) ? "checkmark.circle.fill" : "circle")
                        .foregroundColor(isOwned(equipmentName) ? .green : .orange)
                    
                    Text(equipmentName)
                        .font(.subheadline)
                        .foregroundColor(isOwned(equipmentName) ? .primary : .orange)
                }
            }
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(12)
    }
    
    func isOwned(_ equipmentName: String) -> Bool {
        equipmentManager.equipment.contains { equipment in
            equipment.name.localizedCaseInsensitiveContains(equipmentName) && equipment.isOwned
        }
    }
}
