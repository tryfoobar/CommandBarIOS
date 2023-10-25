import UIKit
import CommandBarIOS

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Setting up the title label
        let titleLabel = UILabel()
        titleLabel.text = "Welcome!"
        titleLabel.textAlignment = .center
        titleLabel.font = UIFont.boldSystemFont(ofSize: 48) // Increase the font size to 30
        titleLabel.numberOfLines = 0 // Allow multiple lines
        titleLabel.lineBreakMode = .byWordWrapping // Wrap within the screen width
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(titleLabel)
        
        // Adding constraints for the title label
        titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        titleLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        titleLabel.leadingAnchor.constraint(greaterThanOrEqualTo: view.leadingAnchor, constant: 20).isActive = true
        titleLabel.trailingAnchor.constraint(lessThanOrEqualTo: view.trailingAnchor, constant: -20).isActive = true
        
        // Setting up the button
        let helpButton = UIButton(type: .system)
        helpButton.setTitle("Open HelpHub", for: .normal)
        helpButton.addTarget(self, action: #selector(openHelpHub), for: .touchUpInside)
        helpButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(helpButton)
        
        // Adding constraints for the button
        helpButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        helpButton.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 20).isActive = true
    }
    
    @objc func openHelpHub() {
        CommandBar.openHelpHub()
    }
}
