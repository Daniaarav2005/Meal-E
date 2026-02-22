//
//  Home.swift
//  SmartFridge
//
//  Created by Michael Pancras on 2/21/26.
//

import SwiftUI

// MARK: - Settings Destination Enum

enum SettingsDest: Hashable {
    case personalInfo, dietary, allergies, cooking, cuisine, macros, schedule
}

// MARK: - Main Settings View

struct SettingsView: View {
    @Environment(UserData.self) var userData
    @State private var path = NavigationPath()

    var body: some View {
        NavigationStack(path: $path) {
            VStack(spacing: 0) {

                // ── Fixed banner ──
                HStack {
                    Spacer()
                    Text("Settings")
                        .font(.system(size: 22, weight: .heavy, design: .serif))
                        .foregroundStyle(Color(hex: "1B4332"))
                    Spacer()
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

                    ScrollView(showsIndicators: false) {
                        VStack(spacing: 24) {

                            summaryCard

                            SettingsGroup(title: "Personal", rows: [
                                (.personalInfo, "person.fill", "Personal Info", Color(hex: "2D6A4F")),
                            ], path: $path)

                            SettingsGroup(title: "Diet & Restrictions", rows: [
                                (.dietary,   "leaf.fill",                   "Dietary Restriction", Color(hex: "40916C")),
                                (.allergies, "exclamationmark.shield.fill", "Allergies",           Color(hex: "DC2626")),
                            ], path: $path)

                            SettingsGroup(title: "Nutrition & Meals", rows: [
                                (.macros,   "chart.bar.fill", "Macro Targets",  Color(hex: "2D6A4F")),
                                (.schedule, "fork.knife",     "Meal Schedule",  Color(hex: "D97706")),
                            ], path: $path)

                            SettingsGroup(title: "Cooking", rows: [
                                (.cooking, "frying.pan.fill", "Cooking Proficiency", Color(hex: "40916C")),
                                (.cuisine, "globe",           "Cuisine Preferences", Color(hex: "52B788")),
                            ], path: $path)
                            
                            Button {
                                withAnimation(.smooth) {
                                    UserDefaults.standard.set(false, forKey: "logged_in")
                                }
                            } label: {
                                HStack {
                                    Spacer()
                                    Label("Log Out", systemImage: "rectangle.portrait.and.arrow.right")
                                        .font(.system(size: 16, weight: .semibold, design: .serif))
                                        .foregroundStyle(Color(red: 0.85, green: 0.2, blue: 0.2))
                                    Spacer()
                                }
                                .padding(.vertical, 14)
                                .background(Color.white)
                                .clipShape(RoundedRectangle(cornerRadius: 16))
                                .shadow(color: Color.red.opacity(0.07), radius: 8, x: 0, y: 3)
                            }
                            .buttonStyle(.plain)
                            
                        }
                        .padding(.horizontal, 18)
                        .padding(.top, 20)
                        .padding(.bottom, 40)
                        .padding(.bottom, 60)
                    }
                }
            }
            .navigationBarHidden(true)
            .ignoresSafeArea(edges: .bottom)
            .navigationDestination(for: SettingsDest.self) { dest in
                switch dest {
                case .personalInfo: PersonalInfoDetail()
                case .dietary:      DietaryDetail()
                case .allergies:    AllergiesDetail()
                case .cooking:      CookingDetail()
                case .cuisine:      CuisineDetail()
                case .macros:       MacrosDetail()
                case .schedule:     ScheduleDetail()
                }
            }
        }
    }

    // MARK: - Summary Card

    private var summaryCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 10) {
                ZStack {
                    Circle()
                        .fill(LinearGradient(colors: [Color(hex: "1B4332"), Color(hex: "2D6A4F")], startPoint: .topLeading, endPoint: .bottomTrailing))
                        .frame(width: 48, height: 48)
                    Text(userData.name.isEmpty ? "?" : String(userData.name.prefix(1)).uppercased())
                        .font(.system(size: 20, weight: .bold, design: .serif))
                        .foregroundStyle(.white)
                }
                VStack(alignment: .leading, spacing: 2) {
                    Text(userData.name.isEmpty ? "Set your name" : userData.name)
                        .font(.system(size: 16, weight: .bold, design: .serif))
                        .foregroundStyle(Color(hex: "1B4332"))
                    Text("Age \(userData.age) · \(userData.household_size) person household")
                        .font(.caption)
                        .foregroundStyle(Color(hex: "2D6A4F").opacity(0.6))
                }
                Spacer()
            }

            Divider().background(Color(hex: "D8F3DC"))

            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 6) {
                SummaryPill(label: "Diet",    value: userData.dietary_restriction.isEmpty ? "Not set" : userData.dietary_restriction)
                SummaryPill(label: "Macros",  value: "\(userData.macro_targets.calories) kcal · \(userData.macro_targets.protein)g protein")
                SummaryPill(label: "Meals",   value: "\(userData.meals_per_day)/day")
                SummaryPill(label: "Cooking", value: userData.cooking_proficiency.isEmpty ? "Not set" : userData.cooking_proficiency)
            }
        }
        .padding(18)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .shadow(color: Color(hex: "2D6A4F").opacity(0.08), radius: 10, x: 0, y: 4)
    }
}

// MARK: - Summary Pill

struct SummaryPill: View {
    let label: String
    let value: String

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(label.uppercased())
                .font(.system(size: 9, weight: .bold))
                .foregroundStyle(Color(hex: "2D6A4F").opacity(0.5))
            Text(value)
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(Color(hex: "1B4332"))
                .lineLimit(1)
                .minimumScaleFactor(0.7)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 10).padding(.vertical, 8)
        .background(Color(hex: "F0FAF4"))
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }
}

// MARK: - Settings Group

struct SettingsGroup: View {
    let title: String
    let rows: [(SettingsDest, String, String, Color)]
    @Binding var path: NavigationPath

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title.uppercased())
                .font(.system(size: 11, weight: .semibold, design: .serif))
                .foregroundStyle(Color(hex: "2D6A4F").opacity(0.5))
                .padding(.horizontal, 4)

            VStack(spacing: 0) {
                ForEach(Array(rows.enumerated()), id: \.offset) { index, row in
                    let (dest, icon, label, color) = row
                    Button { path.append(dest) } label: {
                        HStack(spacing: 14) {
                            ZStack {
                                RoundedRectangle(cornerRadius: 8).fill(color).frame(width: 34, height: 34)
                                Image(systemName: icon).font(.system(size: 16, weight: .semibold)).foregroundStyle(.white)
                            }
                            Text(label).font(.system(size: 16, weight: .medium, design: .serif)).foregroundStyle(Color(hex: "1B4332"))
                            Spacer()
                            Image(systemName: "chevron.right").font(.system(size: 13, weight: .semibold)).foregroundStyle(Color(hex: "2D6A4F").opacity(0.3))
                        }
                        .padding(.horizontal, 16).padding(.vertical, 13)
                        .background(Color.white)
                    }
                    .buttonStyle(.plain)
                    if index < rows.count - 1 { Divider().padding(.leading, 64).background(Color.white) }
                }
            }
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .shadow(color: Color(hex: "2D6A4F").opacity(0.07), radius: 8, x: 0, y: 3)
        }
    }
}

// MARK: - Detail Page Wrapper

struct DetailPageWrapper<Content: View>: View {
    let title: String
    let icon: String
    let iconColor: Color
    @Environment(\.dismiss) private var dismiss
    @ViewBuilder let content: Content
    
    @Environment(UserData.self) var userData: UserData

    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 12) {
                Button {
                    Task {
                        do {
                            let _ = try await APIManager.shared.putProfile(profile: userData.toUser())
                            print("Sent profile!!")
                            print("--------------------------")
                            print(userData.age)
                            print(userData.name)
                            print(userData.household_size)
                            print("--------------------------")
                        } catch {
                            fatalError("Error sending profile data to the server.")
                        }
                    }
                    dismiss()
                } label: {
                    HStack(spacing: 6) {
                        Image(systemName: "chevron.left").font(.system(size: 16, weight: .semibold))
                    }
                    .foregroundStyle(Color(hex: "1B4332"))
                }
                Spacer()
                HStack(spacing: 8) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 8).fill(iconColor).frame(width: 30, height: 30)
                        Image(systemName: icon).font(.system(size: 14, weight: .semibold)).foregroundStyle(.white)
                    }
                    Text(title).font(.system(size: 17, weight: .bold, design: .serif)).foregroundStyle(Color(hex: "1B4332"))
                }
                Spacer()
                Color.clear.frame(width: 80, height: 1)
            }
            .padding(.horizontal, 18).padding(.vertical, 14)
            .background(Color(hex: "D8F3DC"))
            .overlay(Rectangle().fill(Color(hex: "1B4332").opacity(0.07)).frame(height: 1), alignment: .bottom)

            ZStack {
                LinearGradient(colors: [Color(hex: "D8F3DC"), Color(hex: "EDF7F0"), Color(hex: "F0FAF4")], startPoint: .topLeading, endPoint: .bottomTrailing)
                    .ignoresSafeArea()
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 20) { content }
                        .padding(.horizontal, 18).padding(.top, 20).padding(.bottom, 40)
                }
            }
        }
        .navigationBarHidden(true)
        .ignoresSafeArea(edges: .bottom)
    }
}

// MARK: - Reusable Components

