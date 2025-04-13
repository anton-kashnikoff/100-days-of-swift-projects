//
//  ViewController.swift
//  Project28
//
//  Created by Антон Кашников on 03/03/2025.
//

import LocalAuthentication
import UIKit

final class ViewController: UIViewController {
    private let passwordKey = "password"

    @IBOutlet private var secretTextView: UITextView!
    
    private var doneButton: UIBarButtonItem!
    private var passwordButton: UIBarButtonItem!
    
    private var hasPassword: Bool {
        KeychainWrapper.standard.hasValue(forKey: passwordKey)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Nothing to see here"
        
        doneButton = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(saveSecretMessage))
        passwordButton = UIBarButtonItem(title: "Password", style: .plain, target: self, action: #selector(setPassword))
        
        let notificationCenter = NotificationCenter.default
        
        // the hide is required because we do a little hack to make the hardware keyboard toggle work correctly
        notificationCenter.addObserver(
            self,
            selector: #selector(adjustForKeyboard),
            name: UIResponder.keyboardWillHideNotification,
            object: nil
        )
        
        notificationCenter.addObserver(
            self,
            selector: #selector(adjustForKeyboard),
            name: UIResponder.keyboardWillChangeFrameNotification,
            object: nil
        )
        
        notificationCenter.addObserver(
            self,
            selector: #selector(saveSecretMessage),
            name: UIApplication.willResignActiveNotification,
            object: nil
        )
    }
    
    @IBAction private func authenticateTapped() {
        let context = LAContext()
        var error: NSError?

        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            context.evaluatePolicy(
                .deviceOwnerAuthenticationWithBiometrics,
                localizedReason: "Identify yourself!"
            ) { [weak self] success, _ in
                DispatchQueue.main.async {
                    if success {
                        self?.unlockSecretMessage()
                    } else {
                        self?.failedBiometricAuthentication(context: context)
                    }
                }
            }
        } else {
            useFallbackAuthentication()
        }
    }
    
    @objc
    private func adjustForKeyboard(notification: Notification) {
        guard let keyboardValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else {
            return
        }
        
        let keyboardScreenEndFrame = keyboardValue.cgRectValue
        let keyboardViewEndFrame = view.convert(keyboardScreenEndFrame, from: view.window)
        
        secretTextView.contentInset = if notification.name == UIResponder.keyboardWillHideNotification {
            .zero
        } else {
            UIEdgeInsets(
                top: .zero,
                left: .zero,
                bottom: keyboardViewEndFrame.height - view.safeAreaInsets.bottom,
                right: .zero
            )
        }
        
        secretTextView.scrollIndicatorInsets = secretTextView.contentInset
        secretTextView.scrollRangeToVisible(secretTextView.selectedRange)
    }
    
    // only execute this code if the text view is visible, otherwise if a save happens before the app is unlocked then it will overwrite the saved text
    @objc
    private func saveSecretMessage() {
        guard !secretTextView.isHidden else { return }

        KeychainWrapper.standard.set(secretTextView.text, forKey: "SecretMessage")
        secretTextView.resignFirstResponder() // tell a view that has input focus that it should give up that focus (tell our text view that we're finished editing it, so the keyboard can be hidden)
        secretTextView.isHidden = true
        
        title = "Nothing to see here"
        navigationItem.rightBarButtonItem = nil
        navigationItem.leftBarButtonItem = nil
    }
    
    @objc
    private func setPassword() {
        let alertController = UIAlertController(
            title: "Set password",
            message: "Password can be used to authenticate",
            preferredStyle: .alert
        )
        
        alertController.addTextField {
            $0.isSecureTextEntry = true
            $0.placeholder = "Password"
        }
        
        alertController.addTextField {
            $0.isSecureTextEntry = true
            $0.placeholder = "Confirm password"
        }
        
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alertController.addAction(
            UIAlertAction(title: "OK", style: .default) { [weak self, weak alertController] _ in
                guard let password = self?.checkSetPasswordFields(alertController) else {
                    return
                }
                
                if let passwordKey = self?.passwordKey {
                    KeychainWrapper.standard.set(password, forKey: passwordKey)
                }
            }
        )
        
        present(alertController, animated: true)
    }
    
    private func unlockSecretMessage() {
        secretTextView.isHidden = false
        
        title = "Secret stuff!"
        navigationItem.rightBarButtonItem = doneButton
        navigationItem.leftBarButtonItem = passwordButton

        if let text = KeychainWrapper.standard.string(forKey: "SecretMessage") {
            secretTextView.text = text
        }
    }

    private func failedBiometricAuthentication(context: LAContext) {
        if !hasPassword {
            let biometryType = switch context.biometryType {
            case .none: "No biometry type supported"
            case .touchID: "Touch ID"
            case .faceID: "Face ID"
            case .opticID: "Optic ID"
            @unknown default: "Biometry type unknown"
            }
            
            showErrorMessage(
                title: "Authentication failed",
                message: "To use password authentication, first authenticate using \(biometryType) then set a password, or disable \(biometryType)"
            )
        } else {
            useFallbackAuthentication()
        }
    }
    
    private func useFallbackAuthentication() {
        hasPassword ? authenticateWithPassword() : setPassword()
    }
    
    private func showErrorMessage(title: String, message: String? = nil) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .default))
        present(alertController, animated: true)
    }
    
    private func authenticateWithPassword() {
        let alertController = UIAlertController(title: "Password authentication", message: nil, preferredStyle: .alert)
        alertController.addTextField {
            $0.isSecureTextEntry = true
            $0.placeholder = "Password"
        }
        
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alertController.addAction(
            UIAlertAction(title: "OK", style: .default) { [weak self, weak alertController] _ in
                guard let password = self?.getField(alertController, field: 0) else {
                    return
                }
                
                if let passwordKey = self?.passwordKey,
                   let storedPassword = KeychainWrapper.standard.string(forKey: passwordKey),
                   password == storedPassword
                {
                    self?.unlockSecretMessage()
                    return
                }
                
                self?.showErrorMessage(title: "Authentication failed", message: "You couldn't be verified. Please try again.")
            }
        )
        
        present(alertController, animated: true)
    }
    
    private func checkSetPasswordFields(_ alertController: UIAlertController?) -> String? {
        guard let password = getField(alertController, field: 0) else {
            setPasswordError(title: "Missing password")
            return nil
        }
        
        guard let passwordConfirmation = getField(alertController, field: 1) else {
            setPasswordError(title: "Missing password confirmation")
            return nil
        }
        
        guard password == passwordConfirmation else {
            setPasswordError(title: "Passwords don't match")
            return nil
        }
        
        return password
    }
    
    private func getField(_ alertController: UIAlertController?, field: Int) -> String? {
        guard let text = alertController?.textFields?[field].text,
              !text.isEmpty
        else {
            return nil
        }
        
        return text
    }
    
    private func setPasswordError(title: String) {
        let alertController = UIAlertController(title: title, message: nil, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alertController.addAction(
            UIAlertAction(title: "Retry", style: .default) { [weak self] _ in
                self?.setPassword()
            }
        )
        
        present(alertController, animated: true)
    }
}
