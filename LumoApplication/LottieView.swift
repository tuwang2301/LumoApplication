import SwiftUI
import Lottie

struct LottieView: UIViewRepresentable {
    
    // The name of your Lottie JSON file (e.g., "lumoLogo")
    var name: String
    
    // The loop mode for the animation
    var loopMode: LottieLoopMode = .playOnce
    
    // This is the animation view from the Lottie package
    var animationView = LottieAnimationView()

    func makeUIView(context: UIViewRepresentableContext<LottieView>) -> UIView {
        let view = UIView(frame: .zero)
        
        // 1. Load the animation
        animationView.animation = LottieAnimation.named(name)
        
        // 2. Set properties
        animationView.contentMode = .scaleAspectFit
        animationView.loopMode = loopMode
        
        // 3. Set background behavior
        // This makes it play even when the view updates
        animationView.backgroundBehavior = .pauseAndRestore
        
        // 4. Play the animation
        animationView.play()

        // 5. Add constraints
        animationView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(animationView)
        
        NSLayoutConstraint.activate([
            animationView.heightAnchor.constraint(equalTo: view.heightAnchor),
            animationView.widthAnchor.constraint(equalTo: view.widthAnchor)
        ])

        return view
    }

    func updateUIView(_ uiView: UIView, context: UIViewRepresentableContext<LottieView>) {
        // This function is required, but we don't need to put
        // anything here for this use case.
    }
}
