//
//  ActionViewController.swift
//  Extension
//
//  Created by Антон Кашников on 10/01/2024.
//

import UIKit
import MobileCoreServices
import UniformTypeIdentifiers

final class ActionViewController: UIViewController, CustomScriptsDataDelegate {
    // MARK: - IBOutlets
    
    @IBOutlet private var scriptTextView: UITextView!
    
    // MARK: - Private Properties
    
    private var pageTitle = ""
    private var pageURL = ""
    private var savedScripts = [String: String]()
    
    private let savedScriptsKey = "SavedScripts"
    private let customScriptsKey = "CustomScripts"
    
    // MARK: - Public Properties
    
    var customScripts = [CustomScript]()
    
    // MARK: - UIViewController
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        customizeTabBar()
        
        let notificationCenter = NotificationCenter.default
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
        
        // When extension is created, its extensionContext lets us control how it interacts with the parent app.
        // In the case of inputItems this will be an array of data the parent app is sending to our extension to use.
        if let inputItem = extensionContext?.inputItems.first as? NSExtensionItem {
            // Input item contains an array of attachments, which are given to us wrapped up as an NSItemProvider. Our code pulls out the first attachment from the first input item.
            if let itemProvider = inputItem.attachments?.first {
                let identifier = if #available(iOSApplicationExtension 14.0, *) {
                    UTType.propertyList.identifier as String
                } else {
                    kUTTypePropertyList as String
                }
                
                // Ask the item provider to actually provide us with its item.
                // The method will carry on executing while the item provider is busy loading and sending us its data.
                itemProvider.loadItem(forTypeIdentifier: identifier) { [weak self] dict, error in
                    guard
                        let itemDictionary = dict as? NSDictionary,
                        let javaScriptValues = itemDictionary[NSExtensionJavaScriptPreprocessingResultsKey] as? NSDictionary
                    else { return }
                    
                    self?.pageTitle = javaScriptValues["title"] as? String ?? ""
                    self?.pageURL = javaScriptValues["URL"] as? String ?? ""
                    
                    self?.loadData()
                    
                    DispatchQueue.main.async {
                        self?.title = self?.pageTitle
                        self?.showSavedScript()
                    }
                }
            }
        }
    }
    
    // MARK: - Private methods
    
    private func customizeTabBar() {
        navigationItem.leftBarButtonItems = [
            .init(
                image: .init(systemName: "doc.on.doc"),
                style: .plain,
                target: self,
                action: #selector(chooseScript)
            ),
            .init(
                image: .init(systemName: "square.and.arrow.down"),
                style: .plain,
                target: self,
                action: #selector(saveCustomScript)
            ),
            .init(
                image: .init(systemName: "tray"),
                style: .plain,
                target: self,
                action: #selector(showCustomScripts)
            )
        ]
        
        navigationItem.rightBarButtonItem = .init(
            barButtonSystemItem: .done,
            target: self,
            action: #selector(done)
        )
    }
    
    private func saveScriptForCurrentURL() {
        if let host = getURLHost() {
            savedScripts[host] = scriptTextView.text
            UserDefaults.standard.set(savedScripts, forKey: savedScriptsKey)
        }
    }
    
    private func showSavedScript() {
        if let host = getURLHost() {
            scriptTextView.text = savedScripts[host]
        }
    }
    
    private func getURLHost() -> String? {
        if #available(iOSApplicationExtension 16.0, *) {
            if
                let url = URL(string: pageURL),
                let host = url.host()
            { host } else { nil }
        } else {
            if
                let url = URL(string: pageURL),
                let host = url.host
            { host } else { nil }
        }
    }
    
    private func loadData() {
        savedScripts = UserDefaults.standard.object(forKey: savedScriptsKey) as? [String : String] ?? [String: String]()
        
        if let customScriptsData = UserDefaults.standard.object(forKey: customScriptsKey) as? Data {
            customScripts = (try? JSONDecoder().decode([CustomScript].self, from: customScriptsData)) ?? [CustomScript]()
        }
    }
    
    @objc
    private func adjustForKeyboard(notification: Notification) {
        guard let keyboardValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else {
            return
        }
        
        /* We need to convert the rectangle to our view's coordinates.
           This is because rotation isn't factored into the frame,
           so if the user is in landscape we'll have the width and height flipped.
           Using the convert() method will fix that. */
        let keyboardViewEndFrame = view.convert(keyboardValue.cgRectValue, from: view.window)
        
        // A check in there for UIKeyboardWillHide.
        // That's the workaround for hardware keyboards being connected by explicitly setting the insets to be zero.
        scriptTextView.contentInset = if notification.name == UIResponder.keyboardWillHideNotification {
            .zero
        } else {
            .init(top: 0, left: 0, bottom: keyboardViewEndFrame.height - view.safeAreaInsets.bottom, right: 0)
        }
        
        scriptTextView.verticalScrollIndicatorInsets = scriptTextView.contentInset
        scriptTextView.scrollRangeToVisible(scriptTextView.selectedRange)
    }
    
    @objc
    private func chooseScript() {
        let alertController = UIAlertController(
            title: "Choose script",
            message: "Choose the JavaScript script for execution",
            preferredStyle: .actionSheet
        )
        
        for (title, example) in scriptExamples {
            alertController.addAction(
                .init(title: title, style: .default) { [weak self] _ in
                    self?.scriptTextView.text = example
                }
            )
        }
        
        alertController.addAction(.init(title: "Cancel", style: .cancel))
        present(alertController, animated: true)
    }
    
    @objc
    private func saveCustomScript() {
        let alertController = UIAlertController(
            title: "Save script",
            message: "Enter name for your script",
            preferredStyle: .alert
        )
        alertController.addTextField()
        alertController.addAction(
            .init(title: "Save", style: .default) { [weak self, weak alertController] _ in
                guard let self, let name = alertController?.textFields?.first?.text else { return }
                
                self.customScripts.append(CustomScript(name: name, script: self.scriptTextView.text ?? ""))
                
                DispatchQueue.global().async {
                    if let savedData = try? JSONEncoder().encode(self.customScripts) {
                        UserDefaults.standard.set(savedData, forKey: self.customScriptsKey)
                    }
                }
            }
        )
        present(alertController, animated: true)
    }
    
    @objc
    private func showCustomScripts() {
        if let customScriptsTableViewController = storyboard?.instantiateViewController(
            identifier: "CustomScriptsViewController"
        ) as? CustomScriptsTableViewController {
            customScriptsTableViewController.delegate = self
            
            navigationController?.pushViewController(customScriptsTableViewController, animated: true)
        }
    }
    
    // MARK: - IBActions

    @IBAction private func done() {
        DispatchQueue.global().async { [weak self] in
            self?.saveScriptForCurrentURL()
        }
        
        let item = NSExtensionItem()
        let webDictionary: NSDictionary = [
            NSExtensionJavaScriptFinalizeArgumentKey: ["customJavaScript": scriptTextView.text as Any]
        ]
        
        let customJavaScript = if #available(iOSApplicationExtension 14.0, *) {
            NSItemProvider(item: webDictionary, typeIdentifier: UTType.propertyList.identifier as String)
        } else {
            NSItemProvider(item: webDictionary, typeIdentifier: kUTTypePropertyList as String)
        }
        
        item.attachments = [customJavaScript]
        extensionContext?.completeRequest(returningItems: [item])
    }
    
    // MARK: - Public Methods
    
    func setScriptToShow(at index: Int) {
        scriptTextView.text = customScripts[index].script
    }
}
