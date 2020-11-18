//
//  Helpers.swift
//  MacStats
//
//  Created by Tymur Pysarevych on 17.11.20.
//

import SwiftUI

public struct TopProcess: Identifiable {
    public var id = UUID()
    public var pid: Int
    public var command: String
    public var name: String
    public var usage: Double
    public var icon: NSImage?
    
    public init(pid: Int, command: String, name: String, usage: Double, icon: NSImage?) {
        self.pid = pid
        self.command = command
        self.name = name
        self.usage = usage
        self.icon = icon
    }
}
