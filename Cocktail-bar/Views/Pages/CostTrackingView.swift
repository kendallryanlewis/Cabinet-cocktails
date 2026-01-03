//
//  CostTrackingView.swift
//  Cocktail-bar
//
//  Created by Kendall Lewis on 1/2/26.
//

import SwiftUI

struct CostTrackingView: View {
    @StateObject private var costManager = CostTrackingManager.shared
    @State private var selectedTab = 0
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Tab Selector
                Picker("View Mode", selection: $selectedTab) {
                    Text("Budget").tag(0)
                    Text("Ingredients").tag(1)
                    Text("Analytics").tag(2)
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding()
                
                // Content
                TabView(selection: $selectedTab) {
                    BudgetOverviewView()
                        .tag(0)
                    
                    IngredientCostsView()
                        .tag(1)
                    
                    SpendingAnalyticsView()
                        .tag(2)
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
            }
            .navigationTitle("Cost Tracking")
            .navigationBarTitleDisplayMode(.large)
        }
    }
}

// MARK: - Budget Overview View
struct BudgetOverviewView: View {
    @StateObject private var costManager = CostTrackingManager.shared
    @State private var showingBudgetEditor = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                if let budget = costManager.budget {
                    // Budget Card
                    BudgetCard(budget: budget)
                        .padding(.horizontal)
                    
                    // Spending Summary
                    SpendingSummaryCard(budget: budget)
                        .padding(.horizontal)
                    
                    // Edit Budget Button
                    Button(action: { showingBudgetEditor = true }) {
                        Label("Edit Budget", systemImage: "pencil")
                            .font(.headline)
                            .foregroundColor(.blue)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color(.systemGray6))
                            .cornerRadius(12)
                    }
                    .padding(.horizontal)
                } else {
                    // No Budget Set
                    VStack(spacing: 20) {
                        Image(systemName: "dollarsign.circle")
                            .font(.system(size: 60))
                            .foregroundColor(.gray)
                        
                        Text("No Budget Set")
                            .font(.title2)
                            .fontWeight(.semibold)
                        
                        Text("Set a budget to track your\ncocktail ingredient spending")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                        
                        Button(action: { showingBudgetEditor = true }) {
                            Label("Set Budget", systemImage: "plus.circle.fill")
                                .font(.headline)
                                .foregroundColor(.white)
                                .padding()
                                .background(Color.blue)
                                .cornerRadius(12)
                        }
                    }
                    .padding()
                }
            }
            .padding(.vertical)
        }
        .sheet(isPresented: $showingBudgetEditor) {
            BudgetEditorView()
        }
    }
}

// MARK: - Budget Card
struct BudgetCard: View {
    @StateObject private var costManager = CostTrackingManager.shared
    let budget: Budget
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(budget.period.rawValue)
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Text("$\(budget.amount, specifier: "%.2f")")
                        .font(.title)
                        .fontWeight(.bold)
                }
                
                Spacer()
                
                Image(systemName: "dollarsign.circle.fill")
                    .font(.system(size: 40))
                    .foregroundColor(.blue)
            }
            
            // Progress Bar
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    Rectangle()
                        .foregroundColor(Color(.systemGray5))
                        .cornerRadius(10)
                    
                    Rectangle()
                        .foregroundColor(progressColor)
                        .frame(width: geometry.size.width * CGFloat(costManager.getBudgetProgress()))
                        .cornerRadius(10)
                }
            }
            .frame(height: 8)
            
            HStack {
                Text("Budget Period")
                    .font(.caption)
                    .foregroundColor(.secondary)
                Spacer()
                Text(formatDateRange(budget))
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(16)
    }
    
    var progressColor: Color {
        let progress = costManager.getBudgetProgress()
        if progress >= 1.0 {
            return .red
        } else if progress >= 0.75 {
            return .orange
        } else {
            return .green
        }
    }
    
    func formatDateRange(_ budget: Budget) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        return "\(formatter.string(from: budget.startDate)) - \(formatter.string(from: budget.endDate))"
    }
}

// MARK: - Spending Summary Card
struct SpendingSummaryCard: View {
    @StateObject private var costManager = CostTrackingManager.shared
    let budget: Budget
    
    var spent: Double {
        costManager.getTotalSpending(for: budget.period)
    }
    
    var remaining: Double {
        costManager.getRemainingBudget() ?? 0
    }
    
    var body: some View {
        VStack(spacing: 16) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Spent")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text("$\(spent, specifier: "%.2f")")
                        .font(.title3)
                        .fontWeight(.semibold)
                        .foregroundColor(.red)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text("Remaining")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text("$\(remaining, specifier: "%.2f")")
                        .font(.title3)
                        .fontWeight(.semibold)
                        .foregroundColor(remaining < 0 ? .red : .green)
                }
                .frame(maxWidth: .infinity, alignment: .trailing)
            }
            
            if costManager.isOverBudget() {
                HStack {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .foregroundColor(.red)
                    Text("Over budget by $\(abs(remaining), specifier: "%.2f")")
                        .font(.caption)
                        .foregroundColor(.red)
                }
                .padding(.vertical, 8)
                .padding(.horizontal, 12)
                .background(Color.red.opacity(0.1))
                .cornerRadius(8)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
    }
}

