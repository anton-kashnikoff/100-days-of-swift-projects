//
//  NoteViewController.swift
//  MilestoneProjects19-21
//
//  Created by Антон Кашников on 03/07/2024.
//

#if DEBUG
import SwiftUI
#endif

import UIKit

final class NoteViewController: UIViewController {
    // MARK: - UI-elements
    
    @IBOutlet private var textView: UITextView!
    
    // MARK: - Public Properties
    
    var viewModel: NotesViewModel?
    var note: Note?
    
    // MARK: - UIViewController
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupNavigationBar()
        
        textView.delegate = self
        textView.text = note?.text
        
        addObservers()
    }
    
    // MARK: - Private Methods
    
    private func setupNavigationBar() {
        navigationItem.largeTitleDisplayMode = .never
        
        navigationItem.rightBarButtonItems = [
            .init(
                image: .init(systemName: "ellipsis.circle"),
                menu: .init(
                    options: .displayInline,
                    children: [
                        UIAction(
                            title: "Delete",
                            image: .init(systemName: "trash"),
                            attributes: .destructive
                        ) { [weak self] _ in
                            guard let self, let note else { return }
                            
                            self.viewModel?.delete(note: note)
                            self.navigationController?.popViewController(animated: true)
                        }
                    ]
                )
            ),
            .init(
                image: .init(systemName: "square.and.arrow.up"),
                style: .plain,
                target: self,
                action: #selector(shareNote)
            )
        ]
    }
    
    private func addObservers() {
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
        
        notificationCenter.addObserver(
            self,
            selector: #selector(adjustForKeyboard),
            name: UIResponder.keyboardWillShowNotification,
            object: nil
        )
    }
    
    @objc private func endNote() {
        textView.resignFirstResponder()
    }
    
    @objc private func shareNote() {
        let activityViewController = UIActivityViewController(
            activityItems: [note?.text ?? ""],
            applicationActivities: []
        )
        
        if #available(iOS 16.0, *) {
            activityViewController.popoverPresentationController?.sourceItem = navigationItem.rightBarButtonItems?.first
        } else {
            activityViewController.popoverPresentationController?.barButtonItem = navigationItem.rightBarButtonItems?.first
        }
        
        present(activityViewController, animated: true)
    }
    
    @objc private func adjustForKeyboard(notification: Notification) {
        guard
            let keyboardValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue
        else {
            return
        }
        if notification.name == UIResponder.keyboardWillShowNotification {
            navigationItem.rightBarButtonItems?.insert(
                .init(barButtonSystemItem: .done, target: self, action: #selector(endNote)),
                at: 0
            )
        }
        
        let keyboardViewEndFrame = view.convert(keyboardValue.cgRectValue, from: view.window)
        
        if notification.name == UIResponder.keyboardWillHideNotification {
            textView.contentInset = .zero
            
            // protection from calling 2 times
            if navigationItem.rightBarButtonItems?.count == 3 {
                navigationItem.rightBarButtonItems?.removeFirst()
            }
        } else {
            textView.contentInset = .init(
                top: 0,
                left: 0,
                bottom: keyboardViewEndFrame.height - view.safeAreaInsets.bottom,
                right: 0
            )
        }
        
        textView.verticalScrollIndicatorInsets = textView.contentInset
        textView.scrollRangeToVisible(textView.selectedRange)
    }
    
    // MARK: - Public Methods
    
    func saveNote() {
        note?.text = textView.text
        
        if let note {
            DispatchQueue.global().async {
                self.viewModel?.saveNote(note)
            }
        }
    }
}

// MARK: - UITextViewDelegate

extension NoteViewController: UITextViewDelegate {
    func textViewDidEndEditing(_ textView: UITextView) {
        saveNote()
    }
}

#if DEBUG
private struct NoteViewControllerRepresentable: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> UINavigationController {
        .init(
            rootViewController: UIStoryboard(
                name: "Main",
                bundle: nil
            )
            .instantiateViewController(
                identifier: "NoteViewController"
            ) as! NoteViewController
        )
    }

    func updateUIViewController(
        _ uiViewController: UINavigationController,
        context: Context
    ) {}
}

@available(iOS 17, *)
#Preview {
    NoteViewControllerRepresentable()
}
#endif
