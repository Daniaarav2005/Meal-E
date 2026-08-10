//
//  Home.swift
//  SmartFridge
//
//  Created by Michael Pancras on 2/21/26.
//

import SwiftUI

@main
struct SmartFridgeApp: App {
    
    @State var fridgeData: FridgeInventoryViewModel = FridgeInventoryViewModel(pantry: [])
    
    @State var user: UserData = UserData(user: User(name: "", age: 0, household_size: 0, meals_per_day: 0, macro_targets: MacroTargets(calories: 0, protein: 0), dietary_restriction: "", allergies: [], cooking_proficiency: "", cuisine_preferences: []))
    
    @State var fetchError = false
    
    @State var mealPlan: MealPlan = MealPlan(response: MealPlanResponse(plan: []))
    
    init() {
     
        let appearance = UINavigationBarAppearance()
        appearance.largeTitleTextAttributes = [.foregroundColor: UIColor(hex: "1B4332")]
        appearance.titleTextAttributes = [.foregroundColor: UIColor(hex: "1B4332")]
        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = appearance
        
    }
    
    var body: some Scene {
        WindowGroup {
            if fetchError {
                Text("Error fetching data...")
            } else {
                OnboardingView()
                    .environment(fridgeData)
                    .environment(user)
                    .environment(mealPlan)
                    .tint(Color(hex: "1B4332"))
                    .onAppear {
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
                                    fetchError = true
                                } else {
                                    withAnimation(.easeIn) {
                                        user = UserData(user: userProfile!)
                                    }
                                }
                                
                            } catch {
                                print(error.localizedDescription)
                                fetchError = true
                            }
                            
                        }
                        
                        Task {
                            do {
                                
                                if let data = try await APIManager.shared.getMealPlan(generate: false) {
                                    self.mealPlan = MealPlan(response: data)
                                } else {
                                    print("NO DATA FOR MEAL PREP")
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
