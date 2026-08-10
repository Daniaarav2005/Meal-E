//
//  Home.swift
//  SmartFridge
//
//  Created by Michael Pancras on 2/21/26.
//

import SwiftUI

struct InventoryView: View {
    
    
    @Environment(FridgeInventoryViewModel.self) var fridgeData
    @Environment(UserData.self) var userData
    
    @State private var selectedCategory: FridgeItem.Category = .all
    @State private var searchText: String = ""
    @State private var selectedItem: FridgeItem? = nil
    @State private var showAddItem: Bool = false
    @State private var sortOption: SortOption = .expiryAsc

    enum SortOption: String, CaseIterable {
        case expiryAsc = "Expiring First"
        case expiryDesc = "Freshest First"
        case nameAsc = "A → Z"
        case nameDesc = "Z → A"
    }

    var filteredItems: [FridgeItem] {
        var result = fridgeData.items
        if selectedCategory != .all {
            result = result.filter { $0.category == selectedCategory }
        }
        if !searchText.isEmpty {
            result = result.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
        }
        switch sortOption {
        case .expiryAsc: result.sort { $0.daysLeft < $1.daysLeft }
        case .expiryDesc: result.sort { $0.daysLeft > $1.daysLeft }
        case .nameAsc: result.sort { $0.name < $1.name }
        case .nameDesc: result.sort { $0.name > $1.name }
        }
        return result
    }

    var expiringCount: Int {
        fridgeData.items.filter { $0.daysLeft <= 3 && $0.daysLeft >= 0 }.count
    }

