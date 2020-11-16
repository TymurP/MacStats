//
//  ContentView.swift
//  MacStats
//
//  Created by Tymur Pysarevych on 10.11.20.
//

import SwiftUI

var badge = BadgeContent()
struct ContentView: View {
    
    var body: some View {
        Group {
            TabView() {
                HStack {
                    badge
                    VSplitView{}.frame(width: 1.0)
                    
                    Text("Test").frame(maxWidth: .infinity, maxHeight: .infinity)
                }
                .tabItem { Text("CPU") }.tag(1)
                
                Text("Tab Content 2").tabItem { Text("Tab Label 2") }.tag(2)
            }
            .frame(width: 600.0, height: 500.0)
            .padding(.top)
        }
    }
    struct ContentView_Previews: PreviewProvider {
        static var previews: some View {
            Group {
                ContentView().padding(.all)
            }
        }
    }
}
