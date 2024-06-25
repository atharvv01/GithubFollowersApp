import UIKit

class FollowerListViewController: UIViewController {

    var username : String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        navigationController?.navigationBar.isHidden = false
        navigationController?.navigationBar.prefersLargeTitles = true
        
        //lets call api here
        
        NetworkManager.shared.getFollowers(for: username, page: 1) { followers, errorMessage in
            //now we will check if followers has a value coz either followers will be returned or error message not both
            
            guard let followers = followers else{
                //lets show error message in alert
                self.presentGFAlertOnMainThread(title: "Bad stuff", message: errorMessage!, buttonTitle: "OK")
                return
            }
            print ("Followers.count = \(followers.count)")
            print (followers)
        }
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: true)
        
    }
    

}
