//
//  Home.swift
//  SmartFridge
//
//  Created by Michael Pancras on 2/21/26.
//

import SwiftUI

// MARK: - Macro Ranked Sheet

enum MacroSort: String, Identifiable {
    case calories = "Calories"
    case protein  = "Protein"
    case carbs    = "Carbs"
    case fat      = "Fat"
    var id: String { rawValue }

    var unit: String {
        switch self {
        case .calories: return "kcal"
        default:        return "g"
        }
    }
    var icon: String {
        switch self {
        case .calories: return "flame.fill"
        case .protein:  return "figure.strengthtraining.traditional"
        case .carbs:    return "bolt.fill"
        case .fat:      return "drop.fill"
        }
    }
    var color: Color {
        switch self {
        case .calories: return Color(hex: "DC2626")
        case .protein:  return Color(hex: "2D6A4F")
        case .carbs:    return Color(hex: "D97706")
        case .fat:      return Color(hex: "40916C")
        }
    }
    func value(for item: FridgeItem) -> Double {
        switch self {
        case .calories: return Double(item.nutrition.calories)
        case .protein:  return item.nutrition.protein
        case .carbs:    return item.nutrition.carbs
        case .fat:      return item.nutrition.fat
        }
    }
}

struct MacroRankedSheet: View {
    let sort: MacroSort
    let items: [FridgeItem]
    @Environment(\.dismiss) private var dismiss

    var ranked: [FridgeItem] {
        items.sorted { sort.value(for: $0) > sort.value(for: $1) }
    }
    var maxValue: Double {
        ranked.first.map { sort.value(for: $0) } ?? 1
    }

    var body: some View {
        VStack(spacing: 0) {
            // Header
            VStack(spacing: 10) {
                Capsule()
                    .fill(Color(hex: "1B4332").opacity(0.15))
                    .frame(width: 36, height: 4)
                    .padding(.top, 12)

                HStack(spacing: 12) {
                    ZStack {
                        Circle().fill(sort.color.opacity(0.15)).frame(width: 44, height: 44)
                        Image(systemName: sort.icon)
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundStyle(sort.color)
                    }
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Ranked by \(sort.rawValue)")
                            .font(.system(.title3, design: .serif).bold())
                            .foregroundStyle(Color(hex: "1B4332"))
                        Text("Highest to lowest · \(items.count) items")
                            .font(.system(.caption, design: .serif)).foregroundStyle(Color(hex: "2D6A4F").opacity(0.6))
                    }
                    Spacer()
                    Button { dismiss() } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.title2).foregroundStyle(Color(hex: "1B4332").opacity(0.25))
                    }
                }
                .padding(.horizontal, 20).padding(.bottom, 12)
            }
            .background(Color(hex: "D8F3DC"))
            .overlay(Rectangle().fill(Color(hex: "1B4332").opacity(0.07)).frame(height: 1), alignment: .bottom)

            ScrollView(showsIndicators: false) {
                LazyVStack(spacing: 12) {
                    ForEach(Array(ranked.enumerated()), id: \.element.id) { index, item in
                        HStack(spacing: 14) {
                            Text("#\(index + 1)")
                                .font(.system(size: 13, weight: .black, design: .serif))
                                .foregroundStyle(index == 0 ? sort.color : Color(hex: "1B4332").opacity(0.3))
                                .frame(width: 30)

                            Text(item.emoji).font(.title2)

                            VStack(alignment: .leading, spacing: 4) {
                                Text(item.name)
                                    .font(.system(.subheadline).weight(.semibold))
                                    .foregroundStyle(Color(hex: "1B4332"))

                                GeometryReader { geo in
                                    ZStack(alignment: .leading) {
                                        RoundedRectangle(cornerRadius: 3).fill(sort.color.opacity(0.1)).frame(height: 5)
                                        RoundedRectangle(cornerRadius: 3).fill(sort.color)
                                            .frame(width: geo.size.width * CGFloat(sort.value(for: item) / maxValue), height: 5)
                                    }
                                }
                                .frame(height: 5)
                            }

                            Spacer()

                            VStack(alignment: .trailing, spacing: 2) {
                                Text(sort == .calories
                                     ? "\(Int(sort.value(for: item)))"
                                     : String(format: "%.1f", sort.value(for: item)))
                                    .font(.system(size: 16, weight: .black, design: .serif))
                                    .foregroundStyle(sort.color)
                                Text(sort.unit)
                                    .font(.system(size: 10, weight: .medium))
                                    .foregroundStyle(sort.color.opacity(0.6))
                            }
                        }
                        .padding(14).background(Color.white)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                        .overlay(RoundedRectangle(cornerRadius: 16)
                            .stroke(index == 0 ? sort.color.opacity(0.3) : Color.clear, lineWidth: 1.5))
                        .shadow(color: Color(hex: "2D6A4F").opacity(0.07), radius: 6, x: 0, y: 2)
                    }
                }
                .padding(.horizontal, 16).padding(.top, 16).padding(.bottom, 40)
            }
            .background(
                LinearGradient(colors: [Color(hex: "D8F3DC"), Color(hex: "EDF7F0"), Color(hex: "F0FAF4")],
                               startPoint: .top, endPoint: .bottom).ignoresSafeArea()
            )
        }
    }
}

// MARK: - Category Items Sheet

struct CategoryItemsSheet: View {
    let category: FridgeItem.Category
    let items: [FridgeItem]
    let color: Color
    @Environment(\.dismiss) private var dismiss
    @State private var selectedItem: FridgeItem? = nil

    var catItems: [FridgeItem] {
        items.filter { $0.category == category }.sorted { $0.daysLeft < $1.daysLeft }
    }

    var catEmoji: String {
        switch category {
        case .vegetables: return "🥦"
        case .fruits:     return "🍎"
        case .dairy:      return "🥛"
        case .meat:       return "🥩"
        case .drinks:     return "🧃"
        case .leftovers:  return "🍱"
        case .other:      return "📦"
        case .all:        return "🧺"
        }
    }

    var body: some View {
        VStack(spacing: 0) {
            // Header
            VStack(spacing: 10) {
                Capsule()
                    .fill(Color(hex: "1B4332").opacity(0.15))
                    .frame(width: 36, height: 4)
                    .padding(.top, 12)

                HStack(spacing: 12) {
                    Text(catEmoji)
                        .font(.system(size: 36))
                        .frame(width: 52, height: 52)
                        .background(Circle().fill(color.opacity(0.15)))

                    VStack(alignment: .leading, spacing: 3) {
                        Text(category.rawValue)
                            .font(.system(.title2, design: .serif).bold())
                            .foregroundStyle(Color(hex: "1B4332"))
                        Text("\(catItems.count) item\(catItems.count == 1 ? "" : "s") · sorted by freshness")
                            .font(.system(.caption, design: .serif)).foregroundStyle(Color(hex: "2D6A4F").opacity(0.6))
                    }
                    Spacer()
                    Button { dismiss() } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.title2).foregroundStyle(Color(hex: "1B4332").opacity(0.25))
                    }
                }
                .padding(.horizontal, 20).padding(.bottom, 14)
            }
            .background(Color(hex: "D8F3DC"))
            .overlay(Rectangle().fill(Color(hex: "1B4332").opacity(0.07)).frame(height: 1), alignment: .bottom)

            if catItems.isEmpty {
                Spacer()
                VStack(spacing: 12) {
                    Text("🫙").font(.system(size: 48))
                    Text("No \(category.rawValue) in your fridge")
                        .font(.system(.subheadline))
                        .foregroundStyle(Color(hex: "1B4332").opacity(0.5))
                }
                Spacer()
            } else {
                ScrollView(showsIndicators: false) {
                    LazyVStack(spacing: 12) {
                        ForEach(catItems) { item in
                            CategoryItemRow(item: item, accentColor: color)
                                .onTapGesture { selectedItem = item }
                        }
                    }
                    .padding(.horizontal, 16).padding(.top, 16).padding(.bottom, 40)
                }
                .background(
                    LinearGradient(colors: [Color(hex: "D8F3DC"), Color(hex: "EDF7F0"), Color(hex: "F0FAF4")],
                                   startPoint: .top, endPoint: .bottom).ignoresSafeArea()
                )
            }
        }
        .sheet(item: $selectedItem) { item in ItemDetailView(item: item) }
    }
}

struct CategoryItemRow: View {
    let item: FridgeItem
    let accentColor: Color

    var expiryColor: Color {
        switch item.expiryStatus {
        case .expired, .critical: return Color(hex: "DC2626")
        case .warning:            return Color(hex: "D97706")
        case .good:               return accentColor
        }
    }
    var expiryLabel: String {
        if item.daysLeft < 0 { return "Expired" }
        if item.daysLeft == 0 { return "Today!" }
        if item.daysLeft == 1 { return "1 day left" }
        return "\(item.daysLeft) days left"
    }

