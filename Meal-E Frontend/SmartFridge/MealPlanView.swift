//
//  Home.swift
//  SmartFridge
//
//  Created by Michael Pancras on 2/21/26.
//

import SwiftUI

// MARK: - Models

struct MealPlanResponse: Codable {
    let plan: [DayPlan]
}

struct DayPlan: Codable, Identifiable {
    var id: String { day }
    let day: String
    let meals: [Meal]
}

struct Meal: Codable, Identifiable {
    var id: String { name }
    let name: String
    let recipe: String
    let ingredients: [String: String]
    let prepTimeMinutes: Int
    let difficulty: String
    let macros: MealMacros

    enum CodingKeys: String, CodingKey {
        case name, recipe, ingredients, difficulty, macros
        case prepTimeMinutes = "prep_time_minutes"
    }
}

struct MealMacros: Codable {
    let calories: Double
    let carbohydrates: Double
    let protein: Double
    let fat: Double
    let saturatedFat: Double
    let transFat: Double
    let sugar: Double
    let addedSugar: Double
    let fiber: Double
    let sodium: Double
    let iron: Double
    let calcium: Double
    let potassium: Double
    let vitaminD: Double

    enum CodingKeys: String, CodingKey {
        case calories, carbohydrates, protein, fat, fiber, sodium, iron, calcium, potassium
        case saturatedFat = "saturated_fat"
        case transFat     = "trans_fat"
        case sugar        = "sugar"
        case addedSugar   = "added_sugar"
        case vitaminD     = "vitamin_d"
    }
}

// MARK: - Observable Wrapper

@Observable
class MealPlan {
    var week: [DayPlan]

    init(response: MealPlanResponse) {
        self.week = response.plan
    }

    static var placeholder: MealPlan {
        MealPlan(response: MealPlanResponse(plan: [
            DayPlan(day: "Monday", meals: [
                Meal(name: "Hard-Boiled Eggs with Garlic",
                     recipe: "Place eggs in a pot and cover with water. Bring to a boil, then remove from heat and let sit for 10 minutes. Peel and slice. Season with salt, pepper, and garlic powder.",
                     ingredients: ["Eggs": "1 egg (50g)", "Salt": "0.1 tsp", "Black Pepper": "0.1 tsp", "Garlic Powder": "0.1 tsp"],
                     prepTimeMinutes: 15, difficulty: "low",
                     macros: MealMacros(calories: 71.6, carbohydrates: 0.3, protein: 6.0, fat: 5.0, saturatedFat: 1.5, transFat: 0, sugar: 0, addedSugar: 0, fiber: 0.1, sodium: 300.2, iron: 1.0, calcium: 28.0, potassium: 69.0, vitaminD: 1.0)),
                Meal(name: "Garlic Sauteed Spinach",
                     recipe: "Heat olive oil in a pan. Add spinach and garlic powder. Saute until wilted. Season with salt and pepper.",
                     ingredients: ["Spinach": "1 cup (30g)", "Olive Oil": "0.5 tbsp", "Garlic Powder": "0.25 tsp", "Salt": "0.1 tsp"],
                     prepTimeMinutes: 5, difficulty: "low",
                     macros: MealMacros(calories: 69.5, carbohydrates: 1.5, protein: 1.0, fat: 7.0, saturatedFat: 1.0, transFat: 0, sugar: 0, addedSugar: 0, fiber: 1.0, sodium: 254.5, iron: 1.0, calcium: 30.0, potassium: 167.0, vitaminD: 0.0)),
            ]),
            DayPlan(day: "Tuesday", meals: [
                Meal(name: "Soft-Boiled Dipping Egg",
                     recipe: "Boil water, gently lower the egg in, and cook for 6.5 minutes. Immediately place in an ice bath. Peel and serve with salt and pepper.",
                     ingredients: ["Eggs": "1 egg (50g)", "Salt": "0.1 tsp", "Black Pepper": "0.1 tsp"],
                     prepTimeMinutes: 10, difficulty: "low",
                     macros: MealMacros(calories: 70.6, carbohydrates: 0.1, protein: 6.0, fat: 5.0, saturatedFat: 1.5, transFat: 0, sugar: 0, addedSugar: 0, fiber: 0.1, sodium: 300.0, iron: 1.0, calcium: 28.0, potassium: 69.0, vitaminD: 1.0)),
                Meal(name: "Savory Greek Yogurt",
                     recipe: "Whisk greek yogurt with a pinch of salt and onion powder. Divide into two small bowls.",
                     ingredients: ["Greek Yogurt": "3/4 cup (170g)", "Salt": "0.1 tsp", "Onion Powder": "0.1 tsp"],
                     prepTimeMinutes: 5, difficulty: "low",
                     macros: MealMacros(calories: 100.8, carbohydrates: 6.2, protein: 17.0, fat: 0.0, saturatedFat: 0, transFat: 0, sugar: 4.0, addedSugar: 0, fiber: 0.0, sodium: 295.2, iron: 0.0, calcium: 200.0, potassium: 240.0, vitaminD: 0.0)),
            ])
        ]))
    }
}

