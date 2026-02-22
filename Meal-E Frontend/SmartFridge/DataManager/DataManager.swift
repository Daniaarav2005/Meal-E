//
//  DataManager.swift
//  SmartFridge
//
//  Created by Michael Pancras on 2/21/26.
//
//

import SwiftUI

//
//struct InventoryItem: Identifiable {
//    let id: UUID
//    var name: String
//    var quantity: Int
//    var expirationDate: Date
//
//    init(id: UUID = UUID(), name: String, quantity: Int, expirationDate: Date) {
//        self.id = id
//        self.name = name
//        self.quantity = quantity
//        self.expirationDate = expirationDate
//    }
//
//    var daysUntilExpiration: Int {
//        Calendar.current.dateComponents([.day], from: Date(), to: expirationDate).day ?? 0
//    }
//
//    var isExpiringSoon: Bool {
//        daysUntilExpiration <= 3
//    }
//
//    var isExpired: Bool {
//        daysUntilExpiration < 0
//    }
//}
//
//
//class FridgeInventoryViewModel: ObservableObject {
//    @Published var items: [InventoryItem]
//    @Published var dismissedCheckInIDs: Set<UUID> = []
//
//    init() {
//        let calendar = Calendar.current
//        let now = Date()
//
//        self.items = [
//            InventoryItem(name: "Whole Milk", quantity: 1, expirationDate: calendar.date(byAdding: .day, value: -1, to: now)!),
//            InventoryItem(name: "Greek Yogurt", quantity: 2, expirationDate: calendar.date(byAdding: .day, value: 1, to: now)!),
//            InventoryItem(name: "Cheddar Cheese", quantity: 1, expirationDate: calendar.date(byAdding: .day, value: 2, to: now)!),
//            InventoryItem(name: "Baby Spinach", quantity: 1, expirationDate: calendar.date(byAdding: .day, value: 3, to: now)!),
//            InventoryItem(name: "Orange Juice", quantity: 1, expirationDate: calendar.date(byAdding: .day, value: 10, to: now)!),
//            InventoryItem(name: "Leftover Pasta", quantity: 3, expirationDate: calendar.date(byAdding: .day, value: 4, to: now)!),
//            InventoryItem(name: "Eggs", quantity: 6, expirationDate: calendar.date(byAdding: .day, value: 14, to: now)!),
//            InventoryItem(name: "Smoked Salmon", quantity: 1, expirationDate: calendar.date(byAdding: .day, value: 5, to: now)!),
//        ]
//    }
//
//    var expiringSoonItems: [InventoryItem] {
//        items.filter { $0.isExpiringSoon }.sorted { $0.daysUntilExpiration < $1.daysUntilExpiration }
//    }
//
//    var checkInItems: [InventoryItem] {
//        items.filter { !$0.isExpiringSoon && !dismissedCheckInIDs.contains($0.id) }
//    }
//
//    func removeItem(id: UUID) {
//        items.removeAll { $0.id == id }
//        dismissedCheckInIDs.remove(id)
//    }
//
//    func dismissCheckIn(id: UUID) {
//        dismissedCheckInIDs.insert(id)
//    }
//}

struct InventoryItem: Identifiable {
    let id: UUID
    var name: String
    var quantity: Int
    var expirationDate: Date

    init(id: UUID = UUID(), name: String, quantity: Int, expirationDate: Date) {
        self.id = id
        self.name = name
        self.quantity = quantity
        self.expirationDate = expirationDate
    }

    var daysUntilExpiration: Int {
        Calendar.current.dateComponents([.day], from: Date(), to: expirationDate).day ?? 0
    }

    var isExpiringSoon: Bool {
        daysUntilExpiration <= 3
    }

    var isExpired: Bool {
        daysUntilExpiration < 0
    }
}


@Observable
class FridgeInventoryViewModel {
    
    var items: [FridgeItem]
    var dismissedCheckInIDs: Set<UUID> = []
    var userName: String

    init(userName: String = "Anonymous", pantry: [FridgeItem]) {
        let _ = Calendar.current
        let _ = Date()

        self.userName = userName
        self.items = pantry
    }

    var expiringSoonItems: [FridgeItem] {
        items.filter { $0.isExpiringSoon }.sorted { $0.daysUntilExpiration < $1.daysUntilExpiration }
    }

    var checkInItems: [FridgeItem] {
        items.filter { !$0.isExpiringSoon && !dismissedCheckInIDs.contains($0.id) }
    }

    func removeItem(id: UUID) {
        items.removeAll { $0.id == id }
        dismissedCheckInIDs.remove(id)
    }

