import SwiftUI

struct MainTabView: View {
    @ObservedObject var ckService: CloudKitService
    
    var appleUserID: String
    var userName: String
    var userAge: String
    var userGender: String
    var userLanguages: String
    var userInterests: String
    var userImage: Data?
    var userAirport: String
    var userDepartureTime: Date
    
    @State private var selectedTab = 1
    @State private var isRadarMatched = false
    @State private var selectedChatTarget: Target? = nil
    
    var body: some View {
        TabView(selection: $selectedTab) {
            HomeProfileView(
                userName: userName,
                userAge: userAge,
                userGender: userGender,
                userLanguages: userLanguages,
                userImage: userImage,
                userAirport: userAirport
            )
            .tabItem { Label("Profile", systemImage: "person.crop.circle") }
            .tag(0)
            
            Group {
                if isRadarMatched {
                    WindowCarouselView(
                        targets: ckService.downloadedTargets,
                        onRestart: {
                            isRadarMatched = false
                            ckService.startScanning(myAirport: userAirport, myTime: userDepartureTime, myUserID: appleUserID)
                        },
                        onChatRequested: { target in
                            selectedChatTarget = target
                            selectedTab = 2
                        }
                    )
                } else {
                    RadarView(
                        ckService: ckService,
                        appleUserID: appleUserID,
                        userAirport: userAirport,
                        userDepartureTime: userDepartureTime,
                        onFound: { isRadarMatched = true }
                    )
                }
            }
            .tabItem { Label("Radar", systemImage: "dot.radiowaves.left.and.right") }
            .tag(1)
            
            ChatView(target: selectedChatTarget, isOnline: true)
                .tabItem { Label("Chat", systemImage: "message.fill") }
                .tag(2)
        }
        .accentColor(.blue)
    }
}

// MARK: - Premium Boarding Pass Profile View

struct HomeProfileView: View {
    var userName: String
    var userAge: String
    var userGender: String
    var userLanguages: String
    var userImage: Data?
    var userAirport: String
    
    @State private var cloudOffset1: CGFloat = 0
    @State private var cloudOffset2: CGFloat = 0
    
    var body: some View {
        ZStack {
            // 1. Dynamic Sky Background
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(red: 100/255, green: 170/255, blue: 220/255),
                    Color(red: 168/255, green: 200/255, blue: 220/255)
                ]),
                startPoint: .top,
                endPoint: .bottom
            )
            .edgesIgnoringSafeArea(.all)
            
            // 2. Drifting Clouds
            GeometryReader { geo in
                Image(systemName: "cloud.fill")
                    .resizable().scaledToFit().frame(width: 160)
                    .foregroundColor(.white.opacity(0.4))
                    .offset(x: cloudOffset1, y: geo.size.height * 0.08)
                    .onAppear {
                        cloudOffset1 = -200
                        withAnimation(.linear(duration: 40).repeatForever(autoreverses: false)) {
                            cloudOffset1 = geo.size.width + 200
                        }
                    }
                
                Image(systemName: "cloud.fill")
                    .resizable().scaledToFit().frame(width: 220)
                    .foregroundColor(.white.opacity(0.3))
                    .offset(x: cloudOffset2, y: geo.size.height * 0.22)
                    .onAppear {
                        cloudOffset2 = geo.size.width + 200
                        withAnimation(.linear(duration: 55).repeatForever(autoreverses: false)) {
                            cloudOffset2 = -300
                        }
                    }
            }
            
            // 3. The Profile Card
            VStack {
                Text("Passenger Profile")
                    .font(.system(size: 22, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                    .padding(.top, 60)
                    .padding(.bottom, 60)
                
                ZStack(alignment: .top) {
                    // The White Card
                    VStack(spacing: 0) {
                        Spacer().frame(height: 70) // Room for the avatar to overlap
                        
                        Text(userName.isEmpty ? "User Name" : userName)
                            .font(.system(size: 28, weight: .bold, design: .rounded))
                            .foregroundColor(.black)
                        
                        Text("\(userAge.isEmpty ? "-" : userAge) yrs • \(userGender.isEmpty ? "-" : userGender)")
                            .font(.headline)
                            .foregroundColor(.gray)
                            .padding(.top, 4)
                        
                        // Dashed "Ticket" Divider
                        TicketDivider()
                            .stroke(style: StrokeStyle(lineWidth: 1.5, dash: [8]))
                            .foregroundColor(.gray.opacity(0.3))
                            .frame(height: 1)
                            .padding(.vertical, 28)
                            .padding(.horizontal, 30)
                        
                        // Info Rows
                        VStack(spacing: 24) {
                            ProfileInfoRow(
                                icon: "airplane.departure",
                                title: "Departing Airport",
                                value: userAirport.isEmpty ? "Not set" : userAirport
                            )
                            
                            ProfileInfoRow(
                                icon: "bubble.left.and.bubble.right.fill",
                                title: "Languages",
                                value: userLanguages.isEmpty ? "Not set" : userLanguages
                            )
                        }
                        .padding(.horizontal, 30)
                        
                        Spacer()
                        
                        // Edit Profile Button
                        Button(action: {
                            // Action for future edit profile feature
                        }) {
                            Text("Edit Profile")
                                .font(.headline)
                                .foregroundColor(.blue)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                                .background(Color.blue.opacity(0.1))
                                .cornerRadius(16)
                        }
                        .padding(.horizontal, 30)
                        .padding(.bottom, 30)
                    }
                    .frame(width: 340, height: 480)
                    .background(Color.white)
                    .cornerRadius(35)
                    .shadow(color: .black.opacity(0.15), radius: 20, x: 0, y: 10)
                    
                    // The Pop-Out Avatar
                    ZStack {
                        Circle()
                            .fill(Color.white)
                            .frame(width: 116, height: 116)
                            .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)
                        
                        if let data = userImage, let uiImage = UIImage(data: data) {
                            Image(uiImage: uiImage)
                                .resizable()
                                .scaledToFill()
                                .frame(width: 106, height: 106)
                                .clipShape(Circle())
                        } else {
                            Circle()
                                .fill(Color(UIColor.systemGray6))
                                .frame(width: 106, height: 106)
                                .overlay(
                                    Image(systemName: "person.fill")
                                        .font(.system(size: 44))
                                        .foregroundColor(.gray)
                                )
                        }
                    }
                    .offset(y: -58) // Pulls the avatar exactly halfway out of the top of the card
                }
                
                Spacer()
            }
        }
    }
}

