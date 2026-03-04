import SwiftUI

// MARK: - ONBOARDING BACKGROUND

struct OnboardingBackground<BottomContent: View, CenterContent: View, TopContent: View>: View {
    var bottomContent: () -> BottomContent
    var centerContent: () -> CenterContent
    var topContent: () -> TopContent

    let bgColor = Color(red: 168/255, green: 200/255, blue: 220/255)

    init(
        @ViewBuilder bottomContent: @escaping () -> BottomContent,
        @ViewBuilder centerContent: @escaping () -> CenterContent,
        @ViewBuilder topContent: @escaping () -> TopContent
    ) {
        self.bottomContent = bottomContent
        self.centerContent = centerContent
        self.topContent = topContent
    }

    init(
        @ViewBuilder bottomContent: @escaping () -> BottomContent,
        @ViewBuilder topContent: @escaping () -> TopContent
    ) where CenterContent == EmptyView {
        self.bottomContent = bottomContent
        self.centerContent = { EmptyView() }
        self.topContent = topContent
    }

    init(
        @ViewBuilder bottomContent: @escaping () -> BottomContent,
        @ViewBuilder centerContent: @escaping () -> CenterContent
    ) where TopContent == EmptyView {
        self.bottomContent = bottomContent
        self.centerContent = centerContent
        self.topContent = { EmptyView() }
    }

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

                // Clouds - BACK AND MOVING!
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

                // CENTER CONTENT
                centerContent()

                // Bottom white circle
                Circle()
                    .fill(Color.white)
                    .frame(
                        width: geometry.size.width * 2.0,
                        height: geometry.size.width * 2.0
                    )
                    .position(
                        x: geometry.size.width * 0.5,
                        y: geometry.size.height * 0.90
                    )

                // FORMS LOWERED - Moved from 0.65 to 0.70 to put gender page a bit lower
                VStack {
                    bottomContent()
                        .padding(.horizontal, 28)
                }
                .position(x: geometry.size.width / 2, y: geometry.size.height * 0.70)

                // Top content pinned to top-leading safe area
                topContent()
                    .padding(.top, max(geometry.safeAreaInsets.top, 12))
                    .padding(.leading, 16)
            }
        }
    }
}

// MARK: - Shared controls

struct BackButton: View {
    var action: () -> Void
    var body: some View {
        Button(action: action) {
            Image(systemName: "arrow.left")
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(.black)
                .padding(12)
                .background(Color.white.opacity(0.5))
                .clipShape(Circle())
        }
        .buttonStyle(.plain)
    }
}

struct ContinueButton: View {
    var action: () -> Void
    var body: some View {
        Button(action: action) {
            Image(systemName: "arrow.right")
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(.black)
                .frame(width: 60, height: 60)
                .background(Color.white)
                .clipShape(Circle())
                .shadow(radius: 5)
        }
    }
}

// MARK: - Unified form styling

private enum FormStyle {
    static let cornerRadius: CGFloat = 15 // Matches LoginView
    static let sectionSpacing: CGFloat = 16
    static let titleSpacing: CGFloat = 8
}

private struct FormSection<Content: View>: View {
    let title: String
    @ViewBuilder var content: Content

    var body: some View {
        VStack(alignment: .leading, spacing: FormStyle.sectionSpacing) {
            Text(title)
                .font(.headline)
                .foregroundColor(.black)
                .padding(.bottom, FormStyle.titleSpacing)

            content
        }
    }
}

private struct FormTextFieldRow: View {
    let placeholder: String
    @Binding var text: String

    var body: some View {
        TextField(placeholder, text: $text)
            .padding()
            .foregroundColor(.black)
            .background(Color(UIColor.systemGray6))
            .cornerRadius(FormStyle.cornerRadius)
            .overlay(
                RoundedRectangle(cornerRadius: FormStyle.cornerRadius)
                    .stroke(Color.gray, lineWidth: 1.5)
            )
    }
}

private struct FormOptionRow: View {
    let title: String
    let isSelected: Bool
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack {
                Text(title)
                    .foregroundColor(isSelected ? .white : .black)
                Spacer()
                
                if isSelected {
                    Image(systemName: "checkmark")
                        .foregroundColor(.white)
                        .font(.system(size: 16, weight: .bold))
                }
            }
            .padding()
            .frame(maxWidth: .infinity)
            .background(isSelected ? Color.gray : Color(UIColor.systemGray6))
            .cornerRadius(FormStyle.cornerRadius)
            .overlay(
                RoundedRectangle(cornerRadius: FormStyle.cornerRadius)
                    .stroke(Color.gray, lineWidth: 1.5)
            )
        }
        .buttonStyle(.plain)
    }
}

// A simple reusable layout for text inputs
struct BaseInputScreen: View {
    let question: String
    let placeholder: String
    @Binding var inputText: String
    var keyboardType: UIKeyboardType = .default
    var onContinue: () -> Void
    var onBack: () -> Void

    var body: some View {
        OnboardingBackground(
            bottomContent: {
                VStack(alignment: .leading, spacing: 20) {
                    FormSection(title: question) {
                        FormTextFieldRow(placeholder: placeholder, text: $inputText)
                            .keyboardType(keyboardType)
                    }
                    HStack { Spacer(); ContinueButton(action: onContinue) }
                }
            },
            topContent: {
                BackButton(action: onBack)
            }
        )
    }
}

// Age
struct AgeInputView: View {
    @Binding var age: String
    var onContinue: () -> Void
    var onBack: () -> Void

