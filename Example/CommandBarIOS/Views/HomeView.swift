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
    private let amplitudeApiKey = "6dba5c25868be3716e69f525035e33b6"

    func onFallbackAction(withType type: String) {
        CommandBarSDK.shared.closeHelpHub()
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
                            .shadow(color: Color.black.opacity(0.3), radius: 10, x: 0, y: 5)
                        Text("Welcome to CommandBar!")
                            .multilineTextAlignment(.center)
                            .font(.title)
                    }
                    Spacer()
                    VStack() {
                        CustomButton(title: "Open HelpHub") {
                            // 4. Open HelpHub
                            CommandBarSDK.shared.openHelpHub(articleId: nil, withFallbackAction: onFallbackAction)
                        }.alert(isPresented: $showingAlert) {
                            Alert(title: Text("Copilot Fallback Triggered"), message: Text("You can use this to trigger opening up a third party chat provider or handle custom behavior when copilot can't find an answer or when the user triggers a fallback action!"), dismissButton: .default(Text("Got it!")))
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
                CommandBarSDK.shared.boot(amplitudeApiKey, with: CommandBarOptions(user_id: UUID().uuidString ))
            }
        }
    }
}
