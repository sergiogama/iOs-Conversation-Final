//
//  TimerProtocol.swift
//  ChatDemo
//
//  Created by Marco Aurélio Bigélli Cardoso on 31/07/17.
//  Copyright © 2017 IBM. All rights reserved.
//

import Foundation

class TimerGroup {
    var timers: [Timer] = []
    private var blocks: [() -> ()] = []
    private var intervals: [Double] = []
    func newTimer(block: @escaping () -> (), interval: Double) {
        let timer = Timer.scheduledTimer(withTimeInterval: interval,
                                         repeats: false,
                                         block: { t in
                                            block()
                                            t.invalidate()
                                            var i = 0
                                            while i < self.timers.count {
                                                if t === self.timers[i] {
                                                    _ = self.timers.remove(at: i)
                                                    _ = self.blocks.remove(at: i)
                                                    _ = self.intervals.remove(at: i)
                                                    break
                                                } else {
                                                    i += 1
                                                }
                                            }
                                         })
        timers.append(timer)
        blocks.append(block)
        intervals.append(interval)
    }
    
    func advanceTime(by amount: Double) {
        var params: [( () -> (), Double )] = []
        var i = 0
        while i < timers.count {
            if amount >= intervals[i] {
                timers[i].fire()
            } else {
                params.append((blocks[i], intervals[i] - amount))
                i += 1
            }
        }
        params.forEach { param in
            self.newTimer(block: param.0, interval: param.1)
        }
    }
    
    func callFirst() {
        var minInterval = Double.greatestFiniteMagnitude
        for timer in timers {
            minInterval = min(minInterval, timer.timeInterval)
        }
        for timer in timers {
            if timer.timeInterval == minInterval {
                timer.fire()
            }
        }
    }
    
    func callAll() {
        timers.forEach { $0.fire() }
    }
    
    func cancelAll() {
        timers.forEach { $0.invalidate() }
        timers = []
        blocks = []
        intervals = []
    }
}
