import Foundation
import PackagePlugin

@main
struct SwiftLintPlugin: CommandPlugin {
    func performCommand(context: PluginContext, arguments: [String]) throws {
        if arguments.contains("--verbose") {
            print("Command plugin execution with arguments \(arguments.description) for Swift package \(context.package.displayName). All target information: \(context.package.targets.description)")
        }

        var targetsToProcess: [Target] = context.package.targets

        var argExtractor = ArgumentExtractor(arguments)
        let selectedTargets = argExtractor.extractOption(named: "target")
        if !selectedTargets.isEmpty {
            targetsToProcess = context.package.targets.filter { selectedTargets.contains($0.name) }.map { $0 }
        }

        for target in targetsToProcess.compactMap({ $0 as? SourceModuleTarget }) {
            try lintCode(in: target.directory, context: context, arguments: argExtractor.remainingArguments)
        }
    }

    func lintCode(in directory: PackagePlugin.Path, context: PluginContext, arguments: [String]) throws {
        let tool = try context.tool(named: "swiftlint")
        let toolURL = URL(fileURLWithPath: tool.path.string)

        var processArguments = [directory.string]
        processArguments.append(contentsOf: arguments)

        let process = Process()
        process.executableURL = toolURL
        process.arguments = processArguments
        process.environment = env(context: context)

        try process.run()
        process.waitUntilExit()

        if process.terminationReason == .exit, process.terminationStatus == 0 {
            print("Linted the source code in \(directory.string).")
        } else {
            let problem = "\(process.terminationReason):\(process.terminationStatus)"
            Diagnostics.error("swiftlint invocation failed: \(problem)")
        }
    }

    private func env(context: PluginContext, target: SourceModuleTarget? = nil) -> [String: String] {
        [
            "PROJECT_DIR": context.package.directory.string,
            "TARGET_NAME": target?.name ?? "",
            "PRODUCT_MODULE_NAME": target?.moduleName ?? ""
        ]
    }
}
