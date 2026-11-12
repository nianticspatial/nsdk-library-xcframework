import Foundation
import CoreGraphics
import CoreVideo
import ImageIO

/// Protocol for loading playback dataset data from various sources.
/// 
/// This protocol abstracts data retrieval, allowing for different implementations
/// such as bundle loading, file system loading, remote loading, or mock data for testing.
/// 
/// Implementations are used for on-demand frame loading - the loader is passed to
/// `PlaybackDataset` which calls these methods when frames are requested.
@available(*, deprecated, message: "Will be removed in a future release. Use PlaybackDataset.open(), which reads the dataset through native playback.")
public protocol PlaybackDatasetSource {
    /// Loads the capture JSON data from the data source.
    /// 
    /// - Returns: The JSON data as `Data`, or `nil` if loading fails
    func loadCaptureJSON() -> Data?
    
    /// Loads an image from the data source.
    /// 
    /// This method is called on-demand when a frame image is requested.
    /// 
    /// - Parameter imageName: The filename of the image (e.g., "frame_00000000.jpg")
    /// - Returns: The image as a `CGImage`, or `nil` if loading fails
    func loadImage(imageName: String) -> CGImage?
    
    /// Loads depth data from the data source.
    /// 
    /// This method is called on-demand when depth data is requested.
    /// 
    /// - Parameter depthFileName: The filename of the depth data file (e.g., "depth_00000000.bin")
    /// - Returns: The depth data as `Data`, or `nil` if loading fails or depth data is not available
    func loadDepthData(depthFileName: String) -> Data?
    
    /// Loads depth confidence data from the data source.
    /// 
    /// This method is called on-demand when confidence data is requested.
    /// 
    /// - Parameter confidenceFileName: The filename of the confidence data file (e.g., "confidence_00000000.bin")
    /// - Returns: The confidence data as `Data`, or `nil` if loading fails or confidence data is not available
    func loadDepthConfidence(confidenceFileName: String) -> Data?
    
    /// Returns details about the loader configuration.
    /// 
    /// - Returns: A string describing the loader configuration
    func info() -> String
}

/// Base class for loading playback dataset data from various sources.
///
/// This class provides a base implementation that must be subclassed. Subclasses must override
/// `loadCaptureJSON()`, `loadImage(imageName:)`, `loadDepthData(depthFileName:)`, and
/// `loadDepthConfidence(confidenceFileName:)` to provide concrete implementations.
///
/// The loader uses on-demand loading - only the capture JSON is loaded upfront, and frame
/// images/depth data are loaded when requested by `PlaybackDataset`.
///
/// - Note: This class acts as an abstract base class. Do not instantiate directly.
@available(*, deprecated, message: "Will be removed in a future release. Use PlaybackDataset.open(), which reads the dataset through native playback.")
open class PlaybackDatasetLoader: PlaybackDatasetSource {
    
    public init() {}
    
    /// Loads the capture JSON data from the data source.
    ///
    /// This method must be overridden by subclasses. The base implementation reports the
    /// missing override and returns `nil`.
    ///
    /// - Returns: The JSON data as `Data`, or `nil` if loading fails
    /// - Important: Subclasses must override this method. Do not call the base implementation.
    open func loadCaptureJSON() -> Data? {
        nsdkUnexpected("loadCaptureJSON() must be overridden by a subclass", returning: nil)
    }
    
    /// Loads an image from the data source.
    ///
    /// This method must be overridden by subclasses. The base implementation reports the
    /// missing override and returns `nil`.
    /// Called on-demand when a frame image is requested.
    ///
    /// - Parameter imageName: The filename of the image (e.g., "frame_00000000.jpg")
    /// - Returns: The image as a `CGImage`, or `nil` if loading fails
    /// - Important: Subclasses must override this method. Do not call the base implementation.
    open func loadImage(imageName: String) -> CGImage? {
        nsdkUnexpected("loadImage(imageName:) must be overridden by a subclass", returning: nil)
    }
    