    var body: some View {
        HStack(spacing: 14) {
            ZStack {
                RoundedRectangle(cornerRadius: 13).fill(expiryColor.opacity(0.1)).frame(width: 52, height: 52)
                Text(item.emoji).font(.title2)
            }
            VStack(alignment: .leading, spacing: 3) {
                Text(item.name)
                    .font(.system(.subheadline).weight(.semibold))
                    .foregroundStyle(Color(hex: "1B4332"))
                Text(item.quantity)
                    .font(.system(.caption, design: .serif)).foregroundStyle(Color(hex: "1B4332").opacity(0.42))
            }
            Spacer()
            VStack(alignment: .trailing, spacing: 3) {
                Text(expiryLabel)
                    .font(.system(.caption, design: .serif).bold()).foregroundStyle(expiryColor)
                    .padding(.horizontal, 9).padding(.vertical, 4)
                    .background(expiryColor.opacity(0.1)).clipShape(Capsule())
                Text("\(item.nutrition.calories) kcal")
                    .font(.system(size: 10, weight: .medium)).foregroundStyle(Color(hex: "1B4332").opacity(0.35))
            }
        }
        .padding(14).background(Color.white).clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: Color(hex: "2D6A4F").opacity(0.07), radius: 6, x: 0, y: 2)
    }
}

// MARK: - Category Donut Chart

struct CategoryDonutChart: View {
    let items: [FridgeItem]
    @State private var animate = false
    @State private var selectedCat: FridgeItem.Category? = nil
    @State private var sheetCat: IdentifiableCategory? = nil

    // Thin Identifiable wrapper so .sheet(item:) works on Category
    struct IdentifiableCategory: Identifiable {
        let cat: FridgeItem.Category
        var id: String { cat.rawValue }
    }

    let catColors: [FridgeItem.Category: Color] = [
        .vegetables: Color(hex: "40916C"),
        .fruits:     Color(hex: "52B788"),
        .dairy:      Color(hex: "74C69D"),
        .meat:       Color(hex: "DC2626"),
        .drinks:     Color(hex: "2D6A4F"),
        .leftovers:  Color(hex: "D97706"),
        .other:      Color(hex: "1B4332"),
    ]

    var grouped: [(cat: FridgeItem.Category, count: Int)] {
        let dict = Dictionary(grouping: items.filter { $0.category != .all }, by: { $0.category })
        return dict.map { ($0.key, $0.value.count) }.sorted { $0.count > $1.count }
    }
    var total: Int { max(grouped.reduce(0) { $0 + $1.count }, 1) }

    struct SliceInfo { let cat: FridgeItem.Category; let start: CGFloat; let end: CGFloat }

    func sliceAngles() -> [SliceInfo] {
        var results: [SliceInfo] = []
        var cumulative: CGFloat = 0
        for entry in grouped {
            let fraction = CGFloat(entry.count) / CGFloat(total)
            let gap: CGFloat = 0.008
            results.append(SliceInfo(cat: entry.cat, start: cumulative + gap, end: cumulative + fraction - gap))
            cumulative += fraction
        }
        return results
    }

    // MARK: - Extracted sub-views to avoid type-checker timeout

    @ViewBuilder
    private func donutRing() -> some View {
        ZStack {
            ForEach(Array(sliceAngles().enumerated()), id: \.offset) { index, slice in
                Circle()
                    .trim(from: slice.start, to: animate ? slice.end : slice.start)
                    .stroke(
                        catColors[slice.cat] ?? Color(hex: "2D6A4F"),
                        style: StrokeStyle(lineWidth: 26, lineCap: .butt)
                    )
                    .frame(width: 120, height: 120)
                    .rotationEffect(.degrees(-90))
                    .scaleEffect(selectedCat == slice.cat ? 1.07 : 1.0)
                    .animation(.spring(duration: 0.9, bounce: 0.15).delay(Double(index) * 0.05), value: animate)
                    .animation(.spring(duration: 0.25), value: selectedCat)
                    .onTapGesture {
                        let tapped = slice.cat
                        if selectedCat == tapped { sheetCat = IdentifiableCategory(cat: tapped) }
                        else { selectedCat = tapped }
                    }
            }
            donutCenter()
        }
        .frame(width: 120, height: 120)
    }

    @ViewBuilder
    private func donutCenter() -> some View {
        Button { if let sel = selectedCat { sheetCat = IdentifiableCategory(cat: sel) } } label: {
            VStack(spacing: 2) {
                if let sel = selectedCat, let entry = grouped.first(where: { $0.cat == sel }) {
                    Text("\(entry.count)")
                        .font(.system(size: 24, weight: .black, design: .serif))
                        .foregroundStyle(catColors[sel] ?? Color(hex: "1B4332"))
                    Text(sel.rawValue)
                        .font(.system(size: 9, weight: .semibold))
                        .foregroundStyle(Color(hex: "1B4332").opacity(0.5))
                        .multilineTextAlignment(.center)
                    Text("tap to view")
                        .font(.system(size: 8, weight: .medium))
                        .foregroundStyle(Color(hex: "1B4332").opacity(0.3))
                } else {
                    Text("\(total)")
                        .font(.system(size: 24, weight: .black, design: .serif))
                        .foregroundStyle(Color(hex: "1B4332"))
                    Text("items")
                        .font(.system(size: 9, weight: .semibold))
                        .foregroundStyle(Color(hex: "1B4332").opacity(0.5))
                }
            }
        }
        .buttonStyle(.plain)
    }

    @ViewBuilder
    private func legendList() -> some View {
        VStack(alignment: .leading, spacing: 9) {
            ForEach(grouped, id: \.cat) { entry in
                Button {
                    if selectedCat == entry.cat { sheetCat = IdentifiableCategory(cat: entry.cat) }
                    else { selectedCat = entry.cat }
                } label: {
                    HStack(spacing: 7) {
                        RoundedRectangle(cornerRadius: 3)
                            .fill(catColors[entry.cat] ?? Color(hex: "2D6A4F"))
                            .frame(width: 10, height: 10)
                        Text(entry.cat.rawValue)
                            .font(.system(.caption).weight(.medium))
                            .foregroundStyle(Color(hex: "1B4332").opacity(selectedCat == entry.cat ? 1.0 : 0.65))
                        Spacer()
                        Text("\(entry.count)")
                            .font(.system(.caption, design: .serif).bold())
                            .foregroundStyle(catColors[entry.cat] ?? Color(hex: "2D6A4F"))
                        Text(String(format: "%.0f%%", Double(entry.count) / Double(total) * 100))
                            .font(.system(size: 9, weight: .medium))
                            .foregroundStyle(Color(hex: "1B4332").opacity(0.35))
                        if selectedCat == entry.cat {
                            Image(systemName: "chevron.right")
                                .font(.system(size: 8, weight: .bold, design: .serif))
                                .foregroundStyle(catColors[entry.cat]?.opacity(0.6) ?? Color.clear)
                        }
                    }
                }
                .buttonStyle(.plain)
            }
        }
        .frame(maxWidth: .infinity)
    }

    @ViewBuilder
    private func inlinePreviewStrip(sel: FridgeItem.Category) -> some View {
        let catItems = items.filter { $0.category == sel }.sorted { $0.daysLeft < $1.daysLeft }
        let color    = catColors[sel] ?? Color(hex: "2D6A4F")

        Divider().padding(.horizontal, 20)

        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text("Items in \(sel.rawValue)")
                    .font(.system(.caption).weight(.semibold))
                    .foregroundStyle(Color(hex: "1B4332").opacity(0.6))
                Spacer()
                Button { sheetCat = IdentifiableCategory(cat: sel) } label: {
                    HStack(spacing: 3) {
                        Text("See all")
                        Image(systemName: "arrow.right")
                    }
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundStyle(color)
                }
            }
            .padding(.horizontal, 20).padding(.top, 12)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    ForEach(catItems.prefix(6)) { item in
                        Button { sheetCat = IdentifiableCategory(cat: sel) } label: {
                            VStack(spacing: 6) {
                                Text(item.emoji).font(.system(size: 28))
                                Text(item.name)
                                    .font(.system(size: 10, weight: .semibold))
                                    .foregroundStyle(Color(hex: "1B4332"))
                                    .lineLimit(1)
                                Text(item.daysLeft <= 0 ? "Expired" : "\(item.daysLeft)d")
                                    .font(.system(size: 9, weight: .bold, design: .serif))
                                    .foregroundStyle(item.daysLeft <= 1 ? Color(hex: "DC2626") : color)
                            }
                            .frame(width: 64)
                            .padding(.vertical, 10)
                            .background(color.opacity(0.07))
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal, 20).padding(.bottom, 16)
            }
        }
    }

    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 24) {
                donutRing()
                legendList()
            }
            .padding(20)

            if let sel = selectedCat {
                inlinePreviewStrip(sel: sel)
            }
        }
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .shadow(color: Color(hex: "2D6A4F").opacity(0.08), radius: 10, x: 0, y: 4)
        .onAppear { animate = true }
        .sheet(item: $sheetCat) { wrapper in
            CategoryItemsSheet(
                category: wrapper.cat,
                items: items,
                color: catColors[wrapper.cat] ?? Color(hex: "2D6A4F")
            )
        }
    }
}

// MARK: - Home View

struct Home: View {
    
    @Environment(FridgeInventoryViewModel.self) private var fridgeData
    @Environment(UserData.self) var userData

