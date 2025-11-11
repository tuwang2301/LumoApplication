//
//  YAxisIndicator.swift
//  LumoApplication
//
//  Displays vertical axis at left showing High Energy ↑↓ Low Energy
//

import SwiftUI

struct YAxisIndicator: View {
    let progress: Double  // 0.0 (High Energy/idx 0) to 1.0 (Low Energy/idx 13)
    
    var body: some View {
        GeometryReader { geo in
            let startY: CGFloat = -20
            let axisHeight = geo.size.height  // Longer axis (was 80)
            let starY = (axisHeight * progress) - 10
            
            ZStack(alignment: .topLeading) {
                // Axis line with arrow on top
                VStack(spacing: 0) {
                    // Arrow head
                    Image(systemName: "arrowtriangle.up.fill")
                        .font(.system(size: 8))
                        .foregroundColor(.white.opacity(0.4))
                    
                    Rectangle()
                        .fill(Color.white.opacity(0.4))
                        .frame(width: 1.5, height: axisHeight - 50)
                }
                .offset(x: 40, y: startY)
                
                // Labels to the left of axis
                VStack(spacing: 0) {
                    HStack(spacing: 4) {
                        Text("High\nEnergy")
                            .font(.system(size: 10, weight: .medium))
                            .foregroundColor(.white.opacity(0.75))
                            .multilineTextAlignment(.trailing)
                            .lineSpacing(1)
                        
                        Spacer()
                    }
                    
                    Spacer()
                    
                    HStack(spacing: 4) {
                        Text("Low\nEnergy")
                            .font(.system(size: 10, weight: .medium))
                            .foregroundColor(.white.opacity(0.75))
                            .multilineTextAlignment(.trailing)
                            .lineSpacing(1)
                        
                        Spacer()
                    }
                }
                .padding(.leading, 5)
                .padding(.bottom, 70)
                .frame(width: 55)
                
                // Star indicator ON the axis line
                Image("star")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 40, height: 40)
                    .shadow(color: .black.opacity(0.5), radius: 3)
                    .position(x: 42, y: starY)
            }
        }
        .frame(width: 80)
    }
}

#Preview {
    ZStack {
        Color.black.ignoresSafeArea()
        HStack {
            YAxisIndicator(progress: 0.5)
            Spacer()
        }
    }
}
