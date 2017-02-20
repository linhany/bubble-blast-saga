//
//  StorageManager.swift
//  LevelDesigner
//
//  Created by Yong Lin Han on 1/2/17.
//  Copyright © 2017 nus.cs3217.a0139498j. All rights reserved.
//

import UIKit

/// Handles persistency of game data.
/// Uses object archiving to write grid state to file.
struct StorageManager {

    init() {
        let documentDirectory = getUrlForFileInDocumentDirectory()
        let imageFolderPath = documentDirectory.appendingPathComponent("Image")
        do {
            try FileManager.default.createDirectory(atPath: imageFolderPath.path, withIntermediateDirectories: false, attributes: nil)
        } catch {
            // check if folder exists
        }
    }

    func saveLevel(level: Level, levelPreviewImage image: UIImage) -> Bool {
        let documentDirectory = getUrlForFileInDocumentDirectory()
        let fileURL = documentDirectory.appendingPathComponent(
            level.fileName + pListExtension)
        let imageURL = documentDirectory.appendingPathComponent(
            level.fileName + imageExtension)

        let data = NSMutableData()
        let archiver = NSKeyedArchiver(forWritingWith: data)

        archiver.encode(level, forKey: levelKey)
        archiver.finishEncoding()

        let isSaveSuccessful = data.write(to: fileURL, atomically: true)

        guard let imageStored = UIImagePNGRepresentation(image),
            isSaveSuccessful else {
            return false
        }
        let imageData = NSMutableData(data: imageStored)
        let isImageSaveSuccessful = imageData.write(to: imageURL, atomically: true)

        return isSaveSuccessful && isImageSaveSuccessful
    }

    func loadLevel(fromFile fileName: String) -> (Level, UIImage)? {
        let documentDirectory = getUrlForFileInDocumentDirectory()
        let fileURL = documentDirectory.appendingPathComponent(
            fileName + pListExtension)
        let imageURL = documentDirectory.appendingPathComponent(
            fileName + imageExtension)

        guard let data = NSData(contentsOf: fileURL) else {
            return nil
        }
        let unarchiver = NSKeyedUnarchiver(forReadingWith: data as Data)

        let decoded = unarchiver.decodeObject(forKey: levelKey)
        unarchiver.finishDecoding()

        guard let level = decoded as? Level else {
            return nil
        }
        guard let image = UIImage(contentsOfFile: imageURL.path) else {
            assertionFailure("Image was not saved!")
            return nil
        }

        return (level, image)
    }

    func getLevelNamesAndImagesFromDocumentDirectory() -> [(String, UIImage)] {
        let documentDirectory = getUrlForFileInDocumentDirectory()
        guard let directoryContents = getDirectoryContentUrls() else {
            fatalError("Unable to access document directory contents")
        }

        let pLists = directoryContents.filter{ $0.pathExtension == "pList" }
        var levels: [(String, UIImage)] = []
        for pList in pLists {
            let name = pList.deletingPathExtension().lastPathComponent
            let imageURL = documentDirectory.appendingPathComponent(
                name + imageExtension)
            guard let image = UIImage(contentsOfFile: imageURL.path) else {
                fatalError("Image was not saved!")
            }
            levels.append((name, image))
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
    private let imageExtension = ".png"
    private let levelKey = "levelKeyString"
}
