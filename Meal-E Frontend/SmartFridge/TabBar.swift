//
//  Home.swift
//  SmartFridge
//
//  Created by Michael Pancras on 2/21/26.
//

import SwiftUI

struct TabBar: View {
    
    @State var isLoading: Bool = true
    
    @State var selection = 0
    
    var body: some View {
        
        TabView(selection: $selection) {
            Tab("Home", systemImage: "house", value: 0) {
                NavigationStack {
                    Home(selection: $selection)
                }
            }

            Tab("Pantry", systemImage: "cube.box.fill", value: 1) {
                NavigationStack {
                    InventoryView()
                }
            }

            Tab("Meal Prep", systemImage: "doc.append", value: 2) {
                NavigationStack {
                    MealPlanView()
                }
            }

            Tab("Alerts", systemImage: "bell.fill", value: 3) {
                NavigationStack {
                    AlertView()
                }
            }

            Tab("Settings", systemImage: "gear", value: 4) {
                NavigationStack {
                    SettingsView()
                }
            }
        }
        .navigationBarBackButtonHidden(true)
    }
}

#Preview {
    TabBar()
        .tint(.green)
}
