import CoreGraphics
import Foundation

// Query window metadata only; no screenshots or Accessibility permission needed.
guard CommandLine.arguments.count == 2,
      let pid = Int32(CommandLine.arguments[1]) else {
    fputs("Usage: check-macos-window PID\n", stderr)
    exit(2)
}

guard let windows = CGWindowListCopyWindowInfo(
    [.optionOnScreenOnly, .excludeDesktopElements], kCGNullWindowID
) as? [[String: Any]] else {
    fputs("Cannot query the macOS window list\n", stderr)
    exit(2)
}

let visibleWindows = windows.filter { window in
    guard let owner = window[kCGWindowOwnerPID as String] as? NSNumber,
          let layer = window[kCGWindowLayer as String] as? NSNumber,
          let bounds = window[kCGWindowBounds as String] as? [String: Any],
          let width = bounds["Width"] as? NSNumber,
          let height = bounds["Height"] as? NSNumber else {
        return false
    }
    return owner.int32Value == pid && layer.intValue == 0
        && width.doubleValue > 0 && height.doubleValue > 0
}

guard !visibleWindows.isEmpty else {
    fputs("No visible normal window for process \(pid)\n", stderr)
    exit(1)
}
print("Found \(visibleWindows.count) visible application window(s) for process \(pid)")
