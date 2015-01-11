// AppDelegate.swift
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


@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate, StatusBarItemDelegate {

    @IBOutlet weak var window: NSWindow!
    @IBOutlet weak var viewController: EditViewController!
    
    let statusBarItem = NSStatusBar.systemStatusBar().statusItemWithLength(-2)
    
    func applicationDidFinishLaunching(aNotification: NSNotification) {
        self.window!.orderOut(self)
        
        self.viewController.statusBarItemDelegate = self
        
        // Create status bar item.
        self.statusBarItem.image = NSImage(named: "Pin")
        self.statusBarItem.toolTip = "Pins"
        
        self.updateMenu()
    }

    func applicationWillTerminate(aNotification: NSNotification) {
        // Insert code here to tear down your application
    }

    // MARK: - Actions
    
    func openFolder(sender: NSMenuItem) {
        let pinnedFolders = NSUserDefaults.standardUserDefaults().arrayForKey(Constants.PinnedFoldersKey)!
        let pinnedFolder = pinnedFolders[sender.tag] as Dictionary<String, String>
        let pinnedFolderPath = pinnedFolder[Constants.PinnedFoldersFullPathKey]! as String
        
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
    
    // MARK: - Private methods
    
    private func updateMenu() {
        let menu = NSMenu()
        menu.autoenablesItems = false
        
        // Create a menu item for each pinned folder in user defaults.
        if let pinnedFolders = NSUserDefaults.standardUserDefaults().arrayForKey(Constants.PinnedFoldersKey) {
            var counter = 0
            for pinnedFolder in pinnedFolders {
                let menuItem = NSMenuItem()
                menuItem.title = pinnedFolder[Constants.PinnedFoldersShortNameKey]! as String
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
        self.statusBarItem.menu = menu
    }

    // MARK: - Status bar item delegate
    
    func pinsDidChange() {
        self.updateMenu()
    }
    
}

