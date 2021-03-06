/*
Copyright 2020 Google LLC

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    https://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
*/
import Foundation

/// Configuration struct to configure the local and cloud logging logic.
///
/// Set values to instruct the Log Handler to manage how often to
/// write logs to disk and the cloud, when to control the persistance
/// logging itself, cloud and local directory name and the minimum
/// local file system space for temporarily holding the logs.
public struct SwiftLogFireCloudConfig {

  /// Enable to ensure log files are persisted to Firebase Cloud Storage bucket. Note this value works in concert with
  /// `logToCloudOnSimulator` such that when executing on a simulator `logToCloudOnSimulator`
  /// needs to be true as well as `logToCloud` for files to be pushed.  This allows users to default `logToCloud`
  /// to true for the normal builds, but stop file uploading in development with `logTOCloudOnSimulator` false.
  var logToCloud: Bool

  /// The approximate log size when logs will be persisted to Firebase Cloud Storage bucket.
  ///
  /// log files are pushed to the cloud once they eclipse this size or if the `localFileBufferWriteInterval`
  /// has elapsed
  var localFileSizeThresholdToPushToCloud: Int = megabyte

  /// TimeInterval between when logs will be check for persistence  to Firebase Cloud Storage bucket.
  ///
  /// log files are check to be pushed to the cloud on this interval or once they eclipse a size of `localFileSizeThresholdToPushToCloud`
  var localFileBufferWriteInterval: TimeInterval = 60.0

  /// An optional uniqueID string to identify the log file that is embedded in the log file name.
  ///
  /// If omitted, the library will utlize the `UIDevice.current.identifierForVendor`  to uniquely identify the logfile
  let uniqueIDString: String?

  /// Minimum required local file system space to start or continue logging.
  var minFileSystemFreeSpace: Int

  /// Directory name used for storing logs, both locally and as the root directy in the cloud storage bucket.
  var logDirectoryName: String

  /// Boolean value to control whether log files are sent to the cloud when running within a simulator.  Logger will not push
  /// to cloud when executing on a simulator even if `logToCloud` is set to `true` unless `logToCloudOnSimulator`
  /// is also set to `true`.
  var logToCloudOnSimulator: Bool = false

  /// Object responsible for uploading the local log file to the cloud.
  ///
  /// Ideally the library could do this but I don't want the library to depend on firebase,
  /// rather want to receive it from the client of the library.  But I'm not able to compile against
  /// those symbols without also linking against the Firestore library which would create
  /// duplicate symbol issues for theclient app.
  weak var cloudUploader: CloudFileUploaderProtocol?

  internal let isTesting: Bool
  public static let megabyte: Int = 1_048_576

  /// Create a new `SwiftLogFileCloudConfig`.
  ///
  /// - Parameters:
  ///   - logToCloud: Enable to ensure log files are persisted to Firebase Cloud Storage bucket.
  ///   - localFileSizeThresholdToPushToCloud: The approximate log size when logs will be persisted to Firebase Cloud Storage bucket.
  ///   - localFileBufferWriteInterval: TimeInterval between when logs will be check for persistence  to Firebase Cloud Storage bucket.
  ///   - uniqueID: An optional uniqueID string to identify the log file that is embedded in the log file name.
  ///   - minFileSystemFreeSpace: Minimum required local file system space to start or continue logging.
  ///   - logDirectoryName: Directory name used for storing logs, both locally and as the root directy in the cloud storage bucket.
  ///   - logToCloudOnSimulator: Boolean value to control whether log files are sent to the cloud when running within a simulator.
  public init(
    logToCloud: Bool = true,
    localFileSizeThresholdToPushToCloud: Int = SwiftLogFireCloudConfig.megabyte,
    localFileBufferWriteInterval: TimeInterval = 60,
    uniqueID: String? = nil,
    minFileSystemFreeSpace: Int = 20 * SwiftLogFireCloudConfig.megabyte,
    logDirectoryName: String = "Logs",
    logToCloudOnSimulator: Bool = false,
    cloudUploader: CloudFileUploaderProtocol?
  ) {
    self.logToCloud = logToCloud
    self.localFileSizeThresholdToPushToCloud = localFileSizeThresholdToPushToCloud
    self.localFileBufferWriteInterval = localFileBufferWriteInterval
    self.minFileSystemFreeSpace = minFileSystemFreeSpace
    self.logDirectoryName = logDirectoryName
    self.logToCloudOnSimulator = logToCloudOnSimulator
    self.uniqueIDString = uniqueID
    self.cloudUploader = cloudUploader
    self.isTesting = ProcessInfo.processInfo.environment["isTesting"] == "true"
  }
}