// Subcomponents for the Profile View
struct TicketDivider: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: 0, y: 0))
        path.addLine(to: CGPoint(x: rect.width, y: 0))
        return path
    }
}

struct ProfileInfoRow: View {
    var icon: String
    var title: String
    var value: String
    
    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(Color.blue.opacity(0.1))
                    .frame(width: 48, height: 48)
                Image(systemName: icon)
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(.blue)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(.gray)
                Text(value)
                    .font(.system(size: 17, weight: .bold, design: .rounded))
                    .foregroundColor(.black)
            }
            Spacer()
        }
    }
}

// MARK: - Message Data Model
struct Message: Identifiable {
    let id = UUID()
    let isMe: Bool
    let text: String
    let time: String
}

// MARK: - Modern Chat Interface
struct ChatView: View {
    var target: Target?
    var isOnline: Bool
    
    @State private var composerText: String = ""
    @State private var messages: [Message] = []
    
    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 12) {
                ZStack(alignment: .bottomTrailing) {
                    if let t = target, let data = t.profileImageData, let uiImage = UIImage(data: data) {
                        Image(uiImage: uiImage)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 46, height: 46)
                            .clipShape(Circle())
                    } else {
                        Circle()
                            .fill(Color(UIColor.systemGray5))
                            .frame(width: 46, height: 46)
                            .overlay(Image(systemName: "person.fill").foregroundColor(.gray))
                    }
                    
                    if isOnline {
                        Circle()
                            .fill(Color.green)
                            .frame(width: 14, height: 14)
                            .overlay(Circle().stroke(Color.white, lineWidth: 2))
                            .offset(x: 2, y: 2)
                    }
                }
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(target?.name ?? "Giulia")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundColor(.black)
                    Text(isOnline ? "Active now" : "Offline")
                        .font(.system(size: 13))
                        .foregroundColor(isOnline ? .green : .gray)
                }
                Spacer()
            }
            .padding(.horizontal)
            .padding(.vertical, 12)
            .background(Color.white)
            .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 5)
            .zIndex(1)
            
            ScrollView {
                ScrollViewReader { proxy in
                    VStack(spacing: 16) {
                        if messages.isEmpty {
                            VStack {
                                Spacer(minLength: 150)
                                Image(systemName: "bubble.left.and.bubble.right")
                                    .font(.system(size: 40))
                                    .foregroundColor(Color(UIColor.systemGray4))
                                    .padding(.bottom, 8)
                                Text("No messages yet.")
                                    .font(.headline)
                                    .foregroundColor(.gray)
                                Text("Say hi to start the conversation!")
                                    .font(.subheadline)
                                    .foregroundColor(Color(UIColor.systemGray2))
                            }
                            .frame(maxWidth: .infinity)
                        } else {
                            Text("Today")
                                .font(.caption)
                                .fontWeight(.medium)
                                .foregroundColor(.gray)
                                .padding(.top, 16)
                                .padding(.bottom, 8)
                            
                            ForEach(messages) { message in
                                ChatBubble(message: message)
                            }
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.bottom, 20)
                    .onChange(of: messages.count) { _ in
                        if let lastMessage = messages.last {
                            withAnimation {
                                proxy.scrollTo(lastMessage.id, anchor: .bottom)
                            }
                        }
                    }
                }
            }
            .background(Color(UIColor.systemGroupedBackground))
            
            VStack(spacing: 0) {
                Divider()
                HStack(alignment: .center, spacing: 12) {
                    HStack {
                        TextField("Message...", text: $composerText)
                            .font(.system(size: 16))
                            .padding(.horizontal, 16)
                            .padding(.vertical, 10)
                    }
                    .background(Color(UIColor.systemGray6))
                    .clipShape(Capsule())
                    .overlay(Capsule().stroke(Color(UIColor.systemGray5), lineWidth: 1))
                    
                    if composerText.trimmingCharacters(in: .whitespaces).isEmpty {
                        Button(action: {}) {
                            Image(systemName: "mic")
                                .font(.system(size: 22))
                                .foregroundColor(.gray)
                        }
                    } else {
                        Button(action: sendMessage) {
                            Image(systemName: "arrow.up.circle.fill")
                                .font(.system(size: 32))
                                .foregroundColor(.blue)
                        }
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(Color.white)
            }
        }
    }
    
    private func sendMessage() {
        guard !composerText.trimmingCharacters(in: .whitespaces).isEmpty else { return }
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        let timeString = formatter.string(from: Date())
        withAnimation(.spring()) {
            messages.append(Message(isMe: true, text: composerText, time: timeString))
        }
        composerText = ""
    }
}