    var body: some View {
        BaseInputScreen(
            question: "How old are you?",
            placeholder: "Age",
            inputText: $age,
            keyboardType: .numberPad,
            onContinue: onContinue,
            onBack: onBack
        )
        .onChange(of: age, perform: { newValue in
            let filtered = newValue.filter { $0.isNumber }
            if age != String(filtered.prefix(3)) {
                age = String(filtered.prefix(3))
            }
        })
    }
}

// Gender (simple options)
struct GenderInputView: View {
    @Binding var gender: String
    var onContinue: () -> Void
    var onBack: () -> Void

    private let options = ["Male", "Female", "Non-binary", "Prefer not to say"]

    var body: some View {
        OnboardingBackground(
            bottomContent: {
                VStack(alignment: .leading, spacing: 20) {
                    FormSection(title: "What is your gender?") {
                        VStack(spacing: FormStyle.sectionSpacing) {
                            ForEach(options, id: \.self) { option in
                                FormOptionRow(
                                    title: option,
                                    isSelected: gender == option,
                                    action: {
                                        withAnimation(.easeInOut(duration: 0.2)) {
                                            gender = option
                                        }
                                    }
                                )
                            }
                        }
                    }
                    HStack { Spacer(); ContinueButton(action: onContinue) }
                }
            },
            topContent: {
                BackButton(action: onBack)
            }
        )
    }
}

// Languages
struct LanguagesInputView: View {
    @Binding var languages: String
    var onContinue: () -> Void
    var onBack: () -> Void

    var body: some View {
        BaseInputScreen(
            question: "What languages do you speak?",
            placeholder: "e.g. English, Italian",
            inputText: $languages,
            onContinue: onContinue,
            onBack: onBack
        )
    }
}

// Profile Image
struct ProfileImageInputView: View {
    @Binding var imageData: Data?
    var onContinue: () -> Void
    var onBack: () -> Void

    var body: some View {
        OnboardingBackground(
            bottomContent: {
                VStack(alignment: .leading, spacing: 20) {
                    VStack(spacing: 16) {
                        HStack { Spacer() }
                        if let data = imageData, let uiImage = UIImage(data: data) {
                            Image(uiImage: uiImage)
                                .resizable()
                                .scaledToFill()
                                .frame(width: 140, height: 140)
                                .clipShape(Circle())
                                .overlay(Circle().stroke(Color.white, lineWidth: 4))
                                .shadow(radius: 5)
                        } else {
                            Circle()
                                .fill(Color.white.opacity(0.8))
                                .frame(width: 140, height: 140)
                                .overlay(
                                    Image(systemName: "person.fill")
                                        .font(.system(size: 60))
                                        .foregroundColor(.gray)
                                )
                        }

                        Button("Select Photo") {
                            imageData = nil
                        }
                        .padding()
                        .frame(maxWidth: .infinity)
                        .foregroundColor(.black)
                        .background(Color(UIColor.systemGray6))
                        .cornerRadius(FormStyle.cornerRadius)
                        .overlay(
                            RoundedRectangle(cornerRadius: FormStyle.cornerRadius)
                                .stroke(Color.black, lineWidth: 1.5)
                        )
                    }
                    HStack { Spacer(); ContinueButton(action: onContinue) }
                }
            },
            topContent: {
                BackButton(action: onBack)
            }
        )
    }
}

// Airport
struct AirportInputView: View {
    @Binding var airport: String
    var onContinue: () -> Void
    var onBack: () -> Void

    var body: some View {
        BaseInputScreen(
            question: "Which airport are you at?",
            placeholder: "Airport",
            inputText: $airport,
            onContinue: onContinue,
            onBack: onBack
        )
    }
}

// Flight
struct FlightInputView: View {
    @Binding var flight: String
    var onContinue: () -> Void
    var onBack: () -> Void

    var body: some View {
        BaseInputScreen(
            question: "What is your flight number?",
            placeholder: "e.g. AZ123",
            inputText: $flight,
            onContinue: onContinue,
            onBack: onBack
        )
        .onChange(of: flight, perform: { newValue in
            let filtered = newValue.uppercased().filter { $0.isLetter || $0.isNumber }
            if flight != String(filtered.prefix(5)) {
                flight = String(filtered.prefix(5))
            }
        })
    }
}

// Destination
struct DestinationInputView: View {
    @Binding var destination: String
    var onContinue: () -> Void
    var onBack: () -> Void

    var body: some View {
        BaseInputScreen(
            question: "Where are you flying to?",
            placeholder: "Destination",
            inputText: $destination,
            onContinue: onContinue,
            onBack: onBack
        )
    }
}

// Time
struct TimeInputView: View {
    @Binding var time: Date
    var onContinue: () -> Void
    var onBack: () -> Void

    var body: some View {
        OnboardingBackground(
            bottomContent: {
                VStack(alignment: .leading, spacing: 20) {
                    FormSection(title: "When do you depart?") {
                        DatePicker("Departure Time", selection: $time, displayedComponents: [.date, .hourAndMinute])
                            .datePickerStyle(.compact)
                            .labelsHidden()
                            .padding()
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(Color(UIColor.systemGray6))
                            .cornerRadius(FormStyle.cornerRadius)
                            .overlay(
                                RoundedRectangle(cornerRadius: FormStyle.cornerRadius)
                                    .stroke(Color.black, lineWidth: 1.5)
                            )
                    }
                    HStack { Spacer(); ContinueButton(action: onContinue) }
                }
            },
            topContent: {
                BackButton(action: onBack)
            }
        )
    }
}
