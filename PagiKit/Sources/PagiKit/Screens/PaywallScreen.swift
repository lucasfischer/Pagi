import SwiftUI
import StoreKit

public struct PaywallScreen: View {
    @Environment(\.requestReview) var requestReview
    @Environment(\.dismiss) private var dismiss
    @StateObject var preferences = Preferences.shared
    @ObservedObject var store: Store
    
    @State private var product: Product?
    @State private var error: Error?
    
    public init(store: Store) {
        self.store = store
    }
    
    let font: String = iAFont.duo.fileName
    
    @ScaledMetric(relativeTo: .largeTitle) private var largeTitleFontSize = 64
    @ScaledMetric(relativeTo: .title) private var headerFontSize = 28
    @ScaledMetric(relativeTo: .body) private var bodyFontSize = 17
    @ScaledMetric(relativeTo: .subheadline) private var subheadlineFontSize = 15
    @ScaledMetric(relativeTo: .caption) private var captionFontSize = 12
    
    var colors: Theme.Colors { preferences.theme.colors }
    
    func fetchProducts() async {
        do {
            product = try await store.fetchProducts().first
        }
        catch {
            self.error = error
        }
    }
    
    func restore() async {
        do {
            try await store.refreshPurchasedProducts()
        } catch {
            self.error = error
        }
    }
    
    @ViewBuilder
    private func Header() -> some View {
        HStack {
            Button {
                Haptics.buttonTap()
                dismiss()
            } label: {
                Image(systemName: "arrow.left")
                    .font(.title)
                    .foregroundStyle(colors.foreground)
                    .contentShape(.rect)
            }
            Spacer()
            
            Button {
                Haptics.buttonTap()
                Task {
                    await restore()
                }
            } label: {
                Text("Restore", bundle: .module)
            }
            .tint(colors.foreground)
        }
        .buttonStyle(.plain)
    }
    
    @ViewBuilder
    private func ThankYou() -> some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Thank You!", bundle: .module)
                .font(.custom(font, size: headerFontSize).weight(.semibold))
                .foregroundColor(colors.foreground)
            
            Text("Your contribution helps me to continue improving Pagi for you. If you enjoy using Pagi, I would appreciate it if you can leave a review on the App Store.", bundle: .module)
                .fixedSize(horizontal: false, vertical: true)
                .font(.custom(font, size: bodyFontSize))
                .foregroundColor(colors.foregroundLight)
            
            Link(destination: Configuration.reviewURL) {
                HStack {
                    Text("Rate Pagi", bundle: .module)
                        .fontWeight(.semibold)
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 12)
                .background {
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(preferences.theme.colors.accent, lineWidth: 2.5)
                }
                .contentShape(.rect)
            }
            .padding(.top)
            .foregroundStyle(colors.accent)
            .buttonStyle(.plain)
            
