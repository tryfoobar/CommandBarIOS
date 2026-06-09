//
//  HomeView.swift
//  CommandBarIOS_Example
//

import SwiftUI

// 1. Import CommandBar IOS SDK
import CommandBarIOS



struct HomeView: View {
    @State private var showingAlert = false
    @State private var showingKeyAlert = false

    /// Amplitude **Guides & Surveys** API key for your project (same key as the web snippet).
    /// The placeholder below will not load — replace it or paste into Xcode for local testing.
    private let amplitudeApiKey = ""

    func onFallbackAction(withType type: String) {
        CommandBarSDK.shared.closeResourceCenter()
        self.showingAlert = true
    }

    var body: some View {
        VStack(alignment: .center) {
            ZStack {
                GradientView()
                VStack {
                    Spacer()
                    VStack {
                        LogoView()
                        Text("Welcome to Amplitude!")
                            .multilineTextAlignment(.center)
                            .font(.title)
                    }
                    Spacer()
                    VStack() {
                            CustomButton(title: "Open Resource Center") {
                                // 4. Open Resource Center
                                CommandBarSDK.shared.openResourceCenter(articleId: nil, fallbackAction: onFallbackAction)
                            }.alert(isPresented: $showingAlert) {
                                Alert(title: Text("Assistant Fallback Triggered"), message: Text("You can use this to trigger opening up a third party chat provider or handle custom behavior when assistant can't find an answer or when the user triggers a fallback action!"), dismissButton: .default(Text("Got it!")))
                            }
                            CustomButton(title: "Open Assistant") {
                                // 4. Open Assistant
                                CommandBarSDK.shared.openAssistant(fallbackAction: onFallbackAction)
                            }.alert(isPresented: $showingKeyAlert) {
                                Alert(title: Text("Assistant Fallback Triggered"), message: Text("You can use this to trigger opening up a third party chat provider or handle custom behavior when assistant can't find an answer or when the user triggers a fallback action!"), dismissButton: .default(Text("Got it!")))
                            }

                    }
                }.padding(.horizontal)

                if amplitudeApiKey == "" {
                    VStack(alignment: .leading) {
                        Toast(message: "Set amplitudeApiKey in HomeView.swift (Amplitude API key).")
                        Spacer()
                    }
                }

            }
        }
        .onAppear {
            if (amplitudeApiKey != "") {
                // 2. Boot CommandBar by using the shared instance
                CommandBarSDK.shared.boot(options: CommandBarOptions(
                    apiKey: amplitudeApiKey,
                    userId: UUID().uuidString
                ))
            }
        }
    }
}
