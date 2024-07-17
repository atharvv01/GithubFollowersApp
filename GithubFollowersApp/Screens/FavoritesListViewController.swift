import UIKit

class FavoritesListViewController: UIViewController {

    let tableView = UITableView()
    var favorites : [Follower] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureViewController()
        configureTableView()
    }
   /*
    Calling getFavorites function here because viewDidLoad will only be called once
    */
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        getFavorites()
    }
    
    func configureViewController(){
        view.backgroundColor = .systemBackground
        title = "Favorites"
        navigationController?.navigationBar.prefersLargeTitles = true
    }
    
    func configureTableView(){
        view.addSubview(tableView)
        tableView.frame = view.bounds
        tableView.rowHeight = 80
        tableView.delegate = self
        tableView.dataSource = self
        //registering cell into tableview
        tableView.register(FavoriteCell.self, forCellReuseIdentifier: FavoriteCell.reuseID)
    }
    
    func getFavorites(){
        PersistenceManager.retriveFavorities { [weak self] result in
            
            guard let self = self else{
                return
            }
            switch result{
            case .success(let favorites):
                if favorites.isEmpty {
                    self.showEmptyStateView(message: "You have no favorites added :(", in: self.view)
                }else{
                    self.favorites = favorites
                    //now we need to reload data on table view
                    DispatchQueue.main.async {
                        self.tableView.reloadData()
                        //this is to make sure tableview is added as subview to the front as in topmost
                        self.view.bringSubviewToFront(self.tableView)
                    }
                }
            case .failure(let error):
                presentGFAlertOnMainThread(title: "Something went wrong", message: error.rawValue, buttonTitle: "OK")
            }
        }
    }
}

extension FavoritesListViewController : UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return favorites.count
    }
    
    /*
     This function('cellForRowAt indexPath') gets called everytime a cell is shown on screen ,
     and each time it gets called set function will also be called , setting all cells with appropriate info
     */
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //here if we dont cast it as favorite cell it wont know that it has a function set which is required to set the cell information
        let cell = tableView.dequeueReusableCell(withIdentifier: FavoriteCell.reuseID) as! FavoriteCell
        //this grabs the favorite at particular row
        let favorite = favorites[indexPath.row]
        //now we set the favorite
        cell.set(favorite: favorite)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let favorite = favorites[indexPath.row]
        let destVC = FollowerListViewController()
        destVC.username = favorite.login
        destVC.title = favorite.login
        
        navigationController?.pushViewController(destVC, animated: true)
        
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        //this means if theres anything other than delete just return
        guard editingStyle == .delete else{
            return
        }
        
        let favorite = favorites[indexPath.row]
        favorites.remove(at: indexPath.row)
        tableView.deleteRows(at: [indexPath], with: .left)
        
        //now lets handle it in user defaults
        
        PersistenceManager.updateWith(favorite: favorite, actionType: .remove) {[weak self] error in
            guard let self = self else {
                return
            }
            
            guard let error = error else{
                return
            }
            
            //if there is a error
            self.presentGFAlertOnMainThread(title: "Something went wrong", message: error.rawValue, buttonTitle: "OK")
            
        }
    }
    
}
