//
//  Home.swift
//  SmartFridge
//
//  Created by Michael Pancras on 2/21/26.
//

import SwiftUI

struct OnboardingView: View {
    @State private var currentPage = 0
    @AppStorage("logged_in") private var finished = false
    
    @Environment(UserData.self) var user

    // Draft user built up across pages — saved as JSON on finish
    @State private var name: String = ""
    @State private var age: Int = 25
    @State private var householdSize: Int = 1
    @State private var dietaryRestriction: String = ""
    @State private var allergies: [String] = []
    @State private var calories: Int = 2000
    @State private var protein: Int = 150
    @State private var mealsPerDay: Int = 3
    @State private var cookingProficiency: String = ""
    @State private var cuisinePreferences: [String] = []
    
    @State var loggedInNow = false

    let totalPages = 10  // welcome + 9 fields
//
//    init() {
//        UserDefaults.standard.removeObject(forKey: "logged_in")
//    }
//    
    var body: some View {
        if finished {
            TabBar()
                .onAppear {
                    finished = true
                    if loggedInNow {
                        Task {
                            do {
                                let _ = try await APIManager.shared.putProfile(profile: user.toUser())
                                print("Sent profile to server!!")
                                dump(user.name)
                                dump(user.cooking_proficiency)
                                dump(user.cuisine_preferences)
                            } catch {
                                fatalError("Error sending profile data to the server.")
                            }
                        }
                    }
                }
        } else {
            VStack(spacing: 0) {

                // MARK: - Progress Bar
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text("Set up your profile")
                            .font(.caption).foregroundStyle(Color(hex: "2D6A4F"))
                        Spacer()
                        Text("\(currentPage + 1) of \(totalPages)")
                            .font(.caption).fontWeight(.semibold).foregroundStyle(Color(hex: "2D6A4F"))
                    }
                    GeometryReader { geo in
                        ZStack(alignment: .leading) {
                            RoundedRectangle(cornerRadius: 4).fill(Color(hex: "D8F3DC")).frame(height: 6)
                            RoundedRectangle(cornerRadius: 4)
                                .fill(LinearGradient(colors: [Color(hex: "2D6A4F"), Color(hex: "52B788")], startPoint: .leading, endPoint: .trailing))
                                .frame(width: geo.size.width * CGFloat(currentPage + 1) / CGFloat(totalPages), height: 6)
                                .animation(.easeInOut, value: currentPage)
                        }
                    }
                    .frame(height: 6)
                }
                .padding(.horizontal, 22).padding(.vertical, 14)
                .background(Color(hex: "F0FAF4"))
                .overlay(Rectangle().fill(Color(hex: "1B4332").opacity(0.06)).frame(height: 1), alignment: .bottom)

                // MARK: - Pages
                TabView(selection: $currentPage) {
                    WelcomePage().tag(0)
                    NamePage(name: $name).tag(1)
                    AgePage(age: $age).tag(2)
                    HouseholdSizePage(householdSize: $householdSize).tag(3)
                    DietTypePage(dietType: $dietaryRestriction).tag(4)
                    AllergiesPage(selected: $allergies).tag(5)
                    MacrosPage(calories: $calories, protein: $protein).tag(6)
                    MealsPerDayPage(mealsPerDay: $mealsPerDay).tag(7)
                    CookingPage(cookingProficiency: $cookingProficiency).tag(8)
                    CuisinePage(selected: $cuisinePreferences).tag(9)
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .animation(.easeInOut, value: currentPage)

                // MARK: - Navigation Buttons
                HStack(spacing: 14) {
                    if currentPage > 0 {
                        Button { withAnimation { currentPage -= 1 } } label: {
                            Text("Back")
                                .font(.subheadline).bold().foregroundStyle(Color(hex: "2D6A4F"))
                                .frame(maxWidth: .infinity).padding(.vertical, 16)
                                .background(Color(hex: "D8F3DC"), in: RoundedRectangle(cornerRadius: 16))
                        }
                    }
                    Button {
                        withAnimation {
                            if currentPage < totalPages - 1 {
                                currentPage += 1
                            } else {
                                saveUser()
                                loggedInNow = true
                                finished = true
                            }
                        }
                    } label: {
                        Text(currentPage == totalPages - 1 ? "Let's Go! 🌿" : "Next")
                            .font(.subheadline).bold().foregroundStyle(.white)
                            .frame(maxWidth: .infinity).padding(.vertical, 16)
                            .background(
                                LinearGradient(colors: [Color(hex: "1B4332"), Color(hex: "2D6A4F")], startPoint: .leading, endPoint: .trailing),
                                in: RoundedRectangle(cornerRadius: 16))
                            .shadow(color: Color(hex: "1B4332").opacity(0.25), radius: 8, x: 0, y: 4)
                    }
                }
                .padding(.horizontal, 22).padding(.vertical, 16)
                .background(Color(hex: "F0FAF4"))
            }
            .background(Color(hex: "F0FAF4"))
        }
    }

    // Save into the same JSON file UserStore reads
    private func saveUser() {
        let user_update = UserData(user: User(
            name: name,
            age: age,
            household_size: householdSize,
            meals_per_day: mealsPerDay,
            macro_targets: MacroTargets(calories: calories, protein: protein),
            dietary_restriction: dietaryRestriction,
            allergies: allergies,
            cooking_proficiency: cookingProficiency,
            cuisine_preferences: cuisinePreferences
        ))
        
        user.name = user_update.name
        user.age = user_update.age
        user.household_size = user_update.household_size
        user.meals_per_day = user_update.meals_per_day
        user.macro_targets = user_update.macro_targets
        user.dietary_restriction = user_update.dietary_restriction
        user.allergies = user_update.allergies
        user.cooking_proficiency = user_update.cooking_proficiency
        user.cuisine_preferences = user_update.cuisine_preferences
        
    }
}