    @State private var selectedItem:  FridgeItem? = nil
    @State private var showAddItem:   Bool = false
    @State private var showInventory: Bool = false
    @State private var showRecipes:   Bool = false
    @State private var showAlerts:    Bool = false
    @State private var macroSort:     MacroSort? = nil
    
    @Binding var selection: Int

    var expiringSoonItems: [FridgeItem] {
        fridgeData.items.filter { $0.daysLeft <= 3 }.sorted { $0.daysLeft < $1.daysLeft }
    }
    var recentItems: [FridgeItem] {
        Array(fridgeData.items.sorted { $0.addedDate > $1.addedDate }.prefix(5))
    }
    var fridgeHealthScore: Int {
        let items = fridgeData.items
        guard !items.isEmpty else { return 100 }
        let total = items.reduce(0) { acc, item in
            switch item.expiryStatus {
            case .good: return acc + 100; case .warning: return acc + 50
            case .critical: return acc + 10; case .expired: return acc + 0
            }
        }
        return total / items.count
    }
    func greetingText() -> String {
        let hour = Calendar.current.component(.hour, from: Date())
        let name = userData.name
        if hour < 12 { return "Good morning, \(name) 🌤️" }
        if hour < 17 { return "Good afternoon, \(name) ☀️" }
        return "Good evening, \(name) 🌙"
    }

    var body: some View {
        VStack(spacing: 0) {

            // ── Fixed banner ──
            ZStack(alignment: .leading) {
                HStack {
                    Spacer()
                    Spacer()
                    
                    Text("Meal-E 🌿")
                        .font(.system(.title3, design: .serif).weight(.heavy))
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
            }
            .padding(.vertical, 14).background(Color(hex: "D8F3DC"))
            .overlay(Rectangle().fill(Color(hex: "1B4332").opacity(0.07)).frame(height: 1), alignment: .bottom)

            ZStack {
                LinearGradient(colors: [Color(hex: "D8F3DC"), Color(hex: "EDF7F0"), Color(hex: "F0FAF4")],
                               startPoint: .topLeading, endPoint: .bottomTrailing).ignoresSafeArea()

                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 28) {
                        headerSection          // 1. Greeting
                        quickActionsSection    // 2. Add / Alerts / Health / Recipes
                        heroStatsSection       // 3. Item count card → InventoryView
                        smartTipSection        // 4. Most urgent item
                        expiringSoonSection    // 5. Expiring soon list
                        macroSummarySection    // 6. Nutrition tiles → ranked sheet
                        categoryBreakdownSection // 7. Donut ring
                        recentlyAddedSection   // 8. Horizontal scroll
                        tipOfTheDaySection     // 9. Daily tip
                        fridgeHealthSection    // 10. Health ring
                        streakSection          // 11. Freshness streak
                        Spacer(minLength: 40)
                    }
                    .padding(.top, 12).padding(.bottom, 30)
                }
            }
        }
        .navigationBarHidden(true)
        .ignoresSafeArea(edges: .bottom)
        .sheet(item: $selectedItem)  { item in ItemDetailView(item: item) }
        .sheet(isPresented: $showInventory) { InventoryView() }
        .sheet(isPresented: $showRecipes)   { MealPlanView() }
        .sheet(isPresented: $showAlerts)    { AlertView() }
        .sheet(item: $macroSort) { sort in MacroRankedSheet(sort: sort, items: fridgeData.items) }
    }

    // MARK: - 1. Header

    private var headerSection: some View {
        Text(greetingText())
            .font(.system(.title2, design: .serif).bold())
            .foregroundStyle(Color(hex: "1B4332"))
            .multilineTextAlignment(.center)
            .frame(maxWidth: .infinity)
            .padding(.horizontal, 22).padding(.top, 22).padding(.bottom, 4)
    }

    // MARK: - 2. Quick Actions

    private var quickActionsSection: some View {
        HStack(spacing: 12) {
//            QuickActionButton(icon: "plus.circle.fill",  label: "Add Item", color: Color(hex: "2D6A4F")) { showAddItem = true }
            QuickActionButton(icon: "fork.knife",        label: "Recipes",  color: Color(hex: "1B4332")) { selection = 2 }
            QuickActionButton(icon: "refrigerator.fill", label: "Pantry",   color: Color(hex: "40916C")) { selection = 1 }
            QuickActionButton(icon: "bell.badge.fill",   label: "Alerts",   color: Color(hex: "D97706")) { selection = 3 }
        }
        .padding(.horizontal, 22)
    }

    // MARK: - 3. Hero Stats Card → Inventory

    private var heroStatsSection: some View {
        Button { showInventory = true } label: {
            ZStack {
                RoundedRectangle(cornerRadius: 28)
                    .fill(Color(hex: "2D6A4F"))
                    .frame(height: 170)
                    .shadow(color: Color(hex: "1B4332").opacity(0.32), radius: 24, x: 0, y: 14)

                HStack(alignment: .center) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("\(fridgeData.items.count)")
                            .font(.system(size: 68, weight: .black, design: .serif)).foregroundStyle(.white)
                        HStack(spacing: 6) {
                            Text("Items in your fridge")
                                .font(.system(.subheadline).weight(.semibold)).foregroundStyle(Color.white.opacity(0.82))
                            Image(systemName: "chevron.right")
                                .font(.system(.caption, design: .serif).bold()).foregroundStyle(Color.white.opacity(0.5))
                        }
                    }
                    .padding(.leading, 26)
                    Spacer()
                    Text("🧺").font(.system(size: 56)).padding(.trailing, 26)
                }
            }
        }
        .buttonStyle(.plain)
        .padding(.horizontal, 22)
    }

    // MARK: - 4. Smart Tip (most urgent item)

    private var smartTipSection: some View {
        let urgentItem = fridgeData.items.filter { $0.daysLeft >= 0 }.sorted { $0.daysLeft < $1.daysLeft }.first
        return Group {
            if let item = urgentItem {
                Button { selectedItem = item } label: {
                    HStack(spacing: 14) {
                        Text(item.emoji).font(.system(size: 34)).padding(10)
                            .background(Circle().fill(Color(hex: "1B4332").opacity(0.08)))
                        VStack(alignment: .leading, spacing: 3) {
                            Text("Use this first 👇").font(.system(.caption, design: .serif).bold())
                                .foregroundStyle(Color(hex: "2D6A4F").opacity(0.7))
                            Text(item.name).font(.system(size: 16, weight: .bold, design: .serif))
                                .foregroundStyle(Color(hex: "1B4332"))
                            Text(item.daysLeft == 0 ? "Expires today!" : "Expires in \(item.daysLeft) day\(item.daysLeft == 1 ? "" : "s")")
                                .font(.system(.caption, design: .serif)).foregroundStyle(item.expiryStatus.color)
                        }
                        Spacer()
                        Image(systemName: "chevron.right").font(.system(.caption, design: .serif)).foregroundStyle(Color(hex: "2D6A4F").opacity(0.3))
                    }
                    .padding(16)
                    .background(LinearGradient(colors: [Color(hex: "D8F3DC"), Color(hex: "EDF7F0")], startPoint: .leading, endPoint: .trailing))
                    .clipShape(RoundedRectangle(cornerRadius: 18))
                    .overlay(RoundedRectangle(cornerRadius: 18).stroke(Color(hex: "52B788").opacity(0.4), lineWidth: 1.5))
                    .shadow(color: Color(hex: "2D6A4F").opacity(0.08), radius: 8, x: 0, y: 3)
                }
                .buttonStyle(.plain)
                .padding(.horizontal, 22)
            }
        }
    }

    // MARK: - 5. Expiring Soon

    private var expiringSoonSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            HomeSectionHeader(title: "⏳ Expiring Soon", subtitle: "Use these first")
            if expiringSoonItems.isEmpty {
                HStack(spacing: 12) {
                    Text("🎉").font(.title2)
                    Text("Nothing expiring — you're all good!")
                        .font(.system(.subheadline).weight(.semibold)).foregroundStyle(Color(hex: "2D6A4F"))
                }
                .padding(18).frame(maxWidth: .infinity, alignment: .leading).background(Color.white)
                .clipShape(RoundedRectangle(cornerRadius: 18))
                .overlay(RoundedRectangle(cornerRadius: 18).stroke(Color(hex: "52B788").opacity(0.35), lineWidth: 1.5))
                .shadow(color: Color(hex: "2D6A4F").opacity(0.08), radius: 8, x: 0, y: 3)
                .padding(.horizontal, 22)
            } else {
                VStack(spacing: 10) {
                    ForEach(expiringSoonItems) { item in
                        Button { selectedItem = item } label: { BoldExpiringRow(item: item) }.buttonStyle(.plain)
                    }
                }
                .padding(.horizontal, 22)
            }
        }
    }

    // MARK: - 6. Macro Summary → Ranked Sheet

    private var macroSummarySection: some View {
        let items        = fridgeData.items
        let totalCal     = items.reduce(0)   { $0 + $1.nutrition.calories }
        let totalProtein = items.reduce(0.0) { $0 + $1.nutrition.protein }
        let totalCarbs   = items.reduce(0.0) { $0 + $1.nutrition.carbs }
        let totalFat     = items.reduce(0.0) { $0 + $1.nutrition.fat }

        return VStack(alignment: .leading, spacing: 14) {
            HomeSectionHeader(title: "📊 Nutrition Available", subtitle: "Tap a tile to rank your items")
            HStack(spacing: 10) {
                MacroTile(label: "Calories", value: "\(totalCal)",                          unit: "kcal", color: MacroSort.calories.color).onTapGesture { macroSort = .calories }
                MacroTile(label: "Protein",  value: String(format: "%.0f", totalProtein),   unit: "g",    color: MacroSort.protein.color).onTapGesture  { macroSort = .protein }
                MacroTile(label: "Carbs",    value: String(format: "%.0f", totalCarbs),     unit: "g",    color: MacroSort.carbs.color).onTapGesture    { macroSort = .carbs }
                MacroTile(label: "Fat",      value: String(format: "%.0f", totalFat),       unit: "g",    color: MacroSort.fat.color).onTapGesture      { macroSort = .fat }
            }
            .padding(.horizontal, 22)
        }
    }

    // MARK: - 7. Category Donut

    private var categoryBreakdownSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            HomeSectionHeader(title: "🗂 By Category", subtitle: "Tap a slice or label to highlight")
            CategoryDonutChart(items: fridgeData.items).padding(.horizontal, 22)
        }
    }

    // MARK: - 8. Recently Added

    private var recentlyAddedSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            HomeSectionHeader(title: "🕒 Recently Added", subtitle: "Last scanned items")
            if recentItems.isEmpty {
                Text("No items added yet.").font(.system(.subheadline)).foregroundStyle(Color(hex: "1B4332").opacity(0.4)).padding(.horizontal, 22)
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 14) {
                        ForEach(recentItems) { item in
                            Button { selectedItem = item } label: { BoldRecentCard(item: item) }.buttonStyle(.plain)
                        }
                    }
                    .padding(.horizontal, 22).padding(.vertical, 4)
                }
            }
        }
    }

    // MARK: - 9. Tip of the Day

    private var tipOfTheDaySection: some View {
        let tips: [(String, String)] = [
            ("🥗", "Try mixing your expiring greens into a salad or smoothie today."),
            ("🍳", "Eggs are great for using up odds and ends — omelette time!"),
            ("🧊", "Did you know? Most cheeses can be frozen to extend their life."),
            ("📦", "Store leftovers in clear containers so you never forget them."),
            ("🌿", "Fresh herbs last longer wrapped in a damp paper towel."),
            ("🍋", "Squeeze lemon on cut fruit to slow browning."),
            ("🥛", "Milk nearing its date? Make a quick béchamel or pancakes."),
        ]
        let day = Calendar.current.ordinality(of: .day, in: .year, for: Date()) ?? 0
        let tip = tips[day % tips.count]

        return VStack(alignment: .leading, spacing: 14) {
            HomeSectionHeader(title: "💡 Tip of the Day", subtitle: "A little goes a long way")
            HStack(spacing: 14) {
                Text(tip.0).font(.system(size: 32)).frame(width: 52, height: 52)
                    .background(Circle().fill(Color(hex: "52B788").opacity(0.15)))
                Text(tip.1).font(.system(.subheadline))
                    .foregroundStyle(Color(hex: "1B4332").opacity(0.8))
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(16).frame(maxWidth: .infinity, alignment: .leading)
            .background(LinearGradient(colors: [Color(hex: "D8F3DC"), Color.white], startPoint: .topLeading, endPoint: .bottomTrailing))
            .clipShape(RoundedRectangle(cornerRadius: 18))
            .overlay(RoundedRectangle(cornerRadius: 18).stroke(Color(hex: "52B788").opacity(0.3), lineWidth: 1.5))
            .shadow(color: Color(hex: "2D6A4F").opacity(0.07), radius: 8, x: 0, y: 3)
            .padding(.horizontal, 22)
        }
    }

    // MARK: - 10. Fridge Health

    private var fridgeHealthSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            HomeSectionHeader(title: "💚 Fridge Health", subtitle: "Based on freshness of all items")
            FridgeHealthRingCard(score: fridgeHealthScore, items: fridgeData.items).padding(.horizontal, 22)
        }
    }

    // MARK: - 11. Streak

    private var streakSection: some View {
        let hasExpired = fridgeData.items.contains { $0.daysLeft < 0 }
        let streak = hasExpired ? 0 : 7
        let message = hasExpired ? "You have expired items — clear them to restart!" : "No expired items! Keep it up 🔥"

        return VStack(alignment: .leading, spacing: 14) {
            HomeSectionHeader(title: "🔥 Freshness Streak", subtitle: "Days without any expired items")
            HStack(spacing: 18) {
                VStack(spacing: 4) {
                    Text("\(streak)")
                        .font(.system(size: 48, weight: .black, design: .serif))
                        .foregroundStyle(hasExpired ? Color(hex: "DC2626") : Color(hex: "2D6A4F"))
                    Text("days").font(.system(.caption, design: .serif).weight(.semibold)).foregroundStyle(Color(hex: "1B4332").opacity(0.45))
                }
                .frame(width: 80)

                VStack(alignment: .leading, spacing: 6) {
                    Text(message).font(.system(.subheadline).weight(.semibold)).foregroundStyle(Color(hex: "1B4332"))
                        .fixedSize(horizontal: false, vertical: true)
                    HStack(spacing: 6) {
                        ForEach([1, 3, 7, 14, 30], id: \.self) { m in
                            VStack(spacing: 3) {
                                Circle().fill(streak >= m ? Color(hex: "2D6A4F") : Color(hex: "D8F3DC"))
                                    .frame(width: 10, height: 10)
                                    .overlay(Circle().stroke(Color(hex: "52B788").opacity(0.4), lineWidth: 1))
                                Text("\(m)d").font(.system(size: 8, weight: .medium)).foregroundStyle(Color(hex: "1B4332").opacity(0.4))
                            }
                        }
                    }
                }
                Spacer()
            }
            .padding(18).background(Color.white).clipShape(RoundedRectangle(cornerRadius: 20))
            .overlay(RoundedRectangle(cornerRadius: 20)
                .stroke((hasExpired ? Color(hex: "DC2626") : Color(hex: "52B788")).opacity(0.2), lineWidth: 1.5))
            .shadow(color: Color(hex: "2D6A4F").opacity(0.08), radius: 10, x: 0, y: 4)
            .padding(.horizontal, 22)
        }
    }
}