    func dismissCheckIn(id: UUID) {
        dismissedCheckInIDs.insert(id)
    }
    
}


struct FridgeItem: Identifiable {
    let id = UUID()
    var item_id: Int
    var name: String
    var emoji: String
    var category: Category
    var quantity: String
    var daysLeft: Int
    var addedDate: Date
    var expirationDate: Date
    var nutrition: NutritionInfo
    
    var daysUntilExpiration: Int {
        Calendar.current.dateComponents([.day], from: Date(), to: expirationDate).day ?? 0
    }

    var isExpiringSoon: Bool {
        daysUntilExpiration <= 3
    }

    var isExpired: Bool {
        daysUntilExpiration < 0
    }

    enum Category: String, CaseIterable {
        case all = "All"
        case vegetables = "Vegetables"
        case fruits = "Fruits"
        case dairy = "Dairy"
        case meat = "Meat"
        case drinks = "Drinks"
        case leftovers = "Leftovers"
        case other = "Other"

        var icon: String {
            switch self {
            case .all: return "square.grid.2x2"
            case .vegetables: return "leaf"
            case .fruits: return "apple.logo"
            case .dairy: return "cup.and.saucer"
            case .meat: return "fork.knife"
            case .drinks: return "drop"
            case .leftovers: return "takeoutbag.and.cup.and.straw"
            case .other: return "archivebox"
            }
        }
    }

    var expiryStatus: ExpiryStatus {
        switch daysLeft {
        case ..<0: return .expired
        case 0...1: return .critical
        case 2...3: return .warning
        default: return .good
        }
    }

    enum ExpiryStatus {
        case expired, critical, warning, good

        var color: Color {
            switch self {
            case .expired: return Color(hex: "FF3B30")
            case .critical: return Color(hex: "FF3B30")
            case .warning: return Color(hex: "FF9F0A")
            case .good: return Color(hex: "34C759")
            }
        }

        var label: String {
            switch self {
            case .expired: return "Expired"
            case .critical: return "Expires today"
            case .warning: return "Expiring soon"
            case .good: return "Fresh"
            }
        }
    }
}

struct NutritionInfo {
    var calories: Int
    var protein: Double
    var carbs: Double
    var fat: Double
    var fiber: Double
}

// MARK: - Emoji Mapping

func emojiForFood(_ name: String) -> String {
    let emojiMap: [String: String] = [
        "spinach": "🥬",
        "chicken": "🍗",
        "chicken breast": "🍗",
        "milk": "🥛",
        "cheese": "🧀",
        "cheddar cheese": "🧀",
        "yogurt": "🥛",
        "greek yogurt": "🥛",
        "eggs": "🥚",
        "egg": "🥚",
        "pasta": "🍝",
        "tomato": "🍅",
        "tomatoes": "🍅",
        "avocado": "🥑",
        "salmon": "🐟",
        "blueberries": "🫐",
        "apple": "🍎",
        "banana": "🍌",
        "carrot": "🥕",
        "broccoli": "🥦",
        "beef": "🥩",
        "bread": "🍞",
        "butter": "🧈",
        "orange": "🍊",
        "strawberry": "🍓",
        "lemon": "🍋",
    ]
    return emojiMap[name.lowercased()] ?? "🍽️"
}

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3:
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6:
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8:
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(.sRGB,
                  red: Double(r) / 255,
                  green: Double(g) / 255,
                  blue: Double(b) / 255,
                  opacity: Double(a) / 255)
    }
}

extension Date {
    static func daysFromNow(_ days: Int) -> Date {
        Calendar.current.date(byAdding: .day, value: days, to: Date()) ?? Date()
    }
}

