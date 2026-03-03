import SwiftUI

// Shared controls
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
                .foregroundColor(.gray) // Keeps the title gray to match "What's your name?"
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
            .foregroundColor(.black) // User input text is now BLACK
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
                    // White text if selected, BLACK if not
                    .foregroundColor(isSelected ? .white : .black)
                Spacer()
                
                // Add a checkmark if selected!
                if isSelected {
                    Image(systemName: "checkmark")
                        .foregroundColor(.white)
                        .font(.system(size: 16, weight: .bold))
                }
            }
            .padding()
            .frame(maxWidth: .infinity)
            // Dark gray if selected, standard systemGray6 if not
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
    var keyboardType: UIKeyboardType = .default // Allows custom keyboards (like NumberPad)
    var onContinue: () -> Void
    var onBack: () -> Void

    var body: some View {
        BackgroundDesign(
            bottomContent: {
                VStack(alignment: .leading, spacing: 20) {
                    FormSection(title: question) {
                        FormTextFieldRow(placeholder: placeholder, text: $inputText)
                            .keyboardType(keyboardType) // Applies the specific keyboard
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
            keyboardType: .numberPad, // Pops up the number keyboard!
            onContinue: onContinue,
            onBack: onBack
        )
        // Strictly filters input to numbers only, max 3 digits
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
        BackgroundDesign(
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

// Interests
struct InterestsInputView: View {
    @Binding var interests: String
    var onContinue: () -> Void
    var onBack: () -> Void

    var body: some View {
        BaseInputScreen(
            question: "What are your interests?",
            placeholder: "e.g. Travel, Music, Art",
            inputText: $interests,
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
        BackgroundDesign(
            bottomContent: {
                VStack(alignment: .leading, spacing: 20) {
                    FormSection(title: "Add a profile photo") {
                        VStack(spacing: 16) {
                            HStack { Spacer() }
                            // Avatar preview
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
                                // Hook up a picker later; for now just clears
                                imageData = nil
                            }
                            .padding()
                            .frame(maxWidth: .infinity)
                            .foregroundColor(.black) // Button text is now BLACK
                            .background(Color(UIColor.systemGray6))
                            .cornerRadius(FormStyle.cornerRadius)
                            .overlay(
                                RoundedRectangle(cornerRadius: FormStyle.cornerRadius)
                                    .stroke(Color.gray, lineWidth: 1.5)
                            )
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
        // Forces uppercase, removes spaces/symbols, and limits to exactly 5 characters
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
        BackgroundDesign(
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
                                    .stroke(Color.gray, lineWidth: 1.5)
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