// MARK: - Section Header

struct HomeSectionHeader: View {
    let title: String; let subtitle: String
    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(title).font(.system(.subheadline, design: .serif).bold()).foregroundStyle(Color(hex: "1B4332"))
            Text(subtitle).font(.system(.caption, design: .serif)).foregroundStyle(Color(hex: "1B4332").opacity(0.48))
        }
        .padding(.horizontal, 22)
    }
}

// MARK: - Expiring Row

struct BoldExpiringRow: View {
    let item: FridgeItem
    var expiryColor: Color {
        switch item.expiryStatus {
        case .expired, .critical: return Color(hex: "DC2626")
        case .warning:            return Color(hex: "D97706")
        case .good:               return Color(hex: "2D6A4F")
        }
    }
    var expiryLabel: String {
        if item.daysLeft < 0 { return "Expired!" }
        if item.daysLeft == 0 { return "Today!" }
        if item.daysLeft == 1 { return "1 day left" }
        return "\(item.daysLeft) days left"
    }
    var body: some View {
        HStack(spacing: 14) {
            ZStack {
                RoundedRectangle(cornerRadius: 13).fill(expiryColor.opacity(0.1)).frame(width: 50, height: 50)
                Text(item.emoji).font(.title2)
            }
            VStack(alignment: .leading, spacing: 3) {
                Text(item.name).font(.system(.subheadline, design: .serif).bold()).foregroundStyle(Color(hex: "1B4332"))
                Text(item.quantity).font(.system(.caption, design: .serif)).foregroundStyle(Color(hex: "1B4332").opacity(0.42))
            }
            Spacer()
            Text(expiryLabel).font(.system(.caption, design: .serif).bold()).foregroundStyle(expiryColor)
                .padding(.horizontal, 10).padding(.vertical, 5).background(expiryColor.opacity(0.1))
                .clipShape(Capsule()).overlay(Capsule().stroke(expiryColor.opacity(0.28), lineWidth: 1))
        }
        .padding(14).background(Color.white).clipShape(RoundedRectangle(cornerRadius: 18))
        .overlay(RoundedRectangle(cornerRadius: 18).stroke(expiryColor.opacity(0.14), lineWidth: 1.5))
        .shadow(color: Color(hex: "2D6A4F").opacity(0.08), radius: 8, x: 0, y: 3)
    }
}

// MARK: - Recent Card

