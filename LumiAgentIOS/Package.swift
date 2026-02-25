// swift-tools-version: 5.9
//
//  Package.swift — LumiAgentIOS
//
//  iOS 17+ companion app for LumiAgent.
//  Open this package in Xcode 15+ to build and run on iPhone/iPad simulator or device.
//
//  Capabilities delivered:
//   • System environment control  – brightness, volume, media playback, weather
//   • Messages & SMS              – compose and send via system sheet
//   • Mac Remote Control          – discover and command nearby macOS LumiAgent instances
//                                   over a local Bonjour TCP connection
//
//  Required Info.plist keys (add in Xcode target settings → Info):
//   NSLocationWhenInUseUsageDescription  – weather current-location lookup
//   NSSiriUsageDescription               – optional Siri Shortcuts integration
//
//  The macOS side requires LumiAgent/Infrastructure/Network/MacRemoteServer.swift
//  (included in this repo) to be running for remote control to work.

import PackageDescription

let package = Package(
    name: "LumiAgentIOS",
    platforms: [
        .iOS(.v17)
    ],
    products: [
        .library(
            name: "LumiAgentIOS",
            targets: ["LumiAgentIOS"]
        )
    ],
    dependencies: [],
    targets: [
        .target(
            name: "LumiAgentIOS",
            dependencies: [],
            path: "Sources/LumiAgentIOS",
            resources: [
                .process("Resources")
            ]
        )
    ]
)
