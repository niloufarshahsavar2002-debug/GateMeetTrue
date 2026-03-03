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

// MARK: - Profile

struct HomeProfileView: View {
    var userName: String
    var userAge: String
    var userGender: String
    var userLanguages: String
    var userImage: Data?
    var userAirport: String
    
    let bgColor = Color(red: 168/255, green: 200/255, blue: 220/255)
    
    var body: some View {
        ZStack {
            bgColor.edgesIgnoringSafeArea(.all)
            VStack(spacing: 20) {
                Text("Your Profile")
                    .font(.largeTitle).bold()
                    .padding(.top, 40)
                
                if let data = userImage, let uiImage = UIImage(data: data) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 150, height: 150)
                        .clipShape(Circle())
                        .overlay(Circle().stroke(Color.white, lineWidth: 4))
                        .shadow(radius: 5)
                } else {
                    Circle()
                        .fill(Color.white.opacity(0.8))
                        .frame(width: 150, height: 150)
                        .overlay(
                            Image(systemName: "person.fill")
                                .font(.system(size: 60))
                                .foregroundColor(.gray)
                        )
                }
                
                Text(userName.isEmpty ? "User Name" : userName)
                    .font(.title).bold()
                
                Text("\(userAge.isEmpty ? "-" : userAge) years old • \(userGender.isEmpty ? "-" : userGender)")
                    .font(.headline)
                    .foregroundColor(.black.opacity(0.7))
                
                VStack(alignment: .leading, spacing: 10) {
                    HStack {
                        Image(systemName: "airplane.departure")
                        Text(userAirport.isEmpty ? "Airport not set" : userAirport)
                    }
                    HStack {
                        Image(systemName: "mouth")
                        Text(userLanguages.isEmpty ? "No languages selected" : userLanguages)
                    }
                }
                .padding()
                .background(Color.white.opacity(0.6))
                .cornerRadius(15)
                .padding(.horizontal, 40)
                
                Spacer()
            }
        }
    }
}

// MARK: - Chat prototype (clean header, no fake messages, fixed name "Giulia")

struct ChatView: View {
    var target: Target?
    var isOnline: Bool
    
    let bgColor = Color(red: 168/255, green: 200/255, blue: 220/255)
    @State private var composerText: String = ""
    
    var body: some View {
        ZStack {
            bgColor.edgesIgnoringSafeArea(.all)
            VStack(spacing: 0) {
                // Header like Telegram/WhatsApp
                HStack(spacing: 12) {
                    if let t = target,
                       let data = t.profileImageData,
                       let uiImage = UIImage(data: data) {
                        Image(uiImage: uiImage)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 42, height: 42)
                            .clipShape(Circle())
                    } else {
                        Circle()
                            .fill(Color.white.opacity(0.9))
                            .frame(width: 42, height: 42)
                            .overlay(
                                Image(systemName: "person.fill")
                                    .foregroundColor(.gray)
                            )
                    }
                    
                    VStack(alignment: .leading, spacing: 2) {
                        // Fixed name "Giulia" as requested
                        Text("Giulia")
                            .font(.headline)
                            .foregroundColor(.black)
                        Text(isOnline ? "Online" : "Offline")
                            .font(.subheadline)
                            .foregroundColor(isOnline ? .green : .gray)
                    }
                    Spacer()
                    Image(systemName: "ellipsis")
                        .foregroundColor(.blue)
                }
                .padding(.horizontal)
                .padding(.vertical, 10)
                .background(Color.white.opacity(0.7))
                
                // Empty state (no fake chats)
                VStack(spacing: 12) {
                    Spacer()
                    Image(systemName: "bubble.left.and.bubble.right")
                        .font(.system(size: 48))
                        .foregroundColor(.white.opacity(0.8))
                    Text("No messages yet. Say hello to Giulia!")
                        .font(.subheadline)
                        .foregroundColor(.black.opacity(0.7))
                    Spacer()
                }
                .frame(maxWidth: .infinity)
                .background(Color.white.opacity(0.25))
                
                // Composer (no + attachment button)
                HStack(spacing: 8) {
                    TextField("Message", text: $composerText)
                        .padding(10)
                        .background(Color.white)
                        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                    Button {
                        composerText = "" // prototype: clear field on send
                    } label: {
                        Image(systemName: "paperplane.fill")
                            .font(.system(size: 20))
                            .foregroundColor(.blue)
                            .rotationEffect(.degrees(45))
                    }
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 10)
                .background(Color.white.opacity(0.7))
            }
        }
    }
}

