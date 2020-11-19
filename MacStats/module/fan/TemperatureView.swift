//
//  FanView.swift
//  MacStats
//
//  Created by Tymur Pysarevych on 19.11.20.
//

import SwiftUI

struct TemperatureView: View {
    //-------------------------------------
    //  MARK: VARIABLES
    //-------------------------------------
    @State var dynamicSize: CGFloat = 200
    @State var gradient: CGFloat = 0
    @State var heat: CGFloat = 0
    @State var tempSensor: FourCharCode = 0
    
    static let gradientStart = Color(red: 0xEC / 255, green: 0x2F / 255, blue: 0x4B / 255)
    static let gradientEnd = Color(red: 0x00 / 255, green: 0x9F / 255, blue: 0xFF / 255)
    
    //-------------------------------------
    //  MARK: BUILD UI
    //-------------------------------------
    var body: some View {
        GeometryReader { geo in
            ZStack {
                Rectangle()
                    .fill(LinearGradient(
                        gradient: Gradient(stops: [
                            .init(color: Self.gradientStart, location: gradient),
                            .init(color: Self.gradientEnd, location: 1)
                        ]),
                        startPoint: .top,
                        endPoint: .bottom
                    ))
                    .overlay(Rectangle().stroke(Color.white, lineWidth: 2))
                    .onReceive(Utils.TIMER) { _ in
                        DispatchQueue.global().async {
                            self.heat = self.getTemperature()
                            self.gradient = self.heat / 100
                        }
                    }.frame(width: geo.size.width, height: dynamicSize)
                    .padding(.all)
                Text("\(self.heat.trim()) °C")
                    .fontWeight(.bold)
                    .font(.system(size: 60, design: .rounded))
                    .fixedSize(horizontal: true, vertical: true)
                    .multilineTextAlignment(.center)
                    .padding()
                    .frame(width: 300, height: 200)
                    .foregroundColor(.white)
            }
        }
        
    }
    
    private func getTemperature() -> CGFloat {
        do {
            if (self.tempSensor > 0) {
                return CGFloat(try SMCKit.temperature(self.tempSensor, unit: TemperatureUnit.celius))
            }
            for sensor in Utils.tempSensors {
                if (sensor.name.contains("CPU") && sensor.name.contains("PROXIMITY")) {
                    self.tempSensor = sensor.code
                    return CGFloat(try SMCKit.temperature(sensor.code, unit: TemperatureUnit.celius))
                }
            }
        } catch { Utils.handleError(msg: "Error in: Fan -> Sensors") }
        return 0
    }
}

struct TemperatureView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            TemperatureView()
        }
    }
}
