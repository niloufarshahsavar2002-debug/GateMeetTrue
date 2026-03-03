import SwiftUI

struct SplashView: View {
    // Reuse the same sky color you have elsewhere
    private let bgColor = Color(red: 168/255, green: 200/255, blue: 220/255)

    @State private var appear = false

    var body: some View {
        ZStack {
            bgColor.ignoresSafeArea()
            
            // Your awesome GM Logo
            Image("logo1024")
                .resizable()
                .scaledToFit()
                .frame(width: 220, height: 220)
                .shadow(color: .black.opacity(0.15), radius: 10, x: 0, y: 5)
                // These react to the 'appear' state
                .opacity(appear ? 1 : 0.0)
                .scaleEffect(appear ? 1.0 : 0.90) // Slightly increased the scale drop for a better pop!
        }
        .onAppear {
            // Using withAnimation here guarantees it fires correctly every time
            withAnimation(.easeOut(duration: 0.5)) {
                appear = true
            }
        }
    }
}

#Preview {
    SplashView()
}
