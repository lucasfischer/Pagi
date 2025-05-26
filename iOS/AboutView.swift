import PagiKit
import SwiftUI

struct AboutView: View {
    private let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
    private let appBundle = Bundle.main.infoDictionary?["CFBundleVersion"] as? String
    
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
                VStack(spacing: 4) {
                    if let appVersion = appVersion, let appBundle = appBundle {
                        Text("Version \(appVersion) \(Text(verbatim: "(\(appBundle))").fontWeight(.regular))")
                    }
                    
                    Text("Copyright © \(Date(), format: Date.FormatStyle().year()) Lucas Fischer")
                        .opacity(0.5)
                }
                .font(.system(size: 12))
                .frame(maxWidth: .infinity, alignment: .center)
                .listRowBackground(Color.clear)
            }
            
        }
        .navigationTitle("About")
    }
}

struct AboutView_Previews: PreviewProvider {
    static var previews: some View {
        AboutView()
    }
}
