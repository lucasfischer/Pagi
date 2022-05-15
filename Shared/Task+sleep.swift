//
//  Task+sleep.swift
//  Pagi (iOS)
//
//  Created by Lucas Fischer on 15.05.22.
//

extension Task where Success == Never, Failure == Never {
    static func sleep(seconds: Double) async throws {
        let duration = UInt64(seconds * 1_000_000_000)
        try await Task.sleep(nanoseconds: duration)
    }
}