// MARK: - Difficulty Color

extension Meal {
    var difficultyColor: Color {
        switch difficulty.lowercased() {
        case "low":    return Color(hex: "34C759")
        case "medium": return Color(hex: "FF9F0A")
        case "high":   return Color(hex: "FF3B30")
        default:       return Color(hex: "8E8E93")
        }
    }
}

// MARK: - Meal Plan View

struct MealPlanView: View {
    
    @Environment(MealPlan.self) var mealPlan
    @State private var selectedMeal: Meal? = nil
    
    @State var showLoadingScreen: Bool = false

    var body: some View {
        
        if showLoadingScreen {
            LoadingScreen()
                .navigationBarHidden(true)
                .onAppear {
                    Task {
                        do {
                            if let data = try await APIManager.shared.getMealPlan(generate: true) {
                                withAnimation(.easeIn) {
                                    mealPlan.week = data.plan
                                    showLoadingScreen = false
                                }
                                print("Fetched PLAN")
                            }
                        } catch {
                            print(error.localizedDescription)
                        }
                    }
                }
        } else {
            VStack(spacing: 0) {
                
                HStack {
                    Spacer()
                    Spacer()
                    Text("Meal Plan")
                        .font(.system(size: 22, weight: .heavy, design: .serif))
                        .foregroundStyle(Color(hex: "1B4332"))
                    Spacer()
                    Button {
                        withAnimation(.easeIn) {
                            showLoadingScreen = true
                        }
                    } label: {
                        Image(systemName: "arrow.clockwise")
                            .font(.system(size: 22, weight: .heavy, design: .serif))
                            .foregroundStyle(Color(hex: "1B4332"))
                            .padding(.horizontal)
                        
                    }

                }
                .padding(.vertical, 14)
                .background(Color(hex: "D8F3DC"))
                .overlay(Rectangle().fill(Color(hex: "1B4332").opacity(0.07)).frame(height: 1), alignment: .bottom)
                    
                ZStack {
                    LinearGradient(
                        colors: [Color(hex: "D8F3DC"), Color(hex: "EDF7F0"), Color(hex: "F0FAF4")],
                        startPoint: .topLeading, endPoint: .bottomTrailing
                    )
                    .ignoresSafeArea()

                    ScrollView {
                        VStack(spacing: 24) {
                            ForEach(mealPlan.week) { dayPlan in
                                DaySection(dayPlan: dayPlan) { meal in
                                    selectedMeal = meal
                                }
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 20)
                    }
                }
                .navigationTitle("Meal Plan")
                .navigationBarHidden(true)
                .sheet(item: $selectedMeal) { meal in
                    MealDetailSheet(meal: meal)
                }
                .onAppear {
                    Task {
                        do {
                            if let data = try await APIManager.shared.getMealPlan(generate: false) {
                                mealPlan.week = data.plan
                                print("Fetched PLAN")
                            }
                        } catch {
                            print(error.localizedDescription)
                        }
                    }
                }
                
            }
        }
        
    }
}

// MARK: - Day Section

struct DaySection: View {
    let dayPlan: DayPlan
    let onMealTap: (Meal) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(dayPlan.day)
                .font(.system(size: 18, weight: .bold, design: .serif))
                .foregroundColor(Color(hex: "1A4A2A"))
                .padding(.horizontal, 4)

