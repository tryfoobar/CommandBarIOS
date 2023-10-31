import UIKit
import CommandBarIOS

class ViewController: UIViewController {
    
    var commandbar = CommandBar(options: CommandBarOptions(["orgId": "641ade4d", "launchCode": "preview_4686" ]))
    
    // TODO: Remove after demoing
    var button: UIButton? = nil

    override func viewDidLoad() {
        super.viewDidLoad()
        // Create a UIImageView and set its frame to match the size of the view
        let imageView = UIImageView(frame: view.bounds)
        // Set the image to be displayed
        let backgroundImage = UIImage(named: "Background")
        imageView.image = backgroundImage
        // Set the content mode to scale the image to fit the view
        imageView.contentMode = .scaleAspectFill
        // Add the UIImageView as a subview of the view
        view.addSubview(imageView)
        // Send the UIImageView to the back so that other content appears on top
        view.sendSubview(toBack: imageView)
        
        // Setting up the title label
//        let titleLabel = UILabel()
//        titleLabel.text = "Welcome!"
//        titleLabel.textAlignment = .center
//        titleLabel.font = UIFont.boldSystemFont(ofSize: 48) // Increase the font size to 30
//        titleLabel.numberOfLines = 0  Allow multiple lines
//        titleLabel.lineBreakMode = .byWordWrapping // Wrap within the screen width
//        titleLabel.translatesAutoresizingMaskIntoConstraints = false
//        view.addSubview(titleLabel)
        
        // Adding constraints for the title label
//        titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
//        titleLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
//        titleLabel.leadingAnchor.constraint(greaterThanOrEqualTo: view.leadingAnchor, constant: 20).isActive = true
//        titleLabel.trailingAnchor.constraint(lessThanOrEqualTo: view.trailingAnchor, constant: -20).isActive = true
        
        // Setting up the button
//        let helpButton = UIButton(type: .system)
//        helpButton.setTitle("Open HelpHub", for: .normal)
//        helpButton.addTarget(self, action: #selector(openHelpHub), for: .touchUpInside)
//        helpButton.translatesAutoresizingMaskIntoConstraints = false
//        view.addSubview(helpButton)
//      
        // TODO: Remove after demoing
        button = UIButton(type: .custom)
        button!.frame = CGRect(x: 297, y: 756, width: 90, height: 48)
        
        // Customize the button appearance
        button!.backgroundColor = UIColor.clear
        button!.layer.cornerRadius = 4
        button!.layer.borderWidth = 0
        button!.backgroundColor = UIColor.clear
        button!.setTitleColor(UIColor.black, for: .normal)

        button!.addTarget(self, action: #selector(buttonTapped), for: .touchDown)
        button!.addTarget(self, action: #selector(buttonReleased), for: .touchUpOutside)
        button!.addTarget(self, action: #selector(openHelpHub), for: .touchUpInside)
        view.addSubview(button!)
    }
    
    @objc func openHelpHub() {
        self.button?.backgroundColor = UIColor.clear
        commandbar.delegate = self
        commandbar.openHelpHub()
    }
    
    // TODO: Remove after demoing
    @objc func buttonTapped() {
        if #available(iOS 13.0, *) {
            let color = UIColor(
                red: CGFloat(0x36) / 255.0,
                green: CGFloat(0x62) / 255.0,
                blue: CGFloat(0xF1) / 255.0,
                alpha: 0.2
            )

            self.button?.backgroundColor = color
        } else {}
    }
    
    @objc func buttonReleased() {
        self.button?.backgroundColor = UIColor.clear
    }
    
}

extension ViewController : HelpHubWebViewDelegate {
    func didReceiveFallbackAction(_ action: [String : Any]) {
        commandbar.closeHelpHub()
        let alertController = UIAlertController(title: "Fallback Received", message: "An fallback action was triggered in HelpHubWebView.", preferredStyle: .alert)
        let okayAction = UIAlertAction(title: "Okay", style: .default, handler: nil)
        alertController.addAction(okayAction)
        UIApplication.shared.keyWindow?.rootViewController?.present(alertController, animated: true)
    }
}
