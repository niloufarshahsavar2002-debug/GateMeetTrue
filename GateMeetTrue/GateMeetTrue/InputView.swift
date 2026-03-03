import SwiftUI

// MARK: - CONSTANTS
let bgColor = Color(red: 168/255, green: 200/255, blue: 220/255)

// MARK: - BACKGROUND DESIGN (TOP + CENTER + BOTTOM SUPPORT)
struct BackgroundDesign<BottomContent: View, CenterContent: View, TopContent: View>: View {
    var bottomContent: () -> BottomContent
    var centerContent: () -> CenterContent
    var topContent: () -> TopContent

    // Designated initializer with all three content areas
    init(
        @ViewBuilder bottomContent: @escaping () -> BottomContent,
        @ViewBuilder centerContent: @escaping () -> CenterContent,
        @ViewBuilder topContent: @escaping () -> TopContent
    ) {
        self.bottomContent = bottomContent
        self.centerContent = centerContent
        self.topContent = topContent
    }

    // Convenience initializer when no center content is provided
    init(
        @ViewBuilder bottomContent: @escaping () -> BottomContent,
        @ViewBuilder topContent: @escaping () -> TopContent
    ) where CenterContent == EmptyView {
        self.bottomContent = bottomContent
        self.centerContent = { EmptyView() }
        self.topContent = topContent
    }

    // Convenience initializer when no top content is provided
    init(
        @ViewBuilder bottomContent: @escaping () -> BottomContent,
        @ViewBuilder centerContent: @escaping () -> CenterContent
    ) where TopContent == EmptyView {
        self.bottomContent = bottomContent
        self.centerContent = centerContent
        self.topContent = { EmptyView() }
    }

    // Convenience initializer when only bottom content is provided
    init(
        @ViewBuilder bottomContent: @escaping () -> BottomContent
    ) where CenterContent == EmptyView, TopContent == EmptyView {
        self.bottomContent = bottomContent
        self.centerContent = { EmptyView() }
        self.topContent = { EmptyView() }
    }

    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .topLeading) {
                bgColor.ignoresSafeArea()

                // Clouds
                ZStack {
                    AnimatedCloud(y: 110, width: 180, scale: 1.0, speed: 28, opacity: 0.95)
                    AnimatedCloud(y: geometry.size.height * 0.22, width: 150, scale: 1.0, speed: 34, opacity: 0.9, direction: .rightToLeft)
                    AnimatedCloud(y: 70, width: 140, scale: 1.0, speed: 30, opacity: 0.92)
                    AnimatedCloud(y: geometry.size.height * 0.36, width: 200, scale: 1.0, speed: 36, opacity: 0.88, direction: .rightToLeft)
                }
                .allowsHitTesting(false)

                // Airplane
                MinimalAirplane(
                    startY: geometry.size.height * 0.14,
                    endY: geometry.size.height * 0.28,
                    arcHeight: geometry.size.height * 0.10,
                    speed: 14,
                    size: 64
                )
                .allowsHitTesting(false)

                // CENTER CONTENT (LOGO)
                centerContent()

                // Bottom white circle
                Circle()
                    .fill(Color.white)
                    .frame(
                        width: geometry.size.width * 1.6,
                        height: geometry.size.width * 1.6
                    )
                    .position(
                        x: geometry.size.width * 0.5,
                        y: geometry.size.height * 1.02
                    )

                // Bottom content
                VStack {
                    Spacer()
                    bottomContent()
                        .padding(.horizontal, 28)
                        .padding(.bottom, max(geometry.safeAreaInsets.bottom, 24))
                }

                // Top content pinned to top-leading safe area
                topContent()
                    .padding(.top, max(geometry.safeAreaInsets.top, 12))
                    .padding(.leading, 16)
            }
        }
    }
}

// MARK: - CLOUD ANIMATION
struct AnimatedCloud: View {
    enum Direction { case leftToRight, rightToLeft }
    var y: CGFloat
    var width: CGFloat
    var scale: CGFloat
    var speed: Double
    var opacity: Double
    var direction: Direction = .leftToRight
    var gapFactor: CGFloat = 0.35

    @State private var offsetX: CGFloat = 0
    @State private var driftPhase: CGFloat = 0

    var body: some View {
        GeometryReader { geo in
            let screenWidth = geo.size.width
            let step = screenWidth + gapFactor * screenWidth

            ZStack {
                cloud
                    .opacity(opacity)
                    .scaleEffect(scale + 0.02 * sin(driftPhase))
                    .offset(x: baseOffset(step), y: y + 3 * sin(driftPhase))

                cloud
                    .opacity(opacity)
                    .scaleEffect(scale + 0.02 * sin(driftPhase))
                    .offset(x: baseOffset(step) + directional(step), y: y + 3 * sin(driftPhase))
            }
            .onAppear {
                animate(step)
                withAnimation(.easeInOut(duration: 3.5).repeatForever(autoreverses: true)) {
                    driftPhase = .pi
                }
            }
        }
    }
    private func animate(_ step: CGFloat) {
        withAnimation(.linear(duration: speed).repeatForever(autoreverses: false)) {
            offsetX = directional(step)
        }
    }