// MARK: - Welcome Page

struct WelcomePage: View {
    var body: some View {
        OnboardingPageWrapper(icon: "refrigerator.fill", title: "Welcome to Meal-E 🌿",
            subtitle: "Answer a few quick questions so we can personalise your nutrition, meal planning, and recipe suggestions.") {
            EmptyView()
        }
    }
}

// MARK: - Name Page

struct NamePage: View {
    @Binding var name: String
    var body: some View {
        OnboardingPageWrapper(icon: "person.fill", title: "What's your name?",
            subtitle: "We'll use this to personalise your greeting each time you open the app.") {
            VStack(alignment: .leading, spacing: 8) {
                Text("First name").font(.caption).fontWeight(.semibold).foregroundStyle(Color(hex: "2D6A4F")).padding(.horizontal, 4)
                TextField("e.g. Vijay", text: $name)
                    .font(.system(size: 17, weight: .medium))
                    .padding(.horizontal, 16).padding(.vertical, 14)
                    .background(Color.white)
                    .clipShape(RoundedRectangle(cornerRadius: 14))
                    .overlay(RoundedRectangle(cornerRadius: 14).stroke(Color(hex: "52B788").opacity(0.4), lineWidth: 1.5))
                    .shadow(color: Color(hex: "2D6A4F").opacity(0.06), radius: 6, x: 0, y: 2)
            }
            .padding(.horizontal, 22)
        }
    }
}

// MARK: - Age Page

struct AgePage: View {
    @Binding var age: Int
    let ages = Array(13...100)
    var body: some View {
        OnboardingPageWrapper(icon: "birthday.cake.fill", title: "How old are you?",
            subtitle: "Used to personalise your nutrition and calorie recommendations.") {
            Picker("Age", selection: $age) {
                ForEach(ages, id: \.self) { Text("\($0)").tag($0) }
            }
            .pickerStyle(.wheel).frame(height: 150).padding(.horizontal, 22)
        }
    }
}

// MARK: - Household Size Page

struct HouseholdSizePage: View {
    @Binding var householdSize: Int
    let sizes = Array(1...10)
    var body: some View {
        OnboardingPageWrapper(icon: "house.fill", title: "How many people in your household?",
            subtitle: "Helps us suggest the right portion sizes and recipe quantities.") {
            Picker("Household size", selection: $householdSize) {
                ForEach(sizes, id: \.self) { Text("\($0) person\($0 == 1 ? "" : "s")").tag($0) }
            }
            .pickerStyle(.wheel).frame(height: 150).padding(.horizontal, 22)
        }
    }
}

// MARK: - Diet Type Page  (→ dietary_restriction)

struct DietTypePage: View {
    @Binding var dietType: String
    let options: [(String, String)] = [
        ("high protein",   "Prioritise protein-rich meals and ingredients."),
        ("vegetarian",     "No meat — plant-based with dairy and eggs OK."),
        ("vegan",          "Fully plant-based, no animal products."),
        ("keto",           "High fat, very low carb approach."),
        ("paleo",          "Whole foods, no processed or refined items."),
        ("balanced",       "No restrictions — just well-rounded eating."),
        ("low carb",       "Reduced carbohydrates across meals."),
        ("mediterranean",  "Olive oil, fish, legumes, and fresh veg."),
    ]
    var body: some View {
        OnboardingPageWrapper(icon: "leaf.fill", title: "What's your diet type?",
            subtitle: "Helps us personalise your recipe suggestions and nutrition targets.") {
            VStack(spacing: 10) {
                ForEach(options, id: \.0) { option in
                    GoalRow(label: option.0, subtitle: option.1, isSelected: dietType == option.0, onTap: { dietType = option.0 })
                }
            }
            .padding(.horizontal, 22)
        }
    }
}

