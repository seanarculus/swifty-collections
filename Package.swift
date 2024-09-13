// swift-tools-version:5.5
//===----------------------------------------------------------------------===//
//
// This source file is part of the Swift Collections open source project
//
// Copyright (c) 2021 Apple Inc. and the Swift project authors
// Licensed under Apache License v2.0 with Runtime Library Exception
//
// See https://swift.org/LICENSE.txt for license information
//
//===----------------------------------------------------------------------===//

import PackageDescription

// This package recognizes the conditional compilation flags listed below.
// To use enable them, uncomment the corresponding lines or define them
// from the package manager command line:
//
//     swift build -Xswiftc -DCOLLECTIONS_INTERNAL_CHECKS
var settings: [SwiftSetting] = [

  // Enables internal consistency checks at the end of initializers and
  // mutating operations. This can have very significant overhead, so enabling
  // this setting invalidates all documented performance guarantees.
  //
  // This is mostly useful while debugging an issue with the implementation of
  // the hash table itself. This setting should never be enabled in production
  // code.
//  .define("COLLECTIONS_INTERNAL_CHECKS"),

  // Hashing collections provided by this package usually seed their hash
  // function with the address of the memory location of their storage,
  // to prevent some common hash table merge/copy operations from regressing to
  // quadratic behavior. This setting turns off this mechanism, seeding
  // the hash function with the table's size instead.
  //
  // When used in conjunction with the SWIFT_DETERMINISTIC_HASHING environment
  // variable, this enables reproducible hashing behavior.
  //
  // This is mostly useful while debugging an issue with the implementation of
  // the hash table itself. This setting should never be enabled in production
  // code.
//  .define("COLLECTIONS_DETERMINISTIC_HASHING"),

]

let package = Package(
  name: "swifty-collections",
  products: [
    .library(name: "Collections", targets: ["Collections"]),
    .library(name: "BitCollections", targets: ["BitCollections"]),
    .library(name: "DequeModule", targets: ["DequeModule"]),
    .library(name: "HeapModule", targets: ["HeapModule"]),
    .library(name: "OrderedCollections", targets: ["OrderedCollections"]),
    .library(name: "HashTreeCollections", targets: ["HashTreeCollections"]),
    .library(name: "SortedCollections", targets: ["SortedCollections"]),
  ],
  targets: [
    .target(
      name: "Collections",
      dependencies: [
        "BitCollections",
        "DequeModule",
        "HeapModule",
        "OrderedCollections",
        "HashTreeCollections",
        "SortedCollections",
      ],
      exclude: ["CMakeLists.txt"],
      swiftSettings: settings),

    // Testing support module
    .target(
      name: "_CollectionsTestSupport",
      dependencies: ["_CollectionsUtilities"],
      swiftSettings: settings,
      linkerSettings: [
        .linkedFramework(
          "XCTest",
          .when(platforms: [.macOS, .iOS, .watchOS, .tvOS])),
      ]
    ),
    .testTarget(
      name: "CollectionsTestSupportTests",
      dependencies: ["_CollectionsTestSupport"],
      swiftSettings: settings),

    .target(
      name: "_CollectionsUtilities",
      exclude: ["CMakeLists.txt"],
      swiftSettings: settings),

    // BitSet, BitArray
    .target(
      name: "BitCollections",
      dependencies: ["_CollectionsUtilities"],
      exclude: ["CMakeLists.txt"],
      swiftSettings: settings),
    .testTarget(
      name: "BitCollectionsTests",
      dependencies: [
        "BitCollections", "_CollectionsTestSupport", "OrderedCollections"
      ],
      swiftSettings: settings),

    // Deque<Element>
    .target(
      name: "DequeModule",
      dependencies: ["_CollectionsUtilities"],
      exclude: ["CMakeLists.txt"],
      swiftSettings: settings),
    .testTarget(
      name: "DequeTests",
      dependencies: ["DequeModule", "_CollectionsTestSupport"],
      swiftSettings: settings),

    // Heap<Value>
    .target(
      name: "HeapModule",
      dependencies: ["_CollectionsUtilities"],
      exclude: ["CMakeLists.txt"],
      swiftSettings: settings),
    .testTarget(
      name: "HeapTests",
      dependencies: ["HeapModule", "_CollectionsTestSupport"],
      swiftSettings: settings),

    // OrderedSet<Element>, OrderedDictionary<Key, Value>
    .target(
      name: "OrderedCollections",
      dependencies: ["_CollectionsUtilities"],
      exclude: ["CMakeLists.txt"],
      swiftSettings: settings),
    .testTarget(
      name: "OrderedCollectionsTests",
      dependencies: ["OrderedCollections", "_CollectionsTestSupport"],
      swiftSettings: settings),

    // TreeSet<Element>, TreeDictionary<Key, Value>
    .target(
      name: "HashTreeCollections",
      dependencies: ["_CollectionsUtilities"],
      exclude: ["CMakeLists.txt"],
      swiftSettings: settings),
    .testTarget(
      name: "HashTreeCollectionsTests",
      dependencies: ["HashTreeCollections", "_CollectionsTestSupport"],
      swiftSettings: settings),

    // SortedSet<Element>, SortedDictionary<Key, Value>
    .target(
      name: "SortedCollections",
      dependencies: ["_CollectionsUtilities"],
      swiftSettings: settings),
    .testTarget(
      name: "SortedCollectionsTests",
      dependencies: ["SortedCollections", "_CollectionsTestSupport"],
      swiftSettings: settings),
  ]
)