struct Message: Identifiable {
    let id: UUID
    let isMe: Bool
    let text: String
    let time: String
}

// MARK: - Radar scanning

struct RadarView: View {
    @ObservedObject var ckService: CloudKitService
    var appleUserID: String
    var userAirport: String
    var userDepartureTime: Date
    var onFound: () -> Void
    
    @State private var isAnimating = false
    
    var body: some View {
        ZStack {
            Color(red: 168/255, green: 200/255, blue: 220/255)
                .edgesIgnoringSafeArea(.all)
            VStack {
                Spacer()
                Text(ckService.isSearching ? "Searching passengers..." : "Users Found!")
                    .font(.title2).bold()
                    .foregroundColor(.black)
                Spacer()
                ZStack {
                    Circle()
                        .stroke(Color.white.opacity(0.8), lineWidth: 1)
                        .frame(width: 150)
                    Circle()
                        .stroke(Color.white.opacity(0.6), lineWidth: 1)
                        .frame(width: 250)
                    if ckService.isSearching {
                        ForEach(0..<3, id: \.self) { i in
                            Circle()
                                .fill(Color.blue.opacity(0.6))
                                .frame(width: 20, height: 20)
                                .offset(x: 125)
                                .rotationEffect(.degrees(isAnimating ? 360 : 0))
                                .animation(
                                    Animation.linear(duration: 3.0)
                                        .repeatForever(autoreverses: false)
                                        .delay(Double(i) * 0.5),
                                    value: isAnimating
                                )
                        }
                    } else {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 80))
                            .foregroundColor(.blue)
                    }
                }
                .onAppear {
                    isAnimating = true
                    ckService.startScanning(
                        myAirport: userAirport,
                        myTime: userDepartureTime,
                        myUserID: appleUserID
                    )
                }
                .onChange(of: ckService.isSearching) { _, isSearching in
                    if !isSearching {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                            onFound()
                        }
                    }
                }
                Spacer()
            }
        }
    }
}

// MARK: - Horizontal window carousel

struct WindowCarouselView: View {
    var targets: [Target]
    var onRestart: () -> Void
    var onChatRequested: (Target) -> Void
    
    @State private var pageIndex: Int = 0
    private let spacing: CGFloat = 24
    private let cardWidth: CGFloat = 340 // slightly wider to show paging feel
    
    var body: some View {
        ZStack {
            Color(red: 176/255, green: 205/255, blue: 222/255)
                .edgesIgnoringSafeArea(.all)
            
            if targets.isEmpty {
                VStack(spacing: 20) {
                    Image(systemName: "person.slash.fill")
                        .font(.system(size: 60))
                        .foregroundColor(.white.opacity(0.6))
                    Text("No passengers found nearby.")
                        .font(.headline)
                        .foregroundColor(.white)
                    Button("Try Again", action: onRestart)
                        .padding()
                        .background(Color.white)
                        .foregroundColor(.blue)
                        .cornerRadius(10)
                }
            } else {
                VStack {
                    Spacer()
                    // Horizontal paging of window cards
                    TabView(selection: $pageIndex) {
                        ForEach(Array(targets.enumerated()), id: \.offset) { index, target in
                            WindowCardView(
                                target: target,
                                onChatRequested: { onChatRequested(target) }
                            )
                            .frame(width: cardWidth)
                            .padding(.vertical, 10)
                            .tag(index)
                        }
                    }
                    .tabViewStyle(.page(indexDisplayMode: .always))
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .padding(.horizontal, spacing)
                    
                    HStack {
                        Button(action: { pageIndex = max(pageIndex - 1, 0) }) {
                            Text("◀ Prev")
                                .font(.headline)
                                .foregroundColor(.white.opacity(0.8))
                        }
                        Spacer()
                        Button(action: { pageIndex = min(pageIndex + 1, max(targets.count - 1, 0)) }) {
                            Text("Next ▶")
                                .font(.headline)
                                .foregroundColor(.white.opacity(0.8))
                        }
                    }
                    .padding(.horizontal, 36)
                    .padding(.bottom, 12)
                    
                    Text("Swipe left or right to change passenger")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(.white.opacity(0.8))
                        .padding(.bottom, 20)
                }
            }
        }
    }
}

// MARK: - Single window card (push avatar + texts further down)

struct WindowCardView: View {
    var target: Target
    var onChatRequested: () -> Void
    
    @State private var shadeOffset: CGFloat = -480
    @State private var isAnimating = false
    
