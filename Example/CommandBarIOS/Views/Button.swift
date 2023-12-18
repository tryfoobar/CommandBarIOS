//
//  Button.swift
//  CommandBarIOS_Example
//
//  Created by Michael Cavallaro on 12/17/23.
//  Copyright © 2023 CocoaPods. All rights reserved.
//

import Foundation
import SwiftUI

struct CustomButton: View {
    var title: String
    var fullWidth: Bool
    let action: () -> Void
    
    init(title: String, fullWidth: Bool, action: @escaping () -> Void) {
        self.title = title
        self.fullWidth = fullWidth
        self.action = action
    }
    
    init(title: String, action: @escaping () -> Void) {
        self.title = title
        self.action = action
        self.fullWidth = true
    }
 
    var body: some View {
        Button(action: self.action) {
            HStack {
                if (fullWidth) {
                    Spacer()
                }
                
                Text(title)
                    .font(.headline)
                    .foregroundColor(Color.white)
                
                if (fullWidth) {
                    Spacer()
                }
            }
            .padding()
        }
        .background(Color.black.opacity(0.8))
        .cornerRadius(10)
     
    }
}

