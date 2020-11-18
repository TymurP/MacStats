//
//  AppDelegate.swift
//  MacStats
//
//  Created by Tymur Pysarevych on 10.11.20.
//

import Cocoa
import SwiftUI


@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    
    var popover: NSPopover!
    var statusBarItem: NSStatusItem!
    var menu: NSMenu!
    var timer: Timer?
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        var hasSMC = false
        do {
            try SMCKit.open()
            hasSMC = true
        } catch {
            hasSMC = false
            Utils.handleError(msg: "SMC is not available")
        }
        if !hasSMC { return }
        Utils.getSensors()
        constructPopover()
    }
    
    private func constructPopover() {
        let contentView = ContentView()
        let popover = NSPopover()
        popover.contentSize = NSSize(width: 400, height: 500)
        popover.behavior = .transient
        popover.contentViewController = NSHostingController(rootView: contentView)
        self.popover = popover
        self.popover.contentViewController?.view.window?.becomeKey()
        
        self.statusBarItem = NSStatusBar.system.statusItem(withLength:NSStatusItem.squareLength)
        
        self.statusBarItem.button?.image = #imageLiteral(resourceName: "MenuImage")
        self.statusBarItem.button?.image?.size = NSSize(width: 18.0, height: 18.0)
        self.statusBarItem.button?.image?.isTemplate = true
        self.statusBarItem.button?.action = #selector(self.statusBarButtonClicked(sender:))
        self.statusBarItem.button?.sendAction(on: [.leftMouseUp, .rightMouseUp])
        constructMenu()
    }
    
    private func constructMenu() {
        self.menu = NSMenu()
        menu.addItem(NSMenuItem(title: "Quit", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q"))
    }
    
    @objc private func statusBarButtonClicked(sender: NSStatusBarButton) {
        let event = NSApp.currentEvent!
        if self.popover.isShown {
            self.popover.performClose(sender)
        }
        if event.type == NSEvent.EventType.rightMouseUp {
            self.statusBarItem.menu = menu
        } else {
            togglePopover(sender)
        }
    }
    
    func togglePopover(_ sender: AnyObject?) {
        if let button = self.statusBarItem.button {
            if self.popover.isShown {
                self.popover.performClose(sender)
            } else {
                self.popover.show(relativeTo: button.bounds, of: button, preferredEdge: NSRectEdge.minY)
            }
        }
    }
    
    func applicationWillTerminate(_ aNotification: Notification) {
        SMCKit.close()
    }
}
