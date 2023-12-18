import Foundation

import CommandBarIOS
import SwiftUI

@available(iOS 14.0, *)
struct CommandBarIOSExampleApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    var body: some Scene {
        WindowGroup {
            HomeView()
        }
        
    }
    
}

@main
struct CommandBarIOSExampleAppWrapper {
    static func main() {
        if #available(iOS 14.0, *) {
            CommandBarIOSExampleApp.main()
        } else {
            let argv = UnsafeMutableRawPointer(CommandLine.unsafeArgv).bindMemory(to: UnsafeMutablePointer<Int8>.self, capacity: Int(CommandLine.argc))
            UIApplicationMain(CommandLine.argc, argv, nil, NSStringFromClass(SceneDelegate.self))
        }
    }
}