struct BoldRecentCard: View {
    let item: FridgeItem
    var expiryColor: Color {
        switch item.expiryStatus {
        case .expired, .critical: return Color(hex: "DC2626")
        case .warning:            return Color(hex: "D97706")
        case .good:               return Color(hex: "40916C")
        }
    }
    var expiryLabel: String {
        if item.daysLeft < 0 { return "Expired" }
        if item.daysLeft == 0 { return "Today" }
        if item.daysLeft == 1 { return "1 day" }
        return "\(item.daysLeft) days"
    }
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(item.emoji).font(.system(size: 40))
            Text(item.name).font(.system(.subheadline, design: .serif).bold()).foregroundStyle(Color(hex: "1B4332")).lineLimit(1)
            Text(expiryLabel).font(.caption2).fontWeight(.bold).foregroundStyle(expiryColor)
                .padding(.horizontal, 10).padding(.vertical, 4).background(expiryColor.opacity(0.1))
                .clipShape(Capsule()).overlay(Capsule().stroke(expiryColor.opacity(0.25), lineWidth: 1))
        }
        .padding(16).frame(width: 140).background(Color.white).clipShape(RoundedRectangle(cornerRadius: 22))
        .shadow(color: Color(hex: "2D6A4F").opacity(0.1), radius: 12, x: 0, y: 5)
    }
}

// MARK: - Health Category Sheet

enum HealthFilter: String, Identifiable {
    case fresh    = "Fresh"
    case expiring = "Expiring"
    case critical = "Critical"
    var id: String { rawValue }

    var color: Color {
        switch self {
        case .fresh:    return Color(hex: "2D6A4F")
        case .expiring: return Color(hex: "D97706")
        case .critical: return Color(hex: "DC2626")
        }
    }
    var icon: String {
        switch self {
        case .fresh:    return "checkmark.seal.fill"
        case .expiring: return "clock.fill"
        case .critical: return "exclamationmark.triangle.fill"
        }
    }
    var subtitle: String {
        switch self {
        case .fresh:    return "Good for 4+ days"
        case .expiring: return "Use within 1–3 days"
        case .critical: return "Expired or expiring today"
        }
    }
    func matches(_ item: FridgeItem) -> Bool {
        switch self {
        case .fresh:    return item.expiryStatus == .good
        case .expiring: return item.expiryStatus == .warning
        case .critical: return item.expiryStatus == .critical || item.expiryStatus == .expired
        }
    }
}

struct HealthCategorySheet: View {
    let filter: HealthFilter
    let items: [FridgeItem]
    @Environment(\.dismiss) private var dismiss
    @State private var selectedItem: FridgeItem? = nil

    var filtered: [FridgeItem] {
        items.filter { filter.matches($0) }.sorted { $0.daysLeft < $1.daysLeft }
    }

    var body: some View {
        VStack(spacing: 0) {
            // Header
            VStack(spacing: 10) {
                Capsule()
                    .fill(Color(hex: "1B4332").opacity(0.15))
                    .frame(width: 36, height: 4)
                    .padding(.top, 12)

                HStack(spacing: 12) {
                    ZStack {
                        Circle().fill(filter.color.opacity(0.15)).frame(width: 48, height: 48)
                        Image(systemName: filter.icon)
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundStyle(filter.color)
                    }
                    VStack(alignment: .leading, spacing: 3) {
                        Text(filter.rawValue)
                            .font(.system(.title2, design: .serif).bold())
                            .foregroundStyle(Color(hex: "1B4332"))
                        Text(filter.subtitle)
                            .font(.system(.caption, design: .serif))
                            .foregroundStyle(Color(hex: "2D6A4F").opacity(0.6))
                    }
                    Spacer()
                    Button { dismiss() } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.title2)
                            .foregroundStyle(Color(hex: "1B4332").opacity(0.2))
                    }
                }
                .padding(.horizontal, 20)

                // Count pill
                HStack {
                    Text("\(filtered.count) item\(filtered.count == 1 ? "" : "s")")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(filter.color)
                        .padding(.horizontal, 12).padding(.vertical, 5)
                        .background(filter.color.opacity(0.12))
                        .clipShape(Capsule())
                    Spacer()
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 12)
            }
            .background(Color(hex: "D8F3DC"))
            .overlay(Rectangle().fill(Color(hex: "1B4332").opacity(0.07)).frame(height: 1), alignment: .bottom)

            if filtered.isEmpty {
                Spacer()
                VStack(spacing: 12) {
                    Text(filter == .fresh ? "🎉" : filter == .expiring ? "✅" : "✅")
                        .font(.system(size: 52))
                    Text(filter == .fresh ? "No fresh items yet" : "Nothing in this category")
                        .font(.system(.subheadline, design: .serif))
                        .foregroundStyle(Color(hex: "1B4332").opacity(0.5))
                }
                Spacer()
            } else {
                ScrollView(showsIndicators: false) {
                    LazyVStack(spacing: 12) {
                        ForEach(filtered) { item in
                            HealthItemRow(item: item, accentColor: filter.color)
                                .onTapGesture { selectedItem = item }
                        }
                    }
                    .padding(.horizontal, 16).padding(.top, 16).padding(.bottom, 40)
                }
                .background(
                    LinearGradient(
                        colors: [Color(hex: "D8F3DC"), Color(hex: "EDF7F0"), Color(hex: "F0FAF4")],
                        startPoint: .top, endPoint: .bottom
                    ).ignoresSafeArea()
                )
            }
        }
        .sheet(item: $selectedItem) { item in ItemDetailView(item: item) }
    }
}

struct HealthItemRow: View {
    let item: FridgeItem
    let accentColor: Color

    var expiryLabel: String {
        if item.daysLeft < 0  { return "Expired \(abs(item.daysLeft))d ago" }
        if item.daysLeft == 0 { return "Expires today" }
        if item.daysLeft == 1 { return "1 day left" }
        return "\(item.daysLeft) days left"
    }

    var body: some View {
        HStack(spacing: 14) {
            ZStack {
                RoundedRectangle(cornerRadius: 13)
                    .fill(accentColor.opacity(0.1))
                    .frame(width: 52, height: 52)
                Text(item.emoji).font(.title2)
            }
            VStack(alignment: .leading, spacing: 3) {
                Text(item.name)
                    .font(.system(.subheadline, design: .serif).bold())
                    .foregroundStyle(Color(hex: "1B4332"))
                Text(item.quantity)
                    .font(.system(.caption, design: .serif))
                    .foregroundStyle(Color(hex: "1B4332").opacity(0.4))
            }
            Spacer()
            VStack(alignment: .trailing, spacing: 3) {
                Text(expiryLabel)
                    .font(.system(.caption, design: .serif).bold())
                    .foregroundStyle(accentColor)
                    .padding(.horizontal, 9).padding(.vertical, 4)
                    .background(accentColor.opacity(0.1))
                    .clipShape(Capsule())
                Text("\(item.nutrition.calories) kcal")
                    .font(.system(size: 10, weight: .medium))
                    .foregroundStyle(Color(hex: "1B4332").opacity(0.3))
            }
        }
        .padding(14)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: Color(hex: "2D6A4F").opacity(0.07), radius: 6, x: 0, y: 2)
    }
}

// MARK: - Health Ring Card

struct FridgeHealthRingCard: View {
    let score: Int
    let items: [FridgeItem]

    @State private var animate         = false
    @State private var selectedFilter: HealthFilter? = nil
    @State private var sheetFilter:    HealthFilter? = nil

    var ringColor: Color    { score >= 80 ? Color(hex: "2D6A4F") : score >= 50 ? Color(hex: "D97706") : Color(hex: "DC2626") }
    var statusLabel: String { score >= 80 ? "Great shape 🎉" : score >= 50 ? "Needs attention ⚠️" : "Action required 🚨" }

    var freshCount:    Int { items.filter { $0.expiryStatus == .good }.count }
    var warningCount:  Int { items.filter { $0.expiryStatus == .warning }.count }
    var criticalCount: Int { items.filter { $0.expiryStatus == .critical || $0.expiryStatus == .expired }.count }

