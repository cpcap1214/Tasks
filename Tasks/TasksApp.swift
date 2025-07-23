//
//  TasksApp.swift
//  Tasks
//
//  Created by 鍾心哲 on 2025/7/24.
//

import SwiftUI

@main
struct TasksApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .onAppear {
                    // Load sample data for development/testing
                    // Remove this in production
                    #if DEBUG
                    SampleData.setupInitialData()
                    #endif
                }
        }
    }
}