    var body: some View {
        NavigationStack {
            
            VStack(spacing: 0) {
                HStack {
                    Spacer()
                    Spacer()
                    
                    Text("My Pantry")
                        .font(.system(size: 22, weight: .heavy, design: .serif))
                        .foregroundStyle(Color(hex: "1B4332"))
                    
                    Spacer()
                    
                    Button {
                        Task {
                            
                            do {
                                
                                print("Fetching pantry...")
                                
                                let data: [FridgeItem] = try await APIManager.shared.getPantry()
                                    withAnimation(.easeIn) {
                                        fridgeData.items = data
                                    }
                                
                                print("Fetching user profile...")
                                
                                let userProfile: User? = try await APIManager.shared.getProfile()
                                
                                dump(userProfile!)
                                
                                if userProfile == nil {
                                    fatalError("Couldn't fetch user profile")
                                } else {
                                    withAnimation(.easeIn) {
                                        userData.age = "\(userProfile!.age)"
                                        userData.name = userProfile!.name
                                        userData.allergies = userProfile!.allergies
                                        userData.cooking_proficiency = userProfile!.cooking_proficiency
                                        userData.cuisine_preferences = userProfile!.cuisine_preferences
                                        userData.dietary_restriction = userProfile!.dietary_restriction
                                        userData.household_size = "\(userProfile!.household_size)"
                                        userData.macro_targets = Macros(calories: "\(userProfile!.macro_targets.calories)", protein: "\(userProfile!.macro_targets.protein)")
                                        userData.meals_per_day = "\(userProfile!.meals_per_day)"
                                    }
                                }
                                
                            } catch {
                                fatalError("Couldn't fetch data")
                            }
                            
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
                .overlay(
                    Rectangle()
                        .fill(Color(hex: "1B4332").opacity(0.07))
                        .frame(height: 1),
                    alignment: .bottom
                )

                ZStack {
                    LinearGradient(
                        colors: [Color(hex: "D8F3DC"), Color(hex: "EDF7F0"), Color(hex: "F0FAF4")],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                    .ignoresSafeArea()

                    ScrollView {
                        VStack(spacing: 0) {
                            inventoryStatsBar
                            searchBar
                            categoryScrollView
                            sortBar
                            if filteredItems.isEmpty {
                                emptyState
                            } else {
                                itemsList
                            }
                        }
                    }
                }
            }
//            .navigationTitle("My Pantry")
//            .navigationBarTitleDisplayMode(.large)
//            .toolbar {
//                ToolbarItem(placement: .navigationBarTrailing) {
//                    Button(action: { showAddItem = true }) {
//                        Image(systemName: "plus.circle.fill")
//                            .font(.title2)
//                            .foregroundStyle(Color(hex: "2D6A4F"))
//                    }
//                }
//            }
            .navigationBarHidden(true)
            .sheet(item: $selectedItem) { item in
                ItemDetailView(item: item)
            }
        }
    }

    // MARK: - Subviews

    private var inventoryStatsBar: some View {
        HStack(spacing: 12) {
            StatPill(icon: "archivebox.fill", value: "\(fridgeData.items.count)", label: "Total Items", color: Color(hex: "2D6A4F"))
            StatPill(icon: "exclamationmark.triangle.fill", value: "\(expiringCount)", label: "Expiring Soon",
                     color: expiringCount > 0 ? Color.yellow : Color.red)
            StatPill(icon: "checkmark.seal.fill", value: "\(fridgeData.items.filter { $0.daysLeft > 3 }.count)", label: "Fresh", color: Color(hex: "34C759"))
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
    }

    private var searchBar: some View {
        HStack(spacing: 10) {
            Image(systemName: "magnifyingglass").foregroundStyle(.secondary)
            TextField("Search items...", text: $searchText).autocorrectionDisabled()
        }
        .padding(12)
        .background(Color.white.opacity(0.8))
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .overlay(RoundedRectangle(cornerRadius: 14).stroke(Color(hex: "2D6A4F").opacity(0.15), lineWidth: 1))
        .padding(.horizontal, 16)
        .padding(.bottom, 8)
    }

    private var categoryScrollView: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                ForEach(FridgeItem.Category.allCases, id: \.self) { category in
                    CategoryChip(
                        category: category,
                        isSelected: selectedCategory == category,
                        action: { withAnimation(.spring(duration: 0.3)) { selectedCategory = category } }
                    )
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 6)
        }
    }

    private var sortBar: some View {
        HStack {
            Text("\(filteredItems.count) items").font(.caption).foregroundStyle(.secondary)
            Spacer()
            Menu {
                ForEach(SortOption.allCases, id: \.self) { option in
                    Button(action: { sortOption = option }) {
                        if sortOption == option {
                            Label(option.rawValue, systemImage: "checkmark")
                        } else {
                            Text(option.rawValue)
                        }
                    }
                }
            } label: {
                HStack(spacing: 4) {
                    Image(systemName: "arrow.up.arrow.down").font(.caption)
                    Text(sortOption.rawValue).font(.caption).fontWeight(.medium)
                }
                .foregroundStyle(Color(hex: "2D6A4F"))
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
                .background(Color(hex: "2D6A4F").opacity(0.1))
                .clipShape(Capsule())
            }
        }
        .padding(.horizontal, 16)
        .padding(.bottom, 6)
    }

    private var itemsList: some View {
        LazyVStack(spacing: 12) {
            ForEach(filteredItems) { item in
                FridgeItemCard(item: item) {
                    selectedItem = item
                } onDelete: {
                    withAnimation(.spring(duration: 0.4)) {
                        fridgeData.items.removeAll { $0.id == item.id }
                    }
                } onMarkUsed: {
                    withAnimation(.spring(duration: 0.4)) {
                        fridgeData.items.removeAll { $0.id == item.id }
                    }
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.bottom, 32)
        .padding(.top, 4)
    }

    private var emptyState: some View {
        VStack(spacing: 16) {
            Image(systemName: "refrigerator")
                .font(.system(size: 60))
                .foregroundStyle(Color(hex: "2D6A4F").opacity(0.3))
            Text(searchText.isEmpty ? "Your fridge is empty" : "No items found")
                .font(.title3).fontWeight(.semibold).foregroundStyle(.secondary)
            Text(searchText.isEmpty ? "Tap + to add your first item" : "Try a different search")
                .font(.subheadline).foregroundStyle(Color.secondary.opacity(0.7))
        }
        .padding(.top, 80)
    }
}

// MARK: - Stat Pill

struct StatPill: View {
    let icon: String
    let value: String
    let label: String
    let color: Color

    var body: some View {
        VStack(spacing: 4) {
            HStack(spacing: 4) {
                Image(systemName: icon).font(.caption2).foregroundStyle(color)
                Text(value).font(.headline).fontWeight(.bold).foregroundStyle(color)
            }
            Text(label).font(.caption2).foregroundStyle(.secondary).lineLimit(1)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 10)
        .background(color.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .overlay(RoundedRectangle(cornerRadius: 14).stroke(color.opacity(0.2), lineWidth: 1))
    }
}

// MARK: - Category Chip

struct CategoryChip: View {
    let category: FridgeItem.Category
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 5) {
                Image(systemName: category.icon).font(.caption)
                Text(category.rawValue).font(.subheadline).fontWeight(isSelected ? .semibold : .regular).fontDesign(.serif)
            }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 8)
        .background(isSelected ? Color(hex: "2D6A4F") : Color.white.opacity(0.8))
        .foregroundStyle(isSelected ? .white : Color(hex: "2D6A4F"))
        .clipShape(Capsule())
        .overlay(Capsule().stroke(Color(hex: "2D6A4F").opacity(isSelected ? 0 : 0.25), lineWidth: 1))
        .shadow(color: isSelected ? Color(hex: "2D6A4F").opacity(0.3) : .clear, radius: 6, y: 3)
        .buttonStyle(.plain)
    }
}

// MARK: - Fridge Item Card

struct FridgeItemCard: View {
    let item: FridgeItem
    let onTap: () -> Void
    let onDelete: () -> Void
    let onMarkUsed: () -> Void

    @State private var offset: CGFloat = 0
    @State private var showActions: Bool = false
    @State private var animateBar: Bool = false

    var freshnessPercent: Double {
        let maxDays = 14.0
        return min(Double(max(item.daysLeft, 0)) / maxDays, 1.0)
    }

    var body: some View {
        ZStack(alignment: .trailing) {
            HStack(spacing: 8) {
                Spacer()
                Button(action: onMarkUsed) {
                    VStack(spacing: 4) {
                        Image(systemName: "checkmark.circle.fill").font(.title3)
                        Text("Used").font(.caption2).fontWeight(.semibold)
                    }
                    .foregroundStyle(.white)
                    .frame(width: 64, height: 80)
                    .background(Color(hex: "34C759"))
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                }
                Button(action: onDelete) {
                    VStack(spacing: 4) {
                        Image(systemName: "trash.fill").font(.title3)
                        Text("Delete").font(.caption2).fontWeight(.semibold)
                    }
                    .foregroundStyle(.white)
                    .frame(width: 64, height: 80)
                    .background(Color(hex: "FF3B30"))
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                }
            }
            .opacity(showActions ? 1 : 0)

            Button(action: onTap) {
                HStack(spacing: 14) {
                    ZStack {
                        Circle()
                            .fill(item.expiryStatus.color.opacity(0.12))
                            .frame(width: 52, height: 52)
                        Text(item.emoji).font(.title2)
                    }

                    VStack(alignment: .leading, spacing: 6) {
                        HStack {
                            Text(item.name).font(.subheadline).fontWeight(.semibold).fontDesign(.serif).foregroundStyle(.primary)
                            Spacer()
                            ExpiryBadge2(item: item)
                        }
                        Text(item.quantity).font(.caption).foregroundStyle(.secondary)

                        GeometryReader { geo in
                            ZStack(alignment: .leading) {
                                RoundedRectangle(cornerRadius: 4).fill(Color.gray.opacity(0.15)).frame(height: 5)
                                RoundedRectangle(cornerRadius: 4)
                                    .fill(LinearGradient(
                                        colors: [item.expiryStatus.color.opacity(0.7), item.expiryStatus.color],
                                        startPoint: .leading, endPoint: .trailing))
                                    .frame(width: animateBar ? geo.size.width * freshnessPercent : 0, height: 5)
                                    .animation(.spring(duration: 0.8, bounce: 0.2).delay(0.1), value: animateBar)
                            }
                        }
                        .frame(height: 5)
                    }

                    Image(systemName: "chevron.right").font(.caption).foregroundStyle(Color.secondary.opacity(0.5))
                }
                .padding(16)
                .background(Color.white)
                .clipShape(RoundedRectangle(cornerRadius: 18))
                .shadow(color: .black.opacity(0.06), radius: 8, x: 0, y: 3)
            }
            .buttonStyle(.plain)
            .offset(x: offset)
//            .gesture(
//                DragGesture()
//                    .onChanged { value in
//                        if value.translation.width < 0 {
//                            offset = max(value.translation.width, -148)
//                        } else if showActions {
//                            offset = min(value.translation.width - 148, 0)
//                        }
//                    }
//                    .onEnded { value in
//                        withAnimation(.spring(duration: 0.4)) {
//                            if value.translation.width < -60 {
//                                offset = -148
//                                showActions = true
//                            } else {
//                                offset = 0
//                                showActions = false
//                            }
//                        }
//                    }
//            )
        }
        .onAppear { animateBar = true }
    }
}

// MARK: - Expiry Badge

struct ExpiryBadge2: View {
    let item: FridgeItem

    var label: String {
        if item.daysLeft < 0 { return "Expired" }
        if item.daysLeft == 0 { return "Today" }
        if item.daysLeft == 1 { return "1 day" }
        return "\(item.daysLeft) days"
    }

    var body: some View {
        Text(label)
            .font(.caption2).fontWeight(.bold)
            .padding(.horizontal, 8).padding(.vertical, 4)
            .background(item.expiryStatus.color.opacity(0.15))
            .foregroundStyle(item.expiryStatus.color)
            .clipShape(Capsule())
            .overlay(Capsule().stroke(item.expiryStatus.color.opacity(0.3), lineWidth: 1))
    }
}

// MARK: - Item Detail View

struct ItemDetailView: View {
    let item: FridgeItem
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 24)
                            .fill(LinearGradient(
                                colors: [item.expiryStatus.color.opacity(0.15), item.expiryStatus.color.opacity(0.05)],
                                startPoint: .topLeading, endPoint: .bottomTrailing))
                        VStack(spacing: 12) {
                            Text(item.emoji).font(.system(size: 72))
                            Text(item.name).font(.title2).fontWeight(.bold)
                            ExpiryBadge2(item: item)
                        }
                        .padding(32)
                    }
                    .padding(.horizontal, 16)

                    DetailCard(title: "Details", icon: "info.circle.fill") {
                        DetailRow(label: "Category", value: item.category.rawValue)
                        Divider()
                        DetailRow(label: "Quantity", value: item.quantity)
                        Divider()
                        DetailRow(label: "Added", value: item.addedDate.formatted(date: .abbreviated, time: .omitted))
                        Divider()
                        DetailRow(label: "Status", value: item.expiryStatus.label, valueColor: item.expiryStatus.color)
                    }
                    .padding(.horizontal, 16)

                    DetailCard(title: "Nutrition Facts", icon: "chart.bar.fill", iconColor: Color(hex: "2D6A4F")) {
                        Text("Per 100g serving")
                            .font(.caption).foregroundStyle(.secondary)
                            .frame(maxWidth: .infinity, alignment: .leading).padding(.bottom, 4)
                        NutritionBar(label: "Calories", value: Double(item.nutrition.calories), unit: "kcal", max: 500, color: Color(hex: "FF6B6B"))
                        NutritionBar(label: "Protein", value: item.nutrition.protein, unit: "g", max: 40, color: Color(hex: "4ECDC4"))
                        NutritionBar(label: "Carbohydrates", value: item.nutrition.carbs, unit: "g", max: 60, color: Color(hex: "FFD93D"))
                        NutritionBar(label: "Fat", value: item.nutrition.fat, unit: "g", max: 40, color: Color(hex: "6BCB77"))
                        NutritionBar(label: "Fiber", value: item.nutrition.fiber, unit: "g", max: 15, color: Color(hex: "A78BFA"))
                    }
                    .padding(.horizontal, 16)

                    Spacer(minLength: 32)
                }
                .padding(.top, 8)
            }
            .background(Color(hex: "F2F7F2"))
            .navigationTitle(item.name)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") { dismiss() }
                        .fontWeight(.semibold)
                        .foregroundStyle(Color(hex: "2D6A4F"))
                }
            }
        }
    }
}

