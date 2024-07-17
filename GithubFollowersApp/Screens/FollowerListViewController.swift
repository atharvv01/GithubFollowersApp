import UIKit

/*
 This delegate is for when user taps on show followers for a particular user and
 user should be redirected to followers list for that user
 */
protocol FollowersListVCDelegate: AnyObject {
    func didRequestFollowers(for username: String)
}

class FollowerListViewController: UIViewController {

    //since our collection view has only one section
    enum Section {
        case main
    }
    
    var username : String!
    var followers : [Follower] = []
    //creating this for searching
    var filteredFollowers : [Follower] = []
    var collectionView : UICollectionView!
    var page = 1
    //checks wether we are searching or not , intially its false
    var isSearching = false
    //flag to check wether user has more followers or not
    var hasMoreFollowers = true
    
    /*
     Here what we are doing is using diffable data source which is new in ios 13 where in when we want out table/collection view to be dynamic
     we can use this as we search or perform anything that makes changes in the table/collection view , it animates making changes
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
        
        configureSearchController()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: true)
        
    }
    
    func configureViewController(){
        view.backgroundColor = .systemBackground
        navigationController?.navigationBar.isHidden = false
        navigationController?.navigationBar.prefersLargeTitles = true
        
        let addButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addButtonTapped))
        navigationItem.rightBarButtonItem = addButton
    }
    
    @objc func addButtonTapped(){
        showLoadingView()
        
        /*
         Here we will make a api call to get users info , to display the avatar of the favorited user
         */
        NetworkManager.shared.getUsers(for: username) { [weak self] result in
            guard let self  = self else{
                return
            }
            self.dismissLoadingView()
            
            switch result{
                
            case .success(let user):
                
                let favorite = Follower(login: user.login, avatarUrl: user.avatarUrl)
                
                PersistenceManager.updateWith(favorite: favorite, actionType: .add) { [weak self]error in
                    guard let self = self else{
                        return
                    }
                    
                    guard let error = error else{
                        self.presentGFAlertOnMainThread(title: "Success!", message: "You have successfully added user to favorites", buttonTitle: "OK")
                        return
                    }
                    
                    self.presentGFAlertOnMainThread(title: "Somrthing went wrong", message: error.rawValue, buttonTitle: "OK")
                }
                
            case .failure(let error):
                self.presentGFAlertOnMainThread(title: "Somrthing went wrong", message: error.rawValue, buttonTitle: "OK")
            }
        }
    }
   
    
    func configureCollectionView(){
        collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: UIHelper.createThreeColumnFlowLayout(in: view))
        collectionView.delegate = self
        view.addSubview(collectionView)
        collectionView.backgroundColor = .systemBackground
        //setting cell for collection view
        collectionView.register(FollowerCell.self, forCellWithReuseIdentifier: FollowerCell.reuseID)
    }
    
    func configureSearchController(){
        let searchController = UISearchController()
        searchController.searchResultsUpdater = self
        searchController.searchBar.delegate = self
        searchController.searchBar.placeholder = "Search for a username"
        navigationItem.searchController = searchController
    }
    
    func getFollowers( username:String, page:Int){
        
        //calling showLoadingView before making network call
        showLoadingView()
    
        /*
         Here we see theres a strong refrence between self and network manager which shouldnt be there,
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
                
                self.updateData(on: self.followers)
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
    func updateData(on followers: [Follower]){
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
    
    /*
     This tells us what row we tapped on
     */
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        //below checks if is searching is true or false , if true first one is executed if false the other one
        let activeArray = isSearching ? filteredFollowers : followers
        let follower = activeArray[indexPath.item]
        
        let userInfoVC = UserInfoViewController()
        //passing the username to make a network call to show details of the user
        userInfoVC.username = follower.login
        //setting delegate
        userInfoVC.delegate = self
        //adding navigation controller
        let navController = UINavigationController(rootViewController: userInfoVC)
        present(navController, animated: true)
    }
}

extension FollowerListViewController :UISearchResultsUpdating , UISearchBarDelegate {
    func updateSearchResults(for searchController: UISearchController) {
        //using a gaurd to set filter to text entered in text bar and checking its not empty
        guard let filter = searchController.searchBar.text , !filter.isEmpty else{
            return
        }
        isSearching = true
        /*
         In below closure $0 means iterating through all the present followers
         below closure checks if followers contain the filtered followers and appends them to
         filterFollowers array if so
         */
        filteredFollowers = followers.filter{ $0.login.lowercased().contains(filter.lowercased()) }
        updateData(on: filteredFollowers)
    }
    
    //when ever cancel button is clicked show all the followers again
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        isSearching = false
        updateData(on: followers)
    }
}

extension FollowerListViewController : FollowersListVCDelegate {
    
    func didRequestFollowers(for username: String) {
        self.username = username
        title = username
        page = 1
        //before showing new followers for user remove the previous ones from arrays
        followers.removeAll()
        //set scroll view to the top , incase user has scrolled before
        collectionView.setContentOffset(.zero, animated: true)
        //now call the api
        getFollowers(username: username, page: page)
    }
}