// MARK: - Allergies Page  (→ allergies)

struct AllergiesPage: View {
    @Binding var selected: [String]
    let options = ["gluten", "dairy", "nuts", "eggs", "shellfish", "soy", "fish", "none"]
    var body: some View {
        OnboardingPageWrapper(icon: "exclamationmark.shield.fill", title: "Any food allergies?",
            subtitle: "We'll filter out unsafe recipes and flag risky items in your fridge.") {
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
                ForEach(options, id: \.self) { option in
                    MultiSelectRow(label: option, isSelected: selected.contains(option), onTap: {
                        if option == "none" {
                            selected = selected.contains("none") ? [] : ["none"]
                        } else {
                            selected.removeAll { $0 == "none" }
                            if selected.contains(option) { selected.removeAll { $0 == option } }
                            else { selected.append(option) }
                        }
                    })
                }
            }
            .padding(.horizontal, 22)
        }
    }
}

// MARK: - Macros Page  (→ macro_targets: calories + protein)

struct MacrosPage: View {
    @Binding var calories: Int
    @Binding var protein: Int
    let calorieOptions = [1200, 1500, 1800, 2000, 2200, 2500, 2800, 3000]
    let proteinOptions  = [80, 100, 120, 150, 175, 200, 225, 250]

    var body: some View {
        OnboardingPageWrapper(icon: "chart.bar.fill", title: "Daily macro targets",
            subtitle: "Set your daily nutrition goals. You can adjust these any time in Settings.") {
            VStack(spacing: 0) {
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text("🔥").font(.title3).frame(width: 36)
                        Text("Calories (kcal)").font(.subheadline).fontWeight(.semibold).foregroundStyle(Color(hex: "1B4332"))
                        Spacer()
                        Text("\(calories)").font(.subheadline).fontWeight(.bold).foregroundStyle(Color(hex: "DC2626"))
                    }
                    .padding(.horizontal, 18).padding(.top, 14)
                    Picker("Calories", selection: $calories) {
                        ForEach(calorieOptions, id: \.self) { Text("\($0)").tag($0) }
                    }
                    .pickerStyle(.wheel).frame(height: 100)
                }
                Divider().padding(.leading, 54)
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text("💪").font(.title3).frame(width: 36)
                        Text("Protein (g)").font(.subheadline).fontWeight(.semibold).foregroundStyle(Color(hex: "1B4332"))
                        Spacer()
                        Text("\(protein)g").font(.subheadline).fontWeight(.bold).foregroundStyle(Color(hex: "2D6A4F"))
                    }
                    .padding(.horizontal, 18)
                    Picker("Protein", selection: $protein) {
                        ForEach(proteinOptions, id: \.self) { Text("\($0)").tag($0) }
                    }
                    .pickerStyle(.wheel).frame(height: 100)
                    .padding(.bottom, 14)
                }
            }
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 18))
            .shadow(color: Color(hex: "2D6A4F").opacity(0.08), radius: 10, x: 0, y: 4)
            .padding(.horizontal, 22)
        }
    }
}

// MARK: - Meals Per Day Page  (→ meals_per_day)

struct MealsPerDayPage: View {
    @Binding var mealsPerDay: Int
    let options: [(Int, String)] = [
        (1, "One main meal a day."),
        (2, "Lunch and dinner, or two main meals."),
        (3, "Breakfast, lunch, and dinner."),
        (4, "Three meals plus a snack."),
        (5, "Frequent eating, 5 times a day."),
        (6, "6 small meals — common for muscle gain."),
    ]
    var body: some View {
        OnboardingPageWrapper(icon: "fork.knife", title: "How many meals a day?",
            subtitle: "Helps us spread your macro targets across the right number of meals.") {
            VStack(spacing: 10) {
                ForEach(options, id: \.0) { option in
                    GoalRow(label: "\(option.0) meal\(option.0 == 1 ? "" : "s") per day", subtitle: option.1,
                        isSelected: mealsPerDay == option.0, onTap: { mealsPerDay = option.0 })
                }
            }
            .padding(.horizontal, 22)
        }
    }
}

// MARK: - Cooking Proficiency Page  (→ cooking_proficiency)

struct CookingPage: View {
    @Binding var cookingProficiency: String
    let options: [(String, String)] = [
        ("beginner",     "Simple, quick recipes with few ingredients."),
        ("intermediate", "Comfortable with most techniques and recipes."),
        ("advanced",     "Love complex dishes and trying new things."),
    ]
    var body: some View {
        OnboardingPageWrapper(icon: "frying.pan.fill", title: "How confident are you in the kitchen?",
            subtitle: "We'll suggest recipes that match your skill level.") {
            VStack(spacing: 10) {
                ForEach(options, id: \.0) { option in
                    GoalRow(label: option.0, subtitle: option.1, isSelected: cookingProficiency == option.0, onTap: { cookingProficiency = option.0 })
                }
            }
            .padding(.horizontal, 22)
        }
    }
}

