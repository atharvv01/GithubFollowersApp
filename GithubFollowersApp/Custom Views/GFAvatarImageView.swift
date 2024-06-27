import UIKit

class GFAvatarImageView: UIImageView {

    //we will force unwrap here since we know image already exists in ur bundle
    let placeholderImage = UIImage(named: "avatar-placeholder")!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configure()
    {
        layer.cornerRadius = 10
        //this makes sure the image is bounded to the round edges of ui view 
        clipsToBounds = true
        image = placeholderImage
        translatesAutoresizingMaskIntoConstraints = false
    }
    
}
