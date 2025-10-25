import Foundation
import UIKit
import UserNotifications

// MARK: - Notification Names
extension Notification.Name {
    static let pingResultReceived = Notification.Name("PingResultReceived")
}

class PingService: NSObject {
    
    // MARK: - Singleton
    static let shared = PingService()
    private override init() {
        super.init()
    }
    
    // MARK: - Properties
    private var timer: Timer?
    private var backgroundTask: UIBackgroundTaskIdentifier = .invalid
    private(set) var isRunning = false
    
    // MARK: - Public Methods
    func startPinging() {
        guard !isRunning else { return }
        
        let config = ConfigurationManager.shared.configuration
        guard config.isValid else {
            print("Invalid configuration - cannot start pinging")
            return
        }
        
        isRunning = true
        startBackgroundTask()
        schedulePing(with: config)
        
        print("Ping service started - URL: \(config.url), Frequency: \(config.frequency)s")
    }
    
    func stopPinging() {
        guard isRunning else { return }
        
        isRunning = false
        timer?.invalidate()
        timer = nil
        endBackgroundTask()
        
        print("Ping service stopped")
    }
    
    func testPing(with config: PingConfiguration, completion: @escaping (Bool, Error?) -> Void) {
        performPing(url: config.url, contentMask: config.contentMask) { success, error in
            completion(success, error)
        }
    }
    
    // MARK: - Private Methods
    private func schedulePing(with config: PingConfiguration) {
        timer?.invalidate()
        
        timer = Timer.scheduledTimer(withTimeInterval: config.frequency, repeats: true) { [weak self] _ in
            self?.performPing(url: config.url, contentMask: config.contentMask) { success, error in
                self?.handlePingResult(success: success, error: error)
            }
        }
        
        // Perform first ping immediately
        performPing(url: config.url, contentMask: config.contentMask) { [weak self] success, error in
            self?.handlePingResult(success: success, error: error)
        }
    }
    
    private func performPing(url urlString: String, contentMask: String, completion: @escaping (Bool, Error?) -> Void) {
        guard let url = URL(string: urlString) else {
            completion(false, PingError.invalidURL)
            return
        }
        
        let request = URLRequest(url: url, timeoutInterval: 30.0)
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(false, error)
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse,
                  200...299 ~= httpResponse.statusCode else {
                completion(false, PingError.invalidResponse)
                return
            }
            
            guard let data = data,
                  let content = String(data: data, encoding: .utf8) else {
                completion(false, PingError.noContent)
                return
            }
            
            let maskFound = content.contains(contentMask)
            completion(maskFound, maskFound ? nil : PingError.maskNotFound)
            
        }.resume()
    }
    
    private func handlePingResult(success: Bool, error: Error?) {
        let timestamp = Date()
        
        // Post notification for UI update
        DispatchQueue.main.async {
            NotificationCenter.default.post(
                name: .pingResultReceived,
                object: nil,
                userInfo: [
                    "success": success,
                    "timestamp": timestamp,
                    "error": error as Any
                ]
            )
        }
        
        // Send push notification on failure
        if !success {
            sendFailureNotification(error: error)
        }
        
        // Log result
        let result = success ? "SUCCESS" : "FAILED"
        let errorMsg = error?.localizedDescription ?? ""
        print("Ping result: \(result) at \(timestamp) - \(errorMsg)")
    }
    
    private func sendFailureNotification(error: Error?) {
        let content = UNMutableNotificationContent()
        content.title = "Pinger Alert"
        
        if let pingError = error as? PingError {
            switch pingError {
            case .maskNotFound:
                content.body = "Content mask not found in response"
            case .invalidURL:
                content.body = "Invalid URL configured"
            case .invalidResponse:
                content.body = "Server returned error response"
            case .noContent:
                content.body = "No content received from server"
            }
        } else {
            content.body = error?.localizedDescription ?? "Ping failed for unknown reason"
        }
        
        content.sound = .default
        content.badge = 1
        
        let request = UNNotificationRequest(
            identifier: UUID().uuidString,
            content: content,
            trigger: nil // Send immediately
        )
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Failed to send notification: \(error)")
            }
        }
    }
    
    // MARK: - Background Task Management
    private func startBackgroundTask() {
        endBackgroundTask()
        
        backgroundTask = UIApplication.shared.beginBackgroundTask(withName: "PingService") { [weak self] in
            self?.endBackgroundTask()
        }
    }
    
    private func endBackgroundTask() {
        if backgroundTask != .invalid {
            UIApplication.shared.endBackgroundTask(backgroundTask)
            backgroundTask = .invalid
        }
    }
}

// MARK: - Ping Errors
enum PingError: LocalizedError {
    case invalidURL
    case invalidResponse
    case noContent
    case maskNotFound
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "The URL is invalid"
        case .invalidResponse:
            return "Server returned an error response"
        case .noContent:
            return "No content received from server"
        case .maskNotFound:
            return "Content mask not found in response"
        }
    }
}