import UIKit

class FollowerListViewController: UIViewController {

    //since our collection view has only one section
    enum Section {
        case main
    }
    
    var username : String!
    var followers : [Follower] = []
    var collectionView : UICollectionView!
    var page = 1
    //flag to check wether user has more followers or not
    var hasMoreFollowers = true
    
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
        getFollowers(username: username, page: page)
        
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
    
   
    
    func configureCollectionView(){
        collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: UIHelper.createThreeColumnFlowLayout(in: view))
        collectionView.delegate = self
        view.addSubview(collectionView)
        collectionView.backgroundColor = .systemBackground
        //setting cell for collection view
        collectionView.register(FollowerCell.self, forCellWithReuseIdentifier: FollowerCell.reuseID)
    }
    
    func getFollowers( username:String, page:Int){
        
        //calling showLoadingView before making network call
        showLoadingView()
    
        /*
         Here we see theres a strong refrence between self and network manager which should be there,
         Instead there should be a weak refrence , so we will use a capture list "[weak self]" which means all the self here will be
         weak
         */
        NetworkManager.shared.getFollowers(for: username, page: page) { [weak self] result in
            
            //whenever we make self weak it gets converted to optional , so we will unwrap the optional using guard
            guard let self = self else {
                return
            }
            
            //calling DismissLoadingView after making network call
            self.dismissLoadingView()
            
            //Now since we are using result it has only two cases ..succes and failure which we will check using enum
            switch result {
            case.success(let followers):
                
                //checks if fetched followers are 100 or less if less than 100 means dont make another api call
                if followers.count < 30 {
                    self.hasMoreFollowers = false
                }
                
                //here when we load page 2 page 1 followers will disapper so for that to not happen we have used .append
                self.followers.append(contentsOf: followers)
                
                //here we will check if after appending also followers are empty or not , if so that means user has no followers
                if self.followers.isEmpty{
                    let message =  "Uhh Ohh! This user has no followers :( "
                    DispatchQueue.main.async {
                        self.showEmptyStateView(message: message, in: self.view)
                    }
                    return
                }
                
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

extension FollowerListViewController : UICollectionViewDelegate {
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        print("Dragging Ended")
        //this calculates the amount of height scrolled
        let offsetY = scrollView.contentOffset.y
        //this calculates the amount of heigh content requires
        let contentHeight = scrollView.contentSize.height
        //this calculates the height of screen
        let height = scrollView.frame.size.height
        
        if offsetY > contentHeight - height {
            guard hasMoreFollowers else {
                return
            }
            page = page + 1
            getFollowers(username: username, page: page)
        }
    }
}
