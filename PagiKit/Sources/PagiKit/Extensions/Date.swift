import Foundation

public extension Date {
    static var dateFormatStyle: Date.ISO8601FormatStyle {
        Date.ISO8601FormatStyle(timeZone: .current).year().month().day()
    }
}
