//
//  CounterApp.swift
//  Counter
//
//  Created by Pavle on 29-10-26.
//

import SwiftUI

@main
struct CounterApp: App {
    @StateObject private var store = CounterStore()
    @Environment(\.scenePhase) private var scenePhase

    var body: some Scene {
        WindowGroup {
            CounterListView()
                .environmentObject(store)
                .onChange(of: scenePhase) { phase in
                    if phase != .active {
                        store.flush()
                    }
                }
        }
    }
}