struct SettingsCard<Content: View>: View {
    let title: String
    let icon: String
    let iconColor: Color
    @ViewBuilder let content: Content

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(spacing: 10) {
                ZStack {
                    RoundedRectangle(cornerRadius: 8).fill(iconColor.opacity(0.15)).frame(width: 32, height: 32)
                    Image(systemName: icon).font(.system(size: 15, weight: .semibold)).foregroundStyle(iconColor)
                }
                Text(title).font(.system(size: 16, weight: .bold, design: .serif)).foregroundStyle(Color(hex: "1B4332"))
            }
            content
        }
        .padding(18)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .shadow(color: Color(hex: "2D6A4F").opacity(0.07), radius: 10, x: 0, y: 4)
    }
}

struct SettingsSingleSelect: View {
    let label: String
    let options: [String]
    @Binding var selected: String

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            if !label.isEmpty {
                Text(label).font(.caption).fontWeight(.semibold).foregroundStyle(Color(hex: "2D6A4F").opacity(0.7))
            }
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 8) {
                ForEach(options, id: \.self) { option in
                    Button { withAnimation(.spring(duration: 0.25)) { selected = option } } label: {
                        Text(option)
                            .font(.system(size: 13, weight: selected == option ? .bold : .medium, design: .serif))
                            .foregroundStyle(selected == option ? .white : Color(hex: "1B4332"))
                            .lineLimit(1).minimumScaleFactor(0.8)
                            .frame(maxWidth: .infinity).padding(.vertical, 10)
                            .background(selected == option
                                ? AnyShapeStyle(LinearGradient(colors: [Color(hex: "1B4332"), Color(hex: "2D6A4F")], startPoint: .leading, endPoint: .trailing))
                                : AnyShapeStyle(Color(hex: "F0FAF4")))
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                            .overlay(RoundedRectangle(cornerRadius: 10).stroke(selected == option ? Color.clear : Color(hex: "52B788").opacity(0.3), lineWidth: 1))
                            .shadow(color: selected == option ? Color(hex: "1B4332").opacity(0.2) : .clear, radius: 4, y: 2)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }
}

struct SettingsMultiSelect: View {
    let label: String
    let options: [String]
    @Binding var selected: [String]

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            if !label.isEmpty {
                Text(label).font(.caption).fontWeight(.semibold).foregroundStyle(Color(hex: "2D6A4F").opacity(0.7))
            }
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 8) {
                ForEach(options, id: \.self) { option in
                    Button {
                        withAnimation(.spring(duration: 0.25)) {
                            if selected.contains(option) { selected.removeAll { $0 == option } }
                            else { selected.append(option) }
                        }
                    } label: {
                        HStack(spacing: 4) {
                            if selected.contains(option) {
                                Image(systemName: "checkmark").font(.system(size: 10, weight: .bold)).foregroundStyle(.white)
                            }
                            Text(option)
                                .font(.system(size: 13, weight: selected.contains(option) ? .bold : .medium))
                                .foregroundStyle(selected.contains(option) ? .white : Color(hex: "1B4332"))
                                .lineLimit(1).minimumScaleFactor(0.8)
                        }
                        .frame(maxWidth: .infinity).padding(.vertical, 10)
                        .background(selected.contains(option)
                            ? AnyShapeStyle(LinearGradient(colors: [Color(hex: "1B4332"), Color(hex: "40916C")], startPoint: .leading, endPoint: .trailing))
                            : AnyShapeStyle(Color(hex: "F0FAF4")))
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                        .overlay(RoundedRectangle(cornerRadius: 10).stroke(selected.contains(option) ? Color.clear : Color(hex: "52B788").opacity(0.3), lineWidth: 1))
                        .shadow(color: selected.contains(option) ? Color(hex: "1B4332").opacity(0.2) : .clear, radius: 4, y: 2)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }
}

// MARK: - Detail Pages

struct PersonalInfoDetail: View {
    @Environment(UserData.self) var userData
    let ages = Array(13...100)
    let householdSizes = Array(1...10)

    var body: some View {

        DetailPageWrapper(title: "Personal Info", icon: "person.fill", iconColor: Color(hex: "2D6A4F")) {
            SettingsCard(title: "Your Profile", icon: "person.fill", iconColor: Color(hex: "2D6A4F")) {

                VStack(alignment: .leading, spacing: 6) {
                    Text("First Name").font(.caption).fontWeight(.semibold).foregroundStyle(Color(hex: "2D6A4F").opacity(0.7))
                    TextField("e.g. Vijay", text: Bindable(userData).name)
                        .font(.system(size: 15, weight: .medium))
                        .padding(.horizontal, 14).padding(.vertical, 12)
                        .background(Color(hex: "F0FAF4"))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color(hex: "52B788").opacity(0.35), lineWidth: 1.5))
                }

                VStack(alignment: .leading, spacing: 6) {
                    Text("Age").font(.caption).fontWeight(.semibold).foregroundStyle(Color(hex: "2D6A4F").opacity(0.7))
                    Picker("Age", selection: Bindable(userData).age) {
                        ForEach(ages, id: \.self) { Text("\($0)").tag($0) }
                    }
                    .pickerStyle(.wheel).frame(height: 120)
                    .background(Color(hex: "F0FAF4"), in: RoundedRectangle(cornerRadius: 12))
                }

                VStack(alignment: .leading, spacing: 6) {
                    Text("Household Size").font(.caption).fontWeight(.semibold).foregroundStyle(Color(hex: "2D6A4F").opacity(0.7))
                    Picker("Household Size", selection: Bindable(userData).household_size) {  // ← camelCase
                        ForEach(householdSizes, id: \.self) { Text("\($0) person\($0 == 1 ? "" : "s")").tag($0) }
                    }
                    .pickerStyle(.wheel).frame(height: 100)
                    .background(Color(hex: "F0FAF4"), in: RoundedRectangle(cornerRadius: 12))
                }
            }
        }
    }
}

struct DietaryDetail: View {
    @Environment(UserData.self) var userData

    var body: some View {
        DetailPageWrapper(title: "Dietary Restriction", icon: "leaf.fill", iconColor: Color(hex: "40916C")) {
            SettingsCard(title: "Diet Type", icon: "leaf.fill", iconColor: Color(hex: "40916C")) {
                Text("Select the one that best describes your diet.")
                    .font(.caption).foregroundStyle(Color(hex: "1B4332").opacity(0.5))
                SettingsSingleSelect(
                    label: "",
                    options: ["high protein", "vegetarian", "vegan", "keto", "paleo", "balanced", "low carb", "mediterranean"],
                    selected: Bindable(userData).dietary_restriction
                )
            }
        }
    }
}

struct AllergiesDetail: View {
    @Environment(UserData.self) var userData

    var body: some View {
        DetailPageWrapper(title: "Allergies", icon: "exclamationmark.shield.fill", iconColor: Color(hex: "DC2626")) {
            SettingsCard(title: "Food Allergies", icon: "exclamationmark.shield.fill", iconColor: Color(hex: "DC2626")) {
                Text("We'll flag items in your fridge and filter out unsafe recipes.")
                    .font(.caption).foregroundStyle(Color(hex: "1B4332").opacity(0.5))
                SettingsMultiSelect(
                    label: "Select all that apply",
                    options: ["gluten", "dairy", "nuts", "eggs", "shellfish", "soy", "fish", "none"],
                    selected: Bindable(userData).allergies
                )
            }
        }
    }
}

struct MacrosDetail: View {
    @Environment(UserData.self) var userData
    let calorieOptions = [1200, 1500, 1800, 2000, 2200, 2500, 2800, 3000]
    let proteinOptions  = [80, 100, 120, 150, 175, 200, 225, 250]

    var body: some View {
        DetailPageWrapper(title: "Macro Targets", icon: "chart.bar.fill", iconColor: Color(hex: "2D6A4F")) {
            SettingsCard(title: "Daily Macro Targets", icon: "chart.bar.fill", iconColor: Color(hex: "2D6A4F")) {
                VStack(alignment: .leading, spacing: 6) {
                    Text("Calories (kcal)").font(.caption).fontWeight(.semibold).foregroundStyle(Color(hex: "2D6A4F").opacity(0.7))
                    Picker("Calories", selection: Bindable(userData).macro_targets.calories) {
                        ForEach(calorieOptions, id: \.self) { Text("\($0)").tag($0) }
                    }
                    .pickerStyle(.wheel).frame(height: 100)
                    .background(Color(hex: "F0FAF4"), in: RoundedRectangle(cornerRadius: 12))
                }

                VStack(alignment: .leading, spacing: 6) {
                    Text("Protein (g)").font(.caption).fontWeight(.semibold).foregroundStyle(Color(hex: "2D6A4F").opacity(0.7))
                    Picker("Protein", selection: Bindable(userData).macro_targets.protein) {
                        ForEach(proteinOptions, id: \.self) { Text("\($0)g").tag($0) }
                    }
                    .pickerStyle(.wheel).frame(height: 100)
                    .background(Color(hex: "F0FAF4"), in: RoundedRectangle(cornerRadius: 12))
                }
            }
        }
    }
}

struct ScheduleDetail: View {
    @Environment(UserData.self) var userData
    let mealOptions = [1, 2, 3, 4, 5, 6]

    var body: some View {
        DetailPageWrapper(title: "Meal Schedule", icon: "fork.knife", iconColor: Color(hex: "D97706")) {
            SettingsCard(title: "Meals Per Day", icon: "fork.knife", iconColor: Color(hex: "D97706")) {
                VStack(alignment: .leading, spacing: 6) {
                    Text("How many meals do you eat per day?").font(.caption).fontWeight(.semibold).foregroundStyle(Color(hex: "2D6A4F").opacity(0.7))
                    Picker("Meals per day", selection: Bindable(userData).meals_per_day) {
                        ForEach(mealOptions, id: \.self) { Text("\($0) meal\($0 == 1 ? "" : "s")").tag($0) }
                    }
                    .pickerStyle(.wheel).frame(height: 100)
                    .background(Color(hex: "F0FAF4"), in: RoundedRectangle(cornerRadius: 12))
                }
            }
        }
    }
}

