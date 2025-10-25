import UIKit
import UserNotifications

class MainViewController: UIViewController {
    
    // MARK: - IBOutlets
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var toggleButton: UIButton!
    @IBOutlet weak var configButton: UIButton!
    @IBOutlet weak var urlLabel: UILabel!
    @IBOutlet weak var frequencyLabel: UILabel!
    @IBOutlet weak var lastPingLabel: UILabel!
    @IBOutlet weak var lastResultLabel: UILabel!
    
    // MARK: - Properties
    private var pingService = PingService.shared
    private var isMonitoring = false
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad() 
        setupUI()
        setupObservers()
        updateUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateConfigurationDisplay()
    }
    
    // MARK: - Setup
    private func setupUI() {
        title = "Pinger"
        
        // Style the toggle button
        toggleButton.layer.cornerRadius = 8
        toggleButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18)
        
        // Style the config button
        configButton.layer.cornerRadius = 8
        configButton.layer.borderWidth = 1
        configButton.layer.borderColor = UIColor.systemBlue.cgColor
        
        // Setup labels
        statusLabel.font = UIFont.systemFont(ofSize: 24, weight: .bold)
        urlLabel.numberOfLines = 0
        lastResultLabel.numberOfLines = 0
        
        updateToggleButton()
    }
    
    private func setupObservers() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(pingResultReceived(_:)),
            name: .pingResultReceived,
            object: nil
        )
    }
    
    // MARK: - UI Updates
    private func updateUI() {
        isMonitoring = pingService.isRunning
        updateToggleButton()
        updateStatusLabel()
        updateConfigurationDisplay()
    }
    
    private func updateToggleButton() {
        if isMonitoring {
            toggleButton.setTitle("STOP", for: .normal)
            toggleButton.backgroundColor = UIColor.systemRed
        } else {
            toggleButton.setTitle("START", for: .normal)
            toggleButton.backgroundColor = UIColor.systemGreen
        }
    }
    
    private func updateStatusLabel() {
        if isMonitoring {
            statusLabel.text = "Monitoring Active"
            statusLabel.textColor = UIColor.systemGreen
        } else {
            statusLabel.text = "Monitoring Stopped"
            statusLabel.textColor = UIColor.systemRed
        }
    }
    
    private func updateConfigurationDisplay() {
        let config = ConfigurationManager.shared.configuration
        
        if config.url.isEmpty {
            urlLabel.text = "URL: Not configured"
            frequencyLabel.text = "Frequency: Not configured"
        } else {
            urlLabel.text = "URL: \(config.url)"
            frequencyLabel.text = "Frequency: \(Int(config.frequency)) seconds"
        }
    }
    
    // MARK: - Actions
    @IBAction func toggleButtonTapped(_ sender: UIButton) {
        let config = ConfigurationManager.shared.configuration
        
        guard config.isValid else {
            showAlert(title: "Configuration Required", 
                     message: "Please configure URL, frequency, and content mask before starting.")
            return
        }
        
        if isMonitoring {
            stopMonitoring()
        } else {
            startMonitoring()
        }
    }
    
    @IBAction func configButtonTapped(_ sender: UIButton) {
        performSegue(withIdentifier: "ShowConfiguration", sender: self)
    }
    
    // MARK: - Monitoring Control
    private func startMonitoring() {
        pingService.startPinging()
        isMonitoring = true
        updateToggleButton()
        updateStatusLabel()
    }
    
    private func stopMonitoring() {
        pingService.stopPinging()
        isMonitoring = false
        updateToggleButton()
        updateStatusLabel()
        lastPingLabel.text = "Last Ping: Stopped"
        lastResultLabel.text = "Result: -"
    }
    
    // MARK: - Notifications
    @objc private func pingResultReceived(_ notification: Notification) {
        DispatchQueue.main.async {
            if let userInfo = notification.userInfo,
               let success = userInfo["success"] as? Bool,
               let timestamp = userInfo["timestamp"] as? Date {
                
                let formatter = DateFormatter()
                formatter.dateStyle = .none
                formatter.timeStyle = .medium
                
                self.lastPingLabel.text = "Last Ping: \(formatter.string(from: timestamp))"
                
                if success {
                    self.lastResultLabel.text = "Result: ✓ Success (Mask found)"
                    self.lastResultLabel.textColor = UIColor.systemGreen
                } else {
                    self.lastResultLabel.text = "Result: ✗ Failed (Mask not found)"
                    self.lastResultLabel.textColor = UIColor.systemRed
                }
            }
        }
    }
    
    // MARK: - Helper Methods
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowConfiguration",
           let configVC = segue.destination as? ConfigurationViewController {
            // Any setup needed for configuration view
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}