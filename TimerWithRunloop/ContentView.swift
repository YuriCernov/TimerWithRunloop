//
//  ContentView.swift
//  TimerWithRunloop
//
//  Created by Yuri Cernov on 31/01/2025.
//

import SwiftUI

@Observable
class ViewModel {
    
    private let runLoop = RunLoop()
    var time = Date.now
    
    init() {
        runThread()
    }
    
    deinit {
        runLoop.stop()
    }
    
    private func runThread() {
        Thread.detachNewThread { [weak self] in
            self?.runLoop.run()
        }
    }
    
    func getDate(after seconds: Double) {
        let timer = Timer(timeInterval: seconds, repeats: true) { [weak self] in
            Foundation.RunLoop.main.perform {
                self?.time = .now
            }
        }
        runLoop.add(timer: timer)
    }
    
    func stopGetDate() {
        runLoop.removeTimer()
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
            Button("Stop", action: {
                viewModel.stopGetDate()
            })
        }
    }
    
}

class RunLoop {
    
    typealias Operation = () -> Void
    
    private var customOperations: [Operation] = []
    private var timer: Timer?
    
    private let lock = NSLock()
    private let condition = NSCondition()
    private var stopped = false
    
    
    func run() {
        while !isStopped() {
            
            condition.wait()
            
            while let operation = getOperation() {
                operation()
            }
            
            if let timer = getTimer() {
                timer.action()
                if !timer.repeats {
                    removeTimer()
                }
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
    
    private func getTimer() -> Timer? {
        lock.lock()
        defer { lock.unlock() }
        return timer
    }
    
    func add(timer: Timer) {
        lock.lock()
        defer { lock.unlock() }
        self.timer = timer
        condition.signal()
    }
    
    func removeTimer() {
        lock.lock()
        defer { lock.unlock() }
        self.timer = nil
    }
    
}

struct Timer {
    let timeInterval: TimeInterval
    let repeats: Bool
    let action: () -> Void
}


#Preview {
    ContentView()
}