struct CookingDetail: View {
    @Environment(UserData.self) var userData

    var body: some View {
        DetailPageWrapper(title: "Cooking Proficiency", icon: "frying.pan.fill", iconColor: Color(hex: "40916C")) {
            SettingsCard(title: "Skill Level", icon: "frying.pan.fill", iconColor: Color(hex: "40916C")) {
                SettingsSingleSelect(
                    label: "I'm a...",
                    options: ["beginner", "intermediate", "advanced"],
                    selected: Bindable(userData).cooking_proficiency
                )
            }
        }
    }
}

struct CuisineDetail: View {
    @Environment(UserData.self) var userData

    var body: some View {
        
        DetailPageWrapper(title: "Cuisine Preferences", icon: "globe", iconColor: Color(hex: "52B788")) {
            SettingsCard(title: "Favourite Cuisines", icon: "globe", iconColor: Color(hex: "52B788")) {
                Text("Select all you enjoy. We'll prioritise these when suggesting recipes.")
                    .font(.caption).foregroundStyle(Color(hex: "1B4332").opacity(0.5))
                SettingsMultiSelect(
                    label: "",
                    options: ["italian", "asian", "mexican", "mediterranean", "american", "indian", "middle eastern", "french", "japanese", "korean", "thai", "greek"],
                    selected: Bindable(userData).cuisine_preferences
                )
            }
        }
    }
}









