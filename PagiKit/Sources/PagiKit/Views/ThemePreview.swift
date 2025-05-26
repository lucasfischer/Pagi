import SwiftUI

public struct ThemePreview: View {
    var theme: Theme
    var font: iAFont
    var isActive: Bool
    
    @StateObject private var preferences = Preferences.shared
    
    public var body: some View {
        VStack {
            VStack {
                Text(verbatim: "Lorem ipsum dolor sit amet, consectetur adipiscing elit. ")
                    .foregroundColor(theme.colors.foregroundFaded)
                + Text(verbatim: "Fusce nec lobortis elit. ")
                    .foregroundColor(theme.colors.foreground)
                + Text(verbatim: "Morbi nec leo ut est sollicitudin volutpat ac id orci.")
                    .foregroundColor(theme.colors.foregroundFaded)
                + Text(verbatim: "|")
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
