//
//  LevelsTableViewController.swift
//  LevelDesigner
//
//  Created by Yong Lin Han on 31/1/17.
//  Copyright © 2017 nus.cs3217.a0139498j. All rights reserved.
//

import UIKit

// MARK: - LevelsTableViewDelegate
/// The delegate protocols for LevelsTableViewController.
/// Parameters of functions are representations of a level
/// in the Documents directory, which is a file containing the 
/// state of the grid saved using object archiving.
protocol LevelsTableViewDelegate {

    /// Loads a level specified by `fileName`.
    func loadLevel(fileName: String)

    /// Deletes a level specified by `fileIndex`.
    /// - Parameter: The integer corresponding to position of file in directory. Zero-indexed.
    func deleteLevel(fileIndex: Int)
}

// MARK: - LevelsTableViewController
/// The controller responsible for the load level table view.
/// This view is presented as a popover segue from the LevelDesignViewController
/// and renders the level names as strings in table cells.
class LevelsTableViewController: UITableViewController {

    /// The String array containing the names of saved levels.
    internal var levelNames: [String] = []

    /// The delegate for loading and deleting of levels.
    internal var delegate: LevelsTableViewDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
    }

}

// MARK: - Table view data source
extension LevelsTableViewController {

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return levelNames.count
    }

    /// Sets the text of the cell as the level name.
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(
            withIdentifier: Constants.loadLevelsCellIdentifier,
            for: indexPath)

        cell.textLabel?.text = levelNames[indexPath.row]

        return cell
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return Constants.loadLevelTableHeader
    }

    /// Supports editing of table view cells.
    /// Current implementation only supports deletion of cells by swiping left.
    /// Upon selecting to delete, an alert is shown to the user asking for
    /// confirmation. The rationale for this extra step is because we do not
    /// currently support undo operations.
    override func tableView(_ tableView: UITableView,
                            commit editingStyle: UITableViewCellEditingStyle,
                            forRowAt indexPath: IndexPath) {
        guard editingStyle == .delete else {
            return
        }
        let uiAlert = UIAlertController.alertForDeleteLevel { (isDeleteConfirmed) in
            guard isDeleteConfirmed else {
                return
            }
            self.levelNames.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
            guard let delegate = self.delegate else {
                return
            }
            delegate.deleteLevel(fileIndex: indexPath.row)
        }
        self.present(uiAlert, animated: true, completion: nil)
    }

    /// Supports loading of a level upon tapping of cell by user.
    /// Dismisses the popover view upon loading.
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let cell = tableView.cellForRow(at: indexPath) else {
            assertionFailure("Index Path cannot be invalid!")
            return
        }
        guard let fileName = cell.textLabel?.text else {
            assertionFailure("File name must be present!")
            return
        }
        guard let delegate = delegate else {
            fatalError("Delegate was not setup!")
        }

        delegate.loadLevel(fileName: fileName)
        self.dismiss(animated: false, completion: nil)
    }

}
