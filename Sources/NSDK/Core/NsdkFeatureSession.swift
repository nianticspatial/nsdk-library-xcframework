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
