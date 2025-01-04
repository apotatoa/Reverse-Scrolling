import Cocoa

@main
class AppDelegate: NSObject, NSApplicationDelegate {
    var statusBarItem: NSStatusItem?

    func applicationDidFinishLaunching(_ notification: Notification) {
        // Remove the app from the Dock and the app switcher
        NSApp.setActivationPolicy(.accessory)

        // Create the menu bar item
        statusBarItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        
        if let button = statusBarItem?.button {
            button.image = NSImage(systemSymbolName: "arrow.2.circlepath", accessibilityDescription: "Toggle Scrolling Direction")
        }
        
        let menu = NSMenu()
        menu.addItem(NSMenuItem(title: "Quit", action: #selector(quitApp), keyEquivalent: "q"))
        statusBarItem?.menu = menu

        // Start observing input devices and switching scroll directions
        setupScrollingBehavior()
    }

    func setupScrollingBehavior() {
        let eventTap = CGEvent.tapCreate(
            tap: .cghidEventTap,
            place: .headInsertEventTap,
            options: .defaultTap,
            eventsOfInterest: CGEventMask(1 << CGEventType.scrollWheel.rawValue),
            callback: { proxy, type, event, refcon in
                guard type == .scrollWheel else { return Unmanaged.passUnretained(event) }

                // Check if the Shift key is pressed
                let shiftPressed = event.flags.contains(.maskShift)

                // Reverse scroll direction only for non-shift events
                if !shiftPressed {
                    let isContinuous = event.getIntegerValueField(.scrollWheelEventIsContinuous) == 1
                    if !isContinuous { // Mouse scroll
                        let deltaX = -event.getDoubleValueField(.scrollWheelEventDeltaAxis1)
                        let deltaY = -event.getDoubleValueField(.scrollWheelEventDeltaAxis2)
                        event.setDoubleValueField(.scrollWheelEventDeltaAxis1, value: deltaX)
                        event.setDoubleValueField(.scrollWheelEventDeltaAxis2, value: deltaY)
                    }
                }
                return Unmanaged.passUnretained(event)
            },
            userInfo: nil
        )

        if let eventTap = eventTap {
            let runLoopSource = CFMachPortCreateRunLoopSource(kCFAllocatorDefault, eventTap, 0)
            CFRunLoopAddSource(CFRunLoopGetCurrent(), runLoopSource, .commonModes)
            CGEvent.tapEnable(tap: eventTap, enable: true)
        } else {
            print("Failed to create event tap")
        }
    }

    @objc func quitApp() {
        NSApplication.shared.terminate(self)
    }
}
