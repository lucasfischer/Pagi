//
//  AppearanceSettingsView.swift
//  AppearanceSettingsView
//
//  Created by Lucas Fischer on 27.08.21.
//

import SwiftUI

struct AppearanceSettingsView: View {
    @StateObject private var preferences = Preferences.shared
    
    var body: some View {
        
        Form {
            Slider(
                value: $preferences.fontSize,
                in: 10...40, step: 1,
                minimumValueLabel: SliderLabel(size: 8),
                maximumValueLabel: SliderLabel(size: 14)
            ) {
                Text("Font Size (\(preferences.fontSize, specifier: "%.0f")):")
                    .font(.system(.body).monospacedDigit())
            }
            
            Picker("Font:", selection: $preferences.font) {
                ForEach(iAFont.allCases, id: \.self) { font in
                    Text(verbatim: font.rawValue)
                }
            }
            
            
            if #available(macOS 13.0, *) {
                LabeledContent("Theme:") {
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
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .foregroundColor(
                                    Color(NSColor.textBackgroundColor)
                                )
                        )
                        .onAppear {
                            proxy.scrollTo(preferences.theme, anchor: .center)
                        }
                    }
                }
            }
            
            if preferences.theme == .custom {
                ColorPicker("Text:", selection: $preferences.foregroundColor, supportsOpacity: false)
                ColorPicker("Background:", selection: $preferences.backgroundColor, supportsOpacity: false)
                ColorPicker("Accent:", selection: $preferences.accentColor, supportsOpacity: false)
            }
        }
        .padding()
        .frame(width: 400)
        .pickerStyle(SegmentedPickerStyle())
        
    }
}

extension AppearanceSettingsView {
    struct SliderLabel: View {
        var size: Double
        
        var body: some View {
            Image(systemName: "character")
                .resizable()
                .frame(width: size, height: size)
                .foregroundColor(.secondary)
        }
    }
}

struct AppearanceSettingsView_Previews: PreviewProvider {
    static var previews: some View {
        AppearanceSettingsView()
    }
}