    var body: some View {
        VStack(spacing: 0) {
            // Ring + rows
            HStack(spacing: 22) {
                ringView
                rowsView
                Spacer()
            }
            .padding(20)

            // Inline preview strip
            if let sel = selectedFilter {
                let filtered = items.filter { sel.matches($0) }.sorted { $0.daysLeft < $1.daysLeft }
                let color    = sel.color

                Divider().padding(.horizontal, 20)

                VStack(alignment: .leading, spacing: 10) {
                    HStack {
                        Text("Items · \(sel.rawValue)")
                            .font(.system(.caption, design: .serif).weight(.semibold))
                            .foregroundStyle(Color(hex: "1B4332").opacity(0.6))
                        Spacer()
                        Button { sheetFilter = sel } label: {
                            HStack(spacing: 3) {
                                Text("See all")
                                Image(systemName: "arrow.right")
                            }
                            .font(.system(size: 11, weight: .semibold))
                            .foregroundStyle(color)
                        }
                    }
                    .padding(.horizontal, 20).padding(.top, 12)

                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 10) {
                            ForEach(filtered.prefix(6)) { item in
                                Button { sheetFilter = sel } label: {
                                    VStack(spacing: 6) {
                                        Text(item.emoji).font(.system(size: 28))
                                        Text(item.name)
                                            .font(.system(size: 10, weight: .semibold, design: .serif))
                                            .foregroundStyle(Color(hex: "1B4332"))
                                            .lineLimit(1)
                                        Text(item.daysLeft < 0 ? "Expired" : item.daysLeft == 0 ? "Today" : "\(item.daysLeft)d")
                                            .font(.system(size: 9, weight: .bold))
                                            .foregroundStyle(color)
                                    }
                                    .frame(width: 64)
                                    .padding(.vertical, 10)
                                    .background(color.opacity(0.07))
                                    .clipShape(RoundedRectangle(cornerRadius: 12))
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .padding(.horizontal, 20).padding(.bottom, 16)
                    }
                }
            }
        }
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 22))
        .overlay(RoundedRectangle(cornerRadius: 22).stroke(ringColor.opacity(0.15), lineWidth: 1.5))
        .shadow(color: Color(hex: "2D6A4F").opacity(0.09), radius: 12, x: 0, y: 5)
        .onAppear { animate = true }
        .sheet(item: $sheetFilter) { filter in
            HealthCategorySheet(filter: filter, items: items)
        }
    }

    // MARK: Extracted sub-views

    @ViewBuilder
    private var ringView: some View {
        ZStack {
            Circle().stroke(ringColor.opacity(0.12), lineWidth: 14).frame(width: 110, height: 110)
            Circle()
                .trim(from: 0, to: animate ? CGFloat(score) / 100.0 : 0)
                .stroke(
                    AngularGradient(colors: [ringColor.opacity(0.5), ringColor], center: .center,
                                    startAngle: .degrees(-90), endAngle: .degrees(270)),
                    style: StrokeStyle(lineWidth: 14, lineCap: .round)
                )
                .frame(width: 110, height: 110).rotationEffect(.degrees(-90))
                .animation(.spring(duration: 1.2, bounce: 0.2), value: animate)
            VStack(spacing: 2) {
                Text("\(score)%")
                    .font(.system(size: 26, weight: .black, design: .serif))
                    .foregroundStyle(ringColor)
                Text("Health")
                    .font(.caption2).fontWeight(.semibold)
                    .foregroundStyle(Color(hex: "1B4332").opacity(0.5))
            }
        }
    }

    @ViewBuilder
    private var rowsView: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(statusLabel)
                .font(.system(.subheadline, design: .serif).bold())
                .foregroundStyle(ringColor)

            VStack(alignment: .leading, spacing: 6) {
                TappableHealthRow(
                    color: Color(hex: "2D6A4F"), label: "Fresh",    count: freshCount,
                    isSelected: selectedFilter == .fresh
                ) {
                    if selectedFilter == .fresh { sheetFilter = .fresh }
                    else { selectedFilter = .fresh }
                }
                TappableHealthRow(
                    color: Color(hex: "D97706"), label: "Expiring", count: warningCount,
                    isSelected: selectedFilter == .expiring
                ) {
                    if selectedFilter == .expiring { sheetFilter = .expiring }
                    else { selectedFilter = .expiring }
                }
                TappableHealthRow(
                    color: Color(hex: "DC2626"), label: "Critical", count: criticalCount,
                    isSelected: selectedFilter == .critical
                ) {
                    if selectedFilter == .critical { sheetFilter = .critical }
                    else { selectedFilter = .critical }
                }
            }
        }
    }
}

