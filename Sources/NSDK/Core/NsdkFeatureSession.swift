import Foundation

/// A protocol that defines the common lifecycle and configuration interface for NSDK feature sessions.
public protocol NSDKFeatureSession {
    /// The type of configuration used by this session
    associatedtype Configuration

    /// Gets the current status of the feature.
    ///
    /// This method reports any errors or warnings that have occurred within the feature system.
    /// Check this periodically to monitor the health of operations. Once an error is flagged,
    /// it will remain flagged until the problematic process runs again and completes successfully.
    ///
    /// - Returns: Feature status flags indicating current state and any issues
    func featureStatus() -> NSDKFeatureStatus

    func configure(with config: Configuration) throws

    /// Starts the feature session.
    ///
    /// After starting, the session will begin processing incoming frame data according to
    /// its configured behavior. The session must be configured before starting.
    func start()

    /// Stops the feature session.
    ///
    /// This halts all processing. The session can be reconfigured and restarted after stopping.
    func stop()
}

/// Internal protocol for feature sessions that receive per-frame updates driven by `NSDKSession`.
///
/// `NSDKSession.update()` calls `update()` on every registered session conforming to this protocol.
/// Implementations should poll the native SDK for the latest results and publish them.
/// This is a no-op when the session is not active (i.e., between `stop()` and `start()`).
///
/// SDK consumers should not call `update()` directly.
protocol NSDKUpdatableSession: NSDKFeatureSession {
    func update()
}
