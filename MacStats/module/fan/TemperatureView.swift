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
    // @State var dynamicSize: CGFloat = 200
    @State var gradient: CGFloat = 0
    @State var heat: CGFloat = 0
    @State var tempSensor: FourCharCode = 0
    @State var fanSpeed: Double = 0
    
    static let gradientStart = Color(red: 0xEC / 255, green: 0x2F / 255, blue: 0x4B / 255)
    static let gradientEnd = Color(red: 0x00 / 255, green: 0x9F / 255, blue: 0xFF / 255)
    
    //-------------------------------------
    //  MARK: BUILD UI
    //-------------------------------------
    var body: some View {
        VStack {
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
                            //self.setFanSpeed(percent: 50)
                            self.gradient = self.heat / 100
                        }
                    }.frame(width: 590, height: 460, alignment: Alignment.top)
                    .padding(.all)
                VStack {
                    Text("\(self.heat.trim()) °C")
                        .fontWeight(.bold)
                        .font(.system(size: 60, design: .rounded))
                        .fixedSize(horizontal: true, vertical: true)
                        .multilineTextAlignment(.center)
                        .padding()
                        .frame(width: 300, height: 200)
                        .foregroundColor(.white)
                    Text("Fan-Speed").font(.headline)
                    HStack {
                        Text("0%")
                        Slider(value: $fanSpeed, in: 0...100).frame(width: 300, height: 20, alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/)
                        Text("100%")
                    }
                }
            }
        }.frame(width: 600, height: 500.0, alignment: .top)
    }
    
    private func getTemperature() -> CGFloat {
        return CGFloat(SMC.temperature(unit: TemperatureUnit.celius))
    }
    
    private func setFanSpeed(percent: Int) -> Void {
        let allFans = SMC.getAllFans()
        for index in 0 ..< allFans {
            print("\(SMC.getFanDesc(id: index))")
        }
    }
}

struct TemperatureView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            TemperatureView()
        }
    }
}