// MARK: - Budget Editor View
struct BudgetEditorView: View {
    @StateObject private var costManager = CostTrackingManager.shared
    @Environment(\.presentationMode) var presentationMode
    
    @State private var amount: String = ""
    @State private var selectedPeriod: BudgetPeriod = .monthly
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Budget Amount")) {
                    HStack {
                        Text("$")
                            .foregroundColor(.secondary)
                        TextField("0.00", text: $amount)
                            .keyboardType(.decimalPad)
                    }
                }
                
                Section(header: Text("Budget Period")) {
                    Picker("Period", selection: $selectedPeriod) {
                        ForEach(BudgetPeriod.allCases, id: \.self) { period in
                            Text(period.rawValue).tag(period)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                }
                
                Section(footer: Text("Your budget will reset at the end of each period.")) {
                    Button(action: saveBudget) {
                        Text("Save Budget")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(isValid ? Color.blue : Color.gray)
                            .cornerRadius(12)
                    }
                    .disabled(!isValid)
                    .buttonStyle(PlainButtonStyle())
                }
            }
            .navigationTitle("Set Budget")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
            .onAppear {
                if let budget = costManager.budget {
                    amount = String(format: "%.2f", budget.amount)
                    selectedPeriod = budget.period
                }
            }
        }
    }
    
    var isValid: Bool {
        guard let value = Double(amount) else { return false }
        return value > 0
    }
    
    func saveBudget() {
        guard let value = Double(amount) else { return }
        let budget = Budget(amount: value, period: selectedPeriod)
        costManager.budget = budget
        costManager.saveBudget()
        presentationMode.wrappedValue.dismiss()
    }
}

// MARK: - Ingredient Costs View
struct IngredientCostsView: View {
    @StateObject private var costManager = CostTrackingManager.shared
    @State private var showingAddCost = false
    
    var body: some View {
        ZStack {
            if costManager.ingredientCosts.isEmpty {
                VStack(spacing: 20) {
                    Image(systemName: "cart")
                        .font(.system(size: 60))
                        .foregroundColor(.gray)
                    
                    Text("No Ingredient Costs")
                        .font(.title2)
                        .fontWeight(.semibold)
                    
                    Text("Track ingredient costs to calculate\ncocktail pricing and manage budget")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                    
                    Button(action: { showingAddCost = true }) {
                        Label("Add Ingredient Cost", systemImage: "plus.circle.fill")
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding()
                            .background(Color.blue)
                            .cornerRadius(12)
                    }
                }
            } else {
                List {
                    ForEach(costManager.ingredientCosts) { cost in
                        NavigationLink(destination: IngredientCostDetailView(cost: cost)) {
                            IngredientCostRow(cost: cost)
                        }
                    }
                    .onDelete { indexSet in
                        indexSet.forEach { index in
                            costManager.deleteIngredientCost(costManager.ingredientCosts[index])
                        }
                    }
                }
            }
        }
        .navigationBarItems(trailing: Button(action: { showingAddCost = true }) {
            Image(systemName: "plus")
        })
        .sheet(isPresented: $showingAddCost) {
            AddIngredientCostView()
        }
    }
}

// MARK: - Ingredient Cost Row
struct IngredientCostRow: View {
    let cost: IngredientCost
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(cost.ingredientName)
                .font(.headline)
            
            HStack {
                Text("$\(cost.cost, specifier: "%.2f")")
                    .font(.subheadline)
                    .foregroundColor(.green)
                
                Text("•")
                    .foregroundColor(.secondary)
                
                Text("\(cost.quantity, specifier: "%.1f") \(cost.unit.rawValue)")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Text("•")
                    .foregroundColor(.secondary)
                
                Text("$\(cost.costPerUnit, specifier: "%.2f")/\(cost.unit.rawValue)")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            if let storeName = cost.storeName {
                Text("From \(storeName)")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 4)
    }
}

// MARK: - Add Ingredient Cost View
struct AddIngredientCostView: View {
    @StateObject private var costManager = CostTrackingManager.shared
    @Environment(\.presentationMode) var presentationMode
    
