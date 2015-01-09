//
//  EditViewController.swift
//  Pins
//
//  Created by Massimo Peri on 09/01/15.
//  Copyright (c) 2015 Massimo Peri. All rights reserved.
//

import Cocoa


class EditViewController: NSViewController, NSTableViewDataSource, NSTableViewDelegate, NSTextFieldDelegate {
    
    @IBOutlet weak var tableView: NSTableView!
    @IBOutlet weak var deleteButton: NSButton!
    
    var pins = [Dictionary<String, String>]()
    
    weak var statusBarItemDelegate: StatusBarItemDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.

        if let pinnedFolders = NSUserDefaults.standardUserDefaults().arrayForKey("PinnedFolders") {
            self.pins = pinnedFolders as [Dictionary<String, String>]
        }
        
        self.deleteButton.hidden = true
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
                self.statusBarItemDelegate?.pinsDidChange()
            }
        }
    }
    
    @IBAction func removePin(sender: NSButton) {
        self.pins.removeAtIndex(self.tableView.selectedRow)
        if (self.pins.count > 0) {
            NSUserDefaults.standardUserDefaults().setObject(self.pins, forKey: "PinnedFolders")
        }
        else {
            NSUserDefaults.standardUserDefaults().removeObjectForKey("PinnedFolders")
        }
        
        self.tableView.reloadData()
        self.statusBarItemDelegate?.pinsDidChange()
        
        self.deleteButton.hidden = true
    }
    
    func editPin(sender: NSTextField) {
        let newShortName = sender.stringValue
        if (newShortName != "") {
            let index = self.tableView.selectedRow
            
            // Update the pin.
            var editedPin = self.pins[index]
            editedPin["PinnedFolderShortName"] = newShortName
            self.pins[index] = editedPin
            
            NSUserDefaults.standardUserDefaults().setObject(self.pins, forKey: "PinnedFolders")
            
            self.statusBarItemDelegate?.pinsDidChange()
        }
        else {
            self.tableView.reloadData()
            
            self.deleteButton.hidden = true
        }
    }
    
    // MARK: - Table view data source

    func numberOfRowsInTableView(aTableView: NSTableView!) -> Int {
        return self.pins.count
    }
    
    // MARK: - Table view delegate
    
    func tableView(tableView: NSTableView, viewForTableColumn: NSTableColumn, row: Int) -> NSView {
        var cell = NSTableCellView()
        
        let currentPin = self.pins[row]
        if (viewForTableColumn.identifier == "ShortNameTableColumn") {
            cell = tableView.makeViewWithIdentifier("ShortNameCell", owner: self) as NSTableCellView
            cell.textField!.stringValue = currentPin["PinnedFolderShortName"]!
            cell.textField!.editable = true
            cell.textField!.delegate = self
        }
        else if (viewForTableColumn.identifier == "FullPathTableColumn") {
            cell = tableView.makeViewWithIdentifier("FullPathCell", owner: self) as NSTableCellView
            cell.textField!.stringValue = currentPin["PinnedFolderFullPath"]!
            cell.textField!.editable = false
            cell.textField!.selectable = true
        }
        
        return cell
    }
    
    func tableViewSelectionDidChange(notification: NSNotification) {
        if (self.tableView.selectedRow == -1) {
            self.deleteButton.hidden = true
        }
        else {
            self.deleteButton.hidden = false
        }
    }
    
    // MARK: - Text field delegate
    
    func control(control: NSControl, textShouldEndEditing fieldEditor: NSText) -> Bool {
        let sender = control as NSTextField
        self.editPin(sender)
        
        return true
    }
    
}
