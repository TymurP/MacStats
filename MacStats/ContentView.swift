//
//  ContentView.swift
//  MacStats
//
//  Created by Tymur Pysarevych on 10.11.20.
//

import SwiftUI

struct ContentView: View {
    
    //-------------------------------------
    //  MARK: BUILD CPU-TAB
    //-------------------------------------
    var body: some View {
        Group {
            TabView() {
                VStack {
                    CPUHeatView()
                    Divider()
                    ProcessList()
                }
                .tabItem { Text("CPU") }.tag(1)
                VStack {
                    TemperatureView()
                }.tabItem { Text("Fans") }.tag(2)
            }
            .frame(width: 600.0, height: 500.0, alignment: .top)
            .padding(.top)
        }.animation(Animation.easeInOut)
    }
}

#if DEBUG
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
#endif
