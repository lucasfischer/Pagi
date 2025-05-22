import SwiftUI
import StoreKit

struct PaywallScreen: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject var preferences = Preferences.shared
    @ObservedObject var store: Store
    
    @State private var product: Product?
    @State private var error: Error?
    
    let font: String = iAFont.duo.fileName
    
    @ScaledMetric(relativeTo: .largeTitle) private var largeTitleFontSize = 64
    @ScaledMetric(relativeTo: .title) private var headerFontSize = 28
    @ScaledMetric(relativeTo: .body) private var bodyFontSize = 17
    @ScaledMetric(relativeTo: .subheadline) private var subheadlineFontSize = 15
    @ScaledMetric(relativeTo: .caption) private var captionFontSize = 12
    @ScaledMetric(relativeTo: .caption2) private var caption2FontSize = 11
    
    var colors: Theme.Colors { preferences.theme.colors }
    
    func fetchProducts() async {
        do {
            product = try await store.fetchProducts().first
        }
        catch {
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
            
            Button("Restore") {
                Haptics.buttonTap()
                Task {
                    await store.refreshPurchasedProducts()
                }
            }
            .tint(colors.foreground)
        }
    }
    
    @ViewBuilder
    private func ThankYou() -> some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Thank You!")
                .font(.custom(font, size: headerFontSize).weight(.semibold))
                .foregroundColor(colors.foreground)
            
            Text("Your contribution helps me to continue improving Pagi for you. If you enjoy using Pagi, I would appreciate it if you can leave a review on the App Store.")
                .font(.custom(font, size: bodyFontSize))
                .foregroundColor(colors.foregroundLight)
            
            Link(destination: Configuration.reviewURL) {
                HStack {
                    Text("Rate Pagi")
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
            Spacer()
        }
    }
    
    @ViewBuilder
    private func Footer() -> some View {
        HStack(spacing: 8) {
            Link("Terms", destination: Configuration.termsOfService)
            Circle()
                .fill(.white.opacity(0.2))
                .frame(width: 2, height: 2)
            Link("Privacy", destination: Configuration.privacyPolicy)
            Circle()
                .fill(.white.opacity(0.2))
                .frame(width: 2, height: 2)
            Link("Help", destination: Configuration.supportEmailAddressURL)
            Circle()
                .fill(.white.opacity(0.2))
                .frame(width: 2, height: 2)
            Link("What's Included", destination: Configuration.webURL)
        }
        .foregroundStyle(colors.foregroundLight)
        .font(.custom(font, size: caption2FontSize))
        .frame(maxWidth: .infinity)
    }
    
    var body: some View {
        ZStack {
            Rectangle()
                .fill(Gradient(colors: [
                    colors.background.mix(with: .white, by: 0.15),
                    colors.background
                ]))
                .ignoresSafeArea()
            
            VStack(alignment: .leading, spacing: 40) {
                Header()
                
                if store.isEntitled {
                    ThankYou()
                } else if let product {
                    HStack {
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Unlock Pagi")
                                .font(.custom(font, size: headerFontSize).weight(.semibold))
                                .foregroundColor(colors.foreground)
                            
                            Text("Pagi is a paid app, but you can try out the full experience for \(Configuration.freeDays) days.\nThere is no free version with less features, just one paid version.")
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
                        Text("One time payment. \(Text("Valid for life.").fontWeight(.bold))")
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
                            Text("Purchase")
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
                } else {
                    ProgressView()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
                
                Spacer(minLength: 0)
                
                Text("Pagi is developed by Lucas, as an independent project. It's crafted with longevity in mind: working completely offline with no user tracking or third-party dependencies. Updates to Pagi are sporadic, but you can be sure each version has been built to last.")
                    .fixedSize(horizontal: false, vertical: true)
                    .multilineTextAlignment(.center)
                    .lineSpacing(2)
                    .foregroundStyle(colors.foregroundFaded)
                    .font(.custom(font, size: captionFontSize))
                
                Footer()
            }
            .padding(.top, 24)
            .padding(.bottom, 24)
            .padding(.horizontal, 24)
            .font(.custom(font, size: bodyFontSize))
        }
        .tint(colors.accent)
        .errorAlert(error: $error)
        .task {
            await fetchProducts()
            await store.refreshPurchasedProducts()
        }
    }
}

#Preview {
    PaywallScreen(store: .init())
}
