//
//  SettingsView.swift
//  SettingsView
//
//  Created by Lucas Fischer on 11.09.21.
//

import SwiftUI

struct SettingsView: View {
    @Environment(\.dismiss) var dismiss
    
    @AppStorage("wordTarget") private var wordTarget = 1500
    @AppStorage("wordCount") private var wordCount = true
    @AppStorage("progressBar") private var progressBar = true
    @AppStorage("isSpellCheckingEnabled") private var isSpellCheckingEnabled = false
    @AppStorage("focusMode") private var isFocusModeEnabled = false
    @AppStorage("focusType") private var focusType = FocusType.sentence
    
    @AppStorage("theme") private var theme = Theme.system
    @AppStorage("font") private var font = iAFont.duo
    @AppStorage("fontSize") private var fontSize = 18.0
    
    let formatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        return formatter
    }()
    
    let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
    let appBundle = Bundle.main.infoDictionary?["CFBundleVersion"] as? String
    
    var body: some View {
        NavigationView {
            VStack {
                Form {
                    Section("General") {
                        HStack {
                            Text("Word Target")
                            
                            Spacer()
                            
                            TextField(
                                "Word Target",
                                value: $wordTarget.animation(.spring()),
                                formatter: formatter,
                                prompt: Text("Word Target")
                            )
                                .keyboardType(.numberPad)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.trailing)
                        }
                        
                        Toggle("Word Count", isOn: $wordCount.animation(.spring()))
                        Toggle("Progress Bar", isOn: $progressBar.animation(.spring()))
                        Toggle("Spell Checker", isOn: $isSpellCheckingEnabled)
                        Toggle("Focus Mode", isOn: $isFocusModeEnabled)
                        Picker("Focus:", selection: $focusType) {
                            ForEach(FocusType.allCases, id: \.self) { type in
                                Button(type.title) {
                                    focusType = type
                                }
                            }
                        }
                    }
                    
                    Section("Appearance", content: {
                        Slider(value: $fontSize, in: 10...40, step: 1) {
                            Text("Font Size (\(fontSize, specifier: "%.0f")):")
                        } minimumValueLabel: {
                            Image(systemName: "textformat.size.smaller")
                        } maximumValueLabel: {
                            Image(systemName: "textformat.size.larger")
                        }
                        .foregroundColor(.secondary)
                        
                        Picker("Font", selection: $font) {
                            ForEach(iAFont.allCases, id: \.self) { font in
                                Text(verbatim: font.rawValue)
                            }
                        }
                        
                        Picker("Theme", selection: $theme) {
                            ForEach(Theme.allCases, id: \.self) { theme in
                                Text(verbatim: theme.rawValue)
                            }
                        }
                    })
                    
                    // MARK: App Version
                    if let appVersion = appVersion, let appBundle = appBundle {
                        HStack {
                            Text("Version")
                            
                            Spacer()
                            
                            Text("\(appVersion) (\(appBundle))")
                                .foregroundColor(.secondary)
                        }
                    }
                    NavigationLink("Acknowlegements") {
                        Form {
                            Link("iA Writer Typeface", destination: URL(string: "https://github.com/iaolo/iA-Fonts")!)
                        }
                        .navigationTitle("Acknowlegements")
                    }
                }
            }
            .tint(.accentColor)
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
            .navigationViewStyle(.stack)
    }
}