struct ChatBubble: View {
    var message: Message
    var body: some View {
        HStack {
            if message.isMe { Spacer() }
            VStack(alignment: message.isMe ? .trailing : .leading, spacing: 4) {
                Text(message.text)
                    .font(.system(size: 16))
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .background(message.isMe ? Color.blue : Color.white)
                    .foregroundColor(message.isMe ? .white : .black)
                    .clipShape(ChatBubbleShape(isMe: message.isMe))
                    .shadow(color: .black.opacity(0.04), radius: 3, x: 0, y: 2)
                
                HStack(spacing: 4) {
                    Text(message.time)
                        .font(.system(size: 11))
                        .foregroundColor(.gray)
                    if message.isMe {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 10))
                            .foregroundColor(.blue)
                    }
                }
                .padding(.horizontal, 4)
            }
            if !message.isMe { Spacer() }
        }
    }
}

struct ChatBubbleShape: Shape {
    var isMe: Bool
    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: [.topLeft, .topRight, isMe ? .bottomLeft : .bottomRight],
            cornerRadii: CGSize(width: 18, height: 18)
        )
        return Path(path.cgPath)
    }
}

// MARK: - Minimal Animated Radar View
struct RadarView: View {
    @ObservedObject var ckService: CloudKitService
    var appleUserID: String
    var userAirport: String
    var userDepartureTime: Date
    var onFound: () -> Void
    
    @State private var rotationDegree: Double = 0
    @State private var isAnimatingBlips = false
    @State private var pulseScale: CGFloat = 1.0
    @State private var pulseOpacity: Double = 1.0
    
