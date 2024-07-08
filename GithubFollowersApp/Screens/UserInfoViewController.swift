import UIKit

protocol UserInfoVCDelegate: AnyObject {
    //passing user through functions so we have access to user
    func didTapGitHubProfile(for user : User)
    func didTapGetFollowers(for user : User)
}

class UserInfoViewController: UIViewController {

    let headerView = UIView()
    let itemViewOne = UIView()
    let itemViewTwo = UIView()
    let dateLabel = GFBodyLabel(textAlignment: .center)
    var itemViews: [UIView] = []
    
    var username : String!
    weak var delegate: FollowersListVCDelegate!
    
    override func viewDidLoad() {
        super.viewDidLoad()
       
        configureViewController()
        
        getUserInfo()
        
        layoutUI()
    }
    
    func configureViewController(){
        view.backgroundColor = .systemBackground
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(dismissVC))
        navigationItem.rightBarButtonItem = doneButton
    }
    
    //api call
    func getUserInfo(){
        NetworkManager.shared.getUsers(for: username) { [weak self] result in
            
            guard let self = self else {
                return
            }
            switch result {
            case.success(let user):
                DispatchQueue.main.async {
                    self.configureUIElements(with: user)
                }
            case .failure(let error):
                self.presentGFAlertOnMainThread(title: "Something went wrong", message: error.rawValue, buttonTitle: "OK")
            }
        }
    }
    
    func add(childVC: UIViewController , to containerView: UIView)
    {
        addChild(childVC)
        containerView.addSubview(childVC.view)
        childVC.view.frame = containerView.bounds
        childVC.didMove(toParent: self)
    }
    
    func configureUIElements(with user: User) {
        
        let repoItemVC = GFRepoItemVC(user: user)
        //setting the delegate
        repoItemVC.delegate = self
        
        let followersItemVC = GFFollowerItemVC(user: user)
        followersItemVC.delegate = self
        
        self.add(childVC: GFUserInfoHeaderViewController(user: user), to: self.headerView)
        self.add(childVC: repoItemVC, to: self.itemViewOne)
        self.add(childVC: followersItemVC, to: self.itemViewTwo)
        self.dateLabel.text = "Github since \(user.createdAt.convertToDisplayFormat())"
    }
    
    func layoutUI(){
        
        let padding: CGFloat = 20
        let itemHeight: CGFloat = 140
        
        itemViews = [headerView,itemViewOne,itemViewTwo, dateLabel]
        
        
//        instead of this we will use for loop to add all subviews
        
//        view.addSubview(headerView)
//        view.addSubview(itemViewOne)
//        view.addSubview(itemViewTwo)
        
//        headerView.translatesAutoresizingMaskIntoConstraints = false
//        itemViewOne.translatesAutoresizingMaskIntoConstraints = false
//        itemViewTwo.translatesAutoresizingMaskIntoConstraints = false
        
        for itemView in itemViews {
            view.addSubview(itemView)
            itemView.translatesAutoresizingMaskIntoConstraints = false
            
            NSLayoutConstraint.activate([
                itemView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: padding),
                itemView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -padding),
            ])
        }
        
        NSLayoutConstraint.activate([
            headerView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            headerView.heightAnchor.constraint(equalToConstant: 180),
            
            itemViewOne.topAnchor.constraint(equalTo: headerView.bottomAnchor, constant: padding),
            itemViewOne.heightAnchor.constraint(equalToConstant: itemHeight),
            
            itemViewTwo.topAnchor.constraint(equalTo: itemViewOne.bottomAnchor, constant: padding),
            itemViewTwo.heightAnchor.constraint(equalToConstant: itemHeight),
            
            dateLabel.topAnchor.constraint(equalTo: itemViewTwo.bottomAnchor, constant: padding),
            dateLabel.heightAnchor.constraint(equalToConstant: 18)
        ])
    }
    
    @objc func dismissVC(){
        dismiss(animated: true)
    }

}

//lets conform to delegate

extension UserInfoViewController : UserInfoVCDelegate {
    func didTapGitHubProfile(for user: User) {
        //show safari view controller
        guard let url = URL(string: user.htmlUrl) else{
            presentGFAlertOnMainThread(title: "Invalid URL", message: "The URL attached to this user is invalid", buttonTitle: "OK")
            return
        }
        presentSafariVC(with: url)
    }
    
    func didTapGetFollowers(for user: User) {
        //dismiss vc
        //tell follower screen the new user
        
        /*
         Here if a user has zero followers we dont want do all the process just to show a empty screen,
         so we will check it using guard
         */
        guard user.followers != 0 else {
            presentGFAlertOnMainThread(title: "No Followers", message: "The user you selected has no followers!", buttonTitle: "OK")
            return
        }
        delegate.didRequestFollowers(for: user.login)
        dismissVC()
    }

}
