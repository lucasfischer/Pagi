//
//  GeneralSettingsView.swift
//  Pagi
//
//  Created by Lucas Fischer on 05.06.21.
//

import SwiftUI

struct GeneralSettingsView: View {
    @AppStorage("wordTarget") private var wordTarget = 1500
    @AppStorage("theme") private var theme = Theme.system
    @AppStorage("font") private var font = iAFont.duo
    @AppStorage("wordCount") private var wordCount = true
    
    let formatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        return formatter
    }()
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            
            // Word Target
            HStack {
                Text("Word Target:")
                    .frame(width: 128, alignment: .trailing)
                
                TextField("Word Target", value: $wordTarget, formatter: formatter)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .frame(width: 80)
            }
            
            // Word Count
            HStack {
                Text("Show Word Count:")
                    .frame(width: 128, alignment: .trailing)
                
                Toggle("", isOn: $wordCount)
            }
            
            // Font
            HStack {
                Text("Font:")
                    .frame(width: 128, alignment: .trailing)
                
                Picker("", selection: $font) {
                    ForEach(iAFont.allCases, id: \.self) { font in
                        Text("\(font.rawValue)")
                    }
                }
                .offset(x: -10)
                .pickerStyle(SegmentedPickerStyle())
                .frame(width: 160)
            }
            
            // Theme
            HStack {
                Text("Theme:")
                    .frame(width: 128, alignment: .trailing)
                
                Picker("", selection: $theme) {
                    ForEach(Theme.allCases, id: \.self) { theme in
                        Text("\(theme.rawValue)")
                    }
                }
                .offset(x: -10)
                .pickerStyle(SegmentedPickerStyle())
                .frame(width: 160)
            }
        }
        .padding()
        .environment(\.colorScheme, .dark)
    }
}

struct GeneralSettingsView_Previews: PreviewProvider {
    static var previews: some View {
        GeneralSettingsView()
    }
}
