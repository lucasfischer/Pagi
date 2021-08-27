//
//  SettingsView.swift
//  Pagi
//
//  Created by Lucas Fischer on 05.06.21.
//

import SwiftUI

struct SettingsView: View {
    private enum Tabs: Hashable {
        case general, appearance
    }
    
    var body: some View {
        TabView() {
            
            GeneralSettingsView()
                .tabItem {
                    Label("General", systemImage: "gear")
                }
                .tag(Tabs.general)
            
            AppearanceSettingsView()
                .tabItem {
                    Label("Appearance", systemImage: "heart.text.square")
                }
                .tag(Tabs.appearance)
            
        }
        .padding()
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}
