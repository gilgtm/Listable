// swift-tools-version:5.3

import PackageDescription

let package = Package(
    name: "Listable",
    defaultLocalization: "en",
    platforms: [
        .iOS(.v12),
    ],
    products: [
        .library(
            name: "ListableUI",
            targets: ["ListableUI"]
        ),
        .library(
            name: "BlueprintUILists",
            targets: ["BlueprintUILists"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/square/Blueprint", from: "0.19.0"),
    ],
    targets: [
        .target(
            name: "ListableUI",
            path: "ListableUI/Sources",
            exclude: [
                "Internal/KeyboardObserver/SetupKeyboardObserverOnAppStartup.m",
                "Layout/Paged/PagedAppearance.monopic",
                "ContentBounds/ListContentBounds.monopic",
                "Layout/Table/TableAppearance.monopic",
            ]
        ),
        .target(
            name: "EnglishDictionary",
            path: "Internal Pods/EnglishDictionary",
            exclude: ["EnglishDictionary.podspec"],
            resources: [
                .process("Resources"),
            ]
        ),
        .target(
            name: "Snapshot",
            path: "Internal Pods/Snapshot/Sources"
        ),
        .testTarget(
            name: "SnapshotTests",
            dependencies: ["Snapshot"],
            path: "Internal Pods/Snapshot/Tests",
            exclude: ["Snapshot Results"]
        ),
        .testTarget(
            name: "ListableUITests",
            dependencies: ["ListableUI", "EnglishDictionary", "Snapshot"],
            path: "ListableUI/Tests",
            exclude: [
                "Layout/Paged/Snapshot Results",
                "Layout/Retail Grid/Snapshot Results",
                "Layout/Table/Snapshot Results",
                "Previews/Snapshot Results",
            ],
            resources: [
                .process("Resources"),
            ]
        ),
        .target(
            name: "BlueprintUILists",
            dependencies: [
                "ListableUI",
                .product(name: "BlueprintUI", package: "Blueprint")
            ],
            path: "BlueprintUILists/Sources"
        ),
        .testTarget(
            name: "BlueprintUIListsTests",
            dependencies: ["BlueprintUILists"],
            path: "BlueprintUILists/Tests"
        ),
    ],
    swiftLanguageVersions: [.v5]
)