    var body: some View {
        ZStack {
            // 1. Matches the Light Blue sky gradient of the app
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(red: 100/255, green: 170/255, blue: 220/255),
                    Color(red: 168/255, green: 200/255, blue: 220/255)
                ]),
                startPoint: .top,
                endPoint: .bottom
            )
            .edgesIgnoringSafeArea(.all)
            
            // 2. Minimal drifting clouds in background
            GeometryReader { geo in
                Image(systemName: "cloud.fill")
                    .resizable().scaledToFit().frame(width: 140)
                    .foregroundColor(.white.opacity(0.3))
                    .offset(x: geo.size.width * 0.1, y: geo.size.height * 0.15)
                Image(systemName: "cloud.fill")
                    .resizable().scaledToFit().frame(width: 180)
                    .foregroundColor(.white.opacity(0.2))
                    .offset(x: geo.size.width * 0.6, y: geo.size.height * 0.4)
            }
            
            VStack {
                Spacer()
                
                ZStack {
                    // 3. Minimal Frosted Grid Rings
                    ForEach(1..<5, id: \.self) { i in
                        Circle()
                            .stroke(Color.white.opacity(0.4), style: StrokeStyle(lineWidth: 1))
                            .frame(width: CGFloat(i) * 75)
                    }
                    
                    // 4. Subtle Crosshairs
                    Rectangle().fill(Color.white.opacity(0.3)).frame(width: 320, height: 1)
                    Rectangle().fill(Color.white.opacity(0.3)).frame(width: 1, height: 320)
                    
                    if ckService.isSearching {
                        // 5. Minimal White Radar Sweep
                        Circle()
                            .fill(AngularGradient(
                                gradient: Gradient(colors: [Color.white.opacity(0.0), Color.white.opacity(0.4)]),
                                center: .center,
                                startAngle: .degrees(-90),
                                endAngle: .degrees(0)
                            ))
                            .frame(width: 300, height: 300)
                            .rotationEffect(.degrees(rotationDegree))
                            .onAppear {
                                withAnimation(.linear(duration: 3.0).repeatForever(autoreverses: false)) {
                                    rotationDegree = 360
                                }
                            }
                        
                        // 6. Glowing White Passenger Blips
                        Group {
                            Circle().fill(Color.white).frame(width: 10, height: 10)
                                .shadow(color: .white, radius: 4)
                                .offset(x: 60, y: -80)
                            Circle().fill(Color.white).frame(width: 8, height: 8)
                                .shadow(color: .white, radius: 4)
                                .offset(x: -90, y: 40)
                            Circle().fill(Color.white).frame(width: 9, height: 9)
                                .shadow(color: .white, radius: 4)
                                .offset(x: 30, y: 100)
                        }
                        .opacity(isAnimatingBlips ? 1 : 0.3)
                        .animation(.easeInOut(duration: 1.0).repeatForever(), value: isAnimatingBlips)
                        
                    } else {
                        // 7. Found Match Transition
                        Circle()
                            .fill(Color.white.opacity(0.4))
                            .frame(width: 100, height: 100)
                            .scaleEffect(pulseScale)
                            .opacity(pulseOpacity)
                            .onAppear {
                                withAnimation(.easeOut(duration: 1.2).repeatForever(autoreverses: false)) {
                                    pulseScale = 2.5
                                    pulseOpacity = 0.0
                                }
                            }
                        
                        Circle()
                            .fill(Color.white)
                            .frame(width: 80, height: 80)
                            .shadow(color: .white, radius: 15)
                        
                        Image(systemName: "checkmark")
                            .font(.system(size: 34, weight: .bold))
                            .foregroundColor(.blue)
                    }
                    
                    // 8. Minimal Center Hub
                    Circle()
                        .fill(Color.white)
                        .frame(width: 44, height: 44)
                        .shadow(color: .black.opacity(0.1), radius: 5)
                    
                    Image(systemName: "airplane")
                        .font(.system(size: 22))
                        .foregroundColor(.blue)
                }
                .frame(height: 350)
                
                Spacer()
                
                // Typography - Clean and Professional
                VStack(spacing: 8) {
                    Text(ckService.isSearching ? "SEARCHING" : "FOUND")
                        .font(.system(size: 16, weight: .bold, design: .rounded))
                        .tracking(2)
                        .foregroundColor(.white)
                    
                    Text(ckService.isSearching ? "Scanning for nearby passengers..." : "Connection established!")
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.8))
                }
                .padding(.bottom, 60)
            }
        }
        .onAppear {
            isAnimatingBlips = true
            ckService.startScanning(myAirport: userAirport, myTime: userDepartureTime, myUserID: appleUserID)
        }
        .onChange(of: ckService.isSearching) { _, isSearching in
            if !isSearching {
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                    onFound()
                }
            }
        }
    }
}