    /// Loads depth data from the data source.
    ///
    /// This method must be overridden by subclasses. The base implementation reports the
    /// missing override and returns `nil`.
    /// Called on-demand when depth data is requested.
    ///
    /// - Parameter depthFileName: The filename of the depth data file (e.g., "depth_00000000.bin")
    /// - Returns: The depth data as `Data`, or `nil` if loading fails or depth data is not available
    /// - Important: Subclasses must override this method. Do not call the base implementation.
    open func loadDepthData(depthFileName: String) -> Data? {
        nsdkUnexpected("loadDepthData(depthFileName:) must be overridden by a subclass", returning: nil)
    }
    
    /// Loads depth confidence data from the data source.
    ///
    /// This method must be overridden by subclasses. The base implementation reports the
    /// missing override and returns `nil`.
    /// Called on-demand when confidence data is requested.
    ///
    /// - Parameter confidenceFileName: The filename of the confidence data file (e.g., "confidence_00000000.bin")
    /// - Returns: The confidence data as `Data`, or `nil` if loading fails or confidence data is not available
    /// - Important: Subclasses must override this method. Do not call the base implementation.
    open func loadDepthConfidence(confidenceFileName: String) -> Data? {
        nsdkUnexpected("loadDepthConfidence(confidenceFileName:) must be overridden by a subclass", returning: nil)
    }
    
    open func info() -> String {
        return "base implementation"
    }
    
    /// Loads a dataset from the data source.
    /// 
    /// This method only loads the capture JSON metadata upfront. Frame images and depth data
    /// are loaded on-demand when requested, reducing memory pressure for large datasets.
    /// 
    /// - Returns: A `PlaybackDataset` configured for on-demand loading, or `nil` if loading fails
    public func loadDataset() -> PlaybackDataset? {
        // Load JSON data using the loader
        guard let jsonData = loadCaptureJSON() else {
            print("PlaybackDatasetLoader: Failed to load \(PlaybackDatasetConstants.captureJSONFullName) from loader")
            return nil
        }
        
        do {
            let decoder = JSONDecoder()
            let captureRoot = try decoder.decode(PlaybackDataset.CaptureRoot.self, from: jsonData)
            
            let count = captureRoot.frameCount ?? captureRoot.frames.count
            print("PlaybackDatasetLoader: Loaded dataset metadata with \(count) frames from '\(info())'")
            
            // Create dataset with reference to this loader for on-demand frame loading
            return PlaybackDataset(captureRoot: captureRoot, loader: self)
        } catch {
            if let decodingError = error as? DecodingError {
                print("PlaybackDatasetLoader: Failed to decode \(PlaybackDatasetConstants.captureJSONFullName): \(decodingError)")
            } else {
                print("PlaybackDatasetLoader: Failed to load dataset: \(error.localizedDescription)")
            }
            return nil
        }
    }
}

/// Constants for playback dataset file names and extensions.
public enum PlaybackDatasetConstants {
    /// The filename (without extension) for the capture JSON file.
    public static let captureJSONFileName = "capture"
    
    /// The file extension for the capture JSON file.
    public static let captureJSONFileExtension = "json"
    
    /// The full filename for the capture JSON file (filename.extension).
    public static var captureJSONFullName: String {
        "\(captureJSONFileName).\(captureJSONFileExtension)"
    }
}

/// A loader that retrieves playback dataset data from the app bundle.
/// 
/// This is the default implementation for loading datasets from `Bundle.main`.
/// Frame images and depth data are loaded on-demand when requested.
@available(*, deprecated, message: "Will be removed in a future release. Use PlaybackDataset.open(directory:bundle:), which reads the dataset through native playback.")
public class BundlePlaybackDatasetLoader: PlaybackDatasetLoader {
    private let bundle: Bundle
    private let directory: String
    
