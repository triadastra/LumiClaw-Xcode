// swift-tools-version: 6.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "LumiAgent",
    platforms: [
        .macOS(.v15),
        .iOS(.v18)
    ],
    products: [
        .executable(
            name: "LumiAgent",
            targets: ["LumiAgent"]
        )
    ],
    dependencies: [],
    targets: [
        .executableTarget(
            name: "LumiAgent",
            dependencies: [],
            path: "Lumi",
            exclude: [
                "Domain/Services/Info.plist.template",
                "Domain/Services/FIXING_BUNDLE_ID_CRASH.md",
                "Domain/Services/MULTI_PLATFORM_STRATEGY.md",
                "Domain/Services/iOS_SUPPORT.md",
                "App/iOS_BUILD_FIXES.md",
                "Presentation/Views/Agent/FIX_iOS_ERRORS.txt",
                "Presentation/Views/Settings/APPLY_FIX_NOW.md",
                "Presentation/Views/Settings/URGENT_FIX_DUPLICATES.md",
                "Assets.xcassets",
            ],
            resources: [
                .copy("Resources/Models")
            ],
            swiftSettings: [
                .swiftLanguageMode(.v5),
                .unsafeFlags(["-parse-as-library"])
            ]
        )
    ]
)