//import SwiftUI
//
//// MARK: - Settings Store (persisted with UserDefaults)
//
//@Observable
//class SettingsStore {
//    var name: String          = UserDefaults.standard.string(forKey: "s_name") ?? ""          { didSet { UserDefaults.standard.set(name, forKey: "s_name") } }
//    var age: String           = UserDefaults.standard.string(forKey: "s_age") ?? ""           { didSet { UserDefaults.standard.set(age, forKey: "s_age") } }
//    var gender: String        = UserDefaults.standard.string(forKey: "s_gender") ?? ""        { didSet { UserDefaults.standard.set(gender, forKey: "s_gender") } }
//    var householdSize: String = UserDefaults.standard.string(forKey: "s_household") ?? ""     { didSet { UserDefaults.standard.set(householdSize, forKey: "s_household") } }
//
//    var allergies: [String]    = (UserDefaults.standard.array(forKey: "s_allergies") as? [String]) ?? []   { didSet { UserDefaults.standard.set(allergies, forKey: "s_allergies") } }
//    var dietaryPrefs: [String] = (UserDefaults.standard.array(forKey: "s_dietary") as? [String]) ?? []    { didSet { UserDefaults.standard.set(dietaryPrefs, forKey: "s_dietary") } }
//
//    var healthGoal: String    = UserDefaults.standard.string(forKey: "s_healthgoal") ?? ""    { didSet { UserDefaults.standard.set(healthGoal, forKey: "s_healthgoal") } }
//    var calorieGoal: String   = UserDefaults.standard.string(forKey: "s_calgoal") ?? ""       { didSet { UserDefaults.standard.set(calorieGoal, forKey: "s_calgoal") } }
//
//    var mealsPerDay: String   = UserDefaults.standard.string(forKey: "s_meals") ?? "3 meals"  { didSet { UserDefaults.standard.set(mealsPerDay, forKey: "s_meals") } }
//    var breakfastTime: String = UserDefaults.standard.string(forKey: "s_breakfast") ?? "8:00 AM" { didSet { UserDefaults.standard.set(breakfastTime, forKey: "s_breakfast") } }
//    var lunchTime: String     = UserDefaults.standard.string(forKey: "s_lunch") ?? "12:30 PM"   { didSet { UserDefaults.standard.set(lunchTime, forKey: "s_lunch") } }
//    var dinnerTime: String    = UserDefaults.standard.string(forKey: "s_dinner") ?? "7:00 PM"   { didSet { UserDefaults.standard.set(dinnerTime, forKey: "s_dinner") } }
//
//    var cookingLevel: String      = UserDefaults.standard.string(forKey: "s_cooklevel") ?? ""  { didSet { UserDefaults.standard.set(cookingLevel, forKey: "s_cooklevel") } }
//    var budget: String            = UserDefaults.standard.string(forKey: "s_budget") ?? ""     { didSet { UserDefaults.standard.set(budget, forKey: "s_budget") } }
//    var cookTime: String          = UserDefaults.standard.string(forKey: "s_cooktime") ?? ""   { didSet { UserDefaults.standard.set(cookTime, forKey: "s_cooktime") } }
//    var shoppingFrequency: String = UserDefaults.standard.string(forKey: "s_shopfreq") ?? ""   { didSet { UserDefaults.standard.set(shoppingFrequency, forKey: "s_shopfreq") } }
//
//    var cuisines: [String]    = (UserDefaults.standard.array(forKey: "s_cuisines") as? [String]) ?? []    { didSet { UserDefaults.standard.set(cuisines, forKey: "s_cuisines") } }
//
//    var alertDays: Double     = UserDefaults.standard.double(forKey: "s_alertdays") == 0 ? 3 : UserDefaults.standard.double(forKey: "s_alertdays") { didSet { UserDefaults.standard.set(alertDays, forKey: "s_alertdays") } }
//    var alertsEnabled: Bool   = UserDefaults.standard.bool(forKey: "s_alertsenabled")          { didSet { UserDefaults.standard.set(alertsEnabled, forKey: "s_alertsenabled") } }
//    var alertTime: String     = UserDefaults.standard.string(forKey: "s_alerttime") ?? "9:00 AM" { didSet { UserDefaults.standard.set(alertTime, forKey: "s_alerttime") } }
//}
//
//// MARK: - Settings Destination Enum (for NavigationStack)
//
//enum SettingsDest: Hashable {
//    case personalInfo, allergies, dietary, mealGoals, mealSchedule, cooking, cuisine, expiryAlerts
//}
//
//// MARK: - Main Settings View (Landing Page)
//
//struct SettingsView: View {
//    @State private var settings = SettingsStore()
//    @State private var path = NavigationPath()
//
//    var body: some View {
//        NavigationStack(path: $path) {
//            VStack(spacing: 0) {
//
//                // ── Fixed banner ──
//                HStack {
//                    Spacer()
//                    Text("Settings")
//                        .font(.system(size: 22, weight: .heavy, design: .rounded))
//                        .foregroundStyle(Color(hex: "1B4332"))
//                    Spacer()
//                }
//                .padding(.vertical, 14)
//                .background(Color(hex: "D8F3DC"))
//                .overlay(Rectangle().fill(Color(hex: "1B4332").opacity(0.07)).frame(height: 1), alignment: .bottom)
//
//                ZStack {
//                    LinearGradient(
//                        colors: [Color(hex: "D8F3DC"), Color(hex: "EDF7F0"), Color(hex: "F0FAF4")],
//                        startPoint: .topLeading, endPoint: .bottomTrailing
//                    )
//                    .ignoresSafeArea()
//
//                    ScrollView(showsIndicators: false) {
//                        VStack(spacing: 24) {
//
//                            // Profile summary card
//                            profileSummaryCard
//
//                            // Group 1
//                            SettingsGroup(title: "Profile & Diet", rows: [
//                                (.personalInfo, "person.fill",               "Personal Info",        Color(hex: "2D6A4F")),
//                                (.allergies,    "exclamationmark.shield.fill","Allergies",            Color(hex: "DC2626")),
//                                (.dietary,      "leaf.fill",                 "Dietary Preferences",  Color(hex: "40916C")),
//                            ], path: $path)
//
//                            // Group 2
//                            SettingsGroup(title: "Meals & Cooking", rows: [
//                                (.mealGoals,    "target",                    "Meal Goals",           Color(hex: "D97706")),
//                                (.mealSchedule, "clock.fill",                "Meal Schedule",        Color(hex: "2D6A4F")),
//                                (.cooking,      "frying.pan.fill",           "Cooking Preferences",  Color(hex: "40916C")),
//                                (.cuisine,      "globe",                     "Cuisine Preferences",  Color(hex: "52B788")),
//                            ], path: $path)
//
//                            // Group 3
//                            SettingsGroup(title: "Notifications", rows: [
//                                (.expiryAlerts, "bell.fill",                 "Expiry Alerts",        Color(hex: "D97706")),
//                            ], path: $path)
//                        }
//                        .padding(.horizontal, 18)
//                        .padding(.top, 20)
//                        .padding(.bottom, 40)
//                    }
//                }
//            }
//            .navigationBarHidden(true)
//            .ignoresSafeArea(edges: .bottom)
//            .navigationDestination(for: SettingsDest.self) { dest in
//                switch dest {
//                case .personalInfo:  PersonalInfoDetail(settings: settings)
//                case .allergies:     AllergiesDetail(settings: settings)
//                case .dietary:       DietaryDetail(settings: settings)
//                case .mealGoals:     MealGoalsDetail(settings: settings)
//                case .mealSchedule:  MealScheduleDetail(settings: settings)
//                case .cooking:       CookingDetail(settings: settings)
//                case .cuisine:       CuisineDetail(settings: settings)
//                case .expiryAlerts:  ExpiryAlertsDetail(settings: settings)
//                }
//            }
//        }
//    }
//
//    // MARK: - Profile Summary Card
//
//    private var profileSummaryCard: some View {
//        HStack(spacing: 16) {
//            ZStack {
//                Circle()
//                    .fill(LinearGradient(
//                        colors: [Color(hex: "1B4332"), Color(hex: "2D6A4F")],
//                        startPoint: .topLeading, endPoint: .bottomTrailing))
//                    .frame(width: 56, height: 56)
//                Text(settings.name.isEmpty ? "?" : String(settings.name.prefix(1)).uppercased())
//                    .font(.system(size: 24, weight: .bold, design: .rounded))
//                    .foregroundStyle(.white)
//            }
//            VStack(alignment: .leading, spacing: 3) {
//                Text(settings.name.isEmpty ? "Set your name" : settings.name)
//                    .font(.system(size: 18, weight: .bold, design: .rounded))
//                    .foregroundStyle(Color(hex: "1B4332"))
//                let subtitle = [
//                    settings.age.isEmpty ? nil : settings.age + " yrs",
//                    settings.gender.isEmpty ? nil : settings.gender,
//                    settings.householdSize.isEmpty ? nil : settings.householdSize
//                ].compactMap { $0 }.joined(separator: " · ")
//                Text(subtitle.isEmpty ? "Tap Personal Info to get started" : subtitle)
//                    .font(.caption)
//                    .foregroundStyle(Color(hex: "2D6A4F").opacity(0.6))
//                    .lineLimit(1)
//            }
//            Spacer()
//            Image(systemName: "chevron.right")
//                .font(.system(size: 13, weight: .semibold))
//                .foregroundStyle(Color(hex: "2D6A4F").opacity(0.3))
//        }
//        .padding(18)
//        .background(Color.white)
//        .clipShape(RoundedRectangle(cornerRadius: 20))
//        .shadow(color: Color(hex: "2D6A4F").opacity(0.08), radius: 10, x: 0, y: 4)
//        .onTapGesture { path.append(SettingsDest.personalInfo) }
//    }
//}
//
//// MARK: - Settings Group
//
//struct SettingsGroup: View {
//    let title: String
//    let rows: [(SettingsDest, String, String, Color)]
//    @Binding var path: NavigationPath
//
//    var body: some View {
//        VStack(alignment: .leading, spacing: 8) {
//            Text(title.uppercased())
//                .font(.system(size: 11, weight: .semibold))
//                .foregroundStyle(Color(hex: "2D6A4F").opacity(0.5))
//                .padding(.horizontal, 4)
//
//            VStack(spacing: 0) {
//                ForEach(Array(rows.enumerated()), id: \.offset) { index, row in
//                    let (dest, icon, label, color) = row
//
//                    Button { path.append(dest) } label: {
//                        HStack(spacing: 14) {
//                            ZStack {
//                                RoundedRectangle(cornerRadius: 8)
//                                    .fill(color)
//                                    .frame(width: 34, height: 34)
//                                Image(systemName: icon)
//                                    .font(.system(size: 16, weight: .semibold))
//                                    .foregroundStyle(.white)
//                            }
//                            Text(label)
//                                .font(.system(size: 16, weight: .medium))
//                                .foregroundStyle(Color(hex: "1B4332"))
//                            Spacer()
//                            Image(systemName: "chevron.right")
//                                .font(.system(size: 13, weight: .semibold))
//                                .foregroundStyle(Color(hex: "2D6A4F").opacity(0.3))
//                        }
//                        .padding(.horizontal, 16)
//                        .padding(.vertical, 13)
//                        .background(Color.white)
//                    }
//                    .buttonStyle(.plain)
//
//                    if index < rows.count - 1 {
//                        Divider().padding(.leading, 64).background(Color.white)
//                    }
//                }
//            }
//            .clipShape(RoundedRectangle(cornerRadius: 16))
//            .shadow(color: Color(hex: "2D6A4F").opacity(0.07), radius: 8, x: 0, y: 3)
//        }
//    }
//}
//
//// MARK: - Detail Page Wrapper
//
//struct DetailPageWrapper<Content: View>: View {
//    let title: String
//    let icon: String
//    let iconColor: Color
//    @Environment(\.dismiss) private var dismiss
//    @ViewBuilder let content: Content
//
//    var body: some View {
//        VStack(spacing: 0) {
//            HStack {
//                Button { dismiss() } label: {
//                    HStack(spacing: 6) {
//                        Image(systemName: "chevron.left")
//                            .font(.system(size: 16, weight: .semibold))
////                        Text("Settings")
////                            .font(.system(size: 16, weight: .semibold))
//                    }
//                    .foregroundStyle(Color(hex: "1B4332"))
//                }
//                Spacer()
//                HStack(spacing: 8) {
//                    ZStack {
//                        RoundedRectangle(cornerRadius: 8)
//                            .fill(iconColor)
//                            .frame(width: 30, height: 30)
//                        Image(systemName: icon)
//                            .font(.system(size: 14, weight: .semibold))
//                            .foregroundStyle(.white)
//                    }
//                    Text(title)
//                        .font(.system(size: 17, weight: .bold, design: .rounded))
//                        .foregroundStyle(Color(hex: "1B4332"))
//                }
//                Spacer()
//            }
//            .padding(.horizontal, 18)
//            .padding(.vertical, 14)
//            .background(Color(hex: "D8F3DC"))
//            .overlay(Rectangle().fill(Color(hex: "1B4332").opacity(0.07)).frame(height: 1), alignment: .bottom)
//
//            ZStack {
//                LinearGradient(
//                    colors: [Color(hex: "D8F3DC"), Color(hex: "EDF7F0"), Color(hex: "F0FAF4")],
//                    startPoint: .topLeading, endPoint: .bottomTrailing
//                )
//                .ignoresSafeArea()
//
//                ScrollView(showsIndicators: false) {
//                    VStack(spacing: 20) { content }
//                        .padding(.horizontal, 18)
//                        .padding(.top, 20)
//                        .padding(.bottom, 40)
//                }
//            }
//        }
//        .navigationBarHidden(true)
//        .ignoresSafeArea(edges: .bottom)
//    }
//}
//
//// MARK: - Reusable Components
//
//struct SettingsCard<Content: View>: View {
//    let title: String
//    let icon: String
//    let iconColor: Color
//    @ViewBuilder let content: Content
//
//    var body: some View {
//        VStack(alignment: .leading, spacing: 16) {
//            HStack(spacing: 10) {
//                ZStack {
//                    RoundedRectangle(cornerRadius: 8)
//                        .fill(iconColor.opacity(0.15))
//                        .frame(width: 32, height: 32)
//                    Image(systemName: icon)
//                        .font(.system(size: 15, weight: .semibold))
//                        .foregroundStyle(iconColor)
//                }
//                Text(title)
//                    .font(.system(size: 16, weight: .bold, design: .rounded))
//                    .foregroundStyle(Color(hex: "1B4332"))
//            }
//            content
//        }
//        .padding(18)
//        .background(Color.white)
//        .clipShape(RoundedRectangle(cornerRadius: 20))
//        .shadow(color: Color(hex: "2D6A4F").opacity(0.07), radius: 10, x: 0, y: 4)
//    }
//}
//
//struct SettingsTextField: View {
//    let label: String
//    @Binding var text: String
//    var placeholder: String = ""
//
//    var body: some View {
//        VStack(alignment: .leading, spacing: 6) {
//            Text(label)
//                .font(.caption).fontWeight(.semibold)
//                .foregroundStyle(Color(hex: "2D6A4F").opacity(0.7))
//            TextField(placeholder.isEmpty ? label : placeholder, text: $text)
//                .font(.system(size: 15, weight: .medium))
//                .padding(.horizontal, 14).padding(.vertical, 12)
//                .background(Color(hex: "F0FAF4"))
//                .clipShape(RoundedRectangle(cornerRadius: 12))
//                .overlay(RoundedRectangle(cornerRadius: 12)
//                    .stroke(Color(hex: "52B788").opacity(0.35), lineWidth: 1.5))
//        }
//    }
//}
//
//struct SettingsSingleSelect: View {
//    let label: String
//    let options: [String]
//    @Binding var selected: String
//
//    var body: some View {
//        VStack(alignment: .leading, spacing: 8) {
//            if !label.isEmpty {
//                Text(label).font(.caption).fontWeight(.semibold)
//                    .foregroundStyle(Color(hex: "2D6A4F").opacity(0.7))
//            }
//            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 8) {
//                ForEach(options, id: \.self) { option in
//                    Button { withAnimation(.spring(duration: 0.25)) { selected = option } } label: {
//                        Text(option)
//                            .font(.system(size: 13, weight: selected == option ? .bold : .medium))
//                            .foregroundStyle(selected == option ? .white : Color(hex: "1B4332"))
//                            .lineLimit(1).minimumScaleFactor(0.8)
//                            .frame(maxWidth: .infinity).padding(.vertical, 10)
//                            .background(selected == option
//                                ? AnyShapeStyle(LinearGradient(colors: [Color(hex: "1B4332"), Color(hex: "2D6A4F")], startPoint: .leading, endPoint: .trailing))
//                                : AnyShapeStyle(Color(hex: "F0FAF4")))
//                            .clipShape(RoundedRectangle(cornerRadius: 10))
//                            .overlay(RoundedRectangle(cornerRadius: 10)
//                                .stroke(selected == option ? Color.clear : Color(hex: "52B788").opacity(0.3), lineWidth: 1))
//                            .shadow(color: selected == option ? Color(hex: "1B4332").opacity(0.2) : .clear, radius: 4, y: 2)
//                    }
//                    .buttonStyle(.plain)
//                }
//            }
//        }
//    }
//}
//
//struct SettingsMultiSelect: View {
//    let label: String
//    let options: [String]
//    @Binding var selected: [String]
//
//    var body: some View {
//        VStack(alignment: .leading, spacing: 8) {
//            if !label.isEmpty {
//                Text(label).font(.caption).fontWeight(.semibold)
//                    .foregroundStyle(Color(hex: "2D6A4F").opacity(0.7))
//            }
//            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 8) {
//                ForEach(options, id: \.self) { option in
//                    Button {
//                        withAnimation(.spring(duration: 0.25)) {
//                            if selected.contains(option) { selected.removeAll { $0 == option } }
//                            else { selected.append(option) }
//                        }
//                    } label: {
//                        HStack(spacing: 4) {
//                            if selected.contains(option) {
//                                Image(systemName: "checkmark").font(.system(size: 10, weight: .bold)).foregroundStyle(.white)
//                            }
//                            Text(option)
//                                .font(.system(size: 13, weight: selected.contains(option) ? .bold : .medium))
//                                .foregroundStyle(selected.contains(option) ? .white : Color(hex: "1B4332"))
//                                .lineLimit(1).minimumScaleFactor(0.8)
//                        }
//                        .frame(maxWidth: .infinity).padding(.vertical, 10)
//                        .background(selected.contains(option)
//                            ? AnyShapeStyle(LinearGradient(colors: [Color(hex: "1B4332"), Color(hex: "40916C")], startPoint: .leading, endPoint: .trailing))
//                            : AnyShapeStyle(Color(hex: "F0FAF4")))
//                        .clipShape(RoundedRectangle(cornerRadius: 10))
//                        .overlay(RoundedRectangle(cornerRadius: 10)
//                            .stroke(selected.contains(option) ? Color.clear : Color(hex: "52B788").opacity(0.3), lineWidth: 1))
//                        .shadow(color: selected.contains(option) ? Color(hex: "1B4332").opacity(0.2) : .clear, radius: 4, y: 2)
//                    }
//                    .buttonStyle(.plain)
//                }
//            }
//        }
//    }
//}
//
//// MARK: - Detail Pages
//
//struct PersonalInfoDetail: View {
//    @Bindable var settings: SettingsStore
//    let ages = (13...100).map { "\($0)" }
//
//    var body: some View {
//        DetailPageWrapper(title: "Personal Info", icon: "person.fill", iconColor: Color(hex: "2D6A4F")) {
//            SettingsCard(title: "Your Profile", icon: "person.fill", iconColor: Color(hex: "2D6A4F")) {
//                SettingsTextField(label: "First Name", text: $settings.name, placeholder: "e.g. Vijay")
//                VStack(alignment: .leading, spacing: 6) {
//                    Text("Age").font(.caption).fontWeight(.semibold).foregroundStyle(Color(hex: "2D6A4F").opacity(0.7))
//                    Picker("Age", selection: $settings.age) {
//                        ForEach(ages, id: \.self) { Text($0).tag($0) }
//                    }
//                    .pickerStyle(.wheel).frame(height: 120)
//                    .background(Color(hex: "F0FAF4"), in: RoundedRectangle(cornerRadius: 12))
//                }
//                SettingsSingleSelect(label: "Gender",
//                    options: ["Male", "Female", "Non-binary", "Prefer not to say"],
//                    selected: $settings.gender)
//                SettingsSingleSelect(label: "Household Size",
//                    options: ["Just me 🙋", "2 people 👫", "3–4 people 👨‍👩‍👧", "5+ people 👨‍👩‍👧‍👦"],
//                    selected: $settings.householdSize)
//            }
//        }
//    }
//}
//
//struct AllergiesDetail: View {
//    @Bindable var settings: SettingsStore
//
//    var body: some View {
//        DetailPageWrapper(title: "Allergies", icon: "exclamationmark.shield.fill", iconColor: Color(hex: "DC2626")) {
//            SettingsCard(title: "Food Allergies", icon: "exclamationmark.shield.fill", iconColor: Color(hex: "DC2626")) {
//                Text("We'll flag items in your fridge and filter out unsafe recipes.")
//                    .font(.caption).foregroundStyle(Color(hex: "1B4332").opacity(0.5))
//                SettingsMultiSelect(label: "Select all that apply",
//                    options: ["Nuts 🥜", "Dairy 🥛", "Gluten 🌾", "Eggs 🥚", "Shellfish 🦐", "Soy 🫘", "Fish 🐠", "None ✅"],
//                    selected: $settings.allergies)
//            }
//        }
//    }
//}
//
//struct DietaryDetail: View {
//    @Bindable var settings: SettingsStore
//
//    var body: some View {
//        DetailPageWrapper(title: "Dietary Preferences", icon: "leaf.fill", iconColor: Color(hex: "40916C")) {
//            SettingsCard(title: "Your Diet", icon: "leaf.fill", iconColor: Color(hex: "40916C")) {
//                Text("Select all that apply. We'll filter recipes and flag incompatible items.")
//                    .font(.caption).foregroundStyle(Color(hex: "1B4332").opacity(0.5))
//                SettingsMultiSelect(label: "",
//                    options: ["Vegetarian 🥦", "Vegan 🌱", "Pescatarian 🐟", "Keto 🥩", "Paleo 🍖", "Halal ☪️", "Kosher ✡️", "No restrictions 🍽️"],
//                    selected: $settings.dietaryPrefs)
//            }
//        }
//    }
//}
//
//struct MealGoalsDetail: View {
//    @Bindable var settings: SettingsStore
//
//    var body: some View {
//        DetailPageWrapper(title: "Meal Goals", icon: "target", iconColor: Color(hex: "D97706")) {
//            SettingsCard(title: "Health Goal", icon: "heart.fill", iconColor: Color(hex: "DC2626")) {
//                Text("We'll tailor your recipe suggestions and nutrition info around this.")
//                    .font(.caption).foregroundStyle(Color(hex: "1B4332").opacity(0.5))
//                SettingsSingleSelect(label: "Primary goal",
//                    options: ["Lose weight 🔥", "Maintain weight ⚖️", "Gain muscle 💪", "Eat healthier 🥗", "Reduce waste ♻️"],
//                    selected: $settings.healthGoal)
//            }
//            SettingsCard(title: "Daily Calorie Target", icon: "flame.fill", iconColor: Color(hex: "D97706")) {
//                Text("We'll show calorie info for recipes and flag items that don't fit.")
//                    .font(.caption).foregroundStyle(Color(hex: "1B4332").opacity(0.5))
//                SettingsSingleSelect(label: "",
//                    options: ["1200 kcal", "1500 kcal", "1800 kcal", "2000 kcal", "2200 kcal", "2500 kcal", "2800 kcal", "3000+ kcal"],
//                    selected: $settings.calorieGoal)
//            }
//        }
//    }
//}
//
//struct MealScheduleDetail: View {
//    @Bindable var settings: SettingsStore
//
//    var body: some View {
//        DetailPageWrapper(title: "Meal Schedule", icon: "clock.fill", iconColor: Color(hex: "2D6A4F")) {
//            SettingsCard(title: "Meals Per Day", icon: "fork.knife", iconColor: Color(hex: "2D6A4F")) {
//                SettingsSingleSelect(label: "How many meals do you eat?",
//                    options: ["2 meals", "3 meals", "4 meals", "5+ meals"],
//                    selected: $settings.mealsPerDay)
//            }
//            SettingsCard(title: "Meal Times", icon: "clock.fill", iconColor: Color(hex: "40916C")) {
//                Text("Used to send you timely recipe suggestions.")
//                    .font(.caption).foregroundStyle(Color(hex: "1B4332").opacity(0.5))
//                SettingsSingleSelect(label: "Breakfast", options: ["6:00 AM", "7:00 AM", "8:00 AM", "9:00 AM", "10:00 AM"], selected: $settings.breakfastTime)
//                SettingsSingleSelect(label: "Lunch",     options: ["11:30 AM", "12:00 PM", "12:30 PM", "1:00 PM", "2:00 PM"], selected: $settings.lunchTime)
//                SettingsSingleSelect(label: "Dinner",    options: ["5:00 PM", "6:00 PM", "7:00 PM", "8:00 PM", "9:00 PM"],   selected: $settings.dinnerTime)
//            }
//        }
//    }
//}
//
//struct CookingDetail: View {
//    @Bindable var settings: SettingsStore
//
//    var body: some View {
//        DetailPageWrapper(title: "Cooking Preferences", icon: "frying.pan.fill", iconColor: Color(hex: "40916C")) {
//            SettingsCard(title: "Skill Level", icon: "frying.pan.fill", iconColor: Color(hex: "2D6A4F")) {
//                SettingsSingleSelect(label: "I'm a...", options: ["Beginner 🌱", "Intermediate 🍳", "Advanced 👨‍🍳"], selected: $settings.cookingLevel)
//            }
//            SettingsCard(title: "Weekly Budget", icon: "dollarsign.circle.fill", iconColor: Color(hex: "D97706")) {
//                SettingsSingleSelect(label: "Grocery budget per week", options: ["Under $50", "$50–$100", "$100–$150", "$150–$200", "$200+"], selected: $settings.budget)
//            }
//            SettingsCard(title: "Time to Cook", icon: "timer", iconColor: Color(hex: "40916C")) {
//                SettingsSingleSelect(label: "How long can you spend cooking?", options: ["Under 15 min", "15–30 min", "30–60 min", "60+ min"], selected: $settings.cookTime)
//            }
//            SettingsCard(title: "Shopping Frequency", icon: "cart.fill", iconColor: Color(hex: "52B788")) {
//                SettingsSingleSelect(label: "How often do you grocery shop?", options: ["Daily 🛒", "Every few days 📅", "Weekly 🗓️", "Every 2 weeks 📦"], selected: $settings.shoppingFrequency)
//            }
//        }
//    }
//}
//
//struct CuisineDetail: View {
//    @Bindable var settings: SettingsStore
//
//    var body: some View {
//        DetailPageWrapper(title: "Cuisine Preferences", icon: "globe", iconColor: Color(hex: "52B788")) {
//            SettingsCard(title: "Favourite Cuisines", icon: "globe", iconColor: Color(hex: "2D6A4F")) {
//                Text("We'll prioritise these when suggesting recipes from your fridge.")
//                    .font(.caption).foregroundStyle(Color(hex: "1B4332").opacity(0.5))
//                SettingsMultiSelect(label: "",
//                    options: ["Italian 🍝", "Asian 🍜", "Mexican 🌮", "Mediterranean 🫒", "American 🍔", "Indian 🍛", "Middle Eastern 🧆", "French 🥐", "Japanese 🍱", "Korean 🍲", "Thai 🌶️", "Greek 🫙"],
//                    selected: $settings.cuisines)
//            }
//        }
//    }
//}
//
//struct ExpiryAlertsDetail: View {
//    @Bindable var settings: SettingsStore
//
//    var body: some View {
//        DetailPageWrapper(title: "Expiry Alerts", icon: "bell.fill", iconColor: Color(hex: "D97706")) {
//            SettingsCard(title: "Alert Settings", icon: "bell.fill", iconColor: Color(hex: "D97706")) {
//                HStack {
//                    VStack(alignment: .leading, spacing: 2) {
//                        Text("Enable Expiry Alerts").font(.subheadline).fontWeight(.semibold).foregroundStyle(Color(hex: "1B4332"))
//                        Text("Notify me when items are about to expire").font(.caption).foregroundStyle(Color(hex: "2D6A4F").opacity(0.6))
//                    }
//                    Spacer()
//                    Toggle("", isOn: $settings.alertsEnabled).tint(Color(hex: "2D6A4F"))
//                }
//            }
//
//            if settings.alertsEnabled {
//                SettingsCard(title: "Notify Me When", icon: "clock.badge.exclamationmark.fill", iconColor: Color(hex: "DC2626")) {
//                    VStack(alignment: .leading, spacing: 10) {
//                        HStack {
//                            Text("Days before expiry").font(.subheadline).fontWeight(.semibold).foregroundStyle(Color(hex: "1B4332"))
//                            Spacer()
//                            Text("\(Int(settings.alertDays)) day\(settings.alertDays == 1 ? "" : "s")").font(.subheadline).fontWeight(.bold).foregroundStyle(Color(hex: "2D6A4F"))
//                        }
//                        Slider(value: $settings.alertDays, in: 1...7, step: 1).tint(Color(hex: "2D6A4F"))
//                        HStack {
//                            Text("1 day").font(.caption2).foregroundStyle(Color(hex: "1B4332").opacity(0.4))
//                            Spacer()
//                            Text("7 days").font(.caption2).foregroundStyle(Color(hex: "1B4332").opacity(0.4))
//                        }
//                    }
//                }
//
//                SettingsCard(title: "Alert Time", icon: "sun.horizon.fill", iconColor: Color(hex: "40916C")) {
//                    Text("What time should we send daily expiry alerts?").font(.caption).foregroundStyle(Color(hex: "1B4332").opacity(0.5))
//                    SettingsSingleSelect(label: "",
//                        options: ["7:00 AM", "8:00 AM", "9:00 AM", "10:00 AM", "12:00 PM", "6:00 PM", "8:00 PM"],
//                        selected: $settings.alertTime)
//                }
//            }
//        }
//    }
//}
//
//// MARK: - Preview
//
//#Preview {
//    SettingsView()
//        .environment(FridgeInventoryViewModel(pantry: []))
//}

