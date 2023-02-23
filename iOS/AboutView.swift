//
//  AboutView.swift
//  Pagi (iOS)
//
//  Created by Lucas Fischer on 23.02.23.
//

import SwiftUI

struct AboutView: View {
    private let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
    private let appBundle = Bundle.main.infoDictionary?["CFBundleVersion"] as? String
    
    var body: some View {
        Form {
            Section {
                Link("Help", destination: URL(string: "https://pagi.lucas.love")!)
                
                Link("Contact", destination: URL(string: "mailto:xoxo@lucas.love?subject=Pagi")!)
                
                Link("Rate Pagi", destination: URL(string: "https://apps.apple.com/app/id1586446074?action=write-review")!)
                
                Link("Development Journal", destination: URL(string: "https://futureland.tv/lucas/pagi")!)
            }
            
            NavigationLink("Acknowlegements") {
                Form {
                    Link("iA Writer Typeface", destination: URL(string: "https://github.com/iaolo/iA-Fonts")!)
                }
                .navigationTitle("Acknowlegements")
            }
            
            // MARK: App Version
            Section {
                VStack(spacing: 4) {
                    if let appVersion = appVersion, let appBundle = appBundle {
                        Text("Version \(appVersion) (\(appBundle))")
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