struct TappableHealthRow: View {
    let color: Color
    let label: String
    let count: Int
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 7) {
                Circle().fill(color).frame(width: 8, height: 8)
                Text(label)
                    .font(.system(.caption, design: .serif))
                    .foregroundStyle(Color(hex: "1B4332").opacity(isSelected ? 1.0 : 0.6))
                Spacer()
                Text("\(count)")
                    .font(.system(.caption, design: .serif).bold())
                    .foregroundStyle(color)
                Image(systemName: "chevron.right")
                    .font(.system(size: 8, weight: .bold))
                    .foregroundStyle(color.opacity(isSelected ? 0.9 : 0.4))
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Quick Action Button

struct QuickActionButton: View {
    let icon: String; let label: String; let color: Color; let action: () -> Void
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                ZStack {
                    RoundedRectangle(cornerRadius: 14).fill(color.opacity(0.12)).frame(width: 52, height: 52)
                    Image(systemName: icon).font(.system(size: 20, weight: .semibold)).foregroundStyle(color)
                }
                Text(label).font(.system(size: 11, weight: .semibold)).foregroundStyle(Color(hex: "1B4332").opacity(0.7))
            }
            .frame(maxWidth: .infinity)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Macro Tile

struct MacroTile: View {
    let label: String; let value: String; let unit: String; let color: Color
    var body: some View {
        VStack(spacing: 4) {
            Text(value).font(.system(size: 20, weight: .black, design: .serif)).foregroundStyle(color)
            Text(unit).font(.system(size: 10, weight: .semibold)).foregroundStyle(color.opacity(0.7))
            Text(label).font(.system(size: 10, weight: .medium)).foregroundStyle(Color(hex: "1B4332").opacity(0.5))
            Image(systemName: "chevron.up").font(.system(size: 8, weight: .bold, design: .serif)).foregroundStyle(color.opacity(0.4))
        }
        .frame(maxWidth: .infinity).padding(.vertical, 12)
        .background(color.opacity(0.08)).clipShape(RoundedRectangle(cornerRadius: 14))
        .overlay(RoundedRectangle(cornerRadius: 14).stroke(color.opacity(0.2), lineWidth: 1.5))
    }
}


//import SwiftUI
//
///*
// ╔══════════════════════════════════════════════╗
// ║  SMARTFRIDGE COLOR SYSTEM                    ║
// ║                                              ║
// ║  Background: #D8F3DC → #EDF7F0 → #F0FAF4    ║
// ║  Hero card:  #1B4332 → #2D6A4F → #40916C    ║
// ║  Primary:    #1B4332  (deep forest)          ║
// ║  Mid green:  #2D6A4F  (rich forest)          ║
// ║  Bright:     #52B788  (vibrant sage)         ║
// ║  Light tint: #D8F3DC  (soft mint)            ║
// ║  Cards:      #FFFFFF  (white)                ║
// ║  Warn:       #D97706  (golden — expiring)    ║
// ║  Critical:   #DC2626  (red — expired)        ║
// ╚══════════════════════════════════════════════╝
//*/
//
//// MARK: - Pie Chart
//
//struct PieSlice: Shape {
//    var startAngle: Angle
//    var endAngle: Angle
//    func path(in rect: CGRect) -> Path {
//        let center = CGPoint(x: rect.midX, y: rect.midY)
//        let radius = min(rect.width, rect.height) / 2
//        var path = Path()
//        path.move(to: center)
//        path.addArc(center: center, radius: radius,
//                    startAngle: startAngle, endAngle: endAngle, clockwise: false)
//        path.closeSubpath()
//        return path
//    }
//}
//
//struct PieChartView: View {
//    let data: [(String, String, Int)]
//
//    let sliceColors: [Color] = [
//        Color(hex: "1B4332"),
//        Color(hex: "2D6A4F"),
//        Color(hex: "40916C"),
//        Color(hex: "52B788"),
//        Color(hex: "74C69D"),
//        Color(hex: "95D5B2"),
//        Color(hex: "B7E4C7"),
//    ]
//
//    var total: Int { data.reduce(0) { $0 + $1.2 } }
//
//    var slices: [(startAngle: Angle, endAngle: Angle, color: Color, label: String, emoji: String, pct: Int)] {
//        var result: [(Angle, Angle, Color, String, String, Int)] = []
//        var current = -90.0
//        for (i, item) in data.enumerated() {
//            let pct = total > 0 ? Double(item.2) / Double(total) : 0
//            let sweep = pct * 360
//            let start = Angle(degrees: current)
//            let end = Angle(degrees: current + sweep)
//            result.append((start, end, sliceColors[i % sliceColors.count],
//                           item.0, item.1, Int(round(pct * 100))))
//            current += sweep
//        }
//        return result
//    }
//
//    var body: some View {
//        HStack(spacing: 20) {
//            ZStack {
//                ForEach(Array(slices.enumerated()), id: \.offset) { _, slice in
//                    PieSlice(startAngle: slice.startAngle, endAngle: slice.endAngle)
//                        .fill(slice.color)
//                }
//                Circle()
//                    .fill(Color.white)
//                    .frame(width: 66, height: 66)
//                VStack(spacing: 0) {
//                    Text("\(total)")
//                        .font(.system(size: 19, weight: .black, design: .serif))
//                        .foregroundStyle(Color(hex: "1B4332"))
//                    Text("items")
//                        .font(.system(size: 8, weight: .bold))
//                        .tracking(1.2)
//                        .foregroundStyle(Color(hex: "1B4332").opacity(0.45))
//                }
//            }
//            .frame(width: 136, height: 136)
//
//            VStack(alignment: .leading, spacing: 8) {
//                ForEach(Array(slices.enumerated()), id: \.offset) { _, slice in
//                    HStack(spacing: 8) {
//                        RoundedRectangle(cornerRadius: 3)
//                            .fill(slice.color)
//                            .frame(width: 10, height: 10)
//                        Text(slice.emoji).font(.system(size: 12))
//                        Text(slice.label)
//                            .font(.system(size: 12, weight: .semibold))
//                            .foregroundStyle(Color(hex: "1B4332"))
//                        Spacer()
//                        Text("\(slice.pct)%")
//                            .font(.system(size: 12, weight: .black))
//                            .foregroundStyle(slice.color)
//                    }
//                }
//            }
//        }
//        .padding(18)
//        .background(Color.white)
//        .clipShape(RoundedRectangle(cornerRadius: 22))
//        .shadow(color: Color(hex: "2D6A4F").opacity(0.1), radius: 16, x: 0, y: 6)
//    }
//}
//
//// MARK: - Home View
//
//struct Home: View {
//
//    @Environment(FridgeInventoryViewModel.self) private var fridgeData
//    @Environment(UserData.self) var userData
//
//    var expiringSoonItems: [FridgeItem] {
//        fridgeData.items.filter { $0.daysLeft <= 3 }
//    }
//
//    var recentItems: [FridgeItem] {
//        Array(fridgeData.items.prefix(3))
//    }
//
//    var freshCount: Int {
//        fridgeData.items.filter { $0.daysLeft > 3 }.count
//    }
//
//    private var categoryData: [(String, String, Int)] {
//        let items = fridgeData.items
//        var result: [(String, String, Int)] = []
//        let veg      = items.filter { $0.category == .vegetables }.count
//        let fruit    = items.filter { $0.category == .fruits }.count
//        let dairy    = items.filter { $0.category == .dairy }.count
//        let meat     = items.filter { $0.category == .meat }.count
//        let drinks   = items.filter { $0.category == .drinks }.count
//        let leftover = items.filter { $0.category == .leftovers }.count
//        let other    = items.filter { $0.category == .other }.count
//        if veg      > 0 { result.append(("Vegetables", "🥬", veg)) }
//        if fruit    > 0 { result.append(("Fruits",     "🍎", fruit)) }
//        if dairy    > 0 { result.append(("Dairy",      "🧀", dairy)) }
//        if meat     > 0 { result.append(("Meat",       "🍗", meat)) }
//        if drinks   > 0 { result.append(("Drinks",     "🥛", drinks)) }
//        if leftover > 0 { result.append(("Leftovers",  "🍲", leftover)) }
//        if other    > 0 { result.append(("Other",      "🫙", other)) }
//        return result
//    }
//
//    func greetingText() -> String {
//        let hour = Calendar.current.component(.hour, from: Date())
//        let name = userData.name
//        if hour < 12 { return "Good morning, \(name) 🌤️" }
//        if hour < 17 { return "Good afternoon, \(name) ☀️" }
//        return "Good evening, \(name) 🌙"
//    }
//
//    var body: some View {
//    
//        VStack(spacing: 0) {
//
//            // ── Instagram-style fixed top banner ──
//            HStack {
//                
//                Spacer()
//                Spacer()
//                
//                Text("Meal-E 🌿")
//                    .font(.system(size: 22, weight: .heavy, design: .serif))
//                    .foregroundStyle(Color(hex: "1B4332"))
//                
//                Spacer()
//                
//                Button {
//                    Task {
//                        
//                        do {
//                            
//                            print("Fetching pantry...")
//                            
//                            let data: [FridgeItem] = try await APIManager.shared.getPantry()
//                                withAnimation(.easeIn) {
//                                    fridgeData.items = data
//                                }
//                            
//                            print("Fetching user profile...")
//                            
//                            let userProfile: User? = try await APIManager.shared.getProfile()
//                            
//                            dump(userProfile!)
//                            
//                            if userProfile == nil {
//                                fatalError("Couldn't fetch user profile")
//                            } else {
//                                withAnimation(.easeIn) {
//                                    userData.age = "\(userProfile!.age)"
//                                    userData.name = userProfile!.name
//                                    userData.allergies = userProfile!.allergies
//                                    userData.cooking_proficiency = userProfile!.cooking_proficiency
//                                    userData.cuisine_preferences = userProfile!.cuisine_preferences
//                                    userData.dietary_restriction = userProfile!.dietary_restriction
//                                    userData.household_size = "\(userProfile!.household_size)"
//                                    userData.macro_targets = Macros(calories: "\(userProfile!.macro_targets.calories)", protein: "\(userProfile!.macro_targets.protein)")
//                                    userData.meals_per_day = "\(userProfile!.meals_per_day)"
//                                }
//                            }
//                            
//                        } catch {
//                            fatalError("Couldn't fetch data")
//                        }
//                        
//                    }
//                } label: {
//                    Image(systemName: "arrow.clockwise")
//                        .font(.system(size: 22, weight: .heavy, design: .serif))
//                        .foregroundStyle(Color(hex: "1B4332"))
//                        .padding(.horizontal)
//                    
//                }
//                
//            }
//            .padding(.vertical, 14)
//            .background(Color(hex: "D8F3DC"))
//            .overlay(
//                Rectangle()
//                    .fill(Color(hex: "1B4332").opacity(0.07))
//                    .frame(height: 1),
//                alignment: .bottom
//            )
//
//            // ── Scrollable content ──
//            ZStack {
//                LinearGradient(
//                    colors: [Color(hex: "D8F3DC"), Color(hex: "EDF7F0"), Color(hex: "F0FAF4")],
//                    startPoint: .topLeading,
//                    endPoint: .bottomTrailing
//                )
//                .ignoresSafeArea()
//
//                ScrollView(showsIndicators: false) {
//                    VStack(alignment: .leading, spacing: 28) {
//                        headerSection
//                        heroStatsSection
//                        expiringSoonSection
//                        recentlyAddedSection
//                        categoryBreakdownSection
//                        Spacer(minLength: 40)
//                    }
//                    .padding(.bottom, 30)
//                }
//            }
//        }
//        .navigationBarHidden(true)
//        .ignoresSafeArea(edges: .bottom)
//    }
//
//    // MARK: - Header
//
//    private var headerSection: some View {
//        VStack(spacing: 6) {
//            Text(greetingText())
//                .font(.system(size: 24, weight: .bold, design: .serif))
//                .foregroundStyle(Color(hex: "2D6A4F"))
//                .multilineTextAlignment(.center)
//            Text(Date().formatted(date: .long, time: .omitted))
//                .font(.caption)
//                .foregroundStyle(Color(hex: "1B4332").opacity(0.35))
//                .multilineTextAlignment(.center)
//        }
//        .frame(maxWidth: .infinity)
//        .padding(.horizontal, 22)
//        .padding(.top, 20)
//        .padding(.bottom, 4)
//    }
//
//    // MARK: - Hero Stats
//
//    private var heroStatsSection: some View {
//        VStack(spacing: 14) {
//            ZStack {
//                RoundedRectangle(cornerRadius: 28)
//                    .fill(LinearGradient(
//                        colors: [Color(hex: "1B4332"), Color(hex: "2D6A4F"), Color(hex: "40916C")],
//                        startPoint: .topLeading, endPoint: .bottomTrailing))
//                    .frame(height: 170)
//                    .shadow(color: Color(hex: "1B4332").opacity(0.32), radius: 24, x: 0, y: 14)
//
//                GeometryReader { geo in
//                    ZStack {
//                        Circle()
//                            .fill(Color.white.opacity(0.06))
//                            .frame(width: 210, height: 210)
//                            .offset(x: geo.size.width - 55, y: -55)
//                        Circle()
//                            .fill(Color.white.opacity(0.04))
//                            .frame(width: 120, height: 120)
//                            .offset(x: geo.size.width - 10, y: 70)
//                        Circle()
//                            .fill(Color.white.opacity(0.05))
//                            .frame(width: 70, height: 70)
//                            .offset(x: 12, y: -12)
//                    }
//                }
//                .clipShape(RoundedRectangle(cornerRadius: 28))
//
//                HStack(alignment: .center) {
//                    VStack(alignment: .leading, spacing: 4) {
//                        Text("\(fridgeData.items.count)")
//                            .font(.system(size: 68, weight: .black, design: .serif))
//                            .foregroundStyle(.white)
//                        Text("Items in your fridge")
//                            .font(.subheadline).fontWeight(.semibold)
//                            .foregroundStyle(Color.white.opacity(0.82))
//                    }
//                    .padding(.leading, 26)
//                    Spacer()
//                    Text("🧺").font(.system(size: 56)).padding(.trailing, 26)
//                }
//            }
//            .padding(.horizontal, 22)
//
//            HStack(spacing: 14) {
//                MiniStatCard(
//                    emoji: "⏳",
//                    value: "\(expiringSoonItems.count)",
//                    label: "Expiring Soon",
//                    bgColor: Color.white,
//                    valueColor: Color(hex: "D97706"),
//                    borderColor: Color(hex: "F59E0B").opacity(0.35)
//                )
//                MiniStatCard(
//                    emoji: "✅",
//                    value: "\(freshCount)",
//                    label: "Fresh & Good",
//                    bgColor: Color.white,
//                    valueColor: Color(hex: "2D6A4F"),
//                    borderColor: Color(hex: "52B788").opacity(0.4)
//                )
//            }
//            .padding(.horizontal, 22)
//        }
//    }
//
//    // MARK: - Expiring Soon
//
//    private var expiringSoonSection: some View {
//        VStack(alignment: .leading, spacing: 14) {
//            HomeSectionHeader(title: "⏳ Expiring Soon", subtitle: "Use these first")
//
//            if expiringSoonItems.isEmpty {
//                HStack(spacing: 12) {
//                    Text("🎉").font(.title2)
//                    Text("Nothing expiring — you're all good!")
//                        .font(.subheadline).fontWeight(.semibold)
//                        .foregroundStyle(Color(hex: "2D6A4F"))
//                }
//                .padding(18)
//                .frame(maxWidth: .infinity, alignment: .leading)
//                .background(Color.white)
//                .clipShape(RoundedRectangle(cornerRadius: 18))
//                .overlay(RoundedRectangle(cornerRadius: 18)
//                    .stroke(Color(hex: "52B788").opacity(0.35), lineWidth: 1.5))
//                .shadow(color: Color(hex: "2D6A4F").opacity(0.08), radius: 8, x: 0, y: 3)
//                .padding(.horizontal, 22)
//            } else {
//                VStack(spacing: 10) {
//                    ForEach(expiringSoonItems) { item in
//                        BoldExpiringRow(item: item)
//                    }
//                }
//                .padding(.horizontal, 22)
//            }
//        }
//    }
//
//    // MARK: - Recently Added
//
//    private var recentlyAddedSection: some View {
//        VStack(alignment: .leading, spacing: 14) {
//            HomeSectionHeader(title: "🕒 Recently Added", subtitle: "Last scanned items")
//            ScrollView(.horizontal, showsIndicators: false) {
//                HStack(spacing: 14) {
//                    ForEach(recentItems) { item in
//                        BoldRecentCard(item: item)
//                    }
//                }
//                .padding(.horizontal, 22)
//                .padding(.vertical, 4)
//            }
//        }
//    }
//
//    // MARK: - Category Breakdown
//
//    private var categoryBreakdownSection: some View {
//        VStack(alignment: .leading, spacing: 14) {
//            HomeSectionHeader(title: "📊 What's Inside", subtitle: "Breakdown by category")
//
//            if !categoryData.isEmpty {
//                PieChartView(data: categoryData)
//                    .padding(.horizontal, 22)
//            }
//
//            VStack(spacing: 8) {
//                ForEach(Array(categoryData.enumerated()), id: \.offset) { _, cat in
//                    HStack(spacing: 14) {
//                        Text(cat.1)
//                            .font(.title3)
//                            .frame(width: 44, height: 44)
//                            .background(Color(hex: "D8F3DC"))
//                            .clipShape(RoundedRectangle(cornerRadius: 12))
//                        Text(cat.0)
//                            .font(.subheadline).fontWeight(.semibold)
//                            .foregroundStyle(Color(hex: "1B4332"))
//                        Spacer()
//                        Text("\(cat.2) item\(cat.2 == 1 ? "" : "s")")
//                            .font(.caption).fontWeight(.bold)
//                            .foregroundStyle(Color(hex: "2D6A4F"))
//                            .padding(.horizontal, 12).padding(.vertical, 5)
//                            .background(Color(hex: "D8F3DC"))
//                            .clipShape(Capsule())
//                    }
//                    .padding(.horizontal, 16).padding(.vertical, 12)
//                    .background(Color.white)
//                    .clipShape(RoundedRectangle(cornerRadius: 16))
//                    .shadow(color: Color(hex: "2D6A4F").opacity(0.07), radius: 8, x: 0, y: 3)
//                }
//            }
//            .padding(.horizontal, 22)
//        }
//    }
//}
//
//// MARK: - Section Header
//
//struct HomeSectionHeader: View {
//    let title: String
//    let subtitle: String
//
//    var body: some View {
//        VStack(alignment: .leading, spacing: 2) {
//            Text(title)
//                .font(.system(size: 16, weight: .bold))
//                .foregroundStyle(Color(hex: "1B4332"))
//            Text(subtitle)
//                .font(.caption)
//                .foregroundStyle(Color(hex: "1B4332").opacity(0.48))
//        }
//        .padding(.horizontal, 22)
//    }
//}
//
//// MARK: - Mini Stat Card
//
//struct MiniStatCard: View {
//    let emoji: String
//    let value: String
//    let label: String
//    let bgColor: Color
//    let valueColor: Color
//    let borderColor: Color
//
//    var body: some View {
//        HStack(spacing: 12) {
//            Text(emoji).font(.title2)
//            VStack(alignment: .leading, spacing: 2) {
//                Text(value)
//                    .font(.system(size: 26, weight: .black, design: .serif))
//                    .foregroundStyle(valueColor)
//                Text(label)
//                    .font(.caption2).fontWeight(.medium)
//                    .foregroundStyle(valueColor.opacity(0.72))
//                    .lineLimit(1)
//            }
//            Spacer()
//        }
//        .padding(16)
//        .frame(maxWidth: .infinity)
//        .background(bgColor)
//        .clipShape(RoundedRectangle(cornerRadius: 20))
//        .overlay(RoundedRectangle(cornerRadius: 20).stroke(borderColor, lineWidth: 1.5))
//        .shadow(color: valueColor.opacity(0.12), radius: 10, x: 0, y: 4)
//    }
//}
//
//// MARK: - Expiring Row
//
//struct BoldExpiringRow: View {
//    let item: FridgeItem
//
//    var expiryColor: Color {
//        switch item.expiryStatus {
//        case .expired, .critical: return Color(hex: "DC2626")
//        case .warning:            return Color(hex: "D97706")
//        case .good:               return Color(hex: "2D6A4F")
//        }
//    }
//
//    var expiryLabel: String {
//        if item.daysLeft < 0 { return "Expired!" }
//        if item.daysLeft == 0 { return "Today!" }
//        if item.daysLeft == 1 { return "1 day left" }
//        return "\(item.daysLeft) days left"
//    }
//
//    var body: some View {
//        HStack(spacing: 14) {
//            ZStack {
//                RoundedRectangle(cornerRadius: 13)
//                    .fill(expiryColor.opacity(0.1))
//                    .frame(width: 50, height: 50)
//                Text(item.emoji).font(.title2)
//            }
//            VStack(alignment: .leading, spacing: 3) {
//                Text(item.name)
//                    .font(.subheadline).fontWeight(.bold)
//                    .foregroundStyle(Color(hex: "1B4332"))
//                Text(item.quantity)
//                    .font(.caption)
//                    .foregroundStyle(Color(hex: "1B4332").opacity(0.42))
//            }
//            Spacer()
//            Text(expiryLabel)
//                .font(.caption).fontWeight(.bold)
//                .foregroundStyle(expiryColor)
//                .padding(.horizontal, 10).padding(.vertical, 5)
//                .background(expiryColor.opacity(0.1))
//                .clipShape(Capsule())
//                .overlay(Capsule().stroke(expiryColor.opacity(0.28), lineWidth: 1))
//        }
//        .padding(14)
//        .background(Color.white)
//        .clipShape(RoundedRectangle(cornerRadius: 18))
//        .overlay(RoundedRectangle(cornerRadius: 18).stroke(expiryColor.opacity(0.14), lineWidth: 1.5))
//        .shadow(color: Color(hex: "2D6A4F").opacity(0.08), radius: 8, x: 0, y: 3)
//    }
//}
//
//// MARK: - Recent Card
//
//struct BoldRecentCard: View {
//    let item: FridgeItem
//
//    var expiryColor: Color {
//        switch item.expiryStatus {
//        case .expired, .critical: return Color(hex: "DC2626")
//        case .warning:            return Color(hex: "D97706")
//        case .good:               return Color(hex: "40916C")
//        }
//    }
//
//    var expiryLabel: String {
//        if item.daysLeft < 0 { return "Expired" }
//        if item.daysLeft == 0 { return "Today" }
//        if item.daysLeft == 1 { return "1 day" }
//        return "\(item.daysLeft) days"
//    }
//
//    var body: some View {
//        VStack(alignment: .leading, spacing: 10) {
//            Text(item.emoji).font(.system(size: 40))
//            Text(item.name)
//                .font(.subheadline).fontWeight(.bold)
//                .foregroundStyle(Color(hex: "1B4332"))
//                .lineLimit(1)
//            Text(expiryLabel)
//                .font(.caption2).fontWeight(.bold)
//                .foregroundStyle(expiryColor)
//                .padding(.horizontal, 10).padding(.vertical, 4)
//                .background(expiryColor.opacity(0.1))
//                .clipShape(Capsule())
//                .overlay(Capsule().stroke(expiryColor.opacity(0.25), lineWidth: 1))
//        }
//        .padding(16)
//        .frame(width: 140)
//        .background(Color.white)
//        .clipShape(RoundedRectangle(cornerRadius: 22))
//        .shadow(color: Color(hex: "2D6A4F").opacity(0.1), radius: 12, x: 0, y: 5)
//    }
//}
//
//// MARK: - Preview
//
//#Preview {
//    NavigationStack {
//        Home()
//    }
//}
//
