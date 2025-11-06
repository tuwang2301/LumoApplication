//
//  HookView.swift
//  LumoApplication
//
//  Created by Quang Tu Nguyen on 6/11/2025.
//

import SwiftUI

struct HookView: View {
    @EnvironmentObject var appState: AppState
    
    var body: some View {
        VStack(spacing: 30) {
            Text("Discover your emotions")
                .font(.system(size: 40, weight: .bold))
                .multilineTextAlignment(.center)
                .foregroundColor(.black)
            
            Text("I am ready! →")
                .font(.subheadline)
                .foregroundColor(.black)
        }
        .onTapGesture {
            withAnimation {
                appState.hasSeenHook = true                
            }
        }
    }
}

#Preview {
    HookView()
}
