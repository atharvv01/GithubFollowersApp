import UIKit

class GFButton: UIButton {

    //we need to override the init coz we want to do some custom stuff , else we dont need to override it
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    //this is used for storyboard and since we are not using storyboard, we wont write any code in here
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    init(backgroundColour: UIColor, title: String){
        super.init(frame: .zero)
        self.backgroundColor = backgroundColour
        self.setTitle(title, for: .normal)
        configure()
    }
    
    private func configure () {
        layer .cornerRadius = 10
        titleLabel?.textColor = .white
        titleLabel?.font = UIFont.preferredFont(forTextStyle: .headline)
        translatesAutoresizingMaskIntoConstraints = false
    }
    
}
