import SwiftUI

@main
struct MovieAApp: App {
    @State private var isLoggedIn = false

    var body: some Scene {
        WindowGroup {
            Group {
                if isLoggedIn {
                    NavigationStack {
                        MoviesCenter()
                    }
                } else {
                    SignIn(isLoggedIn: $isLoggedIn)
                }
            }
        }
    }
}
