import UIKit

class GFSecondaryTitleLabel: UILabel {

    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    init (fontSize:CGFloat){
        super.init(frame: .zero)
        font = UIFont.systemFont(ofSize: fontSize, weight: .medium)
        configure()
    }
    
    private func configure(){
        textColor = .secondaryLabel
        //what this does is if title label is very long it shrinks to fit it in one line
        adjustsFontSizeToFitWidth = true
        //this defines the maximum shrinkage we want to happen
        minimumScaleFactor = 0.9
        //if username or title is too long it breaks it from the end
        lineBreakMode = .byTruncatingTail
        translatesAutoresizingMaskIntoConstraints = false
    }

}
