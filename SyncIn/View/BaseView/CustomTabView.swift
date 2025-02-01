import SwiftUI

// MARK: - Custom Tab View
struct CustomTabView: View {
    enum Tab {
        case home, chat, map, settings
    }
    
    @State private var activeTab: Tab = .home
    @State private var isEditingProfile = false
    @Binding var isLoggedOut: Bool  // Bind logout state
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Main Content (Takes Full Space)
                ZStack {
                    switch activeTab {
                    case .home:
                        HomeView()
                    case .chat:
                        ChatView()
                    case .map:
                        MapView()
                    case .settings:
                        SettingsView(isEditingProfile: $isEditingProfile, isLoggedOut: $isLoggedOut)
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                
                // Custom Tab Bar (Fixed at Bottom)
                HStack {
                    TabButton(icon: "house.fill", label: "Home", isActive: activeTab == .home) {
                        activeTab = .home
                    }
                    TabButton(icon: "bubble.left.fill", label: "Chat", isActive: activeTab == .chat) {
                        activeTab = .chat
                    }
                    TabButton(icon: "map.fill", label: "Map", isActive: activeTab == .map) {
                        activeTab = .map
                    }
                    TabButton(icon: "gearshape.fill", label: "Settings", isActive: activeTab == .settings) {
                        activeTab = .settings
                    }
                }
                .padding(.vertical)
                .frame(height: 70)
                .background(GlassmorphismBackground())
                .cornerRadius(20)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity) // Ensures full-screen
            .ignoresSafeArea(.keyboard, edges: .bottom) // Prevent keyboard from pushing UI
        }
    }
    
    // MARK: - Tab Button
    struct TabButton: View {
        let icon: String
        let label: String
        let isActive: Bool
        let action: () -> Void
        
        var body: some View {
            Button(action: action) {
                VStack {
                    Image(systemName: icon)
                        .font(.system(size: 24))
                        .foregroundColor(isActive ? .white : .gray)
                    Text(label)
                        .font(.caption)
                        .foregroundColor(isActive ? .white : .gray)
                }
                .padding(.all)
                .frame(maxWidth: .infinity)
                .background(
                    isActive ? AnyView(LinearGradient(
                        gradient: Gradient(colors: [.blue, .yellow]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )) : AnyView(Color.clear)
                )
                .cornerRadius(12)
            }
        }
    }
    
    // MARK: - Glassmorphism Background
    private struct GlassmorphismBackground: View {
        var body: some View {
            VisualEffectBlur()
                .background(Color.white.opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: 20))
                .shadow(radius: 10)
        }
    }
}

// MARK: - VisualEffect Blur
struct VisualEffectBlur: UIViewRepresentable {
    func makeUIView(context: Context) -> UIVisualEffectView {
        let blurEffect = UIBlurEffect(style: .systemUltraThinMaterial)
        let blurView = UIVisualEffectView(effect: blurEffect)
        return blurView
    }
    
    func updateUIView(_ uiView: UIVisualEffectView, context: Context) {}
}

// MARK: - Preview
#Preview {
    CustomTabView(isLoggedOut: .constant(false))
}
