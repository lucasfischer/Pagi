import SwiftUI

public struct Editor<Content: View>: View {
    @Binding var text: String
    @ObservedObject var viewModel: EditorViewModel
    @ViewBuilder var editor: () -> Content
    
    @StateObject var preferences = Preferences.shared
    
    private let progressBarHeight: CGFloat = 24
    
    public init(text: Binding<String>, viewModel: EditorViewModel, editor: @escaping () -> Content) {
        self._text = text
        self.viewModel = viewModel
        self.editor = editor
    }
    
    @ViewBuilder
    func wordCount() -> some View {
        HStack {
            Spacer()
            
            if preferences.wordCount {
                Text("\(viewModel.words)W")
                    .font(
                        .custom(preferences.font.fileName, size: 12)
                        .monospacedDigit()
                    )
                    .foregroundColor(preferences.theme.colors.foregroundLight)
                    .padding(.trailing, 10)
                    .transition(.move(edge: .trailing))
                    .animation(nil, value: viewModel.words)
            }
        }
        .padding(.bottom, viewModel.progressBarVisible ? 0 : 10)
        .animation(.interactiveSpring(), value: viewModel.overlayHover)
        .animation(.default, value: viewModel.words)
    }
    
    @ViewBuilder
    func progressBar() -> some View {
        VStack(spacing: 0) {
            if viewModel.progressBarVisible {
                ProgressBar(
                    percent: viewModel.percent,
                    color: preferences.theme.colors.accent,
                    height: viewModel.isProgressBarExpanded ? progressBarHeight : 5
                )
                .transition(.move(edge: .bottom))
                .animation(.default, value: viewModel.words)
                .animation(.interactiveSpring(), value: viewModel.overlayHover)
                .overlay (
                    VStack {
                        if viewModel.isProgressBarExpanded {
                            Label(viewModel.successText, systemImage: "checkmark")
                                .transition(.offset(x: 0, y: progressBarHeight))
                        }
                    }
                        .textSelectionEnabled()
                        .font(
                            .custom(preferences.font.fileName, size: 12)
                            .monospacedDigit()
                        )
                        .foregroundColor(preferences.theme.colors.background)
                        .animation(.interactiveSpring(), value: viewModel.overlayHover)
                )
            }
        }
    }
    
    public var body: some View {
        VStack(spacing: 0) {
            editor()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(preferences.theme.colors.background)
        .overlay(
            VStack {
                VStack {
                    wordCount()
                    progressBar()
                }
                .onHover(perform: { hover in
                    viewModel.overlayHover = hover
                })
            }
                .frame(maxHeight: .infinity, alignment: .bottom)
        )
        .onAppear {
            viewModel.calculateWordCount(text)
        }
        .onChange(of: text) {
            viewModel.calculateWordCount(text, typing: true)
        }
    }
}
