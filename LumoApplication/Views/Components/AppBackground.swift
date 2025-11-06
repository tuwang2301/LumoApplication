//
//  AppBackground.swift
//  LumoApplication
//
//  Created by Quang Tu Nguyen on 6/11/2025.
//

import SwiftUI

struct AppBackground<Content: View>: View {
    let content: Content
    
    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }
    
    var body: some View {
        ZStack {
            StarBackground() // Background của bạn
            content
        }
    }
}
