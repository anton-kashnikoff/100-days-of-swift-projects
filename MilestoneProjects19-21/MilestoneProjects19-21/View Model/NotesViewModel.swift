//
//  NotesViewModel.swift
//  MilestoneProjects19-21
//
//  Created by Антон Кашников on 03/07/2024.
//

import Foundation

final class NotesViewModel {
    // MARK: - Private Properties
    
    private let documentsDirectoryURL = FileManager.default.urls(
        for: .documentDirectory,
        in: .userDomainMask
    ).first!
    
    private var notesCodable = [NoteCodable]()
    
    // MARK: - Public Properties
    
    var notes = [Note]()
    
    // MARK: - Public Methods
    
    func saveAfterRemoving(at index: Int) {
        notes.remove(at: index)
        notesCodable.remove(at: index)
        
        if let savedData = try? JSONEncoder().encode(notesCodable) {
            UserDefaults.standard.set(savedData, forKey: "notes")
        } else {
            print("Failed to save notes.")
        }
    }
    
    func delete(note: Note) {
        let noteIndex = notes.firstIndex {
            $0.id == note.id
        }
        
        guard let noteIndex else { return }
        
        notes.remove(at: noteIndex)
        notesCodable.remove(at: noteIndex)
        
        if let savedData = try? JSONEncoder().encode(notesCodable) {
            UserDefaults.standard.set(savedData, forKey: "notes")
            NotificationCenter.default.post(name: .init("notesChanged"), object: nil)
        } else {
            print("Failed to save notes.")
        }
    }
    
    func saveNote(_ note: Note) {
        let noteCodable = NoteCodable(id: note.id, title: note.title, date: note.date)
        
        if !isEmpty(note: note) && !isExist(note: note) {
            notes.append(note)
            notesCodable.append(noteCodable)
        } else if !isEmpty(note: note) {
            let noteIndex = notes.firstIndex {
                $0.id == note.id
            }
            
            guard let noteIndex else { return }
            
            notes[noteIndex] = note
            notesCodable[noteIndex] = noteCodable
        }
        
        do {
            try save(note: note, noteCodable: noteCodable)
            
            NotificationCenter.default.post(name: .init("notesChanged"), object: nil)
        } catch {
            print("Failed to save notes.")
        }
    }
    
    func loadNotes() {
        if let savedNotes = UserDefaults.standard.object(forKey: "notes") as? Data {
            do {
                notesCodable = try JSONDecoder().decode([NoteCodable].self, from: savedNotes)
                
                try notesCodable.forEach { noteCodable in
                    notes.append(
                        .init(
                            id: noteCodable.id,
                            title: noteCodable.title,
                            text: try getText(of: noteCodable),
                            date: noteCodable.date
                        )
                    )
                }
                
                NotificationCenter.default.post(name: .init("notesChanged"), object: nil)
            } catch {
                print("Failed to load notes.")
            }
        }
    }
    
    // MARK: - Private Methods
    
    private func save(note: Note, noteCodable: NoteCodable) throws {
        if let savedData = try? JSONEncoder().encode(notesCodable) {
            UserDefaults.standard.set(savedData, forKey: "notes")
        }
        
        try? note.text.write(to: getFilename(of: noteCodable), atomically: true, encoding: .utf8)
    }
    
    private func getFilename(of note: NoteCodable) -> URL {
        if #available(iOS 16.0, *) {
            documentsDirectoryURL.appending(path: "\(note.title).txt")
        } else {
            documentsDirectoryURL.appendingPathComponent("\(note.title).txt")
        }
    }
    
    private func getText(of note: NoteCodable) throws -> String {
        try .init(contentsOf: getFilename(of: note))
    }
    
    private func isExist(note: Note) -> Bool {
        notes.contains { $0.id == note.id }
    }
    
    private func isEmpty(note: Note) -> Bool {
        note.title.isEmpty && note.text.isEmpty
    }
}
