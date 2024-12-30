//
//  NotesListViewController.swift
//  MilestoneProjects19-21
//
//  Created by Антон Кашников on 03/07/2024.
//

#if DEBUG
import SwiftUI
#endif

import UIKit

final class NotesListViewController: UITableViewController {
    // MARK: - Private Properties
    
    private let detailSegueIdentifier = "detailSegue"
    private let viewModel = NotesViewModel()
    
    private var noteViewController: NoteViewController?
    
    // MARK: - UIViewController
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupNavigationBar()
        
        NotificationCenter.default.addObserver(
            forName: .init("notesChanged"),
            object: nil,
            queue: .main
        ) { _ in
            self.tableView.reloadData()
        }
        
        DispatchQueue.global().async {
            self.viewModel.loadNotes()
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == detailSegueIdentifier {
            guard let noteViewController = segue.destination as? NoteViewController else {
                return
            }
            
            self.noteViewController = noteViewController
            noteViewController.viewModel = viewModel
            
            if let noteIndex = tableView.indexPathForSelectedRow?.row {
                noteViewController.note = viewModel.notes[noteIndex]
            }
            
            if let _ = sender as? NotesListViewController {
                noteViewController.note = .init(
                    id: .init(),
                    title: "New note \(viewModel.notes.count + 1)", 
                    text: .init(),
                    date: .init()
                )
            }
        }
    }
    
    // MARK: - Private Methods
    
    private func setupNavigationBar() {
        title = "Notes"
        navigationController?.navigationBar.prefersLargeTitles = true
        
        navigationItem.rightBarButtonItem = .init(
            barButtonSystemItem: .compose,
            target: self,
            action: #selector(createNote)
        )
    }
    
    @objc private func createNote() {
        performSegue(withIdentifier: detailSegueIdentifier, sender: self)
    }
}

// MARK: - UITableViewDataSource

extension NotesListViewController {
    override func tableView(
        _ tableView: UITableView,
        numberOfRowsInSection section: Int
    ) -> Int {
        viewModel.notes.count
    }
    
    override func tableView(
        _ tableView: UITableView,
        cellForRowAt indexPath: IndexPath
    ) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "noteCell", for: indexPath)
        
        let note = viewModel.notes[indexPath.row]
        
        var contentConfiguration = cell.defaultContentConfiguration()
        contentConfiguration.text = note.title
        contentConfiguration.textProperties.numberOfLines = 1
        contentConfiguration.secondaryText = note.text
        contentConfiguration.secondaryTextProperties.numberOfLines = 1
        cell.contentConfiguration = contentConfiguration
        
        return cell
    }
    
    override func tableView(
        _ tableView: UITableView,
        commit editingStyle: UITableViewCell.EditingStyle,
        forRowAt indexPath: IndexPath
    ) {
        if editingStyle == .delete {
            DispatchQueue.global().async {
                self.viewModel.saveAfterRemoving(at: indexPath.row)
            }
            
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }
}

#if DEBUG
private struct NotesListViewControllerRepresentable: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> UINavigationController {
        .init(
            rootViewController: UIStoryboard(
                name: "Main",
                bundle: nil
            )
            .instantiateViewController(
                identifier: "NotesListViewController"
            ) as! NotesListViewController
        )
    }

    func updateUIViewController(
        _ uiViewController: UINavigationController,
        context: Context
    ) {}
}

@available(iOS 17, *)
#Preview {
    NotesListViewControllerRepresentable()
}
#endif
