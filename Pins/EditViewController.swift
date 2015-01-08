//
//  EditViewController.swift
//  Pins
//
//  Created by Massimo Peri on 09/01/15.
//  Copyright (c) 2015 Massimo Peri. All rights reserved.
//

import Cocoa


class EditViewController: NSViewController {
    
    var pins = [Dictionary<String, String>]()
        
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.

        if let pinnedFolders = NSUserDefaults.standardUserDefaults().arrayForKey("PinnedFolders") {
            pins = pinnedFolders as [Dictionary<String, String>]
        }
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
            }
        }
    }
}
