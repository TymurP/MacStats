//
//  ContentView.swift
//  MacStats
//
//  Created by Tymur Pysarevych on 10.11.20.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        Group {
            Text("Hello, World!").frame(maxWidth: .infinity, maxHeight: .infinity)
            Text("Test").frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            ContentView()
        }
    }
}
