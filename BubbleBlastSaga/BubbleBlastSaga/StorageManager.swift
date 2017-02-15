//
//  StorageManager.swift
//  LevelDesigner
//
//  Created by Yong Lin Han on 1/2/17.
//  Copyright © 2017 nus.cs3217.a0139498j. All rights reserved.
//

import Foundation

/// Handles persistency of game data.
/// Uses object archiving to write grid state to file.
struct StorageManager {

    /// Saves the `gridState` represented as a 2D array of GameBubbles to file.
    func saveGridState(gridState: [[GameBubble?]], toFile fileName: String) -> Bool {
        let documentDirectory = getUrlForFileInDocumentDirectory()
        let fileURL = documentDirectory.appendingPathComponent(
            fileName + pListExtension)

        let data = NSMutableData()
        let archiver = NSKeyedArchiver(forWritingWith: data)

        archiver.encode(gridState, forKey: gridStateKey)
        archiver.finishEncoding()

        let isSaveSuccessful = data.write(to: fileURL, atomically: true)
        return isSaveSuccessful
    }

    /// Loads a 2D array representing bubble grid state from file with `fileName`.
    func loadGridState(fromFile fileName: String) -> [[GameBubble?]]? {
        let documentDirectory = getUrlForFileInDocumentDirectory()
        let fileURL = documentDirectory.appendingPathComponent(
            fileName + pListExtension)

        guard let data = NSData(contentsOf: fileURL) else {
            return nil
        }
        let unarchiver = NSKeyedUnarchiver(forReadingWith: data as Data)

        let decoded = unarchiver.decodeObject(forKey: gridStateKey)
        unarchiver.finishDecoding()

        guard let gridState = decoded as? [[GameBubble?]] else {
            return nil
        }
        return gridState
    }

    /// Returns an array of strings, that are the filenames of saved levels
    /// in the document directory.
    func getLevelNamesFromDocumentDirectoryAsStrings() -> [String] {
        guard let directoryContents = getDirectoryContentUrls() else {
            fatalError("Unable to access document directory contents")
        }
        var levels: [String] = []
        for pList in directoryContents {
            levels.append(pList.deletingPathExtension().lastPathComponent)
        }
        return levels
    }

    /// Deletes a file specified by the `index` of it in the directory,
    /// with the first file in the directory as zero indexed.
    func removeFileInDocumentDirectoryAt(index: Int) {
        guard let directoryContents = getDirectoryContentUrls() else {
            fatalError("Unable to access document directory contents")
        }
        do {
            try FileManager.default.removeItem(at: directoryContents[index])
        } catch {
            assertionFailure("File cannot be missing!")
        }
    }

    /// Returns the url for a file in the document directory.
    private func getUrlForFileInDocumentDirectory() -> URL {
        // Get the URL of the Documents Directory
        let urls = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        // Get the URL for a file in the Documents Directory
        let documentDirectory = urls[0]
        return documentDirectory
    }

    /// Returns an array of URLs of files in the document directory.
    private func getDirectoryContentUrls() -> [URL]? {
        let documentDirectory = getUrlForFileInDocumentDirectory()
        guard let directoryContents = try? FileManager.default.contentsOfDirectory(
            at: documentDirectory,
            includingPropertiesForKeys: nil,
            options: []) else {
            return nil
        }
        return directoryContents
    }

	/**
	
	Tutor: put the constant on top next time
	
	*/
	
    private let pListExtension = ".pList"
    private let gridStateKey = "modelKeyString"
}