// MARK: - Detail Card

struct DetailCard<Content: View>: View {
    let title: String
    let icon: String
    var iconColor: Color = Color(hex: "FF9F0A")
    @ViewBuilder let content: Content

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(spacing: 8) {
                Image(systemName: icon).foregroundStyle(iconColor)
                Text(title).font(.headline).fontWeight(.semibold)
            }
            content
        }
        .padding(18)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 18))
        .shadow(color: .black.opacity(0.05), radius: 8, y: 3)
    }
}

// MARK: - Detail Row

struct DetailRow: View {
    let label: String
    let value: String
    var valueColor: Color = .primary

    var body: some View {
        HStack {
            Text(label).font(.subheadline).foregroundStyle(.secondary)
            Spacer()
            Text(value).font(.subheadline).fontWeight(.medium).foregroundStyle(valueColor)
        }
    }
}

// MARK: - Nutrition Bar

struct NutritionBar: View {
    let label: String
    let value: Double
    let unit: String
    let max: Double
    let color: Color

    @State private var animate: Bool = false

    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            HStack {
                Text(label).font(.caption).foregroundStyle(.secondary)
                Spacer()
                Text("\(value, specifier: "%.1f") \(unit)").font(.caption).fontWeight(.semibold).foregroundStyle(color)
            }
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 4).fill(color.opacity(0.12)).frame(height: 7)
                    RoundedRectangle(cornerRadius: 4)
                        .fill(color)
                        .frame(width: animate ? geo.size.width * min(value / max, 1.0) : 0, height: 7)
                        .animation(.spring(duration: 0.9, bounce: 0.2).delay(0.2), value: animate)
                }
            }
            .frame(height: 7)
        }
        .onAppear { animate = true }
    }
}

