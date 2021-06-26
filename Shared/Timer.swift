//
//  Timer.swift
//  Pagi
//
//  Created by Lucas Fischer on 26.06.21.
//

import Foundation

class Timer {
    var startDate: Date?
    var targetReachedDate: Date?
    var endDate: Date?
    
    var isRunning = false
    var isEnded = false
    
    var formatter: DateComponentsFormatter = {
        let dateComponentsFormatter = DateComponentsFormatter()
        dateComponentsFormatter.allowedUnits = [.second, .minute, .hour]
        dateComponentsFormatter.unitsStyle = .full
        return dateComponentsFormatter
    }()
    
    func start() {
        startDate = Date()
        isRunning = true
    }
    
    func stop() {
        endDate = Date()
        targetReachedDate = endDate
        isEnded = true
        isRunning = false
    }
    
    func typing() {
        endDate = Date()
    }
    
    func reset() {
        startDate = nil
        endDate = nil
        isRunning = false
        isEnded = false
    }
    
    var endDuration: String? {
        if let start = startDate, let end = endDate {
            return formatter.string(from: start, to: end)
        }
        return nil
    }
    
    var targetReachedDuration: String? {
        if let start = startDate, let end = endDate {
            return formatter.string(from: start, to: end)
        }
        return nil
    }
}
