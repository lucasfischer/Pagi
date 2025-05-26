import SwiftUI

public struct OnboardingScreen: View {
    @Binding var isPresented: Bool
    
    @StateObject private var preferences = Preferences.shared
    
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @Environment(\.dismissWindow) private var dismissWindow
    
    @State private var displayedText = ""
    @State private var isAnimating = false
    @State private var isAnimationDone = false
    @State private var isDescriptionVisible = false
    
    @State private var scrollPosition: Int? = 1
    
    public init(isPresented: Binding<Bool>) {
        self._isPresented = isPresented
    }
    
    var colors: Theme.Colors { preferences.theme.colors }
    
    var font: String {
        preferences.font.fileName
    }
    
    let words = ["Pagi", " is ", "where ", "\ndays ", "begin."]
    
    @ScaledMetric(relativeTo: .largeTitle) private var titleFontSize = 34
    @ScaledMetric(relativeTo: .title) private var headerFontSize = 28
    @ScaledMetric(relativeTo: .body) private var bodyFontSize = 17
    @ScaledMetric(relativeTo: .subheadline) private var subheadlineFontSize = 15
    @ScaledMetric(relativeTo: .footnote) private var footnoteFontSize = 13
    @ScaledMetric(relativeTo: .caption) private var captionFontSize = 12
    
    private func onDisappear() {
        displayedText = ""
        isAnimating = false
        isAnimationDone = false
        isDescriptionVisible = false
    }
    
