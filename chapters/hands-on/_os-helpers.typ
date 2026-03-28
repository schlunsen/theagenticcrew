// OS-specific helpers for the Hands-On Guide
// Usage: #import "_os-helpers.typ": target-os, is-windows, is-mac, is-linux
//
// Compile with: typst compile --input os=windows ...
//               typst compile --input os=mac ...
//               typst compile --input os=linux ...

#let target-os = sys.inputs.at("os", default: "windows")

#let is-windows = target-os == "windows"
#let is-mac     = target-os == "mac"
#let is-linux   = target-os == "linux"

// Human-readable OS name for prose
#let os-name = if is-windows { "Windows" } else if is-mac { "macOS" } else { "Linux" }