// MARK: - Airplane Window Swipe Interaction

struct WindowCarouselView: View {
    var targets: [Target]
    var onRestart: () -> Void
    var onChatRequested: (Target) -> Void
    
    @State private var pageIndex: Int = 0
    let cabinColor = Color(red: 238/255, green: 238/255, blue: 242/255)
    
    var body: some View {
        ZStack {
            cabinColor.edgesIgnoringSafeArea(.all)
            
            if targets.isEmpty {
                VStack(spacing: 20) {
                    Image(systemName: "person.slash.fill")
                        .font(.system(size: 60))
                        .foregroundColor(.gray.opacity(0.6))
                    Text("No passengers found nearby.")
                        .font(.headline)
                        .foregroundColor(.gray)
                    Button("Try Again", action: onRestart)
                        .padding()
                        .background(Color.white)
                        .foregroundColor(.blue)
                        .cornerRadius(10)
                        .shadow(radius: 2)
                }
            } else {
                VStack {
                    Spacer()
                    
                    // Single window that stays on screen, but updates its target
                    RealisticAirplaneWindowView(
                        target: targets[pageIndex],
                        onNextUser: {
                            pageIndex = (pageIndex + 1) % targets.count
                        },
                        onPrevUser: {
                            pageIndex = (pageIndex - 1 + targets.count) % targets.count
                        }
                    )
                    
                    Spacer()
                    
                    Text("Pull window shade down to see next passenger")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                        .padding(.bottom, 16)
                    
                    // The "Say Hi" button outside
                    Button(action: {
                        if !targets.isEmpty {
                            onChatRequested(targets[pageIndex])
                        }
                    }) {
                        HStack {
                            Image(systemName: "paperplane.fill")
                            Text("Say Hi to \(targets.isEmpty ? "" : targets[pageIndex].name)")
                                .font(.headline)
                        }
                        .foregroundColor(.white)
                        .padding(.vertical, 16)
                        .frame(maxWidth: .infinity)
                        .background(Color.blue)
                        .clipShape(Capsule())
                        .shadow(color: .blue.opacity(0.3), radius: 8, x: 0, y: 4)
                    }
                    .padding(.horizontal, 40)
                    .padding(.bottom, 24)
                    
                    // Dots indicator
                    HStack(spacing: 8) {
                        ForEach(0..<targets.count, id: \.self) { i in
                            Circle()
                                .fill(i == pageIndex ? Color.blue : Color.gray.opacity(0.4))
                                .frame(width: 8, height: 8)
                        }
                    }
                    .padding(.bottom, 30)
                }
            }
        }
    }
}

// MARK: - Single Realistic Window with Interactive Shade
struct RealisticAirplaneWindowView: View {
    var target: Target
    var onNextUser: () -> Void
    var onPrevUser: () -> Void
    
    // -520 keeps the shade perfectly hidden at the top
    @State private var blindOffset: CGFloat = -520
    
    var body: some View {
        ZStack {
            // 1. The Thick Window Frame
            RoundedRectangle(cornerRadius: 170)
                .fill(Color(red: 245/255, green: 245/255, blue: 250/255))
                .frame(width: 340, height: 540)
                .shadow(color: .black.opacity(0.15), radius: 10, x: 5, y: 5)
                .shadow(color: .white, radius: 10, x: -5, y: -5)
            
            RoundedRectangle(cornerRadius: 160)
                .strokeBorder(Color.gray.opacity(0.2), lineWidth: 4)
                .frame(width: 310, height: 510)
            
            // 2. The Window Glass & Content
            ZStack {
                // The Sky Background
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color(red: 100/255, green: 170/255, blue: 220/255),
                        Color(red: 168/255, green: 200/255, blue: 220/255)
                    ]),
                    startPoint: .top,
                    endPoint: .bottom
                )
                
                // Static clouds
                VStack {
                    HStack {
                        Image(systemName: "cloud.fill").foregroundColor(.white.opacity(0.5)).font(.system(size: 70)).offset(x: -10, y: 50)
                        Spacer()
                    }
                    Spacer()
                    HStack {
                        Spacer()
                        Image(systemName: "cloud.fill").foregroundColor(.white.opacity(0.4)).font(.system(size: 90)).offset(x: 40, y: -100)
                    }
                }
                