            Spacer()
        }
    }
    
    @ViewBuilder
    private func PurchaseView(product: Product) -> some View {
        VStack(alignment: .leading, spacing: 40) {
            HStack {
                VStack(alignment: .leading, spacing: 16) {
                    Text("Purchase Pagi", bundle: .module)
                        .fixedSize(horizontal: false, vertical: true)
                        .font(.custom(font, size: headerFontSize).weight(.semibold))
                        .foregroundColor(colors.foreground)
                    
                    Text("Pagi is a paid app, but you can try out the full experience for \(Configuration.freeDays) days.\nThere is no free version with less features, just one paid version.", bundle: .module)
                        .fixedSize(horizontal: false, vertical: true)
                        .font(.custom(font, size: subheadlineFontSize))
                        .lineLimit(nil)
                        .lineSpacing(2)
                        .foregroundColor(colors.foregroundLight)
                }
                Spacer()
            }
            
            VStack(alignment: .leading) {
                Text(product.displayPrice)
                    .foregroundStyle(colors.accent)
                    .font(.custom(font, size: largeTitleFontSize).weight(.bold))
                Text("One time payment. \(Text("Valid for life.", bundle: .module).fontWeight(.bold))", bundle: .module)
                    .fixedSize(horizontal: false, vertical: true)
                    .foregroundStyle(colors.foreground)
                    .font(.custom(font, size: subheadlineFontSize))
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            
            Button {
                Haptics.buttonTap()
                Task {
                    do {
                        try await store.purchase(product: product)
                    } catch {
                        self.error = error
                    }
                }
            } label: {
                HStack {
                    Text("Purchase", bundle: .module)
                        .fontWeight(.semibold)
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 12)
                .background {
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(preferences.theme.colors.accent, lineWidth: 2.5)
                }
                .contentShape(.rect)
            }
            .foregroundStyle(colors.accent)
            .buttonStyle(.plain)
        }
    }
    
    @ViewBuilder
    private func Background() -> some View {
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
    
    @ViewBuilder
    private func Content() -> some View {
        ZStack {
            Background()
            
            VStack(alignment: .leading, spacing: 0) {
                Header()
                    .padding(.bottom, 40)
                
                if store.isUnlocked {
                    ThankYou()
                } else if let product {
                    PurchaseView(product: product)
                } else {
                    ProgressView()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
                
                Spacer(minLength: 40)
                
                Text("Pagi is developed by Lucas, as an independent project. It's crafted with longevity in mind: working completely offline with no user tracking or third-party dependencies. Updates to Pagi are sporadic, but you can be sure each version has been built to last.", bundle: .module)
                    .fixedSize(horizontal: false, vertical: true)
                    .multilineTextAlignment(.center)
                    .lineSpacing(2)
                    .foregroundStyle(colors.foregroundFaded)
                    .font(.custom(font, size: captionFontSize))
                
                Footer()
                    .padding(.top, 40)
            }
            .padding(.top, 24)
            .padding(.bottom, 24)
            .padding(.horizontal, 24)
            .font(.custom(font, size: bodyFontSize))
        }
        .tint(colors.accent)
        .errorAlert(error: $error)
        .onChange(of: store.isUnlocked) {
            if (store.isUnlocked) {
                requestReview()
            }
        }
        .task {
            await restore()
            await fetchProducts()
        }
    }
    
    public var body: some View {
        ZStack {
            Background()
            
            ViewThatFits(in: .vertical) {
                Content()
                
                ScrollView {
                    Content()
                }
            }
        }
#if os(macOS)
        .frame(width: 560, height: 640)
#endif
    }
}

extension PaywallScreen {
    
    private struct Footer: View {
        
        @ObservedObject var preferences = Preferences.shared
        
        @ScaledMetric(relativeTo: .caption2) private var circleSize = 2
        @ScaledMetric(relativeTo: .caption2) private var caption2FontSize = 11
        
        private let font: String = iAFont.duo.fileName
        
        private var circleColor: Color {
            preferences.theme.colors.foregroundFaded
        }
        
        @ViewBuilder
        private func SeparatorCircle() -> some View {
            Circle()
                .fill(circleColor)
                .frame(width: circleSize, height: circleSize)
        }
        
        @ViewBuilder
        private func Content() -> some View {
            Link(destination: Configuration.termsOfService) {
                Text("Terms", bundle: .module)
            }
            SeparatorCircle()
            Link(destination: Configuration.privacyPolicy) {
                Text("Privacy", bundle: .module)
            }
            SeparatorCircle()
            Link(destination: Configuration.supportEmailAddressURL) {
                Text("Help", bundle: .module)
            }
            SeparatorCircle()
            Link(destination: Configuration.webURL) {
                Text("What's Included", bundle: .module)
            }
        }
        
        var body: some View {
            ViewThatFits(in: .horizontal) {
                HStack(spacing: 8) {
                    Content()
                }
                VStack(spacing: 8) {
                    Content()
                }
            }
            .foregroundStyle(preferences.theme.colors.foregroundLight)
            .font(.custom(font, size: caption2FontSize))
            .frame(maxWidth: .infinity)
        }
    }
    
}

#Preview {
    PaywallScreen(store: .init())
}
