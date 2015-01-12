// EditViewController.swift
//
// Copyright (c) 2015 Massimo Peri (@massimoksi)
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

import Cocoa


class EditViewController: NSViewController, NSTableViewDataSource, NSTableViewDelegate, NSTextFieldDelegate {
    
    @IBOutlet weak var tableView: NSTableView!
    @IBOutlet weak var deleteButton: NSButton!
    
    var pins = [Dictionary<String, String>]()
    
    weak var statusBarItemDelegate: StatusBarItemDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.

        self.tableView.registerForDraggedTypes([NSPasteboardTypeString, NSURLPboardType])
        
        if let pinnedFolders = NSUserDefaults.standardUserDefaults().arrayForKey(Constants.PinnedFoldersKey) {
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
                    Constants.PinnedFoldersShortNameKey: pinnedFolder.lastPathComponent!,
                    Constants.PinnedFoldersFullPathKey: pinnedFolder.path!
                ]
                self.pins.append(newPin)

                NSUserDefaults.standardUserDefaults().setObject(self.pins, forKey: Constants.PinnedFoldersKey)
                
                self.tableView.reloadData()
                self.statusBarItemDelegate?.pinsDidChange()
            }
        }
    }
    
    @IBAction func removePin(sender: NSButton) {
        self.pins.removeAtIndex(self.tableView.selectedRow)
        if (self.pins.count > 0) {
            NSUserDefaults.standardUserDefaults().setObject(self.pins, forKey: Constants.PinnedFoldersKey)
        }
        else {
            NSUserDefaults.standardUserDefaults().removeObjectForKey(Constants.PinnedFoldersKey)
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
            editedPin[Constants.PinnedFoldersShortNameKey] = newShortName
            self.pins[index] = editedPin
            
            NSUserDefaults.standardUserDefaults().setObject(self.pins, forKey: Constants.PinnedFoldersKey)
            
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
    
    func tableView(aTableView: NSTableView, writeRowsWithIndexes rowIndexes: NSIndexSet, toPasteboard pboard: NSPasteboard) -> Bool {
        let data = NSKeyedArchiver.archivedDataWithRootObject(rowIndexes)
        pboard.declareTypes([NSPasteboardTypeString], owner: self)
        pboard.setData(data, forType: NSPasteboardTypeString)
        
        return true
    }
    
    func tableView(aTableView: NSTableView, validateDrop info: NSDraggingInfo, proposedRow row: Int, proposedDropOperation operation: NSTableViewDropOperation) -> NSDragOperation {
        if let draggingSource: AnyObject = info.draggingSource() {
            return .Move
        }
        else {
            let pasteboard = info.draggingPasteboard()
            let aClass: AnyObject = classFromType(NSURL.self)
            let classes = [aClass]
            if let urls = pasteboard.readObjectsForClasses(classes, options: nil) as? [NSURL] {
                if (urls.count != 1) {
                    // Allow only single element dragging.
                    return .None
                }
                
                // Check if the url is a directory.
                var error: NSError?
                var resource: AnyObject?
                let success = urls[0].getResourceValue(&resource, forKey: NSURLIsDirectoryKey, error: &error)
                if success {
                    let isDirectory = resource as Bool
                    if isDirectory {
                        return .Copy
                    }
                    else {
                        return .None
                    }
                }
                else {
                    return .None
                }
            }
            else {
                return .None
            }
        }
    }
    
    func tableView(aTableView: NSTableView, acceptDrop info: NSDraggingInfo, row: Int, dropOperation operation: NSTableViewDropOperation) -> Bool {
        if let draggingSource: AnyObject = info.draggingSource() {
            let data = info.draggingPasteboard().dataForType(NSPasteboardTypeString)!
            let rowIndexes = NSKeyedUnarchiver.unarchiveObjectWithData(data) as NSIndexSet
            let sourceRow = rowIndexes.firstIndex
            let draggedPin = self.pins[sourceRow]
            
            self.pins.removeAtIndex(sourceRow)
            if (row > self.pins.count) {
                self.pins.insert(draggedPin, atIndex: row - 1)
            }
            else {
                self.pins.insert(draggedPin, atIndex: row)
            }
        }
        else {
            let pasteboard = info.draggingPasteboard()
            let aClass: AnyObject = classFromType(NSURL.self)
            let classes = [aClass]
            let urls = pasteboard.readObjectsForClasses(classes, options: nil) as [NSURL]
            
            let draggedFolder = urls[0]
            let newPin = [
                Constants.PinnedFoldersShortNameKey: draggedFolder.lastPathComponent!,
                Constants.PinnedFoldersFullPathKey: draggedFolder.path!
            ]
            self.pins.append(newPin)
        }
        
        NSUserDefaults.standardUserDefaults().setObject(self.pins, forKey: Constants.PinnedFoldersKey)
        
        self.statusBarItemDelegate?.pinsDidChange()
        tableView.reloadData()
        
        return true
    }
    
    // MARK: - Table view delegate
    
    func tableView(tableView: NSTableView, viewForTableColumn: NSTableColumn, row: Int) -> NSView {
        var cell = NSTableCellView()
        
        let currentPin = self.pins[row]
        if (viewForTableColumn.identifier == "ShortNameTableColumn") {
            cell = tableView.makeViewWithIdentifier("ShortNameCell", owner: self) as NSTableCellView
            cell.textField!.stringValue = currentPin[Constants.PinnedFoldersShortNameKey]!
            cell.textField!.editable = true
            cell.textField!.delegate = self
        }
        else if (viewForTableColumn.identifier == "FullPathTableColumn") {
            cell = tableView.makeViewWithIdentifier("FullPathCell", owner: self) as NSTableCellView
            cell.textField!.stringValue = currentPin[Constants.PinnedFoldersFullPathKey]!
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
    
    // MARK: - Private methods
    
    private func classFromType<T: NSObject>(type: T.Type) -> AnyObject! {
        // HACK: ask for class indirectly...
        return T.valueForKey("self")
    }
    
}