// MARK: - Cuisine Preferences Page  (→ cuisine_preferences)

struct CuisinePage: View {
    @Binding var selected: [String]
    let options = ["italian", "asian", "mexican", "mediterranean", "american", "indian", "middle eastern", "french", "japanese", "korean", "thai", "greek"]
    var body: some View {
        OnboardingPageWrapper(icon: "globe", title: "Favourite cuisines?",
            subtitle: "We'll prioritise these when suggesting recipes from your fridge.") {
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
                ForEach(options, id: \.self) { option in
                    MultiSelectRow(label: option, isSelected: selected.contains(option), onTap: {
                        if selected.contains(option) { selected.removeAll { $0 == option } }
                        else { selected.append(option) }
                    })
                }
            }
            .padding(.horizontal, 22)
        }
    }
}

// MARK: - Reusable Components

struct OnboardingPageWrapper<Content: View>: View {
    let icon: String
    let title: String
    let subtitle: String
    @ViewBuilder let content: Content

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 24) {
                VStack(spacing: 14) {
                    ZStack {
                        Circle()
                            .fill(LinearGradient(colors: [Color(hex: "D8F3DC"), Color(hex: "B7E4C7")], startPoint: .topLeading, endPoint: .bottomTrailing))
                            .frame(width: 80, height: 80)
                        Image(systemName: icon).font(.system(size: 34)).foregroundStyle(Color(hex: "1B4332"))
                    }
                    Text(title).font(.system(size: 22, weight: .bold, design: .serif)).multilineTextAlignment(.center).foregroundStyle(Color(hex: "1B4332"))
                    Text(subtitle).font(.subheadline).foregroundStyle(Color(hex: "2D6A4F").opacity(0.7)).multilineTextAlignment(.center).padding(.horizontal, 24)
                }
                .padding(.top, 32)
                content
            }
            .padding(.bottom, 32)
        }
    }
}

struct GoalRow: View {
    let label: String
    let subtitle: String
    let isSelected: Bool
    let onTap: () -> Void

    var body: some View {
        Button { onTap() } label: {
            HStack(spacing: 14) {
                VStack(alignment: .leading, spacing: 3) {
                    Text(label).font(.subheadline).fontWeight(.bold).foregroundStyle(isSelected ? .white : Color(hex: "1B4332"))
                    Text(subtitle).font(.caption).foregroundStyle(isSelected ? Color.white.opacity(0.75) : Color(hex: "2D6A4F").opacity(0.6)).fixedSize(horizontal: false, vertical: true)
                }
                Spacer()
                if isSelected { Image(systemName: "checkmark.circle.fill").font(.system(size: 20)).foregroundStyle(.white) }
            }
            .padding(.horizontal, 18).padding(.vertical, 14)
            .background(isSelected
                ? AnyShapeStyle(LinearGradient(colors: [Color(hex: "1B4332"), Color(hex: "2D6A4F")], startPoint: .leading, endPoint: .trailing))
                : AnyShapeStyle(Color.white), in: RoundedRectangle(cornerRadius: 14))
            .shadow(color: isSelected ? Color(hex: "1B4332").opacity(0.2) : Color.black.opacity(0.04), radius: 6, x: 0, y: 2)
        }
    }
}

struct MultiSelectRow: View {
    let label: String
    let isSelected: Bool
    let onTap: () -> Void

    var body: some View {
        Button { onTap() } label: {
            HStack {
                Text(label).font(.caption).fontWeight(.bold).foregroundStyle(isSelected ? .white : Color(hex: "1B4332")).lineLimit(1)
                Spacer()
                if isSelected { Image(systemName: "checkmark").font(.caption2).bold().foregroundStyle(.white) }
            }
            .padding(.horizontal, 12).padding(.vertical, 13)
            .background(isSelected
                ? AnyShapeStyle(LinearGradient(colors: [Color(hex: "1B4332"), Color(hex: "40916C")], startPoint: .leading, endPoint: .trailing))
                : AnyShapeStyle(Color.white), in: RoundedRectangle(cornerRadius: 12))
            .shadow(color: isSelected ? Color(hex: "1B4332").opacity(0.2) : Color.black.opacity(0.04), radius: 4, x: 0, y: 2)
        }
    }
}

#Preview {
    OnboardingView()
        .environment(FridgeInventoryViewModel(pantry: []))
}

