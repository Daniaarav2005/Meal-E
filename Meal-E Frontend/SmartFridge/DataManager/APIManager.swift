//
//  APIManager.swift
//  SmartFridge
//
//  Created by Michael Pancras on 2/21/26.
//

import Foundation

class APIManager {
    
    static let shared = APIManager()
    
    private init() {}
    
    let ip = "Enter your IP here"
    var base: String {
        return "http://\(ip):8000"
    }
    
//    }
    
//    public func get(_ endpoint: String) async -> [PantryItem] {
//        
//        print("HELO")
//        
//        let url = URL(string: "\(base)\(endpoint)")!
//        
//        var request = URLRequest(url: url)
//        request.httpMethod = "GET"
//        
//        let (data, response) = try! await URLSession.shared.data(for: request)
//        let result = try? JSONDecoder().decode(PantryResponse.self, from: data)
//    
//        print("HELLLO")
//        
//        let items = result.pantry
//        return items
//    }
    
    public func getPantry(_ endpoint: String = "/pantry") async throws -> [FridgeItem] {
        
        guard let url = URL(string: "\(base)\(endpoint)") else {
            print("❌ Invalid URL: \(base)\(endpoint)")
            return []
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"

        let (data, response) = try await URLSession.shared.data(for: request)
        
        if let raw = String(data: data, encoding: .utf8) {
            print("📦 Raw response: \(raw)")
        }

        
        let decoded = try JSONDecoder().decode(PantryResponse.self, from: data)
                
        return convertRespone(decoded)

    }
    
    public func deletePantryItem(id: Int) async throws -> Bool {
        var components = URLComponents(string: "\(base)/pantry")
        components?.queryItems = [URLQueryItem(name: "id", value: "\(id)")]

        guard let url = components?.url else {
            print("❌ Invalid URL")
            return false
        }

        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"

        let (_, response) = try await URLSession.shared.data(for: request)

        guard let http = response as? HTTPURLResponse else {
            print("❌ Invalid response type")
            return false
        }

        guard (200...299).contains(http.statusCode) else {
            print("❌ HTTP error: \(http.statusCode)")
            return false
        }

        print("✅ Deleted pantry item \(id)")
        return true
    }
    
    public func getProfile(_ endpoint: String = "/preferences") async throws -> User? {
        
        guard let url = URL(string: "\(base)\(endpoint)") else {
            print("❌ Invalid URL: \(base)\(endpoint)")
            return nil
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        let decoded = try JSONDecoder().decode(User.self, from: data)
        
        return decoded
        
    }
    
    public func putProfile(_ endpoint: String = "/preferences", profile: User) async throws -> User? {
        
        guard let url = URL(string: "\(base)\(endpoint)") else {
            print("❌ Invalid URL: \(base)\(endpoint)")
            return nil
        }

        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONEncoder().encode(profile)

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let http = response as? HTTPURLResponse else {
            print("❌ Invalid response type")
            return nil
        }

        guard (200...299).contains(http.statusCode) else {
            print("❌ HTTP error: \(http.statusCode)")
            return nil
        }

        return nil
    }
    
    public func convertRespone(_ pantry: PantryResponse) -> [FridgeItem] {
        
        return pantryResponseToFridgeItems(pantry)
        
    }
    
    public func getMealPlan(_ endpoint: String = "/meal-plan", generate: Bool) async throws -> MealPlanResponse? {
        
        var components = URLComponents(string: "\(base)\(endpoint)")
        components?.queryItems = [URLQueryItem(name: "generate", value: "\(generate)")]

        guard let url = components?.url else {
            print("❌ Invalid URL: \(base)\(endpoint)")
            return nil
        }

        var request = URLRequest(url: url, timeoutInterval: 300)
        request.httpMethod = "GET"

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let http = response as? HTTPURLResponse else {
            print("❌ Invalid response type")
            return nil
        }

        guard (200...299).contains(http.statusCode) else {
            print("❌ HTTP error: \(http.statusCode)")
            return nil
        }
        
        let decoded = try JSONDecoder().decode(MealPlanResponse.self, from: data)

        return decoded
    }
    
    
    
//    func userPreferencesToProfile(_ response: UserPreferences) -> UserProfile {
//        return UserProfile(
//            householdSize: String(response.servings),
//            calorieGoal: String(response.macroTargets.calories),
//            mealPreferences: [response.dietType],
//            allergies: response.allergies,
//        )
//    }
//    
//    func profileToUserPreferences(_ profile: UserProfile) -> UserPreferences {
//        return UserPreferences(
//            dietType: profile.mealPreferences.first ?? "none",
//            allergies: profile.allergies,
//            budget: "moderate",
//            macroTargets: MacroTargets(
//                calories: Int(profile.calorieGoal) ?? 2000,
//                protein: 150,
//                carbohydrates: 200,
//                fat: 70
//            ),
//            servings: Int(profile.householdSize) ?? 1,
//            mealsPerDay: 3
//        )
//    }
    
}

struct User: Codable {
    let name: String
    let age: Int
    let household_size: Int
    let meals_per_day: Int
    let macro_targets: MacroTargets
    let dietary_restriction: String
    let allergies: [String]
    let cooking_proficiency: String
    let cuisine_preferences: [String]
}

@Observable
class UserData {
    
    var name: String
    var age: String
    var household_size: String
    var meals_per_day: String
    var macro_targets: Macros
    var dietary_restriction: String
    var allergies: [String]
    var cooking_proficiency: String
    var cuisine_preferences: [String]
    
    init(user: User) {
        self.name = user.name
        self.age = "\(user.age)"
        self.household_size = "\(user.household_size)"
        self.meals_per_day = "\(user.meals_per_day)"
        self.macro_targets = Macros(calories: "\(user.macro_targets.calories)", protein: "\(user.macro_targets.protein)")
        self.dietary_restriction = user.dietary_restriction
        self.allergies = user.allergies
        self.cooking_proficiency = user.cooking_proficiency
        self.cuisine_preferences = user.cuisine_preferences
    }
    
    public func toUser() -> User {
        return User(name: name,
             age: Int(age) ?? 0,
             household_size: Int(household_size) ?? 0,
             meals_per_day: Int(meals_per_day) ?? 0,
             macro_targets: MacroTargets(calories: Int(macro_targets.calories) ?? 0, protein: Int(macro_targets.protein) ?? 0),
             dietary_restriction: dietary_restriction,
             allergies: allergies,
             cooking_proficiency: cooking_proficiency,
             cuisine_preferences: cuisine_preferences)
    }
    
}


//struct UserPreferences: Codable {
//    let name: String
//    let age: Int
//    let dietType: String
//    let allergies: [String]
//    let budget: String
//    let macroTargets: MacroTargets
//    let servings: Int
//    let mealsPerDay: Int
//
//    enum CodingKeys: String, CodingKey {
//        case allergies, budget, servings
//        case dietType     = "diet_type"
//        case macroTargets = "macro_targets"
//        case mealsPerDay  = "meals_per_day"
//    }
//}

struct MacroTargets: Codable {
    let calories: Int
    let protein: Int
}

struct Macros {
    var calories: String
    var protein: String
}

struct PantryResponse: Codable {
    let pantry: [PantryItem]
}

struct PantryItem: Codable, Identifiable {
    let id: Int
    let name: String
    let brand: String
    let quantity: Double?        // ← nullable (Chopped Garlic has null)
    let servingSize: String?     // ← nullable
    let nutrients: Nutrients

    enum CodingKeys: String, CodingKey {
        case id, name, brand, quantity, nutrients
        case servingSize = "serving_size"
    }
}

struct Nutrients: Codable {
    let calories: Double?
    let carbohydrates: Double?
    let protein: Double?
    let fat: Double?
    let saturatedFat: Double?
    let transFat: Double?
    let sugar: Double?
    let addedSugar: Double?
    let fiber: Double?
    let sodium: Double?
    let iron: Double?
    let calcium: Double?
    let potassium: Double?
    let vitaminD: Double?

    enum CodingKeys: String, CodingKey {
        case calories, carbohydrates, protein, fat, fiber, sodium, iron, calcium, potassium
        case saturatedFat  = "saturated_fat"
        case transFat      = "trans_fat"
        case sugar         = "sugar"
        case addedSugar    = "added_sugar"
        case vitaminD      = "vitamin_d"
    }
}

//struct PantryItem: Codable, Identifiable {
//    let id: Int
//    let name: String
//    let brand: String
//    let quantity: Double
//    let servingSize: String
//    let nutrients: Nutrients
//
//    enum CodingKeys: String, CodingKey {
//        case id, name, brand, quantity, nutrients
//        case servingSize = "serving_size"
//    }
//}
//
//struct Nutrients: Codable {
//    let calories: Double
//    let carbohydrates: Double
//    let protein: Double
//    let fat: Double
//    let saturatedFat: Double
//    let transFat: Double
//    let sugar: Double
//    let addedSugar: Double
//    let fiber: Double
//    let sodium: Double
//    let iron: Double
//    let calcium: Double
//    let potassium: Double
//    let vitaminD: Double
//
//    enum CodingKeys: String, CodingKey {
//        case calories, carbohydrates, protein, fat, fiber, sodium, iron, calcium, potassium
//        case saturatedFat  = "saturated_fat"
//        case transFat      = "trans_fat"
//        case sugar         = "sugar"
//        case addedSugar    = "added_sugar"
//        case vitaminD      = "vitamin_d"
//    }
//}
