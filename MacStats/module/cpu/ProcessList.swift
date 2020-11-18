//
//  ProcessList.swift
//  MacStats
//
//  Created by Tymur Pysarevych on 17.11.20.
//

import SwiftUI

struct ProcessList: View {
    
    //-------------------------------------
    //  MARK: BUILD UI
    //-------------------------------------
    var body: some View {
        VStack {
            List(self.getTopProcesses()) { proc in
                VStack(alignment: .leading) {
                    Text("\(proc.name)").font(.title)
                    
                    HStack(alignment: .top) {
                        Text("\(proc.pid)").font(.subheadline)
                        Spacer()
                        Text("\(proc.usage.trim(f: ".2"))").font(.subheadline)
                    }
                }
                .padding()
            }
        }
    }
    
    //-------------------------------------
    //  MARK: GET TOP PROCESSES
    //-------------------------------------
    private func getTopProcesses() -> ArraySlice<TopProcess> {
        let task = Process()
        task.launchPath = "/bin/ps"
        task.arguments = ["-Aceo pid,pcpu,comm", "-r"]
        
        let outputPipe = Pipe()
        let errorPipe = Pipe()
        
        task.standardOutput = outputPipe
        task.standardError = errorPipe
        
        do {
            try task.run()
        } catch let error {
            Utils.handleError(msg: error.localizedDescription)
            return []
        }
        
        let outputData = outputPipe.fileHandleForReading.readDataToEndOfFile()
        let errorData = errorPipe.fileHandleForReading.readDataToEndOfFile()
        let output = String(decoding: outputData, as: UTF8.self)
        _ = String(decoding: errorData, as: UTF8.self)
        if output.isEmpty {
            return []
        }
        
        var index = 0
        var processes: [TopProcess] = []
        output.enumerateLines { (line, stop) -> () in
            if index != 0 {
                var str = line.trimmingCharacters(in: .whitespaces)
                let pidString = str.findAndCrop(pattern: "^\\d+")
                let usageString = str.findAndCrop(pattern: "^[0-9,.]+ ")
                let command = str.trimmingCharacters(in: .whitespaces)
                
                let pid = Int(pidString) ?? 0
                let usage = Double(usageString.replacingOccurrences(of: ",", with: ".")) ?? 0
                
                var name: String = ""
                var icon: NSImage? = nil
                if let app = NSRunningApplication(processIdentifier: pid_t(pid) ) {
                    name = app.localizedName ?? "NoName"
                    icon = app.icon
                }
                
                processes.append(TopProcess(pid: pid, command: command, name: name, usage: usage, icon: icon))
            }
            index += 1
        }
        return processes.prefix(5)
    }
}