    /// Initializes a bundle loader with the specified bundle.
    /// 
    /// - Parameters:
    ///   - directory: The subdirectory within the bundle containing the dataset
    ///   - bundle: The bundle to load resources from (defaults to `Bundle.main`)
    public init(directory: String, bundle: Bundle = .main) {
        self.bundle = bundle
        self.directory = directory
        super.init()
    }
    
    public override func loadCaptureJSON() -> Data? {
        guard let captureURL = bundle.url(forResource: PlaybackDatasetConstants.captureJSONFileName,
                                          withExtension: PlaybackDatasetConstants.captureJSONFileExtension,
                                          subdirectory: directory) else {
            print("BundlePlaybackDatasetLoader: Could not find in bundle at '\(directory)/\(PlaybackDatasetConstants.captureJSONFullName)'")
            return nil
        }
        
        return try? Data(contentsOf: captureURL)
    }
    
    public override func loadImage(imageName: String) -> CGImage? {
        // Parse filename and extension, defaulting to "jpg" if no extension is provided
        let url = URL(fileURLWithPath: imageName)
        let nameWithoutExtension = url.deletingPathExtension().lastPathComponent
        let fileExtension = url.pathExtension.isEmpty ? "jpg" : url.pathExtension
        
        // Get the image URL from the bundle
        guard let imageURL = bundle.url(forResource: nameWithoutExtension,
                                        withExtension: fileExtension,
                                        subdirectory: directory) else {
            print("BundlePlaybackDatasetLoader: Could not find image in bundle at '\(directory)/\(imageName)'")
            return nil
        }
        
        // Load the image data and create CGImage directly
        guard let imageData = try? Data(contentsOf: imageURL),
              let imageSource = CGImageSourceCreateWithData(imageData as CFData, nil),
              let cgImage = CGImageSourceCreateImageAtIndex(imageSource, 0, nil) else {
            print("BundlePlaybackDatasetLoader: Failed to load image data from '\(imageURL.path)'")
            return nil
        }
        
        return cgImage
    }
    
    public override func loadDepthData(depthFileName: String) -> Data? {
        // Parse filename and extension, defaulting to "bin" if no extension is provided
        let url = URL(fileURLWithPath: depthFileName)
        let nameWithoutExtension = url.deletingPathExtension().lastPathComponent
        let fileExtension = url.pathExtension.isEmpty ? "bin" : url.pathExtension
        
        // Get the depth data URL from the bundle
        guard let depthURL = bundle.url(forResource: nameWithoutExtension,
                                        withExtension: fileExtension,
                                        subdirectory: directory) else {
            print("BundlePlaybackDatasetLoader: Could not find depth data in bundle at '\(directory)/\(depthFileName)'")
            return nil
        }
        
        guard let depthData = try? Data(contentsOf: depthURL) else {
            print("BundlePlaybackDatasetLoader: Failed to load depth data from '\(depthURL.path)'")
            return nil
        }
        
        return depthData
    }
    
    public override func loadDepthConfidence(confidenceFileName: String) -> Data? {
        // Parse filename and extension, defaulting to "bin" if no extension is provided
        let url = URL(fileURLWithPath: confidenceFileName)
        let nameWithoutExtension = url.deletingPathExtension().lastPathComponent
        let fileExtension = url.pathExtension.isEmpty ? "bin" : url.pathExtension
        
        // Get the confidence data URL from the bundle
        guard let confidenceURL = bundle.url(forResource: nameWithoutExtension,
                                             withExtension: fileExtension,
                                             subdirectory: directory) else {
            print("BundlePlaybackDatasetLoader: Could not find depth confidence in bundle at '\(directory)/\(confidenceFileName)'")
            return nil
        }
        
        guard let confidenceData = try? Data(contentsOf: confidenceURL) else {
            print("BundlePlaybackDatasetLoader: Failed to load depth confidence from '\(confidenceURL.path)'")
            return nil
        }
        
        return confidenceData
    }
    
    public override func info() -> String {
        let bundleIdentifier = bundle.bundleIdentifier ?? "Unknown"
        return "Bundle: \(bundleIdentifier), Subdirectory: \(directory)"
    }
}
