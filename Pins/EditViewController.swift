//
//  EditViewController.swift
//  Pins
//
//  Created by Massimo Peri on 09/01/15.
//  Copyright (c) 2015 Massimo Peri. All rights reserved.
//

import Cocoa


class EditViewController: NSViewController, NSTableViewDataSource, NSTableViewDelegate {
    
    @IBOutlet weak var tableView: NSTableView!
    @IBOutlet weak var deleteButton: NSButton!
    
    var pins = [Dictionary<String, String>]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.

        if let pinnedFolders = NSUserDefaults.standardUserDefaults().arrayForKey("PinnedFolders") {
            pins = pinnedFolders as [Dictionary<String, String>]
        }
        
        deleteButton.hidden = true
    }
    
    // MARK: - Actions
    
    @IBAction func addPin(sender: NSButton) {
        let openPanel = NSOpenPanel()
        openPanel.canChooseFiles = false
        openPanel.canChooseDirectories = true
        openPanel.canCreateDirectories = false
        openPanel.allowsMultipleSelection = false
        openPanel.beginSheetModalForWindow(self.view.window!) { response in
            if (response == NSFileHandlingPanelOKButton) {
                let pinnedFolder = openPanel.URLs[0] as NSURL
                let newPin = [
                    "PinnedFolderShortName": pinnedFolder.lastPathComponent!,
                    "PinnedFolderFullPath": pinnedFolder.path!
                ]
                self.pins.append(newPin)

                NSUserDefaults.standardUserDefaults().setObject(self.pins, forKey: "PinnedFolders")
                
                self.tableView.reloadData()
            }
        }
    }
    
    // MARK: - Table view data source

    func numberOfRowsInTableView(aTableView: NSTableView!) -> Int {
        return pins.count
    }
    
    // MARK: - Table view delegate
    
    func tableView(tableView: NSTableView, viewForTableColumn: NSTableColumn, row: Int) -> NSView {
        var cell = NSTableCellView()
        
        let currentPin = self.pins[row]
        if (viewForTableColumn.identifier == "ShortNameTableColumn") {
            cell = tableView.makeViewWithIdentifier("ShortNameCell", owner: self) as NSTableCellView
            cell.textField!.stringValue = currentPin["PinnedFolderShortName"]!
            cell.textField!.editable = true
        }
        else if (viewForTableColumn.identifier == "FullPathTableColumn") {
            cell = tableView.makeViewWithIdentifier("FullPathCell", owner: self) as NSTableCellView
            cell.textField!.stringValue = currentPin["PinnedFolderFullPath"]!
            cell.textField!.editable = false
            cell.textField!.selectable = true
        }
        
        return cell
    }
    
}
