//
//  AppDelegate.swift
//  Pins
//
//  Created by Massimo Peri on 08/01/15.
//  Copyright (c) 2015 Massimo Peri. All rights reserved.
//

import Cocoa


@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    @IBOutlet weak var window: NSWindow!
    
    let statusBarItem = NSStatusBar.systemStatusBar().statusItemWithLength(-2)
    
    func applicationDidFinishLaunching(aNotification: NSNotification) {
        self.window!.orderOut(self)
        
        // Create status bar item.
        statusBarItem.image = NSImage(named: "Pin")
        statusBarItem.toolTip = "Pins"
        
        self.updateMenu()
    }

    func applicationWillTerminate(aNotification: NSNotification) {
        // Insert code here to tear down your application
    }

    // MARK: - Private methods
    
    func updateMenu() {
        let menu = NSMenu()
        menu.autoenablesItems = false
        
        // Create a menu item for each pinned folder in user defaults.
        if let pinnedFolders = NSUserDefaults.standardUserDefaults().arrayForKey("PinnedFolders") {
            var counter = 0
            for pinnedFolder in pinnedFolders {
                let menuItem = NSMenuItem()
                menuItem.title = pinnedFolder["PinnedFolderShortName"]! as String
                menuItem.action = Selector("openFolder:")
                menuItem.enabled = true
                menuItem.tag = counter++
                menu.addItem(menuItem)
            }
        }
        else {
            let menuItem = NSMenuItem()
            menuItem.title = NSLocalizedString("No pin available", comment: "Menu is empty.")
            menuItem.enabled = false
            menu.addItem(menuItem)
        }
        
        // Create a separator.
        menu.addItem(NSMenuItem.separatorItem())
        
        // Crete the edit menu item.
        let editMenuItem = NSMenuItem(title: NSLocalizedString("Edit...", comment: "Edit."), action: Selector("edit:"), keyEquivalent: "")
        editMenuItem.enabled = true
        menu.addItem(editMenuItem)

        // Create a separator.
        menu.addItem(NSMenuItem.separatorItem())

        // Create the about menu item.
        let aboutMenuItem = NSMenuItem(title: NSLocalizedString("About Pins", comment: "About"), action: Selector("about:"), keyEquivalent: "")
        aboutMenuItem.enabled = true
        menu.addItem(aboutMenuItem)
        
        // Create the quit menu item.
        let quitMenuItem = NSMenuItem(title: NSLocalizedString("Quit Pins", comment: "Quit."), action: Selector("quit:"), keyEquivalent: "")
        quitMenuItem.enabled = true
        menu.addItem(quitMenuItem)
        
        // Add the menu to the status bar item.
        statusBarItem.menu = menu
    }
    
    // MARK: - Actions
    
    func openFolder(sender: NSMenuItem) {
        let pinnedFolders = NSUserDefaults.standardUserDefaults().arrayForKey("PinnedFolders")!
        let pinnedFolder = pinnedFolders[sender.tag] as Dictionary<String, String>
        let pinnedFolderPath = pinnedFolder["PinnedFolderFullPath"]! as String
        
        // Open folder at specified path.
        NSWorkspace.sharedWorkspace().openURL(NSURL(fileURLWithPath: pinnedFolderPath)!)
    }
    
    func edit(sender: NSMenuItem) {
        let app = NSApplication.sharedApplication()
        app.activateIgnoringOtherApps(true)
        self.window!.makeKeyAndOrderFront(self)
    }
    
    func about(sender: NSMenuItem) {
        let app = NSApplication.sharedApplication()
        app.activateIgnoringOtherApps(true)
        app.orderFrontStandardAboutPanel(sender)
    }
    
    func quit(sender: NSMenuItem) {
        NSApplication.sharedApplication().terminate(self)
    }
    
}

