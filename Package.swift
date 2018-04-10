// swift-tools-version:4.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "D4LocalAuth",
    products: [
        // Products define the executables and libraries produced by a package, and make them visible to other packages.
        .library(
            name: "D4LocalAuth",
            targets: ["D4LocalAuth"]),
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        // .package(url: /* package url */, from: "1.0.0"),
        .package(url: "https://github.com/PerfectlySoft/Perfect-HTTPServer.git",.upToNextMajor(from: "3.0.0")),
        .package(url: "https://github.com/PerfectlySoft/Perfect-RequestLogger.git",.upToNextMajor(from: "3.0.0")),
        .package(url: "https://github.com/PerfectlySoft/Perfect-SMTP.git",.upToNextMajor(from: "3.0.0")),
        .package(url: "https://github.com/SwiftORM/MySQL-StORM.git",.upToNextMajor(from: "3.0.0")),
        .package(url: "https://github.com/PerfectlySoft/Perfect-Session-MySQL.git",.upToNextMajor(from: "3.0.0")),
        .package(url: "https://github.com/PerfectlySoft/Perfect-Mustache.git",.upToNextMajor(from: "3.0.0")),
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages which this package depends on.
        .target(
            name: "D4LocalAuth",
            dependencies: ["PerfectMustache","PerfectSessionMySQL","MySQLStORM",
                           "PerfectSMTP","PerfectRequestLogger","PerfectHTTPServer"]),
        .testTarget(
            name: "D4LocalAuthTests",
            dependencies: ["D4LocalAuth"]),
    ]
)
