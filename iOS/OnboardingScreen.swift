import SwiftUI

struct OnboardingScreen: View {
    @Binding var isPresented: Bool
    
    @StateObject private var preferences = Preferences.shared
    
    @State private var displayedText = ""
    @State private var isAnimating = false
    @State private var isAnimationDone = false
    @State private var isDescriptionVisible = false
    
    @State private var scrollPosition: Int? = 0
    
    @Environment(\.dismiss) private var dismiss
    
    let font: String = iAFont.quattro.fileName
    var colors: Theme.Colors { preferences.theme.colors }
    
    let words = ["Pagi", " is ", "where ", "\ndays ", "begin."]
    
    @ScaledMetric(relativeTo: .largeTitle) private var titleFontSize = 34
    @ScaledMetric(relativeTo: .body) private var bodyFontSize = 17
    @ScaledMetric(relativeTo: .caption) private var captionFontSize = 12
    
    @ViewBuilder
    private func Slide1() -> some View {
        VStack(alignment: .leading, spacing: 32) {
            Spacer()
            Text(displayedText)
                .font(.custom(font, size: titleFontSize).weight(.bold))
                .foregroundColor(colors.foreground)
                .multilineTextAlignment(.leading)
                .lineLimit(2, reservesSpace: true)
                .onAppear {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                        animateText()
                    }
                }
            
            VStack {
                if isAnimationDone {
                    Button {
                        Haptics.buttonTap()
                        dismiss()
                        isPresented.toggle()
                    } label: {
                        HStack {
                            Image(systemName: "arrow.right")
                                .fontWeight(.semibold)
                            Text("Try for free")
                        }
                        .font(.custom(font, size: bodyFontSize).weight(.semibold))
                        .padding()
                        .background {
                            RoundedRectangle(cornerRadius: 24)
                                .stroke(colors.accent, lineWidth: 3)
                        }
                    }
                    .tint(colors.accent)
                    .transition(.move(edge: .leading))
                }
            }
            .frame(height: 64)
            
            Text("»Pagi« /paɡi/ means »morning« in Indonesian.")
                .font(.custom(font, size: captionFontSize))
                .foregroundStyle(colors.foregroundLight)
                .opacity(isDescriptionVisible ? 1 : 0)
        }
        .padding(.horizontal, 32)
        .padding(.vertical, 64)
        .frame(maxWidth: .infinity, alignment: .leading)
        .animation(.snappy, value: isAnimationDone)
        .animation(.smooth, value: isDescriptionVisible)
        .containerRelativeFrame(.horizontal, count: 1, spacing: 32)
        .contentMargins(.horizontal, 32, for: .scrollContent)
    }
    
    var body: some View {
        ScrollView(.horizontal) {
            LazyHStack(spacing: 0) {
                Slide1()
                    .id(0)
                
                Text("Slide 2")
                    .containerRelativeFrame(.horizontal, count: 1, spacing: 32)
                    .contentMargins(.horizontal, 32, for: .scrollContent)
                    .id(1)
            }
            .scrollTargetLayout()
        }
        .scrollTargetBehavior(.paging)
        .scrollIndicators(.hidden)
        .scrollDisabled(true)
        .scrollBounceBehavior(.basedOnSize)
        .scrollPosition(id: $scrollPosition)
        .scrollContentBackground(.hidden)
        .animation(.smooth, value: scrollPosition)
        .background {
            Rectangle()
                .fill(Gradient(colors: [
                    colors.background.mix(with: .white, by: 0.15),
                    colors.background
                ]))
                .ignoresSafeArea()
        }
    }
    
    private func animateText() {
        isAnimating = true
        var currentIndex = 0
        
        func addNextWord() {
            guard currentIndex < words.count else {
                isAnimating = false
                return
            }
            
            let nextWord = words[currentIndex]
            displayedText += nextWord
            Haptics.impactOccurred(.rigid)
            
            currentIndex += 1
            
            if currentIndex < words.count {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                    addNextWord()
                }
            } else {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                    isAnimationDone = true
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) {
                        isDescriptionVisible = true
                    }
                }
            }
        }
        addNextWord()
    }
}

#Preview {
    OnboardingScreen(isPresented: .constant(true))
}
