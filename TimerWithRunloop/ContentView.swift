//
//  ContentView.swift
//  TimerWithRunloop
//
//  Created by Yuri Cernov on 31/01/2025.
//

import SwiftUI

@Observable
class ViewModel {
    
    var time = Date.now
    
    func getDate(after seconds: Double) {
        time = .now
    }
    
}

struct ContentView: View {
    
    @State var viewModel = ViewModel()
    
    var body: some View {
        VStack {
            Text("\(viewModel.time)")
            Button("Run", action: {
                viewModel.getDate(after: 3)
            })
        }
    }
}

class RunLoop {
    
    typealias Operation = () -> Void
    
    private var customOperations: [Operation] = []
    private let lock = NSLock()
    private let condition = NSCondition()
    private var stopped = false
    
    func run() {
        while !isStopped() {
            condition.wait()
            
            while let operation = getOperation() {
                operation()
            }
        }
    }
    
    private func getOperation() -> Operation? {
        lock.lock()
        defer { lock.unlock() } // defer calls in the end of the func
        return !customOperations.isEmpty ? customOperations.removeFirst() : nil
    }
    
    func add(operation: @escaping Operation) {
        lock.lock()
        defer { lock.unlock() }
        customOperations.append(operation)
        condition.signal()
    }
    
    private func isStopped() -> Bool {
        lock.lock()
        defer { lock.unlock() }
        return stopped
    }
    
    func stop() {
        lock.lock()
        defer { lock.unlock() }
        stopped = true
        condition.signal()
    }
    
}

#Preview {
    ContentView()
}