            VStack(spacing: 10) {
                ForEach(dayPlan.meals) { meal in
                    MealCard(meal: meal)
                        .onTapGesture { onMealTap(meal) }
                }
            }
        }
    }
}

// MARK: - Meal Card

struct MealCard: View {
    let meal: Meal

    var body: some View {
        HStack(spacing: 14) {
            VStack(alignment: .leading, spacing: 6) {
                Text(meal.name)
                    .font(.system(size: 15, weight: .semibold, design: .serif))
                    .foregroundColor(Color(hex: "1A4A2A"))

                HStack(spacing: 12) {
                    Label("\(meal.prepTimeMinutes) min", systemImage: "clock")
                        .font(.system(size: 12))
                        .foregroundColor(Color(hex: "3A7A4A"))

                    HStack(spacing: 4) {
                        Circle()
                            .fill(meal.difficultyColor)
                            .frame(width: 7, height: 7)
                        Text(meal.difficulty.capitalized)
                            .font(.system(size: 12))
                            .foregroundColor(Color(hex: "3A7A4A"))
                    }
                }

                HStack(spacing: 6) {
                    MacroPill(label: "\(Int(meal.macros.calories)) cal",           color: Color(hex: "4CAF50"))
                    MacroPill(label: "\(Int(meal.macros.protein))g protein",       color: Color(hex: "2196F3"))
                    MacroPill(label: "\(Int(meal.macros.carbohydrates))g carbs",   color: Color(hex: "FF9800"))
                }
            }

            Spacer()

            Image(systemName: "chevron.right")
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(Color(hex: "3A7A4A").opacity(0.5))
        }
        .padding(.vertical, 14)
        .padding(.horizontal, 16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white.opacity(0.85))
                .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color(hex: "C8E6C9"), lineWidth: 1))
        )
        .shadow(color: Color(hex: "1A4A2A").opacity(0.06), radius: 6, x: 0, y: 2)
    }
}

// MARK: - Macro Pill

struct MacroPill: View {
    let label: String
    let color: Color

    var body: some View {
        Text(label)
            .font(.system(size: 11, weight: .medium))
            .foregroundColor(color)
            .padding(.horizontal, 8)
            .padding(.vertical, 3)
            .background(color.opacity(0.1))
            .clipShape(Capsule())
    }
}

// MARK: - Meal Detail Sheet

