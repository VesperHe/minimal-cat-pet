import AppKit

private struct PetConfiguration {
    let resourceNames: [String]
    let windowSize: NSSize
    let horizontalInset: CGFloat
    let animationInterval: TimeInterval?

    static func current() -> PetConfiguration {
        PetConfiguration(
            resourceNames: ["sleep_0", "sleep_1"],
            windowSize: NSSize(width: 170, height: 150),
            horizontalInset: 254,
            animationInterval: 0.8
        )
    }
}

private final class PetWindow: NSWindow {
    override var canBecomeKey: Bool { true }
    override var canBecomeMain: Bool { false }
}

private final class PetView: NSView {
    private let frames: [NSImage]
    private var frameIndex = 0
    private var animationTimer: Timer?
    private var dragStartMouse = NSPoint.zero
    private var dragStartWindow = NSPoint.zero

    init(frame: NSRect, images: [NSImage], animationInterval: TimeInterval?) {
        frames = images
        super.init(frame: frame)
        wantsLayer = true
        layer?.masksToBounds = false

        if let animationInterval, images.count > 1 {
            animationTimer = Timer.scheduledTimer(withTimeInterval: animationInterval, repeats: true) { [weak self] _ in
                guard let self else { return }
                self.frameIndex = (self.frameIndex + 1) % self.frames.count
                self.needsDisplay = true
            }
        }
    }

    required init?(coder: NSCoder) { nil }

    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
        NSGraphicsContext.current?.imageInterpolation = .none
        frames[frameIndex].draw(in: bounds, from: .zero, operation: .sourceOver, fraction: 1)
    }

    override func acceptsFirstMouse(for event: NSEvent?) -> Bool { true }

    override func mouseDown(with event: NSEvent) {
        dragStartMouse = NSEvent.mouseLocation
        dragStartWindow = window?.frame.origin ?? .zero
    }

    override func mouseDragged(with event: NSEvent) {
        guard let window else { return }
        let current = NSEvent.mouseLocation
        let origin = NSPoint(
            x: dragStartWindow.x + current.x - dragStartMouse.x,
            y: dragStartWindow.y + current.y - dragStartMouse.y
        )
        window.setFrameOrigin(origin)
    }

    override func mouseUp(with event: NSEvent) {
        guard let origin = window?.frame.origin else { return }
        UserDefaults.standard.set(origin.x, forKey: "petPositionX")
        UserDefaults.standard.set(origin.y, forKey: "petPositionY")
    }

    override func rightMouseDown(with event: NSEvent) {
        NSMenu.popUpContextMenu(closeMenu(), with: event, for: self)
    }

    override func menu(for event: NSEvent) -> NSMenu? {
        closeMenu()
    }

    private func closeMenu() -> NSMenu {
        let menu = NSMenu()
        menu.autoenablesItems = false
        let item = NSMenuItem(title: "关闭这只猫咪", action: #selector(closePet), keyEquivalent: "")
        item.target = self
        item.attributedTitle = NSAttributedString(
            string: "✕  关闭这只猫咪",
            attributes: [
                .font: NSFont.monospacedSystemFont(ofSize: 14, weight: .bold),
                .foregroundColor: NSColor(calibratedRed: 0.86, green: 0.20, blue: 0.16, alpha: 1)
            ]
        )
        menu.addItem(item)
        return menu
    }

    @objc private func closePet() {
        NSApplication.shared.terminate(nil)
    }
}

private final class AppDelegate: NSObject, NSApplicationDelegate {
    private var petWindow: PetWindow?

    func applicationDidFinishLaunching(_ notification: Notification) {
        NSApp.setActivationPolicy(.accessory)
        createPetWindow()
    }

    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool { true }

    private func clampedOrigin(_ proposedOrigin: NSPoint, windowSize: NSSize) -> NSPoint {
        let proposedFrame = NSRect(origin: proposedOrigin, size: windowSize)
        let visibleFrame = NSScreen.screens.first(where: { $0.visibleFrame.intersects(proposedFrame) })?.visibleFrame
            ?? NSScreen.main?.visibleFrame
            ?? NSRect(x: 0, y: 0, width: 1440, height: 900)

        return NSPoint(
            x: min(max(proposedOrigin.x, visibleFrame.minX), visibleFrame.maxX - windowSize.width),
            y: min(max(proposedOrigin.y, visibleFrame.minY), visibleFrame.maxY - windowSize.height)
        )
    }

    private func createPetWindow() {
        let configuration = PetConfiguration.current()
        let images = configuration.resourceNames.compactMap { name -> NSImage? in
            guard let url = Bundle.main.url(forResource: name, withExtension: "png") else { return nil }
            return NSImage(contentsOf: url)
        }
        guard !images.isEmpty else {
            NSApp.terminate(nil)
            return
        }

        let screenFrame = NSScreen.main?.visibleFrame ?? NSRect(x: 0, y: 0, width: 1440, height: 900)
        let defaults = UserDefaults.standard
        let hasSavedPosition = defaults.object(forKey: "petPositionX") != nil && defaults.object(forKey: "petPositionY") != nil
        let proposedOrigin = hasSavedPosition
            ? NSPoint(x: defaults.double(forKey: "petPositionX"), y: defaults.double(forKey: "petPositionY"))
            : NSPoint(
                x: screenFrame.maxX - configuration.windowSize.width - configuration.horizontalInset,
                y: screenFrame.minY + 24
            )
        let origin = clampedOrigin(proposedOrigin, windowSize: configuration.windowSize)

        let frame = NSRect(origin: origin, size: configuration.windowSize)
        let window = PetWindow(contentRect: frame, styleMask: [.borderless], backing: .buffered, defer: false)
        window.isOpaque = false
        window.backgroundColor = .clear
        window.hasShadow = false
        window.level = .floating
        window.ignoresMouseEvents = false
        window.isMovableByWindowBackground = false
        window.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]
        window.contentView = PetView(
            frame: NSRect(origin: .zero, size: configuration.windowSize),
            images: images,
            animationInterval: configuration.animationInterval
        )
        window.orderFrontRegardless()
        petWindow = window
    }
}

private let application = NSApplication.shared
private let appDelegate = AppDelegate()
application.delegate = appDelegate
application.run()
