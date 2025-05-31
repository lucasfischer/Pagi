import PagiKit
import SwiftUI
import StoreKit

struct AboutView: View {
    private let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
    private let appBundle = Bundle.main.infoDictionary?["CFBundleVersion"] as? String
    
    @State private var appTransaction: AppTransaction?
    @State private var error: Error?
    
    @ObservedObject var preferences = Preferences.shared
    
    private var colors: Theme.Colors {
        preferences.theme.colors
    }
    
    private func onAppear() async {
        do {
            let shared = try await AppTransaction.shared
            switch shared {
                case .verified(let transaction):
                    self.appTransaction = transaction
                case .unverified(let transaction, let error):
                    self.error = error
                    self.appTransaction = transaction
            }
        } catch {
            self.error = error
        }
    }
    
    var body: some View {
        Form {
            Section {
                Link("Help", destination: Configuration.webURL)
                
                Link("Contact", destination: Configuration.supportEmailAddressURL)
                
                Link("Rate Pagi", destination: Configuration.reviewURL)
                
                Link("Development Journal", destination: URL(string: "https://futureland.tv/lucas/pagi")!)
            }
            
            NavigationLink("Acknowlegements") {
                Form {
                    Link(destination: URL(string: "https://github.com/iaolo/iA-Fonts")!) {
                        Text(verbatim: "iA Writer Typeface")
                    }
                }
                .navigationTitle("Acknowlegements")
            }
            
            // MARK: App Version
            Section {
                VStack(spacing: 16) {
                    if let appVersion = appVersion, let appBundle = appBundle {
                        VStack(spacing: 0) {
                            Text(verbatim: "Current Version")
                                .foregroundStyle(colors.foregroundLight)
                            Text(verbatim: "\(appVersion) (\(appBundle))")
                        }
                    }
                    
                    if let appTransaction {
                        VStack(spacing: 0) {
                            Text(verbatim: "Original Version")
                                .foregroundStyle(colors.foregroundLight)
                            Text(appTransaction.originalAppVersion)
                        }
                        
                        VStack(spacing: 0) {
                            Text(verbatim: "Original Purchase Date")
                                .foregroundStyle(colors.foregroundLight)
                            Text(appTransaction.originalPurchaseDate.formatted(Date.FormatStyle(date: .numeric, time: .shortened).timeZone()))
                        }
                    }
                    
                    Text("Copyright © \(Date(), format: Date.FormatStyle().year()) Lucas Fischer")
                        .foregroundStyle(colors.foregroundLight)
                }
                .font(.system(size: 12))
                .frame(maxWidth: .infinity, alignment: .center)
                .listRowBackground(Color.clear)
            }
            
        }
        .navigationTitle("About")
        .errorAlert(error: $error)
        .task(onAppear)
    }
}

struct AboutView_Previews: PreviewProvider {
    static var previews: some View {
        AboutView()
    }
}