struct MealDetailSheet: View {
    let meal: Meal
    @Environment(\.dismiss) var dismiss

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {

                    // Header Stats
                    HStack(spacing: 12) {
                        StatsCard(value: "\(Int(meal.macros.calories))", label: "Calories",   color: Color(hex: "4CAF50"))
                        StatsCard(value: "\(meal.prepTimeMinutes)m",     label: "Prep Time",  color: Color(hex: "2196F3"))
                        StatsCard(value: meal.difficulty.capitalized,    label: "Difficulty", color: meal.difficultyColor)
                    }

                    // Macros
                    SectionCard(title: "Macros", icon: "chart.pie.fill") {
                        VStack(spacing: 10) {
                            MacroRow(label: "Calories",      value: "\(Int(meal.macros.calories)) kcal",      color: Color(hex: "4CAF50"))
                            MacroRow(label: "Protein",       value: "\(Int(meal.macros.protein))g",           color: Color(hex: "2196F3"))
                            MacroRow(label: "Carbohydrates", value: "\(Int(meal.macros.carbohydrates))g",     color: Color(hex: "FF9800"))
                            MacroRow(label: "Fat",           value: "\(Int(meal.macros.fat))g",               color: Color(hex: "FF5722"))
                            MacroRow(label: "Fiber",         value: "\(Int(meal.macros.fiber))g",             color: Color(hex: "4CAF50"))
                            MacroRow(label: "Sugar",         value: "\(Int(meal.macros.sugar))g",             color: Color(hex: "E91E63"))
                            MacroRow(label: "Sodium",        value: "\(Int(meal.macros.sodium))mg",           color: Color(hex: "9C27B0"))
                        }
                    }

                    // Ingredients
                    SectionCard(title: "Ingredients", icon: "basket.fill") {
                        VStack(spacing: 8) {
                            ForEach(meal.ingredients.sorted(by: { $0.key < $1.key }), id: \.key) { name, amount in
                                HStack {
                                    Text("•  \(name)")
                                        .font(.system(size: 14, weight: .medium))
                                        .foregroundColor(Color(hex: "1A4A2A"))
                                    Spacer()
                                    Text(amount)
                                        .font(.system(size: 13))
                                        .foregroundColor(Color(hex: "3A7A4A").opacity(0.8))
                                }
                            }
                        }
                    }

                    // Recipe
                    SectionCard(title: "Recipe", icon: "doc.text") {
                        Text(meal.recipe)
                            .font(.system(size: 14))
                            .foregroundColor(Color(hex: "1A4A2A"))
                            .lineSpacing(6)
                    }

                    // Additional Nutrients
                    SectionCard(title: "Additional Nutrients", icon: "leaf.fill") {
                        VStack(spacing: 10) {
                            MacroRow(label: "Saturated Fat", value: "\(Int(meal.macros.saturatedFat))g",  color: Color(hex: "FF5722"))
                            MacroRow(label: "Calcium",       value: "\(Int(meal.macros.calcium))mg",      color: Color(hex: "00BCD4"))
                            MacroRow(label: "Iron",          value: "\(Int(meal.macros.iron))mg",         color: Color(hex: "795548"))
                            MacroRow(label: "Potassium",     value: "\(Int(meal.macros.potassium))mg",    color: Color(hex: "607D8B"))
                            MacroRow(label: "Vitamin D",     value: "\(meal.macros.vitaminD)mcg",         color: Color(hex: "FFC107"))
                        }
                    }
                }
                .padding(16)
            }
            .background(
                LinearGradient(
                    colors: [Color(hex: "F2F7F2"), Color(hex: "E8F4E8")],
                    startPoint: .top, endPoint: .bottom
                )
                .ignoresSafeArea()
            )
            .navigationTitle(meal.name)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { dismiss() }
                        .foregroundColor(Color(hex: "3A7A4A"))
                        .fontWeight(.semibold)
                }
            }
        }
    }
}

// MARK: - Reusable Components

struct StatsCard: View {
    let value: String
    let label: String
    let color: Color

    var body: some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(color)
            Text(label)
                .font(.system(size: 11))
                .foregroundColor(Color(hex: "3A7A4A").opacity(0.7))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 14)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(color.opacity(0.08))
                .overlay(RoundedRectangle(cornerRadius: 14).stroke(color.opacity(0.2), lineWidth: 1))
        )
    }
}

struct SectionCard<Content: View>: View {
    let title: String
    let icon: String
    @ViewBuilder let content: Content

    var body: some View {
        HStack {
            Spacer()
            VStack(alignment: .leading, spacing: 14) {
                HStack(spacing: 7) {
                    Image(systemName: icon)
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(Color(hex: "3A7A4A"))
                    Text(title)
                        .font(.system(size: 15, weight: .semibold, design: .serif))
                        .foregroundColor(Color(hex: "1A4A2A"))
                }
                content
            }
            Spacer()
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white.opacity(0.85))
                .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color(hex: "C8E6C9"), lineWidth: 1))
        )
        .shadow(color: Color(hex: "1A4A2A").opacity(0.05), radius: 5, x: 0, y: 2)
    }
}

struct MacroRow: View {
    let label: String
    let value: String
    let color: Color

    var body: some View {
        HStack {
            HStack(spacing: 8) {
                RoundedRectangle(cornerRadius: 3)
                    .fill(color)
                    .frame(width: 4, height: 16)
                Text(label)
                    .font(.system(size: 14))
                    .foregroundColor(Color(hex: "1A4A2A"))
            }
            Spacer()
            Text(value)
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(Color(hex: "1A4A2A"))
        }
    }
}

