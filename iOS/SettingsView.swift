//
//  SettingsView.swift
//  SettingsView
//
//  Created by Lucas Fischer on 11.09.21.
//

import SwiftUI

struct SettingsView: View {
    @Environment(\.dismiss) var dismiss
    
    @StateObject private var preferences = Preferences.shared
    
    let formatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        return formatter
    }()
    
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
                                value: $preferences.wordTarget.animation(.spring()),
                                formatter: formatter,
                                prompt: Text("Word Target")
                            )
                            .keyboardType(.numberPad)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.trailing)
                        }
                        
                        Toggle("Word Count", isOn: $preferences.wordCount.animation(.spring()))
                        Toggle("Progress Bar", isOn: $preferences.progressBar.animation(.spring()))
                        Toggle("Spell Checker", isOn: $preferences.isSpellCheckingEnabled)
                        Toggle("Focus Mode", isOn: $preferences.isFocusModeEnabled)
                        Picker("Focus:", selection: $preferences.focusType) {
                            ForEach(FocusType.allCases, id: \.self) { type in
                                Button(type.title) {
                                    preferences.focusType = type
                                }
                            }
                        }
                    }
                    
                    Section("Appearance", content: {
                        Slider(value: $preferences.fontSize, in: 10...40, step: 1) {
                            Text("Font Size (\(preferences.fontSize, specifier: "%.0f")):")
                        } minimumValueLabel: {
                            Image(systemName: "textformat.size.smaller")
                        } maximumValueLabel: {
                            Image(systemName: "textformat.size.larger")
                        }
                        .foregroundColor(.secondary)
                        
                        Picker("Font", selection: $preferences.font) {
                            ForEach(iAFont.allCases, id: \.self) { font in
                                Text(verbatim: font.rawValue)
                            }
                        }
                        
                        ScrollViewReader { proxy in
                            ScrollView(.horizontal) {
                                HStack {
                                    ForEach(Theme.allCases, id: \.self) { theme in
                                        Button {
                                            preferences.theme = theme
                                        } label: {
                                            ThemePreview(
                                                theme: theme,
                                                font: preferences.font,
                                                isActive: theme == preferences.theme
                                            )
                                        }
                                        .buttonStyle(.plain)
                                        .id(theme)
                                    }
                                }
                                .padding(8)
                                .padding(.bottom)
                            }
                            .onAppear {
                                proxy.scrollTo(preferences.theme, anchor: .center)
                            }
                        }
                        
                        if preferences.theme == .custom {
                            ColorPicker("Text", selection: $preferences.foregroundColor, supportsOpacity: false)
                            ColorPicker("Background", selection: $preferences.backgroundColor, supportsOpacity: false)
                            ColorPicker("Accent", selection: $preferences.accentColor, supportsOpacity: false)
                        }
                    })
                    
                    NavigationLink("About") {
                        AboutView()
                    }
                }
            }
            .tint(preferences.theme.colors.accent)
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
