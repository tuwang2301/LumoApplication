import SwiftUI

struct BubbleFrame:View {
    let size: CGFloat

    var body: some View {
        ZStack{
            Image("BubbleFrame")
                .resizable()
                .frame(width: size, height:size)
        }
    }
}

#Preview {
    ZStack{
        StarBackground()
        BubbleFrame(size: 500)
    }
}
