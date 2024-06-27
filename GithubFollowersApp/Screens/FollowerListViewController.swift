import UIKit

class FollowerListViewController: UIViewController {

    //since our collection view has only one section
    enum Section {
        case main
    }
    
    var username : String!
    var followers : [Follower] = []
    var collectionView : UICollectionView!
    
    /*
     Here what we are doing is using diffable data source which is new in ios 13 where in when we want out table/collection view to be dynamic
     we can use this as as we search or perform anything that makes changes in the table/collection view , it animates making changes
     This is done by comparing the snap shots of before and after the change
     Above was a very high level explantion of what diffable data source is and why it is used
     
     Now it is a generic that takes two params and they both should conform to hashable protocol , because thats what it uses to give
     unique ids to snapshots it takes
     
     first param is a section , and here we are using enum for it which are hashable by default
     second param would be follower
     */
    var dataSource : UICollectionViewDiffableDataSource<Section, Follower>!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        configureViewController()
        
        //lets call collection view here
        configureCollectionView()
        
        //lets call api here
        getFollowers()
        
        configureDataSource()
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
        collectionView.backgroundColor = .systemBackground
        //setting cell for collection view
        collectionView.register(FollowerCell.self, forCellWithReuseIdentifier: FollowerCell.reuseID)
    }
    
    func getFollowers(){
        NetworkManager.shared.getFollowers(for: username, page: 1) { result in
            
            //Now since we are using result it has only two cases ..succes and failure which we will check using enum
            
            switch result {
            case.success(let followers):
                self.followers = followers
                self.updateData()
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
    
    //configuring diff data source
    func configureDataSource(){
        dataSource = UICollectionViewDiffableDataSource<Section, Follower>(collectionView: collectionView, cellProvider: { (collectionView, indexPath, follower) -> UICollectionViewCell? in
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: FollowerCell.reuseID, for: indexPath) as! FollowerCell
            //what this does is passes the follower and calls the function to set the title of cell and username of the follower
            cell.set(follower: follower)
            return cell
        })
    }
    
    //this function is called when we need to update the data in diffable data source
    func updateData(){
        var snapshot = NSDiffableDataSourceSnapshot<Section,Follower>()
        snapshot.appendSections([.main])
        snapshot.appendItems(followers)
        //now that we have all the data apply it in mian thread
        DispatchQueue.main.async {
            self.dataSource.apply(snapshot, animatingDifferences: true)
        }
        
        
    }

}
