//
//  LogoView.swift
//  CommandBarIOS_Example
//
//  Created by Michael Cavallaro on 12/17/23.
//  Copyright © 2023 CocoaPods. All rights reserved.
//

import SwiftUI

struct LogoView: View {
    var body: some View {
         Image("Logo") // your app icon's filename
            .resizable()
            .aspectRatio(contentMode: .fill)
            .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
            .frame(width: 100, height: 100)
    }
}

struct LogoView_Previews: PreviewProvider {
    static var previews: some View {
        LogoView()
    }
}
