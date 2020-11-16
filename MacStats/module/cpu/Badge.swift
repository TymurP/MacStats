//
//  Badge.swift
//  MacStats
//
//  Created by Tymur Pysarevych on 13.11.20.
//

import SwiftUI

struct BadgeContent: View {
    @State var dynamicSize: CGFloat = 400
    @State var gradient: CGFloat = 2.0
    @State var cpuColor: CGFloat = 0.1
    
    var body: some View {
        Circle()
            .fill(LinearGradient(
                gradient: .init(colors: [Self.gradientStart, Self.gradientEnd]),
                startPoint: .init(x: 0.5, y: 0),
                endPoint: .init(x: 0.5, y: 0.6)
            ))
            .frame(width: dynamicSize, height: dynamicSize)
            .overlay(GeometryReader{ geometry in
                Circle()
                    .fill(LinearGradient(
                        gradient: .init(colors: [Self.gradientStart, Self.gradientEnd]),
                        startPoint: .init(x: cpuColor, y: cpuColor),
                        endPoint: .init(x: gradient, y: gradient)
                    ))
                    .onReceive(Utils.init().timer) { _ in
                        DispatchQueue.global().async {
                            let counter:CGFloat = 0.1 // Change color of badge
                            self.cpuColor = self.cpuColor + counter
                            print("Ticker! \(self.cpuColor)")
                        }
                    }
                    .frame(width: geometry.size.width, height: geometry.size.height)
            })
    }
    
    static let gradientStart = Color(red: 0xEC / 255, green: 0x2F / 255, blue: 0x4B / 255)
    static let gradientEnd = Color(red: 0x00 / 255, green: 0x9F / 255, blue: 0xFF / 255)
}