//
//  SettingsView.swift
//  SmartFridge
//
//
//import SwiftUI
//
//// MARK: - Codable User Model (matches backend)
//
//struct MacroTargets: Codable {
//    var calories: Int
//    var protein: Int
//}
//
//struct User: Codable {
//    var name: String
//    var age: Int
//    var household_size: Int
//    var meals_per_day: Int
//    var macro_targets: MacroTargets
//    var dietary_restriction: String
//    var allergies: [String]
//    var cooking_proficiency: String
//    var cuisine_preferences: [String]
//}
//
//// MARK: - User Store (JSON file persistence)
//
//@Observable
//class UserStore {
//    var user: User
//
//    private static let fileURL: URL = {
//        let docs = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
//        return docs.appendingPathComponent("user_profile.json")
//    }()
//
//    init() {
//        if let data = try? Data(contentsOf: UserStore.fileURL),
//           let decoded = try? JSONDecoder().decode(User.self, from: data) {
//            self.user = decoded
//        } else {
//            self.user = User(
//                name: "",
//                age: 25,
//                household_size: 1,
//                meals_per_day: 3,
//                macro_targets: MacroTargets(calories: 2000, protein: 150),
//                dietary_restriction: "",
//                allergies: [],
//                cooking_proficiency: "",
//                cuisine_preferences: []
//            )
//        }
//    }
//
//    func save() {
//        if let data = try? JSONEncoder().encode(user) {
//            try? data.write(to: UserStore.fileURL)
//        }
//    }
//
//    // Convenience: call after any mutation
//    func update(_ mutation: (inout User) -> Void) {
//        mutation(&user)
//        save()
//    }
//}
//
//// MARK: - Settings Destination Enum
//
//enum SettingsDest: Hashable {
//    case personalInfo, dietary, allergies, cooking, cuisine, macros, schedule
//}
//
//// MARK: - Main Settings View
//
//struct SettingsView: View {
//    @State private var store = UserStore()
//    @State private var path = NavigationPath()
//
//    var body: some View {
//        NavigationStack(path: $path) {
//            VStack(spacing: 0) {
//
//                // ── Fixed banner ──
//                HStack {
//                    Spacer()
//                    Text("SmartFridge 🌿")
//                        .font(.system(size: 22, weight: .heavy, design: .rounded))
//                        .foregroundStyle(Color(hex: "1B4332"))
//                    Spacer()
//                }
//                .padding(.vertical, 14)
//                .background(Color(hex: "D8F3DC"))
//                .overlay(Rectangle().fill(Color(hex: "1B4332").opacity(0.07)).frame(height: 1), alignment: .bottom)
//
//                ZStack {
//                    LinearGradient(
//                        colors: [Color(hex: "D8F3DC"), Color(hex: "EDF7F0"), Color(hex: "F0FAF4")],
//                        startPoint: .topLeading, endPoint: .bottomTrailing
//                    )
//                    .ignoresSafeArea()
//
//                    ScrollView(showsIndicators: false) {
//                        VStack(spacing: 24) {
//
//                            summaryCard
//
//                            SettingsGroup(title: "Personal", rows: [
//                                (.personalInfo, "person.fill", "Personal Info", Color(hex: "2D6A4F")),
//                            ], path: $path)
//
//                            SettingsGroup(title: "Diet & Restrictions", rows: [
//                                (.dietary,   "leaf.fill",                   "Dietary Restriction", Color(hex: "40916C")),
//                                (.allergies, "exclamationmark.shield.fill", "Allergies",           Color(hex: "DC2626")),
//                            ], path: $path)
//
//                            SettingsGroup(title: "Nutrition & Meals", rows: [
//                                (.macros,    "chart.bar.fill", "Macro Targets",       Color(hex: "2D6A4F")),
//                                (.schedule,  "fork.knife",     "Meal Schedule",       Color(hex: "D97706")),
//                            ], path: $path)
//
//                            SettingsGroup(title: "Cooking", rows: [
//                                (.cooking,  "frying.pan.fill", "Cooking Proficiency", Color(hex: "40916C")),
//                                (.cuisine,  "globe",           "Cuisine Preferences", Color(hex: "52B788")),
//                            ], path: $path)
//                        }
//                        .padding(.horizontal, 18)
//                        .padding(.top, 20)
//                        .padding(.bottom, 40)
//                    }
//                }
//            }
//            .navigationBarHidden(true)
//            .ignoresSafeArea(edges: .bottom)
//            .navigationDestination(for: SettingsDest.self) { dest in
//                switch dest {
//                case .personalInfo: PersonalInfoDetail(store: store)
//                case .dietary:      DietaryDetail(store: store)
//                case .allergies:    AllergiesDetail(store: store)
//                case .cooking:      CookingDetail(store: store)
//                case .cuisine:      CuisineDetail(store: store)
//                case .macros:       MacrosDetail(store: store)
//                case .schedule:     ScheduleDetail(store: store)
//                }
//            }
//        }
//    }
//
//    // MARK: - Summary Card
//
//    private var summaryCard: some View {
//        VStack(alignment: .leading, spacing: 12) {
//            HStack(spacing: 10) {
//                ZStack {
//                    Circle()
//                        .fill(LinearGradient(colors: [Color(hex: "1B4332"), Color(hex: "2D6A4F")], startPoint: .topLeading, endPoint: .bottomTrailing))
//                        .frame(width: 48, height: 48)
//                    Text(store.user.name.isEmpty ? "?" : String(store.user.name.prefix(1)).uppercased())
//                        .font(.system(size: 20, weight: .bold, design: .rounded))
//                        .foregroundStyle(.white)
//                }
//                VStack(alignment: .leading, spacing: 2) {
//                    Text(store.user.name.isEmpty ? "Set your name" : store.user.name)
//                        .font(.system(size: 16, weight: .bold, design: .rounded))
//                        .foregroundStyle(Color(hex: "1B4332"))
//                    Text("Age \(store.user.age) · \(store.user.household_size) person household")
//                        .font(.caption)
//                        .foregroundStyle(Color(hex: "2D6A4F").opacity(0.6))
//                }
//                Spacer()
//            }
//
//            Divider().background(Color(hex: "D8F3DC"))
//
//            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 6) {
//                SummaryPill(label: "Diet",    value: store.user.dietary_restriction.isEmpty ? "Not set" : store.user.dietary_restriction)
//                SummaryPill(label: "Macros",  value: "\(store.user.macro_targets.calories) kcal · \(store.user.macro_targets.protein)g protein")
//                SummaryPill(label: "Meals",   value: "\(store.user.meals_per_day)/day")
//                SummaryPill(label: "Cooking", value: store.user.cooking_proficiency.isEmpty ? "Not set" : store.user.cooking_proficiency)
//            }
//        }
//        .padding(18)
//        .background(Color.white)
//        .clipShape(RoundedRectangle(cornerRadius: 20))
//        .shadow(color: Color(hex: "2D6A4F").opacity(0.08), radius: 10, x: 0, y: 4)
//    }
//}
//
//struct SummaryPill: View {
//    let label: String
//    let value: String
//
//    var body: some View {
//        VStack(alignment: .leading, spacing: 2) {
//            Text(label.uppercased())
//                .font(.system(size: 9, weight: .bold))
//                .foregroundStyle(Color(hex: "2D6A4F").opacity(0.5))
//            Text(value)
//                .font(.system(size: 12, weight: .semibold))
//                .foregroundStyle(Color(hex: "1B4332"))
//                .lineLimit(1)
//                .minimumScaleFactor(0.7)
//        }
//        .frame(maxWidth: .infinity, alignment: .leading)
//        .padding(.horizontal, 10).padding(.vertical, 8)
//        .background(Color(hex: "F0FAF4"))
//        .clipShape(RoundedRectangle(cornerRadius: 10))
//    }
//}
//
//// MARK: - Settings Group
//
//struct SettingsGroup: View {
//    let title: String
//    let rows: [(SettingsDest, String, String, Color)]
//    @Binding var path: NavigationPath
//
//    var body: some View {
//        VStack(alignment: .leading, spacing: 8) {
//            Text(title.uppercased())
//                .font(.system(size: 11, weight: .semibold))
//                .foregroundStyle(Color(hex: "2D6A4F").opacity(0.5))
//                .padding(.horizontal, 4)
//
//            VStack(spacing: 0) {
//                ForEach(Array(rows.enumerated()), id: \.offset) { index, row in
//                    let (dest, icon, label, color) = row
//                    Button { path.append(dest) } label: {
//                        HStack(spacing: 14) {
//                            ZStack {
//                                RoundedRectangle(cornerRadius: 8).fill(color).frame(width: 34, height: 34)
//                                Image(systemName: icon).font(.system(size: 16, weight: .semibold)).foregroundStyle(.white)
//                            }
//                            Text(label).font(.system(size: 16, weight: .medium)).foregroundStyle(Color(hex: "1B4332"))
//                            Spacer()
//                            Image(systemName: "chevron.right").font(.system(size: 13, weight: .semibold)).foregroundStyle(Color(hex: "2D6A4F").opacity(0.3))
//                        }
//                        .padding(.horizontal, 16).padding(.vertical, 13)
//                        .background(Color.white)
//                    }
//                    .buttonStyle(.plain)
//                    if index < rows.count - 1 { Divider().padding(.leading, 64).background(Color.white) }
//                }
//            }
//            .clipShape(RoundedRectangle(cornerRadius: 16))
//            .shadow(color: Color(hex: "2D6A4F").opacity(0.07), radius: 8, x: 0, y: 3)
//        }
//    }
//}
//
//// MARK: - Detail Page Wrapper
//
//struct DetailPageWrapper<Content: View>: View {
//    let title: String
//    let icon: String
//    let iconColor: Color
//    @Environment(\.dismiss) private var dismiss
//    @ViewBuilder let content: Content
//
//    var body: some View {
//        VStack(spacing: 0) {
//            HStack(spacing: 12) {
//                Button { dismiss() } label: {
//                    HStack(spacing: 6) {
//                        Image(systemName: "chevron.left").font(.system(size: 16, weight: .semibold))
//                        Text("Settings").font(.system(size: 16, weight: .semibold))
//                    }
//                    .foregroundStyle(Color(hex: "1B4332"))
//                }
//                Spacer()
//                HStack(spacing: 8) {
//                    ZStack {
//                        RoundedRectangle(cornerRadius: 8).fill(iconColor).frame(width: 30, height: 30)
//                        Image(systemName: icon).font(.system(size: 14, weight: .semibold)).foregroundStyle(.white)
//                    }
//                    Text(title).font(.system(size: 17, weight: .bold, design: .rounded)).foregroundStyle(Color(hex: "1B4332"))
//                }
//                Spacer()
//                Color.clear.frame(width: 80, height: 1)
//            }
//            .padding(.horizontal, 18).padding(.vertical, 14)
//            .background(Color(hex: "D8F3DC"))
//            .overlay(Rectangle().fill(Color(hex: "1B4332").opacity(0.07)).frame(height: 1), alignment: .bottom)
//
//            ZStack {
//                LinearGradient(colors: [Color(hex: "D8F3DC"), Color(hex: "EDF7F0"), Color(hex: "F0FAF4")], startPoint: .topLeading, endPoint: .bottomTrailing)
//                    .ignoresSafeArea()
//                ScrollView(showsIndicators: false) {
//                    VStack(spacing: 20) { content }
//                        .padding(.horizontal, 18).padding(.top, 20).padding(.bottom, 40)
//                }
//            }
//        }
//        .navigationBarHidden(true)
//        .ignoresSafeArea(edges: .bottom)
//    }
//}
//
//// MARK: - Reusable Components
//
//struct SettingsCard<Content: View>: View {
//    let title: String
//    let icon: String
//    let iconColor: Color
//    @ViewBuilder let content: Content
//
//    var body: some View {
//        VStack(alignment: .leading, spacing: 16) {
//            HStack(spacing: 10) {
//                ZStack {
//                    RoundedRectangle(cornerRadius: 8).fill(iconColor.opacity(0.15)).frame(width: 32, height: 32)
//                    Image(systemName: icon).font(.system(size: 15, weight: .semibold)).foregroundStyle(iconColor)
//                }
//                Text(title).font(.system(size: 16, weight: .bold, design: .rounded)).foregroundStyle(Color(hex: "1B4332"))
//            }
//            content
//        }
//        .padding(18)
//        .background(Color.white)
//        .clipShape(RoundedRectangle(cornerRadius: 20))
//        .shadow(color: Color(hex: "2D6A4F").opacity(0.07), radius: 10, x: 0, y: 4)
//    }
//}
//
//struct SettingsSingleSelect: View {
//    let label: String
//    let options: [String]
//    @Binding var selected: String
//
//    var body: some View {
//        VStack(alignment: .leading, spacing: 8) {
//            if !label.isEmpty { Text(label).font(.caption).fontWeight(.semibold).foregroundStyle(Color(hex: "2D6A4F").opacity(0.7)) }
//            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 8) {
//                ForEach(options, id: \.self) { option in
//                    Button { withAnimation(.spring(duration: 0.25)) { selected = option } } label: {
//                        Text(option)
//                            .font(.system(size: 13, weight: selected == option ? .bold : .medium))
//                            .foregroundStyle(selected == option ? .white : Color(hex: "1B4332"))
//                            .lineLimit(1).minimumScaleFactor(0.8)
//                            .frame(maxWidth: .infinity).padding(.vertical, 10)
//                            .background(selected == option
//                                ? AnyShapeStyle(LinearGradient(colors: [Color(hex: "1B4332"), Color(hex: "2D6A4F")], startPoint: .leading, endPoint: .trailing))
//                                : AnyShapeStyle(Color(hex: "F0FAF4")))
//                            .clipShape(RoundedRectangle(cornerRadius: 10))
//                            .overlay(RoundedRectangle(cornerRadius: 10).stroke(selected == option ? Color.clear : Color(hex: "52B788").opacity(0.3), lineWidth: 1))
//                            .shadow(color: selected == option ? Color(hex: "1B4332").opacity(0.2) : .clear, radius: 4, y: 2)
//                    }
//                    .buttonStyle(.plain)
//                }
//            }
//        }
//    }
//}
//
//struct SettingsMultiSelect: View {
//    let label: String
//    let options: [String]
//    @Binding var selected: [String]
//
//    var body: some View {
//        VStack(alignment: .leading, spacing: 8) {
//            if !label.isEmpty { Text(label).font(.caption).fontWeight(.semibold).foregroundStyle(Color(hex: "2D6A4F").opacity(0.7)) }
//            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 8) {
//                ForEach(options, id: \.self) { option in
//                    Button {
//                        withAnimation(.spring(duration: 0.25)) {
//                            if selected.contains(option) { selected.removeAll { $0 == option } }
//                            else { selected.append(option) }
//                        }
//                    } label: {
//                        HStack(spacing: 4) {
//                            if selected.contains(option) { Image(systemName: "checkmark").font(.system(size: 10, weight: .bold)).foregroundStyle(.white) }
//                            Text(option)
//                                .font(.system(size: 13, weight: selected.contains(option) ? .bold : .medium))
//                                .foregroundStyle(selected.contains(option) ? .white : Color(hex: "1B4332"))
//                                .lineLimit(1).minimumScaleFactor(0.8)
//                        }
//                        .frame(maxWidth: .infinity).padding(.vertical, 10)
//                        .background(selected.contains(option)
//                            ? AnyShapeStyle(LinearGradient(colors: [Color(hex: "1B4332"), Color(hex: "40916C")], startPoint: .leading, endPoint: .trailing))
//                            : AnyShapeStyle(Color(hex: "F0FAF4")))
//                        .clipShape(RoundedRectangle(cornerRadius: 10))
//                        .overlay(RoundedRectangle(cornerRadius: 10).stroke(selected.contains(option) ? Color.clear : Color(hex: "52B788").opacity(0.3), lineWidth: 1))
//                        .shadow(color: selected.contains(option) ? Color(hex: "1B4332").opacity(0.2) : .clear, radius: 4, y: 2)
//                    }
//                    .buttonStyle(.plain)
//                }
//            }
//        }
//    }
//}
//
//// MARK: - Detail Pages
//
//struct PersonalInfoDetail: View {
//    @State var store: UserStore
//    let ages = Array(13...100)
//    let householdSizes = Array(1...10)
//
//    var body: some View {
//        DetailPageWrapper(title: "Personal Info", icon: "person.fill", iconColor: Color(hex: "2D6A4F")) {
//            SettingsCard(title: "Your Profile", icon: "person.fill", iconColor: Color(hex: "2D6A4F")) {
//
//                // Name
//                VStack(alignment: .leading, spacing: 6) {
//                    Text("First Name").font(.caption).fontWeight(.semibold).foregroundStyle(Color(hex: "2D6A4F").opacity(0.7))
//                    TextField("e.g. Vijay", text: Binding(
//                        get: { store.user.name },
//                        set: { newVal in store.update { $0.name = newVal } }
//                    ))
//                    .font(.system(size: 15, weight: .medium))
//                    .padding(.horizontal, 14).padding(.vertical, 12)
//                    .background(Color(hex: "F0FAF4"))
//                    .clipShape(RoundedRectangle(cornerRadius: 12))
//                    .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color(hex: "52B788").opacity(0.35), lineWidth: 1.5))
//                }
//
//                // Age
//                VStack(alignment: .leading, spacing: 6) {
//                    Text("Age").font(.caption).fontWeight(.semibold).foregroundStyle(Color(hex: "2D6A4F").opacity(0.7))
//                    Picker("Age", selection: Binding(
//                        get: { store.user.age },
//                        set: { newVal in store.update { $0.age = newVal } }
//                    )) {
//                        ForEach(ages, id: \.self) { Text("\($0)").tag($0) }
//                    }
//                    .pickerStyle(.wheel).frame(height: 120)
//                    .background(Color(hex: "F0FAF4"), in: RoundedRectangle(cornerRadius: 12))
//                }
//
//                // Household size
//                VStack(alignment: .leading, spacing: 6) {
//                    Text("Household Size").font(.caption).fontWeight(.semibold).foregroundStyle(Color(hex: "2D6A4F").opacity(0.7))
//                    Picker("Household Size", selection: Binding(
//                        get: { store.user.household_size },
//                        set: { newVal in store.update { $0.household_size = newVal } }
//                    )) {
//                        ForEach(householdSizes, id: \.self) { Text("\($0) person\($0 == 1 ? "" : "s")").tag($0) }
//                    }
//                    .pickerStyle(.wheel).frame(height: 100)
//                    .background(Color(hex: "F0FAF4"), in: RoundedRectangle(cornerRadius: 12))
//                }
//            }
//        }
//    }
//}
//
//struct DietaryDetail: View {
//    @State var store: UserStore
//
//    var body: some View {
//        DetailPageWrapper(title: "Dietary Restriction", icon: "leaf.fill", iconColor: Color(hex: "40916C")) {
//            SettingsCard(title: "Diet Type", icon: "leaf.fill", iconColor: Color(hex: "40916C")) {
//                Text("Stored as `dietary_restriction`.")
//                    .font(.caption).foregroundStyle(Color(hex: "1B4332").opacity(0.5))
//                SettingsSingleSelect(label: "",
//                    options: ["high protein", "vegetarian", "vegan", "keto", "paleo", "balanced", "low carb", "mediterranean"],
//                    selected: Binding(
//                        get: { store.user.dietary_restriction },
//                        set: { newVal in store.update { $0.dietary_restriction = newVal } }
//                    ))
//            }
//        }
//    }
//}
//
//struct AllergiesDetail: View {
//    @State var store: UserStore
//
//    var body: some View {
//        DetailPageWrapper(title: "Allergies", icon: "exclamationmark.shield.fill", iconColor: Color(hex: "DC2626")) {
//            SettingsCard(title: "Food Allergies", icon: "exclamationmark.shield.fill", iconColor: Color(hex: "DC2626")) {
//                Text("Stored as `allergies`. Select all that apply.")
//                    .font(.caption).foregroundStyle(Color(hex: "1B4332").opacity(0.5))
//                SettingsMultiSelect(label: "",
//                    options: ["gluten", "dairy", "nuts", "eggs", "shellfish", "soy", "fish", "none"],
//                    selected: Binding(
//                        get: { store.user.allergies },
//                        set: { newVal in store.update { $0.allergies = newVal } }
//                    ))
//            }
//        }
//    }
//}
//
//struct MacrosDetail: View {
//    @State var store: UserStore
//    let calorieOptions = ["1200", "1500", "1800", "2000", "2200", "2500", "2800", "3000"]
//    let proteinOptions  = ["80", "100", "120", "150", "175", "200", "225", "250"]
//
//    var body: some View {
//        DetailPageWrapper(title: "Macro Targets", icon: "chart.bar.fill", iconColor: Color(hex: "2D6A4F")) {
//            SettingsCard(title: "Daily Macro Targets", icon: "chart.bar.fill", iconColor: Color(hex: "2D6A4F")) {
//                Text("Stored as `macro_targets`.")
//                    .font(.caption).foregroundStyle(Color(hex: "1B4332").opacity(0.5))
//
//                VStack(alignment: .leading, spacing: 6) {
//                    Text("Calories (kcal)").font(.caption).fontWeight(.semibold).foregroundStyle(Color(hex: "2D6A4F").opacity(0.7))
//                    Picker("Calories", selection: Binding(
//                        get: { String(store.user.macro_targets.calories) },
//                        set: { newVal in store.update { $0.macro_targets.calories = Int(newVal) ?? 2000 } }
//                    )) {
//                        ForEach(calorieOptions, id: \.self) { Text($0).tag($0) }
//                    }
//                    .pickerStyle(.wheel).frame(height: 100)
//                    .background(Color(hex: "F0FAF4"), in: RoundedRectangle(cornerRadius: 12))
//                }
//
//                VStack(alignment: .leading, spacing: 6) {
//                    Text("Protein (g)").font(.caption).fontWeight(.semibold).foregroundStyle(Color(hex: "2D6A4F").opacity(0.7))
//                    Picker("Protein", selection: Binding(
//                        get: { String(store.user.macro_targets.protein) },
//                        set: { newVal in store.update { $0.macro_targets.protein = Int(newVal) ?? 150 } }
//                    )) {
//                        ForEach(proteinOptions, id: \.self) { Text($0).tag($0) }
//                    }
//                    .pickerStyle(.wheel).frame(height: 100)
//                    .background(Color(hex: "F0FAF4"), in: RoundedRectangle(cornerRadius: 12))
//                }
//            }
//        }
//    }
//}
//
//struct ScheduleDetail: View {
//    @State var store: UserStore
//
//    var body: some View {
//        DetailPageWrapper(title: "Meal Schedule", icon: "fork.knife", iconColor: Color(hex: "D97706")) {
//            SettingsCard(title: "Meals Per Day", icon: "fork.knife", iconColor: Color(hex: "D97706")) {
//                Text("Stored as `meals_per_day`.")
//                    .font(.caption).foregroundStyle(Color(hex: "1B4332").opacity(0.5))
//                SettingsSingleSelect(label: "",
//                    options: ["1", "2", "3", "4", "5", "6"],
//                    selected: Binding(
//                        get: { String(store.user.meals_per_day) },
//                        set: { newVal in store.update { $0.meals_per_day = Int(newVal) ?? 3 } }
//                    ))
//            }
//        }
//    }
//}
//
//struct CookingDetail: View {
//    @State var store: UserStore
//
//    var body: some View {
//        DetailPageWrapper(title: "Cooking Proficiency", icon: "frying.pan.fill", iconColor: Color(hex: "40916C")) {
//            SettingsCard(title: "Skill Level", icon: "frying.pan.fill", iconColor: Color(hex: "40916C")) {
//                Text("Stored as `cooking_proficiency`.")
//                    .font(.caption).foregroundStyle(Color(hex: "1B4332").opacity(0.5))
//                SettingsSingleSelect(label: "",
//                    options: ["beginner", "intermediate", "advanced"],
//                    selected: Binding(
//                        get: { store.user.cooking_proficiency },
//                        set: { newVal in store.update { $0.cooking_proficiency = newVal } }
//                    ))
//            }
//        }
//    }
//}
//
//struct CuisineDetail: View {
//    @State var store: UserStore
//
//    var body: some View {
//        DetailPageWrapper(title: "Cuisine Preferences", icon: "globe", iconColor: Color(hex: "52B788")) {
//            SettingsCard(title: "Favourite Cuisines", icon: "globe", iconColor: Color(hex: "52B788")) {
//                Text("Stored as `cuisine_preferences`. Select all you enjoy.")
//                    .font(.caption).foregroundStyle(Color(hex: "1B4332").opacity(0.5))
//                SettingsMultiSelect(label: "",
//                    options: ["italian", "asian", "mexican", "mediterranean", "american", "indian", "middle eastern", "french", "japanese", "korean", "thai", "greek"],
//                    selected: Binding(
//                        get: { store.user.cuisine_preferences },
//                        set: { newVal in store.update { $0.cuisine_preferences = newVal } }
//                    ))
//            }
//        }
//    }
//}
//
//// MARK: - Preview
//
//#Preview {
//    SettingsView()
//        .environment(FridgeInventoryViewModel())
//}

