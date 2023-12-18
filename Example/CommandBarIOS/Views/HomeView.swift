//
//  HomeView.swift
//  CommandBarIOS_Example
//

import SwiftUI

// 1. Import CommandBar IOS SDK
import CommandBarIOS

struct HomeView: View {
    var ORG_ID = ""
    
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
                        CustomButton(title: "Trigger Test Event") {
                            // 3. Track Events
                            CommandBarSDK.shared.trackEvent(event: "test_event")
                        }
                    }
                }.padding(.horizontal)

                if ORG_ID == "" {
                    VStack(alignment: .leading) {
                        Toast(message: "Org ID not set.")
                        Spacer()
                    }
                }
        
            }
        }
        .onAppear {
            if (ORG_ID != "") {
                // 2. Boot CommandBar by using the shared instance
                CommandBarSDK.shared.boot(ORG_ID, with: CommandBarOptions(user_id: UUID().uuidString ))
            }
        }
    }
}
