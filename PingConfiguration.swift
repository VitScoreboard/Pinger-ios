import Foundation

class PingConfiguration: NSObject, NSCoding {
    var url: String
    var frequency: TimeInterval // in seconds
    var contentMask: String
    
    init(url: String = "", frequency: TimeInterval = 30.0, contentMask: String = "") {
        self.url = url
        self.frequency = frequency
        self.contentMask = contentMask
        super.init()
    }
    
    // MARK: - NSCoding
    required init?(coder: NSCoder) {
        self.url = coder.decodeObject(forKey: "url") as? String ?? ""
        self.frequency = coder.decodeDouble(forKey: "frequency")
        self.contentMask = coder.decodeObject(forKey: "contentMask") as? String ?? ""
        super.init()
    }
    
    func encode(with coder: NSCoder) {
        coder.encode(url, forKey: "url")
        coder.encode(frequency, forKey: "frequency")
        coder.encode(contentMask, forKey: "contentMask")
    }
    
    // MARK: - Validation
    var isValid: Bool {
        return !url.isEmpty && 
               URL(string: url) != nil &&
               frequency > 0 &&
               !contentMask.isEmpty
    }
}

// MARK: - Configuration Manager
class ConfigurationManager {
    static let shared = ConfigurationManager()
    private let userDefaults = UserDefaults.standard
    private let configKey = "PingConfiguration"
    
    private init() {}
    
    var configuration: PingConfiguration {
        get {
            if let data = userDefaults.data(forKey: configKey),
               let config = try? NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(data) as? PingConfiguration {
                return config
            }
            return PingConfiguration()
        }
        set {
            if let data = try? NSKeyedArchiver.archivedData(withRootObject: newValue, requiringSecureCoding: false) {
                userDefaults.set(data, forKey: configKey)
            }
        }
    }
    
    func saveConfiguration(_ config: PingConfiguration) {
        configuration = config
    }
}