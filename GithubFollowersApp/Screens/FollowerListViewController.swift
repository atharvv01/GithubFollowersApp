import UIKit

class FollowerListViewController: UIViewController {

    var username : String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        navigationController?.navigationBar.isHidden = false
        navigationController?.navigationBar.prefersLargeTitles = true
        
        //lets call api here
        
        NetworkManager.shared.getFollowers(for: username, page: 1) { result in
            
            //Now since we are using result it has only two cases ..succes and failure which we will check using enum
            
            switch result {
            case.success(let followers):
                print (followers) 
            case.failure(let error):
                self.presentGFAlertOnMainThread(title: "Bad stuff", message: error.rawValue, buttonTitle: "OK")
            }
            
            
            //THIS IS OLD METHOD
            //now we will check if followers has a value coz either followers will be returned or error message not both
            
//            guard let followers = followers else{
//                //lets show error message in alert
//                self.presentGFAlertOnMainThread(title: "Bad stuff", message: errorMessage!.rawValue, buttonTitle: "OK")
//                return
//            }
//            print ("Followers.count = \(followers.count)")
//            print (followers)
        }
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: true)
        
    }
    

}
