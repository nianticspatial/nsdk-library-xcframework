/// Reports the state of an asynchronous NSDK operation.
public enum NSDKAsyncState<Value, Error: Swift.Error> {
    /// Deprecated – use `inProgress` instead.
    @available(*, deprecated, renamed: "inProgress")
    case notReady

    /// The asynchronous operation is currently in progress.
    /// The associated value may contain a partial result if available.
    case inProgress(Value?)

    /// The asynchronous operation has completed successfully with a result.
    case success(Value)

    /// The asynchronous operation has failed with an error.
    case failure(Error)

    /// Indicates whether the asynchronous operation has finished
    public var isFinished: Bool {
        if case .notReady = self { return false }
        if case .inProgress = self { return false }
        return true
    }
}
