//
//  ThemePreview.swift
//  Pagi
//
//  Created by Lucas Fischer on 07.02.23.
//

import SwiftUI

struct ThemePreview: View {
    var theme: Theme
    var font: iAFont
    var isActive: Bool
    
    @StateObject private var preferences = Preferences.shared
    
    var body: some View {
        VStack {
            VStack {
                Text("Lorem ipsum dolor sit amet, consectetur adipiscing elit. ")
                    .foregroundColor(theme.colors.foregroundFaded)
                + Text("Fusce nec lobortis elit. ")
                    .foregroundColor(theme.colors.foreground)
                + Text("Morbi nec leo ut est sollicitudin volutpat ac id orci.")
                    .foregroundColor(theme.colors.foregroundFaded)
                + Text("|")
                    .foregroundColor(theme.colors.accent)
            }
            .font(.custom(font.fileName, fixedSize: 6))
            .lineSpacing(0.5)
            .padding(.horizontal, 8)
            .frame(width: 90, height: 90)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .foregroundColor(theme.colors.background)
                    .padding(2)
            )
            .background(
                isActive ? RoundedRectangle(cornerRadius: 8)
                    .foregroundColor(.accentColor) : nil
            )
            
            theme.text
        }
    }
}

struct ThemePreview_Previews: PreviewProvider {
    static var previews: some View {
        HStack {
            ThemePreview(theme: .neon, font: .duo, isActive: true)
            ThemePreview(theme: .oneDark, font: .duo, isActive: false)
            ThemePreview(theme: .pastel, font: .duo, isActive: false)
        }
        .padding()
    }
}
