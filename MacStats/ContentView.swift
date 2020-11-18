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
                HStack {
                    CPUBadge()
                    VSplitView{}.frame(width: 1.0)
                    ProcessList()
                }
                .tabItem { Text("CPU") }.tag(1)
                
                HStack {
                    /*var heatSum: CGFloat = 0
                     do {
                     for sensor in Utils.tempSensors {
                     let temp = CGFloat(try SMCKit.temperature(sensor.code, unit: TemperatureUnit.celius))
                     heatSum = heatSum + temp
                     }
                     } catch { print("Error in: CPU -> Sensors") }
                     
                     self.gradient = getGradient(heatSum: (heatSum / CGFloat(Utils.tempSensors.count)))*/
                }.tabItem { Text("Fans") }.tag(2)
            }
            .frame(width: 600.0, height: 500.0)
            .padding(.top)
        }
    }
}

#if DEBUG
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
#endif
