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
        let menuItem = NSMenuItem()
        if let pinnedFolders = NSUserDefaults.standardUserDefaults().arrayForKey("PinnedFolders") {
            // TODO: implement.
        }
        else {
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
    
    func edit(sender: NSMenuItem) {
        self.window!.orderFront(self)
        // TODO: make the window active.
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

