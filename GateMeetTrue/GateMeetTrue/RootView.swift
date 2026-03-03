import SwiftUI

struct RootView: View {
    @State private var showSplash = true

    var body: some View {
        ZStack {
            ContentView()
                .opacity(showSplash ? 0 : 1)
            if showSplash {
                SplashView()
                    .transition(.opacity)
            }
        }
        .onAppear {
            // Hide the splash after ~1 second
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                withAnimation(.easeInOut(duration: 0.35)) {
                    showSplash = false
                }
            }
        }
    }
}
