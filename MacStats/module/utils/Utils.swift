//
//  Utils.swift
//  MacStats
//
//  Created by Tymur Pysarevych on 15.11.20.
//

import Foundation

struct Utils{
    var timer = Timer.publish(every: 1, on: .current, in: .common).autoconnect()
}