// MARK: - Add Item View
//
//struct AddItemView: View {
//    @Binding var items: [FridgeItem]
//    @Environment(\.dismiss) private var dismiss
//
//    @State private var name: String = ""
//    @State private var quantity: String = ""
//    @State private var selectedCategory: FridgeItem.Category = .other
//    @State private var daysUntilExpiry: Double = 7
//    @State private var selectedEmoji: String = "🥦"
//
//    let emojiOptions = ["🥦", "🥕", "🍎", "🍗", "🧀", "🥛", "🐟", "🥑", "🍳", "🫙", "🥩", "🍋"]
//
//    var body: some View {
//        NavigationStack {
//            Form {
//                Section("Item Info") {
//                    ScrollView(.horizontal, showsIndicators: false) {
//                        HStack(spacing: 10) {
//                            ForEach(emojiOptions, id: \.self) { emoji in
//                                Button(action: { selectedEmoji = emoji }) {
//                                    Text(emoji)
//                                        .font(.title2).padding(8)
//                                        .background(selectedEmoji == emoji ? Color(hex: "2D6A4F").opacity(0.15) : Color.clear)
//                                        .clipShape(RoundedRectangle(cornerRadius: 10))
//                                        .overlay(RoundedRectangle(cornerRadius: 10)
//                                            .stroke(selectedEmoji == emoji ? Color(hex: "2D6A4F") : Color.clear, lineWidth: 2))
//                                }
//                                .buttonStyle(.plain)
//                            }
//                        }
//                        .padding(.vertical, 4)
//                    }
//                    TextField("Item name", text: $name)
//                    TextField("Quantity (e.g. 200g, 1 bag)", text: $quantity)
//                }
//
//                Section("Category") {
//                    Picker("Category", selection: $selectedCategory) {
//                        ForEach(FridgeItem.Category.allCases.filter { $0 != .all }, id: \.self) { cat in
//                            Label(cat.rawValue, systemImage: cat.icon).tag(cat)
//                        }
//                    }
//                    .pickerStyle(.menu)
//                }
//
//                Section("Expiry") {
//                    VStack(alignment: .leading, spacing: 8) {
//                        HStack {
//                            Text("Days until expiry")
//                            Spacer()
//                            Text("\(Int(daysUntilExpiry)) days").fontWeight(.semibold).foregroundStyle(Color(hex: "2D6A4F"))
//                        }
//                        Slider(value: $daysUntilExpiry, in: 0...30, step: 1).tint(Color(hex: "2D6A4F"))
//                    }
//                }
//            }
//            .navigationTitle("Add Item")
//            .navigationBarTitleDisplayMode(.inline)
//            .toolbar {
//                ToolbarItem(placement: .cancellationAction) {
//                    Button("Cancel") { dismiss() }
//                }
//                ToolbarItem(placement: .confirmationAction) {
//                    Button("Add") {
//                        guard !name.isEmpty else { return }
//                        let newItem = FridgeItem(
//                            name: name,
//                            emoji: selectedEmoji,
//                            category: selectedCategory,
//                            quantity: quantity.isEmpty ? "1 piece" : quantity,
//                            daysLeft: Int(daysUntilExpiry),
//                            addedDate: Date(),
//                            expirationDate:
//                            nutrition: NutritionInfo(calories: 0, protein: 0, carbs: 0, fat: 0, fiber: 0)
//                        )
//                        withAnimation(.spring(duration: 0.4)) { items.append(newItem) }
//                        dismiss()
//                    }
//                    .fontWeight(.semibold)
//                    .foregroundStyle(name.isEmpty ? .secondary : Color(hex: "2D6A4F"))
//                    .disabled(name.isEmpty)
//                }
//            }
//        }
//    }
//}

// MARK: - Preview

#Preview {
    InventoryView()
}
