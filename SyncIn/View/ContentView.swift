import SwiftUI

struct ContentView: View {
    @AppStorage("hasSeenOnboarding") private var hasSeenOnboarding = false
    @State private var isLoggedOut = false  // Track logout status

    var body: some View {
        NavigationStack {
            if !hasSeenOnboarding {
                OnboardingView(showOnboarding: $hasSeenOnboarding)
            } else if isLoggedOut {
                LoginView()  // Pass logout state
            } else {
                CustomTabView(isLoggedOut: $isLoggedOut) // Main app UI
            }
        }
        .animation(.easeInOut, value: hasSeenOnboarding)
        .animation(.easeInOut, value: isLoggedOut)
    }
}

#Preview {
    ContentView()
}


