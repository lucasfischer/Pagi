import Foundation

extension Date {
    static var dateFormatStyle: Date.ISO8601FormatStyle {
        Date.ISO8601FormatStyle().year().month().day()
    }
}