    private func onAppear() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
            animateText()
        }
    }
    
    private func dismiss() {
        isPresented = false
#if os(macOS)
        dismissWindow()
#endif
        if preferences.onBoardingCompletedAt == nil {
            preferences.onBoardingCompletedAt = Date.now.timeIntervalSinceReferenceDate
        }
    }
    
    @ViewBuilder
    private func Slide1() -> some View {
        let horizontalSpacing: Double = horizontalSizeClass == .compact ? 32 : 80
        
        VStack(alignment: .leading, spacing: 32) {
            Spacer()
            Text(displayedText)
                .font(.custom(font, size: titleFontSize).weight(.bold))
                .foregroundColor(colors.foreground)
                .multilineTextAlignment(.leading)
                .lineLimit(2, reservesSpace: true)
                .onAppear(perform: onAppear)
                .onDisappear(perform: onDisappear)
            
            VStack {
                if isAnimationDone {
                    Button {
                        Haptics.buttonTap()
                        scrollPosition = 2
                    } label: {
                        HStack {
                            Image(systemName: "arrow.right")
                                .fontWeight(.semibold)
                            Text("Try for free", bundle: .module)
                        }
                        .font(.custom(font, size: bodyFontSize).weight(.semibold))
                        .padding()
                        .background {
                            RoundedRectangle(cornerRadius: 24)
                                .stroke(colors.accent, lineWidth: 3)
                        }
                        .contentShape(.rect)
                    }
                    .foregroundStyle(colors.accent)
                    .tint(colors.accent)
                    .transition(.asymmetric(insertion: .move(edge: .leading), removal: .identity))
                }
            }
            .frame(height: 64)
            
            Text("»Pagi« /paɡi/ means »morning« in Indonesian.", bundle: .module)
                .font(.custom(font, size: captionFontSize))
                .foregroundStyle(colors.foregroundLight)
                .opacity(isDescriptionVisible ? 1 : 0)
        }
        .padding(.horizontal, horizontalSpacing)
        .padding(.vertical, 64)
        .frame(maxWidth: .infinity, alignment: .leading)
        .animation(.snappy, value: isAnimationDone)
        .animation(.smooth, value: isDescriptionVisible)
        .containerRelativeFrame(.horizontal, count: 1, spacing: horizontalSpacing)
    }
    
    @ViewBuilder
    private func Slide2() -> some View {
        let horizontalSpacing: Double = 32
        
        ScrollView {
            VStack(alignment: horizontalSizeClass == .compact ? .leading : .center, spacing: 32) {
                Text("Get Started", bundle: .module)
                    .font(.custom(font, size: titleFontSize).weight(.semibold))
                    .padding(.bottom, 16)
                
                if horizontalSizeClass == .compact {
                    ForEach(Block.all) { block in
                        VStack(alignment: .leading, spacing: 4) {
                            Text(block.title)
                                .font(.custom(font, size: subheadlineFontSize))
                                .fixedSize(horizontal: false, vertical: true)
                                .fontWeight(.semibold)
                            Text(block.text)
                                .font(.custom(font, size: footnoteFontSize))
                                .fixedSize(horizontal: false, vertical: true)
                                .foregroundStyle(colors.foregroundLight)
                        }
                    }
                } else {
                    LazyVGrid(columns: Array(repeating: .init(.fixed(360), spacing: 40, alignment: .topLeading), count: 2), alignment: .center, spacing: 40) {
                        ForEach(Block.all) { block in
                            VStack(alignment: .leading, spacing: 4) {
                                Text(block.title)
                                    .font(.custom(font, size: subheadlineFontSize))
                                    .fixedSize(horizontal: false, vertical: true)
                                    .fontWeight(.semibold)
                                Text(block.text)
                                    .font(.custom(font, size: footnoteFontSize))
                                    .fixedSize(horizontal: false, vertical: true)
                                    .foregroundStyle(colors.foregroundLight)
                            }
                        }
                    }
                }
                
                Button {
                    Haptics.buttonTap()
                    dismiss()
                } label: {
                    HStack {
                        Text("Start Writing", bundle: .module)
                    }
                    .font(.custom(font, size: bodyFontSize).weight(.semibold))
                    .foregroundStyle(colors.accent)
                    .padding()
                    .background {
                        RoundedRectangle(cornerRadius: 24)
                            .stroke(colors.accent, lineWidth: 3)
                    }
                    .contentShape(.rect)
                }
                .font(.custom(font, size: headerFontSize).weight(.bold))
                .foregroundStyle(colors.accent)
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(.top, 24)
            }
            .frame(maxWidth: .infinity, alignment: .center)
            .padding(.horizontal, horizontalSpacing)
            .font(.custom(font, size: bodyFontSize))
            .foregroundStyle(colors.foreground)
        }
        .scrollBounceBehavior(.basedOnSize)
        .defaultScrollAnchor(horizontalSizeClass == .compact ? .top : .center)
#if !os(macOS)
        .contentMargins(.vertical, horizontalSizeClass == .compact ? 40 : 8, for: .scrollContent)
#endif
        .containerRelativeFrame(.horizontal, count: 1, spacing: horizontalSpacing)
    }
    
    public var body: some View {
        ScrollView(.horizontal) {
            LazyHStack(spacing: 0) {
                Slide1()
                    .id(1)
                
                Slide2()
                    .id(2)
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
        .buttonStyle(.plain)
        .background {
            if #available(iOS 18.0, macOS 15.0, *) {
                Rectangle()
                    .fill(Gradient(colors: [
                        colors.background.mix(with: .white, by: 0.15),
                        colors.background
                    ]))
                    .ignoresSafeArea()
            } else {
                colors.background
                    .ignoresSafeArea()
            }
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

extension OnboardingScreen {
    
    struct Block: Identifiable, Equatable {
        var id: String { title.localizedStringResource.key }
        var title: LocalizedStringResource
        var text: LocalizedStringResource
        
        init(title: LocalizedStringResource, text: String) {
            self.title = title
            self.text = LocalizedStringResource(String.LocalizationValue(text), bundle: .atURL(Bundle.module.bundleURL))
        }
        
        init(title: String, text: String) {
            self.title = LocalizedStringResource(String.LocalizationValue(title), bundle: .atURL(Bundle.module.bundleURL))
            self.text = LocalizedStringResource(String.LocalizationValue(text), bundle: .atURL(Bundle.module.bundleURL))
        }
        
        static let all: [Block] = [
            .init(
                title: LocalizedStringResource("1. Write freely for \(Configuration.defaultWordTarget) words", bundle: .atURL(Bundle.module.bundleURL)),
                text: "Let your thoughts flow without worrying about grammar, spelling, or making sense. There's no right or wrong way to do this."),
            .init(title: "2. Don't stop writing", text: "Keep typing even if you're not sure what to write about. Write about being stuck, what you see around you, or how you're feeling in the moment."),
            .init(title: "3. Make it a daily habit", text: "Try to do this first thing when you wake up, before checking social media or starting your day. Consistency matters more than perfection."),
            .init(title: "4. This is just for you", text: "Your writing is private and meant to clear your mind, not create something beautiful. Think of it as a mental warm-up to start your day with clarity and focus.")
        ]
    }
    
}

#Preview {
    OnboardingScreen(isPresented: .constant(true))
}
