public enum Loadable<T> {
    
    case notRequested
    case isLoading(last: T?)
    case loaded(T)
    case failed(Error)
    
    public var value: T? {
        switch self {
            case let .loaded(value): return value
            case let .isLoading(last): return last
            default: return nil
        }
    }
    public var error: Error? {
        switch self {
            case let .failed(error): return error
            default: return nil
        }
    }
}

extension Loadable: Equatable where T: Equatable {
    public static func == (lhs: Loadable<T>, rhs: Loadable<T>) -> Bool {
        switch (lhs, rhs) {
            case (.notRequested, .notRequested): return true
            case let (.isLoading(lhsV), .isLoading(rhsV)):
                return lhsV == rhsV
            case let (.loaded(lhsV), .loaded(rhsV)): return lhsV == rhsV
            case let (.failed(lhsE), .failed(rhsE)):
                return lhsE.localizedDescription == rhsE.localizedDescription
            default: return false
        }
    }
}
