import Foundation
import PackagePlugin

@main
struct SwiftLintPlugin: BuildToolPlugin {
    func createBuildCommands(context: PluginContext, target: Target) throws -> [Command] {
        let directory = context.pluginWorkDirectory
        // Clear the SwiftLint plugin's directory
        // try? FileManager.default.removeItem(atPath: directory.string)
        // try? FileManager.default.createDirectory(atPath: directory.string, withIntermediateDirectories: false)

        return [.buildCommand(
            displayName: "SwiftLint",
            executable: try context.tool(named: "swiftlint").path,
            arguments: [
                "--cache-path", "\(directory)"
            ]
        )]
    }
}

#if canImport(XcodeProjectPlugin)
import XcodeProjectPlugin

extension SwiftLintPlugin: XcodeBuildToolPlugin {
    func createBuildCommands(context: XcodePluginContext, target: XcodeTarget) throws -> [Command] {
        let directory = context.pluginWorkDirectory
        // Clear the SwiftLint plugin's directory
        // try? FileManager.default.removeItem(atPath: directory.string)
        // try? FileManager.default.createDirectory(atPath: directory.string, withIntermediateDirectories: false)

        return [.buildCommand(
            displayName: "SwiftLint",
            executable: try context.tool(named: "swiftlint").path,
            arguments: [
                "--cache-path", "\(directory)"
            ]
        )]
    }
}
#endif
