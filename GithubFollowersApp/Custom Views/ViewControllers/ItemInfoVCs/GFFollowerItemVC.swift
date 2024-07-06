import UIKit

//here we are inhereting all the properties of this view controller
class GFFollowerItemVC : GFItemInfoViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureItems()
    }
    
    private func configureItems() {
        itemInfoViewOne.set(itemInfoType: .followers, withCount: user.followers)
        itemInfoViewTwo.set(itemInfoType: .following, withCount: user.following)
        actionButton.set(backgroundColour: .systemGreen, title: "Get Followers")
    }
}