//
//extension FridgeItem {
//    static let sampleItems: [FridgeItem] = [
//        FridgeItem(name: "Spinach", emoji: emojiForFood("Spinach"), category: .vegetables,
//                   quantity: "2 bags", daysLeft: 3, addedDate: Date(),
//                   nutrition: NutritionInfo(calories: 23, protein: 2.9, carbs: 3.6, fat: 0.4, fiber: 2.2)),
//        FridgeItem(name: "Milk", emoji: emojiForFood("Milk"), category: .drinks,
//                   quantity: "1 bottle", daysLeft: 5, addedDate: Date(),
//                   nutrition: NutritionInfo(calories: 61, protein: 3.2, carbs: 4.8, fat: 3.3, fiber: 0.0)),
//        FridgeItem(name: "Chicken Breast", emoji: emojiForFood("Chicken Breast"), category: .meat,
//                   quantity: "3 pieces", daysLeft: 2, addedDate: Date(),
//                   nutrition: NutritionInfo(calories: 165, protein: 31.0, carbs: 0.0, fat: 3.6, fiber: 0.0)),
//        FridgeItem(name: "Cheddar Cheese", emoji: emojiForFood("Cheddar Cheese"), category: .dairy,
//                   quantity: "1 block", daysLeft: 1, addedDate: Date(),
//                   nutrition: NutritionInfo(calories: 403, protein: 25.0, carbs: 1.3, fat: 33.0, fiber: 0.0)),
//        FridgeItem(name: "Greek Yogurt", emoji: emojiForFood("Greek Yogurt"), category: .dairy,
//                   quantity: "4 cups", daysLeft: 7, addedDate: Date(),
//                   nutrition: NutritionInfo(calories: 59, protein: 10.0, carbs: 3.6, fat: 0.4, fiber: 0.0)),
//        FridgeItem(name: "Eggs", emoji: emojiForFood("Eggs"), category: .other,
//                   quantity: "12 pcs", daysLeft: 21, addedDate: Date(),
//                   nutrition: NutritionInfo(calories: 155, protein: 13.0, carbs: 1.1, fat: 11.0, fiber: 0.0)),
//        FridgeItem(name: "Pasta", emoji: emojiForFood("Pasta"), category: .other,
//                   quantity: "1 pack", daysLeft: 1, addedDate: Date(),
//                   nutrition: NutritionInfo(calories: 131, protein: 5.0, carbs: 25.0, fat: 1.1, fiber: 1.8)),
//        FridgeItem(name: "Tomatoes", emoji: emojiForFood("Tomatoes"), category: .vegetables,
//                   quantity: "2 pcs", daysLeft: 10, addedDate: Date(),
//                   nutrition: NutritionInfo(calories: 18, protein: 0.9, carbs: 3.9, fat: 0.2, fiber: 1.2)),
//    ]
//}

extension UIColor {
    convenience init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let r, g, b, a: UInt64
        switch hex.count {
        case 6: (r, g, b, a) = (int >> 16, int >> 8 & 0xFF, int & 0xFF, 255)
        case 8: (r, g, b, a) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default: (r, g, b, a) = (0, 0, 0, 255)
        }
        self.init(red: CGFloat(r)/255, green: CGFloat(g)/255, blue: CGFloat(b)/255, alpha: CGFloat(a)/255)
    }
}

func pantryResponseToFridgeItems(_ response: PantryResponse) -> [FridgeItem] {
    return response.pantry.map { pantryItem in
        FridgeItem(
            item_id: pantryItem.id,
            name: pantryItem.name,
            emoji: emojiForFood(pantryItem.name),
            category: categoryForFood(pantryItem.name),
            quantity: formatQuantity(pantryItem.quantity ?? -1),
            daysLeft: 7, // default since PantryItem has no expiration date
            addedDate: Date(),
            expirationDate: .daysFromNow(7), // default, adjust as needed
            nutrition: NutritionInfo(
                calories: Int(pantryItem.nutrients.calories ?? -1),
                protein: pantryItem.nutrients.protein ?? -1,
                carbs: pantryItem.nutrients.carbohydrates ?? -1,
                fat: pantryItem.nutrients.fat ?? -1,
                fiber: pantryItem.nutrients.fiber ?? -1
            )
        )
    }
}

// Maps food name to a Category
private func categoryForFood(_ name: String) -> FridgeItem.Category {
    let lower = name.lowercased()

    let categoryMap: [FridgeItem.Category: [String]] = [
        .dairy:      ["milk", "cheese", "yogurt", "butter", "cream"],
        .meat:       ["chicken", "beef", "salmon", "fish", "pork", "turkey", "shrimp"],
        .vegetables: ["spinach", "carrot", "broccoli", "tomato", "lettuce", "kale", "pepper"],
        .fruits:     ["apple", "banana", "orange", "strawberry", "blueberry", "lemon", "avocado"],
        .drinks:     ["juice", "soda", "water", "milk"],
        .leftovers:  ["pasta", "rice", "soup", "leftover"],
    ]

    for (category, keywords) in categoryMap {
        if keywords.contains(where: { lower.contains($0) }) {
            return category
        }
    }

    return .other
}

// Formats a Double quantity into a readable string
private func formatQuantity(_ quantity: Double) -> String {
    if quantity.truncatingRemainder(dividingBy: 1) == 0 {
        return "\(Int(quantity))"
    }
    return String(format: "%.1f", quantity)
}
