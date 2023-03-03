//
//  AboutView.swift
//  Pagi (macOS)
//
//  Created by Lucas Fischer on 28.09.21.
//

import SwiftUI
import AppKit

struct AboutView: View {
    let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
    let appBundle = Bundle.main.infoDictionary?["CFBundleVersion"] as? String
    
    @State private var showAck = false
    
    @ViewBuilder
    func makeFooter() -> some View {
        HStack {
            HoverLink("© Lucas Fischer", destination: URL(string: "https://lucas-fischer.com")!)
                .foregroundColor(.foreground)
            
            Spacer()
            
            HoverLink("❤️", destination: URL(string: "https://lucas.love")!)
        }
    }
    
    var body: some View {
        VStack {
            Image(nsImage: NSImage(named: "AppIcon")!)
                .padding(.top)
            
            // MARK: App Name
            Text("Pagi")
                .font(.title)
                .fontWeight(.bold)
            
            // MARK: App Version
            if let appVersion = appVersion, let appBundle = appBundle {
                Text("Version \(appVersion) (\(appBundle))")
                    .padding(.top, 1)
            }
            
            // MARK: Acknowlegements
            VStack(alignment: .leading, spacing: 4) {
                HoverButton(action: { showAck.toggle() }) {
                    Text("Acknowlegements")
                        .fontWeight(.medium)
                }
                .popover(isPresented: $showAck) {
                    VStack(alignment: .leading) {
                        HoverLink("iA Writer Typeface", destination: URL(string: "https://github.com/iaolo/iA-Fonts")!)
                    }
                    .padding()
                }
            }
            .padding(.top)
            
            Spacer()
            
            // MARK: Footer
            makeFooter()
                .padding(12)
        }
        .frame(width: 320, height: 320)
        .buttonStyle(PlainButtonStyle())
        .background(Color.background.ignoresSafeArea())
    }
}

extension AboutView {
    struct HoverButton<Label: View>: View {
        var action: () -> Void
        @ViewBuilder var label: Label
        
        @State private var isHover = false
        
        var body: some View {
            Button(action: action) {
                label
            }
            .padding(.vertical, 2)
            .padding(.horizontal, 4)
            .background(Color.foregroundLight.opacity(isHover ? 0.2 : 0).cornerRadius(5))
            .onHover { isHover = $0 }
        }
    }
    
    struct HoverLink: View {
        var label: LocalizedStringKey
        var destination: URL
        
        @State private var isHover = false
        
        init(_ label: LocalizedStringKey, destination: URL) {
            self.label = label
            self.destination = destination
        }
        
        var body: some View {
            Link(label, destination: destination)
                .padding(.vertical, 2)
                .padding(.horizontal, 4)
                .background(Color.foregroundLight.opacity(isHover ? 0.2 : 0).cornerRadius(5))
                .onHover { isHover = $0 }
        }
    }
}

struct AboutView_Previews: PreviewProvider {
    static var previews: some View {
        AboutView()
    }
}
