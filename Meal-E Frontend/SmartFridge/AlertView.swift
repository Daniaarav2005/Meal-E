//
//  Home.swift
//  SmartFridge
//
//  Created by Michael Pancras on 2/21/26.
//

import SwiftUI
import Combine

struct ExpiringItemCard: View {
    let item: FridgeItem
    let onDismiss: () -> Void

    var urgencyColor: Color {
        if item.isExpired { return Color(red: 0.85, green: 0.2, blue: 0.2) }
        if item.daysUntilExpiration == 0 { return Color(red: 0.95, green: 0.45, blue: 0.1) }
        if item.daysUntilExpiration <= 1 { return Color(red: 0.95, green: 0.6, blue: 0.1) }
        return Color(red: 0.85, green: 0.75, blue: 0.1)
    }

    var expirationLabel: String {
        if item.isExpired {
            let days = abs(item.daysUntilExpiration)
            return days == 1 ? "Expired yesterday" : "Expired \(days) days ago"
        }
        switch item.daysUntilExpiration {
        case 0: return "Expires today"
        case 1: return "Expires tomorrow"
        default: return "Expires in \(item.daysUntilExpiration) days"
        }
    }

    var body: some View {
        HStack(spacing: 14) {
            // Urgency indicator
            RoundedRectangle(cornerRadius: 3)
                .fill(urgencyColor)
                .frame(width: 5)

            VStack(alignment: .leading, spacing: 4) {
                Text(item.name)
                    .font(.system(size: 16, weight: .semibold, design: .serif))
                    .foregroundColor(.primary)
                HStack(spacing: 6) {
                    Image(systemName: "clock.badge.exclamationmark")
                        .font(.system(size: 11))
                        .foregroundColor(urgencyColor)
                    Text(expirationLabel)
                        .font(.system(size: 13, weight: .medium, design: .serif))
                        .foregroundColor(urgencyColor)
                }
                Text("Qty: \(item.quantity)")
                    .font(.system(size: 12))
                    .foregroundColor(.secondary)
            }

            Spacer()

            Button(action: onDismiss) {
                Image(systemName: "xmark.circle.fill")
                    .font(.system(size: 22))
                    .foregroundColor(urgencyColor.opacity(0.5))
            }
            .buttonStyle(.plain)
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 14)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(Color(.secondarySystemGroupedBackground))
                .overlay(
                    RoundedRectangle(cornerRadius: 14)
                        .stroke(urgencyColor.opacity(0.25), lineWidth: 1)
                )
        )
        .shadow(color: urgencyColor.opacity(0.08), radius: 6, x: 0, y: 2)
    }
}

// MARK: - Check-In Card

struct StillHaveCard: View {
    let item: FridgeItem
    let onStillHave: () -> Void
    let onRemove: () -> Void

    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: item.expirationDate)
    }

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(item.name)
                    .font(.system(size: 16, weight: .semibold, design: .serif))
                    .foregroundColor(.primary)
                HStack(spacing: 6) {
                    Image(systemName: "calendar")
                        .font(.system(size: 11))
                        .foregroundColor(.secondary)
                    Text("Expires \(formattedDate)")
                        .font(.system(size: 12))
                        .foregroundColor(.secondary)
                }
                Text("Qty: \(item.quantity)")
                    .font(.system(size: 12))
                    .foregroundColor(.secondary)
            }

            Spacer()

            HStack(spacing: 8) {
                Button(action: onStillHave) {
                    Text("Still have it")
                        .lineLimit(1)
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.green)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(Color.green.opacity(0.3), in: RoundedRectangle(cornerRadius: 10))
                }
                .buttonStyle(.plain)

                Button(action: onRemove) {
                    Text("Remove")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.red)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(Color.red.opacity(0.3), in: RoundedRectangle(cornerRadius: 10))
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 14)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(Color(.secondarySystemGroupedBackground))
        )
    }
}

