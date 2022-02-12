//
//  AboutView.swift
//  Pagi (iOS)
//
//  Created by Lucas Fischer on 11.10.21.
//

import SwiftUI

struct AboutView: View {
    var year: String {
        Date().formatted(.dateTime.year())
    }
    
    var body: some View {
        Form {
            Section {
                Link("iA Writer Typeface", destination: URL(string: "https://github.com/iaolo/iA-Fonts")!)
            } header: {
                Text("Acknowlegements")
            }
            
            Section {
                Link("lucas.love", destination: URL(string: "https://lucas.love")!)
                Link("lucas-fischer.com", destination: URL(string: "https://lucas-fischer.com")!)
            } header: {
                Text("Copyright © \(year) Lucas Fischer")
            }
        }
    }
}

struct AboutView_Previews: PreviewProvider {
    static var previews: some View {
        AboutView()
    }
}