    private func baseOffset(_ step: CGFloat) -> CGFloat { offsetX - step / 2 }
    private func directional(_ value: CGFloat) -> CGFloat {
        direction == .leftToRight ? value : -value
    }

    private var cloud: some View {
        Image(systemName: "cloud.fill")
            .resizable()
            .scaledToFit()
            .frame(width: width)
            .foregroundColor(.white)
            .shadow(color: .black.opacity(0.12), radius: 6, x: 0, y: 5)
    }
}

// MARK: - AIRPLANE
struct MinimalAirplane: View {
    enum Direction { case leftToRight, rightToLeft }
    var startY: CGFloat
    var endY: CGFloat
    var arcHeight: CGFloat
    var speed: Double
    var direction: Direction = .leftToRight
    var size: CGFloat = 64

    @State private var t: CGFloat = 0

    var body: some View {
        GeometryReader { geo in
            let W = geo.size.width
            let H = geo.size.height

            let p0 = CGPoint(x: -0.1 * W, y: startY)
            let p3 = CGPoint(x: 1.1 * W, y: endY)
            let c1 = CGPoint(x: 0.25 * W, y: (startY + endY)/2 - arcHeight)
            let c2 = CGPoint(x: 0.75 * W, y: (startY + endY)/2 + arcHeight)

            let point = bezierPoint(t, p0, c1, c2, p3)
            let tangent = bezierTangent(t, p0, c1, c2, p3)
            let angle = atan2(tangent.y, tangent.x) * 180 / .pi

            Image(systemName: "airplane")
                .resizable()
                .scaledToFit()
                .frame(width: size)
                .foregroundColor(.white.opacity(0.95))
                .rotationEffect(.degrees(angle))
                .position(point)
                .onAppear {
                    withAnimation(.linear(duration: speed).repeatForever(autoreverses: false)) {
                        t = 1
                    }
                }
        }
    }

    private func bezierPoint(_ t: CGFloat, _ p0: CGPoint, _ c1: CGPoint, _ c2: CGPoint, _ p3: CGPoint) -> CGPoint {
        let u = 1 - t
        return CGPoint(
            x: u*u*u*p0.x + 3*u*u*t*c1.x + 3*u*t*t*c2.x + t*t*t*p3.x,
            y: u*u*u*p0.y + 3*u*u*t*c1.y + 3*u*t*t*c2.y + t*t*t*p3.y
        )
    }

    private func bezierTangent(_ t: CGFloat, _ p0: CGPoint, _ c1: CGPoint, _ c2: CGPoint, _ p3: CGPoint) -> CGPoint {
        let u = 1 - t
        return CGPoint(
            x: 3*u*u*(c1.x - p0.x) + 6*u*t*(c2.x - c1.x) + 3*t*t*(p3.x - c2.x),
            y: 3*u*u*(c1.y - p0.y) + 6*u*t*(c2.y - c1.y) + 3*t*t*(p3.y - c2.y)
        )
    }
}

// NOTE: ContinueButton was removed here to avoid duplicate with OnboardingScreens.swift
// If you prefer to keep it in this file instead, remove the one from OnboardingScreens.swift.

// MARK: - FIRST SCREEN (LOGO CENTERED)
struct LoginView: View {
    @State private var userName = ""
    var onContinue: () -> Void = {}
    var onBack: () -> Void = {}
    var body: some View {
        BackgroundDesign(
            bottomContent: {
                VStack(spacing: 20) {
                    Text("What's your name?")
                        .font(.headline)
                        .foregroundColor(.gray)
                    
                    TextField("Name", text: $userName)
                        .padding()
                        .foregroundColor(.gray)
                        .background(Color(UIColor.systemGray6))
                        .cornerRadius(15)
                        .overlay(
                            RoundedRectangle(cornerRadius: 15)
                                .stroke(Color.gray, lineWidth: 1.5)
                        )
                    
                    HStack {
                        Spacer()
                        ContinueButton { onContinue() }
                    }
                }
            },
           
     centerContent: {
                Image("logo1024")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 220)
                    .shadow(color: .black.opacity(0.12), radius: 10, x: 0, y: 6)
            },
            topContent: {
                BackButton(action: onBack)
            }
        )
    }
}
