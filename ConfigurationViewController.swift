import UIKit

class ConfigurationViewController: UIViewController {
    
    // MARK: - IBOutlets
    @IBOutlet weak var urlTextField: UITextField!
    @IBOutlet weak var frequencyTextField: UITextField!
    @IBOutlet weak var maskTextField: UITextField!
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var testButton: UIButton!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var contentView: UIView!
    
    // MARK: - Properties
    private var configuration = PingConfiguration()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        loadConfiguration()
        setupKeyboardHandling()
    }
    
    // MARK: - Setup
    private func setupUI() {
        title = "Configuration"
        
        // Add navigation bar buttons
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .cancel,
            target: self,
            action: #selector(cancelTapped)
        )
        
        // Style text fields
        styleTextField(urlTextField, placeholder: "Enter URL (e.g., https://example.com)")
        styleTextField(frequencyTextField, placeholder: "Frequency in seconds (e.g., 30)")
        styleTextField(maskTextField, placeholder: "Content mask to search for")
        
        // Setup numeric keyboard for frequency
        frequencyTextField.keyboardType = .numberPad
        
        // Style buttons
        saveButton.layer.cornerRadius = 8
        saveButton.backgroundColor = UIColor.systemBlue
        
        testButton.layer.cornerRadius = 8
        testButton.layer.borderWidth = 1
        testButton.layer.borderColor = UIColor.systemBlue.cgColor
        testButton.backgroundColor = UIColor.clear
        testButton.setTitleColor(UIColor.systemBlue, for: .normal)
        
        // Add text field delegates
        urlTextField.delegate = self
        frequencyTextField.delegate = self
        maskTextField.delegate = self
        
        // Add target for text field changes
        urlTextField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        frequencyTextField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        maskTextField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
    }
    
    private func styleTextField(_ textField: UITextField, placeholder: String) {
        textField.placeholder = placeholder
        textField.layer.cornerRadius = 8
        textField.layer.borderWidth = 1
        textField.layer.borderColor = UIColor.systemGray4.cgColor
        textField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: textField.frame.height))
        textField.leftViewMode = .always
        textField.rightView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: textField.frame.height))
        textField.rightViewMode = .always
    }
    
    private func loadConfiguration() {
        configuration = ConfigurationManager.shared.configuration
        
        urlTextField.text = configuration.url
        frequencyTextField.text = configuration.frequency > 0 ? "\(Int(configuration.frequency))" : ""
        maskTextField.text = configuration.contentMask
        
        updateSaveButtonState()
    }
    
    private func setupKeyboardHandling() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillShow(_:)),
            name: UIResponder.keyboardWillShowNotification,
            object: nil
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillHide(_:)),
            name: UIResponder.keyboardWillHideNotification,
            object: nil
        )
        
        // Add tap gesture to dismiss keyboard
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tapGesture)
    }
    
    // MARK: - Actions
    @objc private func cancelTapped() {
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func saveButtonTapped(_ sender: UIButton) {
        guard validateInput() else { return }
        
        saveConfiguration()
        
        let alert = UIAlertController(
            title: "Configuration Saved",
            message: "Your ping configuration has been saved successfully.",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default) { _ in
            self.navigationController?.popViewController(animated: true)
        })
        present(alert, animated: true)
    }
    
    @IBAction func testButtonTapped(_ sender: UIButton) {
        guard validateInput() else { return }
        
        testButton.isEnabled = false
        testButton.setTitle("Testing...", for: .normal)
        
        let tempConfig = PingConfiguration(
            url: urlTextField.text ?? "",
            frequency: TimeInterval(frequencyTextField.text ?? "30") ?? 30,
            contentMask: maskTextField.text ?? ""
        )
        
        PingService.shared.testPing(with: tempConfig) { [weak self] success, error in
            DispatchQueue.main.async {
                self?.testButton.isEnabled = true
                self?.testButton.setTitle("Test Connection", for: .normal)
                
                let title = success ? "Test Successful" : "Test Failed"
                let message = success ? 
                    "URL is reachable and content mask was found." : 
                    (error?.localizedDescription ?? "Content mask not found or URL unreachable.")
                
                let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default))
                self?.present(alert, animated: true)
            }
        }
    }
    
    @objc private func textFieldDidChange() {
        updateSaveButtonState()
    }
    
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
    
    // MARK: - Validation
    private func validateInput() -> Bool {
        guard let urlText = urlTextField.text, !urlText.isEmpty,
              let frequencyText = frequencyTextField.text, !frequencyText.isEmpty,
              let maskText = maskTextField.text, !maskText.isEmpty else {
            showAlert(title: "Missing Information", message: "Please fill in all fields.")
            return false
        }
        
        guard URL(string: urlText) != nil else {
            showAlert(title: "Invalid URL", message: "Please enter a valid URL.")
            return false
        }
        
        guard let frequency = Double(frequencyText), frequency > 0 else {
            showAlert(title: "Invalid Frequency", message: "Please enter a valid positive number for frequency.")
            return false
        }
        
        return true
    }
    
    private func updateSaveButtonState() {
        let hasUrl = !(urlTextField.text?.isEmpty ?? true)
        let hasFrequency = !(frequencyTextField.text?.isEmpty ?? true)
        let hasMask = !(maskTextField.text?.isEmpty ?? true)
        
        saveButton.isEnabled = hasUrl && hasFrequency && hasMask
        saveButton.alpha = saveButton.isEnabled ? 1.0 : 0.6
    }
    
    // MARK: - Save Configuration
    private func saveConfiguration() {
        configuration.url = urlTextField.text ?? ""
        configuration.frequency = TimeInterval(frequencyTextField.text ?? "30") ?? 30
        configuration.contentMask = maskTextField.text ?? ""
        
        ConfigurationManager.shared.saveConfiguration(configuration)
    }
    
    // MARK: - Keyboard Handling
    @objc private func keyboardWillShow(_ notification: Notification) {
        guard let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else {
            return
        }
        
        let keyboardHeight = keyboardFrame.height
        scrollView.contentInset.bottom = keyboardHeight
        scrollView.scrollIndicatorInsets.bottom = keyboardHeight
    }
    
    @objc private func keyboardWillHide(_ notification: Notification) {
        scrollView.contentInset.bottom = 0
        scrollView.scrollIndicatorInsets.bottom = 0
    }
    
    // MARK: - Helper Methods
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

// MARK: - UITextFieldDelegate
extension ConfigurationViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        switch textField {
        case urlTextField:
            frequencyTextField.becomeFirstResponder()
        case frequencyTextField:
            maskTextField.becomeFirstResponder()
        case maskTextField:
            textField.resignFirstResponder()
        default:
            textField.resignFirstResponder()
        }
        return true
    }
}