    @State private var ingredientName = ""
    @State private var cost = ""
    @State private var quantity = ""
    @State private var selectedUnit: MeasurementUnit = .oz
    @State private var storeName = ""
    @State private var purchaseDate = Date()
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Ingredient")) {
                    TextField("Ingredient Name", text: $ingredientName)
                }
                
                Section(header: Text("Cost")) {
                    HStack {
                        Text("$")
                            .foregroundColor(.secondary)
                        TextField("0.00", text: $cost)
                            .keyboardType(.decimalPad)
                    }
                }
                
                Section(header: Text("Quantity")) {
                    HStack {
                        TextField("Amount", text: $quantity)
                            .keyboardType(.decimalPad)
                        
                        Picker("Unit", selection: $selectedUnit) {
                            ForEach(MeasurementUnit.allCases, id: \.self) { unit in
                                Text(unit.rawValue).tag(unit)
                            }
                        }
                        .pickerStyle(MenuPickerStyle())
                    }
                }
                
                Section(header: Text("Store (Optional)")) {
                    TextField("Store Name", text: $storeName)
                }
                
                Section(header: Text("Purchase Date")) {
                    DatePicker("Date", selection: $purchaseDate, displayedComponents: .date)
                }
            }
            .navigationTitle("Add Ingredient Cost")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        saveCost()
                    }
                    .disabled(!isValid)
                }
            }
        }
    }
    
    var isValid: Bool {
        guard !ingredientName.isEmpty,
              let costValue = Double(cost), costValue > 0,
              let quantityValue = Double(quantity), quantityValue > 0 else {
            return false
        }
        return true
    }
    
    func saveCost() {
        guard let costValue = Double(cost),
              let quantityValue = Double(quantity) else { return }
        
        let ingredientCost = IngredientCost(
            ingredientName: ingredientName,
            cost: costValue,
            quantity: quantityValue,
            unit: selectedUnit,
            purchaseDate: purchaseDate,
            storeName: storeName.isEmpty ? nil : storeName
        )
        
        costManager.addIngredientCost(ingredientCost)
        presentationMode.wrappedValue.dismiss()
    }
}

// MARK: - Ingredient Cost Detail View
struct IngredientCostDetailView: View {
    let cost: IngredientCost
    
    var body: some View {
        List {
            Section(header: Text("Details")) {
                HStack {
                    Text("Ingredient")
                    Spacer()
                    Text(cost.ingredientName)
                        .foregroundColor(.secondary)
                }
                
                HStack {
                    Text("Total Cost")
                    Spacer()
                    Text("$\(cost.cost, specifier: "%.2f")")
                        .foregroundColor(.green)
                }
                
                HStack {
                    Text("Quantity")
                    Spacer()
                    Text("\(cost.quantity, specifier: "%.1f") \(cost.unit.rawValue)")
                        .foregroundColor(.secondary)
                }
                
                HStack {
                    Text("Cost per Unit")
                    Spacer()
                    Text("$\(cost.costPerUnit, specifier: "%.2f")/\(cost.unit.rawValue)")
                        .foregroundColor(.secondary)
                }
            }
            
            Section(header: Text("Purchase Info")) {
                HStack {
                    Text("Purchase Date")
                    Spacer()
                    Text(cost.purchaseDate, style: .date)
                        .foregroundColor(.secondary)
                }
                
                if let storeName = cost.storeName {
                    HStack {
                        Text("Store")
                        Spacer()
                        Text(storeName)
                            .foregroundColor(.secondary)
                    }
                }
            }
        }
        .navigationTitle("Ingredient Details")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - Spending Analytics View
struct SpendingAnalyticsView: View {
    @StateObject private var costManager = CostTrackingManager.shared
    
    var weeklySpending: Double {
        costManager.getTotalSpending(for: .weekly)
    }
    
    var monthlySpending: Double {
        costManager.getTotalSpending(for: .monthly)
    }
    
    var yearlySpending: Double {
        costManager.getTotalSpending(for: .yearly)
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Spending Overview
                VStack(alignment: .leading, spacing: 16) {
                    Text("Spending Overview")
                        .font(.headline)
                    
                    SpendingPeriodCard(period: "This Week", amount: weeklySpending, icon: "calendar", color: .blue)
                    SpendingPeriodCard(period: "This Month", amount: monthlySpending, icon: "calendar.badge.clock", color: .green)
                    SpendingPeriodCard(period: "This Year", amount: yearlySpending, icon: "calendar.circle", color: .purple)
                }
                .padding()
                
                // Top Ingredients
                if !costManager.ingredientCosts.isEmpty {
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Recent Purchases")
                            .font(.headline)
                            .padding(.horizontal)
                        
                        ForEach(costManager.ingredientCosts.sorted(by: { $0.purchaseDate > $1.purchaseDate }).prefix(5)) { cost in
                            RecentPurchaseRow(cost: cost)
                                .padding(.horizontal)
                        }
                    }
                }
            }
            .padding(.vertical)
        }
    }
}

// MARK: - Spending Period Card
struct SpendingPeriodCard: View {
    let period: String
    let amount: Double
    let icon: String
    let color: Color
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
                .frame(width: 40)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(period)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                Text("$\(amount, specifier: "%.2f")")
                    .font(.title3)
                    .fontWeight(.semibold)
            }
            
            Spacer()
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(12)
    }
}

// MARK: - Recent Purchase Row
struct RecentPurchaseRow: View {
    let cost: IngredientCost
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(cost.ingredientName)
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                Text(cost.purchaseDate, style: .date)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Text("$\(cost.cost, specifier: "%.2f")")
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundColor(.green)
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
    }
}
