//
//  XAxisIndicator.swift
//  LumoApplication
//
//  Displays horizontal axis at bottom showing Unpleasant ←→ Pleasant
//

import SwiftUI

struct XAxisIndicator: View {
    let progress: Double  // 0.0 (Unpleasant) to 1.0 (Pleasant)
    
    var body: some View {
        GeometryReader { geo in
            let startX: CGFloat = 43
            let axisWidth = geo.size.width - 60
            let starX = startX + (axisWidth * progress)
            
            ZStack(alignment: .topLeading) {
                // Axis line with arrow on right
                HStack(spacing: 0) {
                    Rectangle()
                        .fill(Color.white.opacity(0.4))
                        .frame(width: axisWidth - 4, height: 1.5)
                    
                    // Arrow head
                    Image(systemName: "arrowtriangle.right.fill")
                        .font(.system(size: 8))
                        .foregroundColor(.white.opacity(0.4))
                }
                .offset(x: startX, y: 43)
                
                // Labels below axis
                HStack {
                    Text("Unpleasant")
                        .font(.system(size: 10, weight: .medium))
                        .foregroundColor(.white.opacity(0.75))
                    
                    Spacer()
                    
                    Text("Pleasant")
                        .font(.system(size: 10, weight: .medium))
                        .foregroundColor(.white.opacity(0.75))
                }
                .padding(.horizontal, 20)
                .padding(.leading, 20)
                .offset(y: 60)
                
                // Star indicator ON the axis line
                Image("star")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 50, height: 50)
                    .shadow(color: .black.opacity(0.5), radius: 3)
                    .position(x: starX, y: 46)
            }
        }
        .frame(height: 60)
    }
}

#Preview {
    ZStack {
        Color.black.ignoresSafeArea()
        VStack {
            Spacer()
            XAxisIndicator(progress: 0.5)
                .padding(.bottom, 40)
        }
    }
}
