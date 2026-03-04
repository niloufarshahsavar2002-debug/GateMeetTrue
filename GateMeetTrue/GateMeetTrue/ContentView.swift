import SwiftUI

enum AppStep {
    // Removed .inputInterests from this list
    case login, inputAge, inputGender, inputLanguages, inputImage, inputAirport, inputFlight, inputDestination, inputTime, mainApp
}

struct ContentView: View {
    @StateObject var ckService = CloudKitService()
    
    @State private var draftAppleID = "UI_TEST_USER"
    @State private var draftName = ""
    @State private var draftAge = ""
    @State private var draftGender = ""
    @State private var draftLanguages = ""
    // Removed draftInterests variable
    @State private var draftImageData: Data? = nil
    @State private var draftAirport = ""
    @State private var draftFlight = ""
    @State private var draftDestination = ""
    @State private var draftDepartureTime = Date()
    
    @State private var currentStep: AppStep = .login
    @State private var isForward: Bool = true

    var body: some View {
        ZStack {
            activeStepView()
                .id(currentStep) // Make transitions trigger on step change
                .transition(.asymmetric(
                    insertion: .move(edge: isForward ? .trailing : .leading).combined(with: .opacity),
                    removal: .move(edge: isForward ? .leading : .trailing).combined(with: .opacity)
                ))
        }
        .animation(.easeInOut, value: currentStep)
        .preferredColorScheme(.light)
    }

    @ViewBuilder
    private func activeStepView() -> some View {
        switch currentStep {
        case .login:
            LoginView(onContinue: {
                isForward = true
                withAnimation { currentStep = .inputAge }
            })
        case .inputAge:
            AgeInputView(
                age: $draftAge,
                onContinue: {
                    isForward = true
                    withAnimation { currentStep = .inputGender }
                },
                onBack: {
                    isForward = false
                    withAnimation { currentStep = .login }
                }
            )
        case .inputGender:
            GenderInputView(
                gender: $draftGender,
                onContinue: {
                    isForward = true
                    withAnimation { currentStep = .inputLanguages }
                },
                onBack: {
                    isForward = false
                    withAnimation { currentStep = .inputAge }
                }
            )
        case .inputLanguages:
            LanguagesInputView(
                languages: $draftLanguages,
                onContinue: {
                    isForward = true
                    // Skips Interests and goes straight to Image
                    withAnimation { currentStep = .inputImage }
                },
                onBack: {
                    isForward = false
                    withAnimation { currentStep = .inputGender }
                }
            )
        case .inputImage:
            ProfileImageInputView(
                imageData: $draftImageData,
                onContinue: {
                    isForward = true
                    withAnimation { currentStep = .inputAirport }
                },
                onBack: {
                    isForward = false
                    // Goes back to Languages instead of Interests
                    withAnimation { currentStep = .inputLanguages }
                }
            )
        case .inputAirport:
            AirportInputView(
                airport: $draftAirport,
                onContinue: {
                    isForward = true
                    withAnimation { currentStep = .inputFlight }
                },
                onBack: {
                    isForward = false
                    withAnimation { currentStep = .inputImage }
                }
            )
        case .inputFlight:
            FlightInputView(
                flight: $draftFlight,
                onContinue: {
                    isForward = true
                    withAnimation { currentStep = .inputDestination }
                },
                onBack: {
                    isForward = false
                    withAnimation { currentStep = .inputAirport }
                }
            )
        case .inputDestination:
            DestinationInputView(
                destination: $draftDestination,
                onContinue: {
                    isForward = true
                    withAnimation { currentStep = .inputTime }
                },
                onBack: {
                    isForward = false
                    withAnimation { currentStep = .inputFlight }
                }
            )
        case .inputTime:
            TimeInputView(
                time: $draftDepartureTime,
                onContinue: {
                    isForward = true
                    withAnimation { currentStep = .mainApp }
                },
                onBack: {
                    isForward = false
                    withAnimation { currentStep = .inputDestination }
                }
            )
        case .mainApp:
            MainTabView(
                ckService: ckService,
                appleUserID: draftAppleID,
                userName: draftName,
                userAge: draftAge,
                userGender: draftGender,
                userLanguages: draftLanguages,
                userInterests: "", // Passed as an empty string to prevent build errors!
                userImage: draftImageData,
                userAirport: draftAirport,
                userDepartureTime: draftDepartureTime
            )
        }
    }
}
