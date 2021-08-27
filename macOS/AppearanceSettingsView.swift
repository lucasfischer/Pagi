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
            
            Slider(value: $fontSize, in: 10...40, step: 1) {
                Text("Font Size (\(fontSize, specifier: "%.0f")):")
            } minimumValueLabel: {
                Image(systemName: "character")
                    .resizable()
                    .frame(width: 8, height: 8)
                    .foregroundColor(.secondary)
            } maximumValueLabel: {
                Image(systemName: "character")
                    .resizable()
                    .frame(width: 14, height: 14)
                    .foregroundColor(.secondary)
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

struct AppearanceSettingsView_Previews: PreviewProvider {
    static var previews: some View {
        AppearanceSettingsView()
    }
}