// MARK: - Preview

#Preview {
    NavigationStack {
        MealPlanView()
            .environment(MealPlan.placeholder)
    }
}

//import SwiftUI
//
//// MARK: - Models
//
//@Observable
//class MealPlan {
//    let week: [DayPlan]
//    
//    init(response: MealPlanResponse) {
//        self.week = response.week
//    }
//    
//}
//
//struct MealPlanResponse: Codable {
//    let week: [DayPlan]
//}
//
//struct DayPlan: Codable, Identifiable {
//    var id: String { day }
//    let day: String
//    let meals: [String: Meal]
//}
//
//struct Meal: Codable {
//    let servings: Int
//    let prepTimeMinutes: Int
//    let barcodeIngredients: [String: BarcodeIngredient]
//    let produceIngredients: [String: ProduceIngredient]
//    let spicesAndZeroNutriment: [String]
//    let recipe: [String]
//
//    enum CodingKeys: String, CodingKey {
//        case servings
//        case prepTimeMinutes        = "prep_time_minutes"
//        case barcodeIngredients     = "barcode_ingredients"
//        case produceIngredients     = "produce_ingredients"
//        case spicesAndZeroNutriment = "spices_and_zero_nutriment"
//        case recipe
//    }
//}
//
//struct BarcodeIngredient: Codable {
//    let quantity: Double
//    let unit: String
//}
//
//struct ProduceIngredient: Codable {
//    let quantity: Double
//    let unit: String
//    let nutrimentsPer100g: Nutriments
//    let nutrimentsForQuantity: Nutriments
//
//    enum CodingKeys: String, CodingKey {
//        case quantity, unit
//        case nutrimentsPer100g     = "nutriments_per_100g"
//        case nutrimentsForQuantity = "nutriments_for_quantity"
//    }
//}
//
//struct Nutriments: Codable {
//    let energyKcal: Double
//    let proteinG: Double
//    let carbsG: Double
//    let fatG: Double
//    let fiberG: Double?
//
//    enum CodingKeys: String, CodingKey {
//        case energyKcal = "energy_kcal"
//        case proteinG   = "protein_g"
//        case carbsG     = "carbs_g"
//        case fatG       = "fat_g"
//        case fiberG     = "fiber_g"
//    }
//}
//
//// MARK: - Helpers
//
//let mealOrder = ["Breakfast", "Lunch", "Dinner"]
//
//// Totals across all produce ingredients for a meal
//extension Meal {
//    var totalCalories: Double  { produceIngredients.values.reduce(0) { $0 + $1.nutrimentsForQuantity.energyKcal } }
//    var totalProtein: Double   { produceIngredients.values.reduce(0) { $0 + $1.nutrimentsForQuantity.proteinG } }
//    var totalCarbs: Double     { produceIngredients.values.reduce(0) { $0 + $1.nutrimentsForQuantity.carbsG } }
//    var totalFat: Double       { produceIngredients.values.reduce(0) { $0 + $1.nutrimentsForQuantity.fatG } }
//    var totalFiber: Double     { produceIngredients.values.reduce(0) { $0 + ($1.nutrimentsForQuantity.fiberG ?? 0) } }
//}
//
//// MARK: - Meal Plan View
//
//struct MealPlanView: View {
//    @Environment(MealPlan.self) var mealPlan
//    @State private var selectedMealEntry: (name: String, meal: Meal)? = nil
//
//    var body: some View {
//        ZStack {
//            LinearGradient(
//                colors: [Color(hex: "F2F7F2"), Color(hex: "E8F4E8")],
//                startPoint: .top, endPoint: .bottom
//            )
//            .ignoresSafeArea()
//
//            ScrollView {
//                VStack(spacing: 24) {
//                    ForEach(mealPlan.week) { dayPlan in
//                        DaySection(dayPlan: dayPlan) { name, meal in
//                            selectedMealEntry = (name, meal)
//                        }
//                    }
//                }
//                .padding(.horizontal, 16)
//                .padding(.vertical, 20)
//            }
//        }
//        .navigationTitle("Meal Plan")
//        .navigationBarTitleDisplayMode(.large)
//        .sheet(isPresented: Binding(
//            get: { selectedMealEntry != nil },
//            set: { if !$0 { selectedMealEntry = nil } }
//        )) {
//            if let entry = selectedMealEntry {
//                MealDetailSheet(mealName: entry.name, meal: entry.meal)
//            }
//        }
//        .onAppear {
//            print("MEAL PLAN:")
//            print(mealPlan.week.first ?? "None")
//        }
//
//    }
//}
//
//// MARK: - Day Section
//
//struct DaySection: View {
//    let dayPlan: DayPlan
//    let onMealTap: (String, Meal) -> Void
//
//    var body: some View {
//        VStack(alignment: .leading, spacing: 12) {
//            Text(dayPlan.day)
//                .font(.system(size: 18, weight: .bold))
//                .foregroundColor(Color(hex: "1A4A2A"))
//                .padding(.horizontal, 4)
//
//            VStack(spacing: 10) {
//                ForEach(mealOrder, id: \.self) { mealName in
//                    if let meal = dayPlan.meals[mealName] {
//                        MealCard(mealName: mealName, meal: meal)
//                            .onTapGesture { onMealTap(mealName, meal) }
//                    }
//                }
//            }
//        }
//    }
//}
//
//// MARK: - Meal Card
//
//struct MealCard: View {
//    let mealName: String
//    let meal: Meal
//
//    var mealIcon: String {
//        switch mealName {
//        case "Breakfast": return "☀️"
//        case "Lunch":     return "🌤️"
//        case "Dinner":    return "🌙"
//        default:          return "🍽️"
//        }
//    }
//
//    var body: some View {
//        HStack(spacing: 14) {
//            VStack(alignment: .leading, spacing: 6) {
//                HStack(spacing: 6) {
//                    Text(mealIcon).font(.system(size: 14))
//                    Text(mealName)
//                        .font(.system(size: 16, weight: .semibold))
//                        .foregroundColor(Color(hex: "1A4A2A"))
//                }
//
//                Label("\(meal.prepTimeMinutes) min", systemImage: "clock")
//                    .font(.system(size: 12))
//                    .foregroundColor(Color(hex: "3A7A4A"))
//
//                // Produce ingredients as pills
//                let produceNames = meal.produceIngredients.keys.sorted()
//                if !produceNames.isEmpty {
//                    ScrollView(.horizontal, showsIndicators: false) {
//                        HStack(spacing: 6) {
//                            ForEach(produceNames, id: \.self) { name in
//                                MacroPill(label: name, color: Color(hex: "4CAF50"))
//                            }
//                            ForEach(meal.spicesAndZeroNutriment.prefix(2), id: \.self) { spice in
//                                MacroPill(label: spice, color: Color(hex: "FF9800"))
//                            }
//                        }
//                    }
//                }
//
//                // Calorie summary
//                HStack(spacing: 6) {
//                    MacroPill(label: "\(Int(meal.totalCalories)) cal", color: Color(hex: "4CAF50"))
//                    MacroPill(label: "\(Int(meal.totalProtein))g protein", color: Color(hex: "2196F3"))
//                    MacroPill(label: "\(Int(meal.totalCarbs))g carbs", color: Color(hex: "FF9800"))
//                }
//            }
//
//            Spacer()
//
//            Image(systemName: "chevron.right")
//                .font(.system(size: 13, weight: .semibold))
//                .foregroundColor(Color(hex: "3A7A4A").opacity(0.5))
//        }
//        .padding(.vertical, 14)
//        .padding(.horizontal, 16)
//        .background(
//            RoundedRectangle(cornerRadius: 16)
//                .fill(Color.white.opacity(0.85))
//                .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color(hex: "C8E6C9"), lineWidth: 1))
//        )
//        .shadow(color: Color(hex: "1A4A2A").opacity(0.06), radius: 6, x: 0, y: 2)
//    }
//}
//
//// MARK: - Macro Pill
//
//struct MacroPill: View {
//    let label: String
//    let color: Color
//
//    var body: some View {
//        Text(label)
//            .font(.system(size: 11, weight: .medium))
//            .foregroundColor(color)
//            .padding(.horizontal, 8)
//            .padding(.vertical, 3)
//            .background(color.opacity(0.1))
//            .clipShape(Capsule())
//    }
//}
//
//// MARK: - Meal Detail Sheet
//
//struct MealDetailSheet: View {
//    let mealName: String
//    let meal: Meal
//    @Environment(\.dismiss) var dismiss
//
//    var body: some View {
//        NavigationStack {
//            ScrollView {
//                VStack(alignment: .leading, spacing: 24) {
//
//                    // MARK: Header Stats
//                    HStack(spacing: 12) {
//                        StatsCard(value: "\(Int(meal.totalCalories))", label: "Calories",  color: Color(hex: "4CAF50"))
//                        StatsCard(value: "\(meal.prepTimeMinutes)m",   label: "Prep Time", color: Color(hex: "2196F3"))
//                        StatsCard(value: "\(meal.servings)",            label: "Servings",  color: Color(hex: "FF9800"))
//                    }
//
//                    // MARK: Nutrition Summary
//                    SectionCard(title: "Nutrition", icon: "chart.pie.fill") {
//                        VStack(spacing: 10) {
//                            MacroRow(label: "Calories",      value: "\(Int(meal.totalCalories)) kcal", color: Color(hex: "4CAF50"))
//                            MacroRow(label: "Protein",       value: "\(String(format: "%.1f", meal.totalProtein))g",  color: Color(hex: "2196F3"))
//                            MacroRow(label: "Carbohydrates", value: "\(String(format: "%.1f", meal.totalCarbs))g",    color: Color(hex: "FF9800"))
//                            MacroRow(label: "Fat",           value: "\(String(format: "%.1f", meal.totalFat))g",      color: Color(hex: "FF5722"))
//                            MacroRow(label: "Fiber",         value: "\(String(format: "%.1f", meal.totalFiber))g",    color: Color(hex: "4CAF50"))
//                        }
//                    }
//
//                    // MARK: Produce Ingredients
//                    if !meal.produceIngredients.isEmpty {
//                        SectionCard(title: "Fresh Ingredients", icon: "basket.fill") {
//                            VStack(spacing: 10) {
//                                ForEach(meal.produceIngredients.keys.sorted(), id: \.self) { name in
//                                    if let ingredient = meal.produceIngredients[name] {
//                                        HStack {
//                                            VStack(alignment: .leading, spacing: 2) {
//                                                Text("•  \(name)")
//                                                    .font(.system(size: 14, weight: .medium))
//                                                    .foregroundColor(Color(hex: "1A4A2A"))
//                                                Text("\(Int(ingredient.nutrimentsForQuantity.energyKcal)) kcal · \(String(format: "%.1f", ingredient.nutrimentsForQuantity.proteinG))g protein")
//                                                    .font(.system(size: 11))
//                                                    .foregroundColor(Color(hex: "3A7A4A").opacity(0.7))
//                                            }
//                                            Spacer()
//                                            Text("\(ingredient.quantity, specifier: ingredient.quantity == ingredient.quantity.rounded() ? "%.0f" : "%.1f") \(ingredient.unit)")
//                                                .font(.system(size: 13))
//                                                .foregroundColor(Color(hex: "3A7A4A").opacity(0.8))
//                                        }
//                                    }
//                                }
//                            }
//                        }
//                    }
//
//                    // MARK: Spices
//                    if !meal.spicesAndZeroNutriment.isEmpty {
//                        SectionCard(title: "Spices & Seasonings", icon: "sparkles") {
//                            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 8) {
//                                ForEach(meal.spicesAndZeroNutriment, id: \.self) { spice in
//                                    Text(spice.capitalized)
//                                        .font(.system(size: 12, weight: .medium))
//                                        .foregroundColor(Color(hex: "FF9800"))
//                                        .frame(maxWidth: .infinity)
//                                        .padding(.vertical, 6)
//                                        .background(Color(hex: "FF9800").opacity(0.08))
//                                        .clipShape(RoundedRectangle(cornerRadius: 8))
//                                }
//                            }
//                        }
//                    }
//
//                    // MARK: Recipe Steps
//                    SectionCard(title: "Recipe", icon: "list.number") {
//                        VStack(alignment: .leading, spacing: 12) {
//                            ForEach(Array(meal.recipe.enumerated()), id: \.offset) { index, step in
//                                HStack(alignment: .top, spacing: 12) {
//                                    Text("\(index + 1)")
//                                        .font(.system(size: 13, weight: .bold))
//                                        .foregroundColor(.white)
//                                        .frame(width: 24, height: 24)
//                                        .background(Color(hex: "3A7A4A"))
//                                        .clipShape(Circle())
//                                    Text(step)
//                                        .font(.system(size: 14))
//                                        .foregroundColor(Color(hex: "1A4A2A"))
//                                        .lineSpacing(4)
//                                        .fixedSize(horizontal: false, vertical: true)
//                                }
//                            }
//                        }
//                    }
//                }
//                .padding(16)
//            }
//            .background(
//                LinearGradient(
//                    colors: [Color(hex: "F2F7F2"), Color(hex: "E8F4E8")],
//                    startPoint: .top, endPoint: .bottom
//                )
//                .ignoresSafeArea()
//            )
//            .navigationTitle(mealName)
//            .navigationBarTitleDisplayMode(.inline)
//            .toolbar {
//                ToolbarItem(placement: .topBarTrailing) {
//                    Button("Done") { dismiss() }
//                        .foregroundColor(Color(hex: "3A7A4A"))
//                        .fontWeight(.semibold)
//                }
//            }
//        }
//    }
//}
//
//// MARK: - Reusable Detail Components
//
//struct StatsCard: View {
//    let value: String
//    let label: String
//    let color: Color
//
//    var body: some View {
//        VStack(spacing: 4) {
//            Text(value)
//                .font(.system(size: 18, weight: .bold))
//                .foregroundColor(color)
//            Text(label)
//                .font(.system(size: 11))
//                .foregroundColor(Color(hex: "3A7A4A").opacity(0.7))
//        }
//        .frame(maxWidth: .infinity)
//        .padding(.vertical, 14)
//        .background(
//            RoundedRectangle(cornerRadius: 14)
//                .fill(color.opacity(0.08))
//                .overlay(RoundedRectangle(cornerRadius: 14).stroke(color.opacity(0.2), lineWidth: 1))
//        )
//    }
//}
//
//struct SectionCard<Content: View>: View {
//    let title: String
//    let icon: String
//    @ViewBuilder let content: Content
//
//    var body: some View {
//        VStack(alignment: .leading, spacing: 14) {
//            HStack(spacing: 7) {
//                Image(systemName: icon)
//                    .font(.system(size: 13, weight: .semibold))
//                    .foregroundColor(Color(hex: "3A7A4A"))
//                Text(title)
//                    .font(.system(size: 15, weight: .semibold))
//                    .foregroundColor(Color(hex: "1A4A2A"))
//            }
//            content
//        }
//        .padding(16)
//        .background(
//            RoundedRectangle(cornerRadius: 16)
//                .fill(Color.white.opacity(0.85))
//                .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color(hex: "C8E6C9"), lineWidth: 1))
//        )
//        .shadow(color: Color(hex: "1A4A2A").opacity(0.05), radius: 5, x: 0, y: 2)
//    }
//}
//
//struct MacroRow: View {
//    let label: String
//    let value: String
//    let color: Color
//
//    var body: some View {
//        HStack {
//            HStack(spacing: 8) {
//                RoundedRectangle(cornerRadius: 3)
//                    .fill(color)
//                    .frame(width: 4, height: 16)
//                Text(label)
//                    .font(.system(size: 14))
//                    .foregroundColor(Color(hex: "1A4A2A"))
//            }
//            Spacer()
//            Text(value)
//                .font(.system(size: 14, weight: .semibold))
//                .foregroundColor(Color(hex: "1A4A2A"))
//        }
//    }
//}
//
//// MARK: - Preview
//
//#Preview {
//    NavigationStack {
//        MealPlanView()
//    }
//}