    // Increased height to allow more room at the bottom
    private let windowWidth: CGFloat = 220
    private let windowHeight: CGFloat = 500
    
    var body: some View {
        ZStack(alignment: .top) {
            ZStack(alignment: .top) {
                if !isAnimating {
                    VStack(spacing: 10) {
                        // Top controls
                        HStack {
                            Button(action: onChatRequested) {
                                Image(systemName: "message.circle.fill")
                                    .font(.system(size: 34))
                                    .foregroundColor(.white)
                                    .padding(.leading, 10)
                            }
                            Spacer()
                            Menu {
                                Button("Report User", role: .destructive) { }
                                Button("Block User", role: .destructive) { }
                            } label: {
                                Image(systemName: "exclamationmark.triangle.fill")
                                    .foregroundColor(.red.opacity(0.85))
                                    .padding(.trailing, 10)
                            }
                        }
                        .padding(.top, 6)
                        
                        // Avatar further down
                        ZStack {
                            Circle().fill(Color.white)
                                .frame(width: 100, height: 100)
                            if let imageData = target.profileImageData,
                               let uiImage = UIImage(data: imageData) {
                                Image(uiImage: uiImage)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 90, height: 90)
                                    .clipShape(Circle())
                            } else {
                                Image(systemName: "person.fill")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 60, height: 60)
                                    .foregroundColor(Color.blue.opacity(0.5))
                            }
                        }
                        .overlay(Circle().stroke(Color.white, lineWidth: 5))
                        .shadow(radius: 8)
                        .padding(.top, 48) // move avatar even further down
                        
                        // Info further down
                        VStack(spacing: 8) {
                            HStack(alignment: .firstTextBaseline, spacing: 8) {
                                Text(target.name)
                                    .font(.system(size: 26, weight: .bold))
                                    .foregroundColor(.white)
                                Text(target.age)
                                    .font(.title3)
                                    .foregroundColor(.white.opacity(0.85))
                            }
                            
                            if !target.airport.isEmpty {
                                Text("📍 \(target.airport)")
                                    .font(.subheadline)
                                    .foregroundColor(.white.opacity(0.9))
                            }
                            if !target.languages.isEmpty {
                                Text("🗣️ \(target.languages)")
                                    .font(.caption)
                                    .foregroundColor(.white.opacity(0.85))
                                    .padding(.horizontal)
                            }
                            
                            VStack(spacing: 6) {
                                Text("✈️ \(target.flightInfo)")
                                    .font(.headline)
                                    .padding(.vertical, 7)
                                    .padding(.horizontal, 16)
                                    .background(Color.black.opacity(0.4))
                                    .cornerRadius(15)
                                    .foregroundColor(.white)
                                if !target.destination.isEmpty {
                                    Text("To: \(target.destination)")
                                        .font(.subheadline)
                                        .foregroundColor(.white.opacity(0.85))
                                }
                            }
                            .padding(.top, 8)
                        }
                        .padding(.top, 34) // push texts even further down
                        
                        Spacer(minLength: 60) // keep content anchored toward bottom
                    }
                    .frame(width: windowWidth, height: windowHeight + 60)
                    .background(Color.blue.opacity(0.6))
                }
                
                Rectangle()
                    .fill(Color(red: 220/255, green: 220/255, blue: 230/255))
                    .frame(width: windowWidth, height: windowHeight + 30)
                    .offset(y: shadeOffset)
            }
            .mask(
                RoundedRectangle(cornerRadius: 120)
                    .frame(width: windowWidth, height: windowHeight)
            )
            
            RoundedRectangle(cornerRadius: 120)
                .stroke(Color.white, lineWidth: 25)
                .frame(width: windowWidth + 30, height: windowHeight + 30)
                .shadow(radius: 10)
                .contentShape(Rectangle())
                .gesture(
                    DragGesture()
                        .onEnded { v in
                            if v.translation.width < -40 {
                                closeAndReopenShutter()
                            } else if v.translation.width > 40 {
                                closeAndReopenShutter()
                            }
                        }
                )
        }
        .onAppear {
            // Ensure shutter starts opened
            shadeOffset = -480
        }
    }
    
    private func closeAndReopenShutter() {
        withAnimation(.easeIn(duration: 0.18)) { shadeOffset = 0 }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.22) {
            isAnimating = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.08) {
                isAnimating = false
                withAnimation(.spring(response: 0.6, dampingFraction: 0.75)) {
                    shadeOffset = -480
                }
            }
        }
    }
}
