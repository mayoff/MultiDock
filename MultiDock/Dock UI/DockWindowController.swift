//
//  DockWindowController.swift
//  MultiDock
//
//  Created by Dave DeLong on 1/26/19.
//  Copyright © 2019 Syzygy. All rights reserved.
//

import Cocoa

class DockWindowController: NSWindowController, NSWindowDelegate {

    private var configuration: DockConfiguration
    
    private var tiles = Array<ClickableItem>()
    private let stack = DockViewController()
    
    private var windowWidth: NSLayoutConstraint?
    private var windowHeight: NSLayoutConstraint?
    
    override var windowNibName: NSNib.Name? { return "DockWindowController" }
    
    init(configuration: DockConfiguration) {
        self.configuration = configuration
        super.init(window: nil)

        shouldCascadeWindows = false
        showWindow(self)
        stack.displayApps(configuration.apps.map { $0.0 })
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func update(with newConfiguration: DockConfiguration) {
        guard newConfiguration.display.displayID == configuration.display.displayID else { return }
        if newConfiguration == configuration { return }
        
        configuration = newConfiguration
        stack.displayApps(configuration.apps.map { $0.0 })
        window?.setFrame(configuration.display.bounds, display: false)
        
        windowWidth?.constant = configuration.display.bounds.width
        windowHeight?.constant = configuration.display.bounds.height
    }
    
    override func windowDidLoad() {
        super.windowDidLoad()
        window?.delegate = self
        window?.hasShadow = false
        window?.isOpaque = false
        window?.backgroundColor = .clear
        
        // the dock is at level 20, according to the deprecated .dock value
        window?.level = NSWindow.Level(rawValue: 21)
        window?.title = configuration.display.name
        window?.setFrame(configuration.display.bounds, display: true)
        
        let dockView = stack.view
        guard let container = window?.contentView else {
            fatalError("window is missing its contentView")
        }
        
        dockView.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(dockView)
        
        let w = container.widthAnchor.constraint(equalToConstant: configuration.display.bounds.width)
        let h = container.heightAnchor.constraint(equalToConstant: configuration.display.bounds.height)
        
        NSLayoutConstraint.activate([
            w,
            h,
            dockView.bottomAnchor.constraint(equalTo: container.bottomAnchor),
            dockView.centerXAnchor.constraint(equalTo: container.centerXAnchor),
            dockView.leadingAnchor.constraint(greaterThanOrEqualTo: container.leadingAnchor)
        ])
        
        windowWidth = w
        windowHeight = h
    }
}
