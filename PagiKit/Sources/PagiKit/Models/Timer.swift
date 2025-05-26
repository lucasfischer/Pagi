import Foundation

public class Timer {
    public var startDate: Date?
    public var targetReachedDate: Date?
    public var endDate: Date?
    
    public var isRunning = false
    public var isEnded = false
    
    var formatter: DateComponentsFormatter = {
        let dateComponentsFormatter = DateComponentsFormatter()
        dateComponentsFormatter.allowedUnits = [.second, .minute, .hour]
        dateComponentsFormatter.unitsStyle = .full
        return dateComponentsFormatter
    }()
    
    public func start() {
        startDate = Date()
        isRunning = true
    }
    
    public func stop() {
        endDate = Date()
        targetReachedDate = endDate
        isEnded = true
        isRunning = false
    }
    
    public func typing() {
        endDate = Date()
    }
    
    public func reset() {
        startDate = nil
        endDate = nil
        isRunning = false
        isEnded = false
    }
    
    public var endDuration: String? {
        if let start = startDate, let end = endDate {
            return formatter.string(from: start, to: end)
        }
        return nil
    }
    
    public var targetReachedDuration: String? {
        if let start = startDate, let end = endDate {
            return formatter.string(from: start, to: end)
        }
        return nil
    }
}
