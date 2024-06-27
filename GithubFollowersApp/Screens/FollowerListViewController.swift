import UIKit

class FollowerListViewController: UIViewController {

    var username : String!
    var collectionView : UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        configureViewController()
        
        //lets call collection view here
        configureCollectionView()
        
        //lets call api here
        getFollowers()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: true)
        
    }
    
    func configureViewController(){
        view.backgroundColor = .systemBackground
        navigationController?.navigationBar.isHidden = false
        navigationController?.navigationBar.prefersLargeTitles = true
    }
    
    func createThreeColumnFlowLayout() ->UICollectionViewFlowLayout {
        let width = view.bounds.width
        let padding :CGFloat = 12
        let minimumItemSpacing : CGFloat = 10
        let availableWidth = width - (padding*2) - (minimumItemSpacing*2)
        let itemWidth = availableWidth/3
        
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.sectionInset = UIEdgeInsets(top: padding, left: padding, bottom: padding, right: padding)
        flowLayout.itemSize = CGSize(width: itemWidth, height: itemWidth + 40)
         
        return flowLayout
    }
    
    func configureCollectionView(){
        collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: createThreeColumnFlowLayout())
        view.addSubview(collectionView)
        collectionView.backgroundColor = .systemPink
        //setting cell for collection view
        collectionView.register(FollowerCell.self, forCellWithReuseIdentifier: FollowerCell.reuseID)
    }
    
    func getFollowers(){
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

}
