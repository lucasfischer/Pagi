//
//  ThemePicker.swift
//  Pagi
//
//  Created by Lucas Fischer on 22.03.23.
//

import SwiftUI

struct ThemePicker: View {
    @Binding var theme: Theme
    @Binding var font: iAFont
    
    @ViewBuilder
    func CustomScrollView<Content: View>(@ViewBuilder content: () -> Content) -> some View{
#if os(macOS)
        ScrollView(.horizontal) {
            content()
        }
        .background(
            RoundedRectangle(cornerRadius: 8)
                .foregroundColor(
                    Color(NSColor.textBackgroundColor)
                )
        )
#else
        ScrollView(.horizontal) {
            content()
        }
#endif
    }
    
    var body: some View {
        ScrollViewReader { proxy in
            CustomScrollView {
                HStack {
                    ForEach(Theme.allCases, id: \.self) { theme in
                        Button {
#if os(iOS)
                            Haptics.selectionChanged()
#endif
                            self.theme = theme
                        } label: {
                            ThemePreview(
                                theme: theme,
                                font: font,
                                isActive: theme == self.theme
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
                proxy.scrollTo(self.theme, anchor: .center)
            }
        }
    }
}

struct ThemePicker_Previews: PreviewProvider {
    static var previews: some View {
        ThemePicker(theme: .constant(.dark), font: .constant(.duo))
    }
}
