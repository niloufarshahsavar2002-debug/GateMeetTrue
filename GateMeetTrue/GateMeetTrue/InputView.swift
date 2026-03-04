import SwiftUI

// MARK: - CONSTANTS
let bgColor = Color(red: 168/255, green: 200/255, blue: 220/255)

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

// MARK: - FIRST SCREEN (LOGO CENTERED)
struct LoginView: View {
    @State private var userName = ""
    var onContinue: () -> Void = {}
    var onBack: () -> Void = {}
    var body: some View {
        // CHANGED from BackgroundDesign to OnboardingBackground to perfectly match the other screens!
        OnboardingBackground(
            bottomContent: {
                VStack(alignment: .leading, spacing: 16) {
                    Text("What's your name?")
                        .font(.headline)
                        .foregroundColor(.black)
                    
                    TextField("Name", text: $userName)
                        .padding()
                        .foregroundColor(.black) // Input text is now black to match!
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
                // To prevent the logo from overlapping with the raised inputs, we shift it up slightly
                VStack {
                    Image("logo1024")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 160)
                        .shadow(color: .black.opacity(0.12), radius: 10, x: 0, y: 6)
                    Spacer()
                }
                .padding(.top, 140) // Pushes logo into the upper sky
            },
            topContent: {
                BackButton(action: onBack)
            }
        )
    }
}
