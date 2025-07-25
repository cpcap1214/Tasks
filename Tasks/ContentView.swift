//
//  ContentView.swift
//  Tasks
//
//  Created by 鍾心哲 on 2025/7/24.
//

import SwiftUI

struct ContentView: View {
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            // Dashboard Tab
            DashboardView()
                .tabItem {
                    Image(systemName: selectedTab == 0 ? "house.fill" : "house")
                    Text("專注")
                }
                .tag(0)
            
            // All Tasks Tab (replacing Stats)
            AllTasksView()
                .tabItem {
                    Image(systemName: selectedTab == 1 ? "list.bullet" : "list.bullet")
                    Text("所有任務")
                }
                .tag(1)
            
            // Settings Tab
            SettingsView()
                .tabItem {
                    Image(systemName: selectedTab == 2 ? "gearshape.fill" : "gearshape")
                    Text("設定")
                }
                .tag(2)
        }
        .accentColor(AppConstants.Colors.accent)
        .onAppear {
            // Configure tab bar appearance following DESIGN.md
            let appearance = UITabBarAppearance()
            appearance.configureWithOpaqueBackground()
            appearance.backgroundColor = UIColor(AppConstants.Colors.background)
            
            // Selected item appearance
            appearance.stackedLayoutAppearance.selected.titleTextAttributes = [
                .foregroundColor: UIColor(AppConstants.Colors.accent)
            ]
            appearance.stackedLayoutAppearance.selected.iconColor = UIColor(AppConstants.Colors.accent)
            
            // Normal item appearance
            appearance.stackedLayoutAppearance.normal.titleTextAttributes = [
                .foregroundColor: UIColor(AppConstants.Colors.secondaryText)
            ]
            appearance.stackedLayoutAppearance.normal.iconColor = UIColor(AppConstants.Colors.secondaryText)
            
            UITabBar.appearance().standardAppearance = appearance
            UITabBar.appearance().scrollEdgeAppearance = appearance
        }
    }
    

}

#Preview {
    ContentView()
}
