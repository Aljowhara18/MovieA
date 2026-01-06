//
//  MovieAApp.swift
//  MovieA
//
//  Created by Jojo on 31/12/2025.
//

import SwiftUI
import SwiftData
/*
@main
struct MovieAApp: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Item.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            SignIn()
        }
        .modelContainer(sharedModelContainer)
    }
}
*/

@main
struct MovieAApp: App {
    // حالة للتحكم في أي شاشة تظهر أولاً
    @State private var isLoggedIn = false

    var body: some Scene {
        WindowGroup {
            Group {
                if isLoggedIn {
                    // إذا سجل دخول، نفتح الموفيز سنتر داخل ستاك خاص بها
                    NavigationStack {
                        MoviesCenter()
                    }
                } else {
                    // إذا لم يسجل، تظهر صفحة السين إن فقط
                    // نمرر الـ Binding لكي نغير الحالة من داخل صفحة الـ SignIn
                    SignIn(isLoggedIn: $isLoggedIn)
                }
            }
        }
    }
}