// MARK: - Alerts View

struct AlertView: View {
    
    @Environment(FridgeInventoryViewModel.self) var fridgeData
    @Environment(UserData.self) var userData

    var body: some View {
        
        VStack(spacing: 0) {
            
            HStack {
                Spacer()
                Spacer()
                
                Text("Alerts")
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
                    LazyVStack(spacing: 20) {

                        // MARK: Expiring Soon Section
                        Section {
                            if fridgeData.expiringSoonItems.isEmpty {
                                emptyStateCard(
                                    icon: "checkmark.seal.fill",
                                    color: .green,
                                    title: "All clear!",
                                    subtitle: "No items are expiring soon."
                                )
                            } else {
                                VStack(spacing: 10) {
                                    ForEach(fridgeData.expiringSoonItems) { item in
                                        ExpiringItemCard(item: item) {
                                            withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                                                fridgeData.removeItem(id: item.id)
                                            }
                                        }
                                        .transition(.asymmetric(
                                            insertion: .opacity.combined(with: .move(edge: .trailing)),
                                            removal: .opacity.combined(with: .move(edge: .leading))
                                        ))
                                    }
                                }
                            }
                        } header: {
                            sectionHeader(
                                icon: "exclamationmark.triangle.fill",
                                title: "Expiring Soon",
                                count: fridgeData.expiringSoonItems.count,
                                accentColor: .orange
                            )
                        }

                        // MARK: Check-In Section
                        Section {
                            if fridgeData.checkInItems.isEmpty {
                                emptyStateCard(
                                    icon: "tray.2.fill",
                                    color: .blue,
                                    title: "Nothing to check",
                                    subtitle: "All items have been confirmed."
                                )
                            } else {
                                VStack(spacing: 10) {
                                    ForEach(fridgeData.checkInItems) { item in
                                        StillHaveCard(item: item) {
                                            withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                                                fridgeData.dismissCheckIn(id: item.id)
                                            }
                                        } onRemove: {
                                            Task {
                                                
                                                let success = try await APIManager.shared.deletePantryItem(id: item.item_id)
                                                if success {
                                                    
                                                    withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                                                        fridgeData.removeItem(id: item.id)
                                                    }
                                                    
                                                }
                                            }
                                            
                                        }
                                        .transition(.asymmetric(
                                            insertion: .opacity.combined(with: .move(edge: .trailing)),
                                            removal: .opacity.combined(with: .move(edge: .leading))
                                        ))
                                    }
                                }
                            }
                        } header: {
                            sectionHeader(
                                icon: "questionmark.circle.fill",
                                title: "Still in your fridge?",
                                count: fridgeData.checkInItems.count,
                                accentColor: .blue
                            )
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.bottom, 24)
                }
                .navigationTitle("Alerts")
                .navigationBarTitleDisplayMode(.large)
                .navigationBarHidden(true)
            }
        }
        
    }

    // MARK: - Helper Views

    @ViewBuilder
    private func sectionHeader(icon: String, title: String, count: Int, accentColor: Color) -> some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .foregroundColor(accentColor)
                .font(.system(size: 14, weight: .semibold))
            Text(title)
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(.primary)
            Spacer()
            if count > 0 {
                Text("\(count)")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(.white)
                    .frame(minWidth: 20, minHeight: 20)
                    .background(accentColor)
                    .clipShape(Capsule())
            }
        }
        .padding(.horizontal, 2)
        .padding(.vertical, 10)
    }

    @ViewBuilder
    private func emptyStateCard(icon: String, color: Color, title: String, subtitle: String) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 26))
                .foregroundColor(color)
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(.primary)
                Text(subtitle)
                    .font(.system(size: 13))
                    .foregroundColor(.secondary)
            }
            Spacer()
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(Color(.secondarySystemGroupedBackground))
        )
    }
}

// MARK: - Preview

#Preview {
    AlertView()
}
