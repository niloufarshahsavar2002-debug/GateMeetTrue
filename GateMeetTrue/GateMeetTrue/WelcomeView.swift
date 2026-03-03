//
//  WelcomeView.swift
//  GateMeetUI
//
//  Created by Niloufar on 02/03/26.
//
import SwiftUI

struct WelcomeView: View {
    @State private var isShowingSplash = true
    @State private var goToApp = false
    @State private var currentPage = 0 // Tracks which onboarding screen we are on (0, 1, or 2)
    
    // Reuse the sky color from elsewhere
    private let bgColor = Color(red: 168/255, green: 200/255, blue: 220/255)
    
    var body: some View {
        ZStack {
            if isShowingSplash {
                SplashView()
                    .transition(.opacity)
            } else {
                NavigationStack {
                    ZStack {
                        // MARK: - BACKGROUND LAYER
                        bgColor.ignoresSafeArea()
                        
                        // MARK: - CONTENT LAYER (Static Clouds + Dynamic Pages)
                        GeometryReader { geo in
                            let minSide = min(geo.size.width, geo.size.height)
                            let circleSize = minSide * 1.25
                            
                            // MARK: - Static Minimal Clouds
                            // Shadows added so they are visible even when overlapping the white circles!
                            ZStack {
                                if currentPage == 0 {
                                    // PAGE 1: 4 clouds top, 2 clouds bottom
                                    ZStack {
                                        // Top Clouds
                                        Image(systemName: "cloud.fill").resizable().scaledToFit().frame(width: 90)
                                            .foregroundColor(.white).opacity(0.85)
                                            .shadow(color: .black.opacity(0.12), radius: 5, x: 0, y: 4)
                                            .position(x: geo.size.width * 0.2, y: geo.size.height * 0.15)
                                        Image(systemName: "cloud.fill").resizable().scaledToFit().frame(width: 110)
                                            .foregroundColor(.white).opacity(0.7)
                                            .shadow(color: .black.opacity(0.12), radius: 5, x: 0, y: 4)
                                            .position(x: geo.size.width * 0.8, y: geo.size.height * 0.2)
                                        Image(systemName: "cloud.fill").resizable().scaledToFit().frame(width: 60)
                                            .foregroundColor(.white).opacity(0.75)
                                            .shadow(color: .black.opacity(0.12), radius: 5, x: 0, y: 4)
                                            .position(x: geo.size.width * 0.45, y: geo.size.height * 0.08)
                                        Image(systemName: "cloud.fill").resizable().scaledToFit().frame(width: 75)
                                            .foregroundColor(.white).opacity(0.6)
                                            .shadow(color: .black.opacity(0.12), radius: 5, x: 0, y: 4)
                                            .position(x: geo.size.width * 0.85, y: geo.size.height * 0.35)
                                        
                                        // Bottom Clouds
                                        Image(systemName: "cloud.fill").resizable().scaledToFit().frame(width: 100)
                                            .foregroundColor(.white).opacity(0.9)
                                            .shadow(color: .black.opacity(0.15), radius: 6, x: 0, y: 5)
                                            .position(x: geo.size.width * 0.15, y: geo.size.height * 0.85)
                                        Image(systemName: "cloud.fill").resizable().scaledToFit().frame(width: 70)
                                            .foregroundColor(.white).opacity(0.7)
                                            .shadow(color: .black.opacity(0.15), radius: 6, x: 0, y: 5)
                                            .position(x: geo.size.width * 0.45, y: geo.size.height * 0.93)
                                    }
                                    .transition(.asymmetric(insertion: .move(edge: .trailing), removal: .move(edge: .leading)))
                                    
                                } else if currentPage == 1 {
                                    // PAGE 2: 3 clouds at the bottom, 1 cloud at the top
                                    ZStack {
                                        // Top Cloud
                                        Image(systemName: "cloud.fill").resizable().scaledToFit().frame(width: 85)
                                            .foregroundColor(.white).opacity(0.7)
                                            .shadow(color: .black.opacity(0.12), radius: 5, x: 0, y: 4)
                                            .position(x: geo.size.width * 0.8, y: geo.size.height * 0.1)
                                        
                                        // Bottom Clouds
                                        Image(systemName: "cloud.fill").resizable().scaledToFit().frame(width: 110)
                                            .foregroundColor(.white).opacity(0.85)
                                            .shadow(color: .black.opacity(0.12), radius: 5, x: 0, y: 4)
                                            .position(x: geo.size.width * 0.25, y: geo.size.height * 0.8)
                                        Image(systemName: "cloud.fill").resizable().scaledToFit().frame(width: 70)
                                            .foregroundColor(.white).opacity(0.65)
                                            .shadow(color: .black.opacity(0.12), radius: 5, x: 0, y: 4)
                                            .position(x: geo.size.width * 0.7, y: geo.size.height * 0.75)
                                        Image(systemName: "cloud.fill").resizable().scaledToFit().frame(width: 60)
                                            .foregroundColor(.white).opacity(0.5)
                                            .shadow(color: .black.opacity(0.12), radius: 5, x: 0, y: 4)
                                            .position(x: geo.size.width * 0.15, y: geo.size.height * 0.9)
                                    }
                                    .transition(.asymmetric(insertion: .move(edge: .trailing), removal: .move(edge: .leading)))
                                    
                                } else {
                                    // PAGE 3: 4 clouds top, 2 clouds bottom (arranged differently from Page 1)
                                    ZStack {
                                        // Top Clouds
                                        Image(systemName: "cloud.fill").resizable().scaledToFit().frame(width: 100)
                                            .foregroundColor(.white).opacity(0.85)
                                            .shadow(color: .black.opacity(0.12), radius: 5, x: 0, y: 4)
                                            .position(x: geo.size.width * 0.75, y: geo.size.height * 0.12)
                                        Image(systemName: "cloud.fill").resizable().scaledToFit().frame(width: 85)
                                            .foregroundColor(.white).opacity(0.65)
                                            .shadow(color: .black.opacity(0.12), radius: 5, x: 0, y: 4)
                                            .position(x: geo.size.width * 0.25, y: geo.size.height * 0.22)
                                        Image(systemName: "cloud.fill").resizable().scaledToFit().frame(width: 60)
                                            .foregroundColor(.white).opacity(0.75)
                                            .shadow(color: .black.opacity(0.12), radius: 5, x: 0, y: 4)
                                            .position(x: geo.size.width * 0.55, y: geo.size.height * 0.08)
                                        Image(systemName: "cloud.fill").resizable().scaledToFit().frame(width: 80)
                                            .foregroundColor(.white).opacity(0.55)
                                            .shadow(color: .black.opacity(0.12), radius: 5, x: 0, y: 4)
                                            .position(x: geo.size.width * 0.15, y: geo.size.height * 0.35)
                                        
                                        // Bottom Clouds (Moved UP to avoid the Get Started button!)
                                        Image(systemName: "cloud.fill").resizable().scaledToFit().frame(width: 110)
                                            .foregroundColor(.white).opacity(0.9)
                                            .shadow(color: .black.opacity(0.15), radius: 6, x: 0, y: 5)
                                            .position(x: geo.size.width * 0.25, y: geo.size.height * 0.82)
                                        Image(systemName: "cloud.fill").resizable().scaledToFit().frame(width: 65)
                                            .foregroundColor(.white).opacity(0.7)
                                            .shadow(color: .black.opacity(0.15), radius: 6, x: 0, y: 5)
                                            .position(x: geo.size.width * 0.55, y: geo.size.height * 0.75)
                                    }
                                    .transition(.asymmetric(insertion: .move(edge: .trailing), removal: .move(edge: .leading)))
                                }
                            }
                            .allowsHitTesting(false)
                            
                            // MARK: - Dynamic Pages (Circles & Text)
                            ZStack {
                                if currentPage == 0 {
                                    // PAGE 1: Circle at the bottom
                                    ZStack {
                                        VStack(spacing: 0) {
                                            Spacer()
                                            ZStack {
                                                Circle()
                                                    .fill(Color.white)
                                                    .frame(width: circleSize, height: circleSize)
                                                    .shadow(color: .black.opacity(0.12), radius: 25, x: 0, y: 6)
                                                    .offset(y: circleSize * 0.10)
                                                
                                                VStack(alignment: .leading, spacing: 16) {
                                                    Text("Connect while you wait")
                                                        .font(.system(size: 25, weight: .bold))
                                                        .multilineTextAlignment(.leading)
                                                        .foregroundColor(.black)
                                                        .lineLimit(3)
                                                        .minimumScaleFactor(0.85)
                                                        .frame(maxWidth: circleSize * 0.65, alignment: .leading)
                                                    
                                                    Text("meet travelers in your airport who are flying around the same time as you.")
                                                        .font(.system(size: 15, weight: .regular))
                                                        .multilineTextAlignment(.leading)
                                                        .foregroundColor(.black.opacity(0.75))
                                                        .lineLimit(3)
                                                        .minimumScaleFactor(0.9)
                                                        .frame(maxWidth: circleSize * 0.65, alignment: .leading)
                                                }
                                                .padding(.horizontal, 30)
                                                .offset(y: circleSize * 0.10)
                                            }
                                            .frame(maxWidth: .infinity, maxHeight: circleSize * 0.7, alignment: .bottom)
                                            
                                            Spacer()
                                            Spacer()
                                        }
                                    }
                                    .transition(.asymmetric(insertion: .move(edge: .trailing), removal: .move(edge: .leading)))
                                    
                                } else if currentPage == 1 {
                                    // PAGE 2: Circle at the top
                                    ZStack {
                                        VStack(spacing: 0) {
                                            ZStack {
                                                Circle()
                                                    .fill(Color.white)
                                                    .frame(width: circleSize, height: circleSize)
                                                    .shadow(color: .black.opacity(0.12), radius: 25, x: 0, y: 6)
                                                    .offset(y: -circleSize * 0.05)
                                                
                                                VStack(alignment: .leading, spacing: 16) {
                                                    Text("Match by Flight Time")
                                                        .font(.system(size: 25, weight: .bold))
                                                        .multilineTextAlignment(.leading)
                                                        .foregroundColor(.black)
                                                        .lineLimit(2)
                                                        .minimumScaleFactor(0.85)
                                                        .frame(maxWidth: circleSize * 0.65, alignment: .leading)
                                                    
                                                    Text("Enter your departure time and discover people nearby with similar schedules.")
                                                        .font(.system(size: 15, weight: .regular))
                                                        .multilineTextAlignment(.leading)
                                                        .foregroundColor(.black.opacity(0.75))
                                                        .lineLimit(3)
                                                        .minimumScaleFactor(0.9)
                                                        .frame(maxWidth: circleSize * 0.65, alignment: .leading)
                                                }
                                                .padding(.horizontal, 30)
                                                .offset(y: -circleSize * 0.05)
                                            }
                                            .frame(maxWidth: .infinity, maxHeight: circleSize * 0.9, alignment: .top)
                                            
                                            Spacer()
                                        }
                                    }
                                    .transition(.asymmetric(insertion: .move(edge: .trailing), removal: .move(edge: .leading)))
                                    
                                } else {
                                    // PAGE 3: Circle at the bottom again
                                    ZStack {
                                        VStack(spacing: 0) {
                                            Spacer()
                                            ZStack {
                                                Circle()
                                                    .fill(Color.white)
                                                    .frame(width: circleSize, height: circleSize)
                                                    .shadow(color: .black.opacity(0.12), radius: 25, x: 0, y: 6)
                                                    .offset(y: circleSize * 0.10)
                                                
                                                VStack(alignment: .leading, spacing: 16) {
                                                    Text("Make Airport Time More Special")
                                                        .font(.system(size: 25, weight: .bold))
                                                        .multilineTextAlignment(.leading)
                                                        .foregroundColor(.black)
                                                        .lineLimit(3)
                                                        .minimumScaleFactor(0.85)
                                                        .frame(maxWidth: circleSize * 0.65, alignment: .leading)
                                                    
                                                    Text("Chat, Grab a coffee , or explore the airport before takeoff")
                                                        .font(.system(size: 15, weight: .regular))
                                                        .multilineTextAlignment(.leading)
                                                        .foregroundColor(.black.opacity(0.75))
                                                        .lineLimit(3)
                                                        .minimumScaleFactor(0.9)
                                                        .frame(maxWidth: circleSize * 0.65, alignment: .leading)
                                                }
                                                .padding(.horizontal, 30)
                                                .offset(y: circleSize * 0.10)
                                            }
                                            .frame(maxWidth: .infinity, maxHeight: circleSize * 0.7, alignment: .bottom)
                                            
                                            Spacer()
                                            Spacer()
                                        }
                                    }
                                    .transition(.asymmetric(insertion: .move(edge: .trailing), removal: .move(edge: .leading)))
                                }
                            }
                            
                            // Hidden NavigationLink triggered when onboarding is completely done
                            NavigationLink(destination: ContentView().navigationBarHidden(true), isActive: $goToApp) {
                                EmptyView()
                            }
                            .hidden()
                            
                            // MARK: - Navigation Buttons
                            VStack {
                                Spacer() // Pushes everything to the bottom
                                
                                if currentPage < 2 {
                                    // ARROW BUTTON for Pages 1 and 2
                                    HStack {
                                        Spacer()
                                        Button(action: {
                                            withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                                                currentPage += 1
                                            }
                                        }) {
                                            Image(systemName: "arrow.right")
                                                .font(.system(size: 24, weight: .bold))
                                                .foregroundColor(.white)
                                                .frame(width: 64, height: 64)
                                                .background(Color.black)
                                                .clipShape(Circle())
                                                .shadow(color: .black.opacity(0.2), radius: 10, x: 0, y: 5)
                                        }
                                        .padding(.trailing, 30)
                                        .padding(.bottom, 40)
                                    }
                                    .transition(.opacity) // Smooth fade transition
                                } else {
                                    // GET STARTED BUTTON for Page 3
                                    Button(action: {
                                        withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                                            goToApp = true
                                        }
                                    }) {
                                        Text("Get Started")
                                            .font(.system(size: 20, weight: .bold))
                                            .foregroundColor(.black)
                                            .frame(maxWidth: .infinity)
                                            .padding(.vertical, 18)
                                            .background(Color.white)
                                            .clipShape(Capsule())
                                            .shadow(color: .black.opacity(0.15), radius: 10, x: 0, y: 5)
                                    }
                                    .padding(.horizontal, 30)
                                    .padding(.bottom, 20)
                                    .transition(.opacity) // Smooth fade transition
                                }
                            }
                        }
                    }
                    .navigationBarHidden(true)
                }
                .transition(.opacity)
            }
        }
        .onAppear {
            // Snappy 1.0 second splash screen!
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                withAnimation(.easeInOut(duration: 0.5)) {
                    isShowingSplash = false
                }
            }
        }
    }
}
