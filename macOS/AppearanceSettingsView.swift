//
//  AppearanceSettingsView.swift
//  AppearanceSettingsView
//
//  Created by Lucas Fischer on 27.08.21.
//

import SwiftUI

struct AppearanceSettingsView: View {
    @AppStorage("theme") private var theme = Theme.system
    @AppStorage("font") private var font = iAFont.duo
    @AppStorage("fontSize") private var fontSize = 18.0
    
    var body: some View {
        
        Form {
            Slider(
                value: $fontSize,
                in: 10...40, step: 1,
                minimumValueLabel: SliderLabel(size: 8),
                maximumValueLabel: SliderLabel(size: 14)
            ) {
                Text("Font Size (\(fontSize, specifier: "%.0f")):")
            }
            
            Picker("Font:", selection: $font) {
                ForEach(iAFont.allCases, id: \.self) { font in
                    Text("\(font.rawValue)")
                }
            }
            
            Picker("Theme:", selection: $theme) {
                ForEach(Theme.allCases, id: \.self) { theme in
                    Text("\(theme.rawValue)")
                }
            }
        }
        .padding()
        .frame(width: 320)
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