                // The Target's Information
                VStack(spacing: 14) {
                    Spacer().frame(height: 30)
                    
                    // Avatar
                    if let data = target.profileImageData, let uiImage = UIImage(data: data) {
                        Image(uiImage: uiImage)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 120, height: 120)
                            .clipShape(Circle())
                            .overlay(Circle().stroke(Color.white, lineWidth: 3))
                            .shadow(color: .black.opacity(0.2), radius: 5, x: 0, y: 3)
                    } else {
                        Circle()
                            .fill(Color.white.opacity(0.8))
                            .frame(width: 120, height: 120)
                            .overlay(Image(systemName: "person.fill").font(.system(size: 50)).foregroundColor(.gray))
                            .shadow(color: .black.opacity(0.2), radius: 5, x: 0, y: 3)
                    }
                    
                    // Info
                    VStack(spacing: 6) {
                        Text("\(target.name), \(target.age)")
                            .font(.system(size: 26, weight: .bold))
                            .foregroundColor(.white)
                            .shadow(color: .black.opacity(0.2), radius: 2, x: 0, y: 1)
                        
                        if !target.airport.isEmpty {
                            Text("📍 \(target.airport)")
                                .font(.headline)
                                .foregroundColor(.white.opacity(0.95))
                        }
                    }
                    
                    if !target.languages.isEmpty {
                        Text("🗣️ \(target.languages)")
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(.white)
                            .padding(.horizontal, 14)
                            .padding(.vertical, 6)
                            .background(Color.black.opacity(0.15))
                            .clipShape(Capsule())
                    }
                    
                    VStack(spacing: 6) {
                        Text("✈️ \(target.flightInfo)")
                            .font(.title3).bold()
                            .foregroundColor(.white)
                        if !target.destination.isEmpty {
                            Text("To: \(target.destination)")
                                .font(.headline)
                                .foregroundColor(.white.opacity(0.8))
                        }
                    }
                    .padding(.vertical, 14)
                    .padding(.horizontal, 24)
                    .background(Color.black.opacity(0.25))
                    .cornerRadius(16)
                    
                    Spacer()
                }
                
                // 3. The Interactive Window Shade (Blind)
                ZStack(alignment: .bottom) {
                    Color(red: 235/255, green: 235/255, blue: 240/255)
                    
                    // Plastic Ridges
                    VStack(spacing: 16) {
                        ForEach(0..<30, id: \.self) { _ in
                            Rectangle()
                                .fill(Color.black.opacity(0.04))
                                .frame(height: 2)
                        }
                    }
                    .padding(.bottom, 40)
                    
                    // Pull Handle
                    Capsule()
                        .fill(Color.gray.opacity(0.3))
                        .frame(width: 80, height: 6)
                        .padding(.bottom, 16)
                }
                .frame(height: 520)
                .offset(y: blindOffset)
                .shadow(color: .black.opacity(0.3), radius: 6, x: 0, y: 5)
                
            }
            .frame(width: 296, height: 496)
            .clipShape(RoundedRectangle(cornerRadius: 150)) // Clips glass and shade to the window
            // The Drag Gesture controls the blind!
            .gesture(
                DragGesture()
                    .onChanged { value in
                        // Drag down pulls the blind down
                        if value.translation.height > 0 {
                            blindOffset = min(0, -520 + value.translation.height)
                        }
                    }
                    .onEnded { value in
                        if value.translation.height > 150 {
                            // Pulled far enough! Snap shut, change user, open up.
                            withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                                blindOffset = 0
                            }
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                onNextUser()
                                // Wait a fraction of a second before opening to reveal new user
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                                    withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                                        blindOffset = -520
                                    }
                                }
                            }
                        } else if value.translation.height < -50 {
                            // Swipe up quickly goes to previous user
                            withAnimation(.easeIn(duration: 0.2)) {
                                blindOffset = 0
                            }
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                                onPrevUser()
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                    withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                                        blindOffset = -520
                                    }
                                }
                            }
                        } else {
                            // Didn't pull far enough, snap back open
                            withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                                blindOffset = -520
                            }
                        }
                    }
            )
        }
    }
}
