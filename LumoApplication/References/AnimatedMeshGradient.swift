import SwiftUI

struct AnimatedMeshGradient: View {
    @State private var selectedColors: Set<Int> = [0, 1, 2, 3]
    
    let availableColors: [(name: String, color: Color)] = [
        ("Purple", .purple),
        ("Indigo", .indigo),
        ("Pink", .pink),
        ("Yellow", .yellow),
        ("Orange", .orange),
        ("Red", .red),
        ("Blue", .blue),
        ("Green", .green),
        ("Cyan", .cyan),
        ("Mint", .mint)
    ]
    
    var activeColorsList: [Color] {
        if selectedColors.isEmpty {
            return [.gray]
        }
        return selectedColors.sorted().map { availableColors[$0].color }
    }
    
    var body: some View {
        VStack(spacing: 40) {
            Spacer()
            
            // Animated Mesh Gradient Ball
            ZStack {
                TimelineView(.animation) { context in
                    let time = context.date.timeIntervalSince1970
                    let offsetX = Float(sin(time)) * 0.1
                    let offsetY = Float(cos(time)) * 0.1
                    
                    Circle()
                        .fill(
                            MeshGradient(
                                width: 4,
                                height: 4,
                                points: [
                                    SIMD2(0.0, 0.0),
                                    SIMD2(0.3, 0.0),
                                    SIMD2(0.7, 0.0),
                                    SIMD2(1.0, 0.0),
                                    SIMD2(0.0, 0.3),
                                    SIMD2(0.2 + offsetX, 0.4 + offsetY),
                                    SIMD2(0.7 + offsetX, 0.2 + offsetY),
                                    SIMD2(1.0, 0.3),
                                    SIMD2(0.0, 0.7),
                                    SIMD2(0.3 + offsetX, 0.8),
                                    SIMD2(0.7 + offsetX, 0.6),
                                    SIMD2(1.0, 0.7),
                                    SIMD2(0.0, 1.0),
                                    SIMD2(0.3, 1.0),
                                    SIMD2(0.7, 1.0),
                                    SIMD2(1.0, 1.0)
                                ],
                                colors: meshColors
                            )
                        )
                        .frame(width: 350, height: 350)
                        .shadow(color: .black.opacity(0.3), radius: 30, x: 0, y: 15)
                }
            }
            
            Spacer()
            
            // Color Selection
            VStack(spacing: 20) {
                Text("Tap to Add/Remove Colors")
                    .font(.headline)
                
                LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 15), count: 5), spacing: 15) {
                    ForEach(0..<availableColors.count, id: \.self) { index in
                        VStack(spacing: 5) {
                            Circle()
                                .fill(availableColors[index].color)
                                .frame(width: 55, height: 55)
                                .overlay(
                                    Circle()
                                        .strokeBorder(.white, lineWidth: selectedColors.contains(index) ? 5 : 0)
                                )
                                .overlay(
                                    Circle()
                                        .strokeBorder(.black.opacity(0.2), lineWidth: 1)
                                )
                                .shadow(radius: 4)
                                .onTapGesture {
                                    withAnimation(.spring()) {
                                        if selectedColors.contains(index) {
                                            selectedColors.remove(index)
                                        } else {
                                            selectedColors.insert(index)
                                        }
                                    }
                                }
                            
                            Text(availableColors[index].name)
                                .font(.caption2)
                                .foregroundColor(.secondary)
                        }
                    }
                }
                .padding(.horizontal)
            }
            
            Spacer()
        }
        .padding()
    }
    
    var meshColors: [Color] {
        let colors = activeColorsList
        let count = colors.count
        
        if count == 0 {
            return Array(repeating: Color.gray, count: 16)
        }
        
        // Distribute selected colors across the 16 mesh points
        var result: [Color] = []
        for i in 0..<16 {
            let colorIndex = i % count
            result.append(colors[colorIndex])
        }
        
        
        return result
    }
}

#Preview {
    AnimatedMeshGradient()
}
