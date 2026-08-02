import Cocoa

@main
class AppDelegate: NSObject, NSApplicationDelegate {
    var statusBarItem: NSStatusItem?

    // Persist enable state in UserDefaults
    @objc dynamic var isEnabled: Bool = UserDefaults.standard.object(forKey: "isEnabled") as? Bool ?? true {
        didSet { UserDefaults.standard.set(isEnabled, forKey: "isEnabled") }
    }

    func applicationDidFinishLaunching(_ notification: Notification) {
        // Remove the app from the Dock and the app switcher
        NSApp.setActivationPolicy(.accessory)

        // Create the menu bar item
        statusBarItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)

        if let button = statusBarItem?.button {
            button.image = NSImage(systemSymbolName: "arrow.2.circlepath", accessibilityDescription: "Toggle Scrolling Direction")
        }

        buildMenu()
        setupScrollingBehavior()
    }

    // MARK: - Menu Setup

    func buildMenu() {
        let menu = NSMenu()

        // Enable Checkbox
        let enableItem = NSMenuItem(title: "Enabled", action: #selector(toggleEnable(_:)), keyEquivalent: "")
        enableItem.state = isEnabled ? .on : .off
        menu.addItem(enableItem)

        menu.addItem(NSMenuItem.separator())

        // Quit Option
        menu.addItem(NSMenuItem(title: "Quit", action: #selector(quitApp), keyEquivalent: "q"))

        statusBarItem?.menu = menu
    }

    @objc func toggleEnable(_ sender: NSMenuItem) {
        isEnabled.toggle()
        sender.state = isEnabled ? .on : .off
    }

    @objc func quitApp() {
        NSApplication.shared.terminate(self)
    }

    // MARK: - Event Tap Logic

    func setupScrollingBehavior() {
        // Pass 'self' as refcon pointer so the C callback can access `isEnabled`
        let selfPointer = Unmanaged.passUnretained(self).toOpaque()

        let eventTap = CGEvent.tapCreate(
            tap: .cghidEventTap,
            place: .headInsertEventTap,
            options: .defaultTap,
            eventsOfInterest: CGEventMask(1 << CGEventType.scrollWheel.rawValue),
            callback: { proxy, type, event, refcon in
                guard type == .scrollWheel, let refcon = refcon else {
                    return Unmanaged.passUnretained(event)
                }

                let appDelegate = Unmanaged<AppDelegate>.fromOpaque(refcon).takeUnretainedValue()

                // If feature is disabled via menu bar toggle, pass through unchanged
                guard appDelegate.isEnabled else {
                    return Unmanaged.passUnretained(event)
                }

                let isContinuous = event.getIntegerValueField(.scrollWheelEventIsContinuous) == 1

                // Target discrete mouse scroll wheels (excludes trackpads)
                if !isContinuous {
                    let deltaX = -event.getDoubleValueField(.scrollWheelEventDeltaAxis1)
                    let deltaY = -event.getDoubleValueField(.scrollWheelEventDeltaAxis2)
                    event.setDoubleValueField(.scrollWheelEventDeltaAxis1, value: deltaX)
                    event.setDoubleValueField(.scrollWheelEventDeltaAxis2, value: deltaY)
                }

                return Unmanaged.passUnretained(event)
            },
            userInfo: selfPointer
        )

        if let eventTap = eventTap {
            let runLoopSource = CFMachPortCreateRunLoopSource(kCFAllocatorDefault, eventTap, 0)
            CFRunLoopAddSource(CFRunLoopGetCurrent(), runLoopSource, .commonModes)
            CGEvent.tapEnable(tap: eventTap, enable: true)
        } else {
            print("Failed to create event tap. Ensure Accessibility permissions are granted in System Settings.")
        }
    }
}
