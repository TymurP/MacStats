//
//  Badge.swift
//  MacStats
//
//  Created by Tymur Pysarevych on 13.11.20.
//

import SwiftUI

struct CPUHeatView: View {
    //-------------------------------------
    //  MARK: VARIABLES
    //-------------------------------------
    @State var dynamicSize: CGFloat = 200
    @State var gradient: CGFloat = 0
    @State var cpuUsage: CGFloat = 0
    
    static let gradientStart = Color(red: 0xEC / 255, green: 0x2F / 255, blue: 0x4B / 255)
    static let gradientEnd = Color(red: 0x00 / 255, green: 0x9F / 255, blue: 0xFF / 255)
    
    //-------------------------------------
    //  MARK: BUILD UI
    //-------------------------------------
    var body: some View {
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
                            let usage = Utils.system.usageCPU()
                            self.cpuUsage = CGFloat(usage.user + usage.system)
                            self.gradient = self.cpuUsage / 100
                        }
                    }.frame(width: 590, height: dynamicSize, alignment: .top)
                Text("\(self.cpuUsage.trim())%")
                    .fontWeight(/*@START_MENU_TOKEN@*/.bold/*@END_MENU_TOKEN@*/)
                    .font(.system(size: 60, design: .rounded))
                    .fixedSize(horizontal: true, vertical: true)
                    .multilineTextAlignment(.center)
                    .padding()
                    .frame(width: 300, height: 200)
                    .foregroundColor(.white)
            }
    }
}
