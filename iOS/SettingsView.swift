//
//  SettingsView.swift
//  SettingsView
//
//  Created by Lucas Fischer on 11.09.21.
//

import SwiftUI

struct SettingsView: View {
    
    let storageURL: URL?
    
    @Environment(\.dismiss) var dismiss
    @Environment(\.openURL) var openURL
    
    @StateObject private var preferences = Preferences.shared
    
    let formatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        return formatter
    }()
    
    private var storageLocationURL: URL? {
        if let url = storageURL,
           var components = URLComponents(url: url, resolvingAgainstBaseURL: false) {
            components.scheme = "shareddocuments"
            guard let url = components.url else { return nil }
            guard UIApplication.shared.canOpenURL(url) else { return nil }
            return url
        } else {
            return nil
        }
    }
    
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
                        Toggle("Autocorrection", isOn: $preferences.isAutocorrectionEnabled)
                        Toggle("Haptic Feedback", isOn: $preferences.isHapticsEnabled)
                        Toggle("Focus Mode", isOn: $preferences.isFocusModeEnabled)
                        Picker("Focus", selection: $preferences.focusType) {
                            ForEach(FocusType.allCases, id: \.self) { type in
                                Button(type.title) {
                                    preferences.focusType = type
                                }
                            }
                        }
                        .onChange(of: preferences.focusType) {
                            Haptics.selectionChanged()
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
                        .onChange(of: preferences.fontSize) {
                            Haptics.selectionChanged()
                        }
                        .foregroundColor(.secondary)
                        
                        Picker("Font", selection: $preferences.font) {
                            ForEach(iAFont.allCases, id: \.self) { font in
                                Text(verbatim: font.rawValue)
                            }
                        }
                        .onChange(of: preferences.font) {
                            Haptics.selectionChanged()
                        }
                        
                        ThemePicker(theme: $preferences.theme, font: $preferences.font)
                        
                        if preferences.theme == .custom {
                            ColorPicker("Text", selection: $preferences.foregroundColor, supportsOpacity: false)
                            ColorPicker("Background", selection: $preferences.backgroundColor, supportsOpacity: false)
                            ColorPicker("Accent", selection: $preferences.accentColor, supportsOpacity: false)
                        }
                    })
                    
                    Section {
                        if let url = storageLocationURL {
                            Button("Open Storage Location") {
                                Haptics.buttonTap()
                                openURL(url)
                            }
                        }
                        Picker("Default File Type", selection: $preferences.exportType) {
                            ForEach(FileType.allCases, id: \.self) { type in
                                Button(type.name) {
                                    preferences.exportType = type
                                }
                            }
                        }
                        .onChange(of: preferences.exportType) {
                            Haptics.selectionChanged()
                        }
                    } header: {
                        Text("Files")
                    } footer: {
                        Text("Saved files will have the .\(preferences.exportType.type.preferredFilenameExtension ?? "") extension.")
                    }
                    
                    Button("Show Onboarding") {
                        Haptics.buttonTap()
                        dismiss()
                        preferences.isOnboardingPresented = true
                    }
                    
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
                        Haptics.selectionChanged()
                        dismiss()
                    }
                }
            }
        }
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView(storageURL: MockStorageLocationProvider().storageURL)
            .navigationViewStyle(.stack)
    }
}
