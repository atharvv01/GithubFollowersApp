import Foundation

enum PersistenceActionType{
    case add, remove
}

enum PersistenceManager {
    
    //creating instance of user defaults
    static private let defaults = UserDefaults.standard
    
    //make enum to hold keys
    enum Keys{
        static let favorites = "favorites"
    }
    
    static func updateWith(favorite : Follower, actionType: PersistenceActionType, completion : @escaping (GFError?) -> Void){
        /*
         Now irrespective of wether we are adding or removing from favorites , we need to reacg to user defaults and retrive
         the data
         */
        retriveFavorities { result in
            switch result {
            case.success(let favorites):
                /*
                 We will make a temp array which is var because then it will be mutable , so we can add or delete elements
                 */
                var retrivedFavorites = favorites
                
                switch actionType{
                case.add:
                    /*
                     Here we will check if the user is already added to fav , if so we dont want to add it again
                     */
                    guard !retrivedFavorites.contains(favorite) else{
                        completion(.alreadyInFavorites)
                        return
                    }
                    retrivedFavorites.append(favorite)
                case.remove:
                    //matches the login of the user in the list
                    retrivedFavorites.removeAll{ $0.login == favorite.login}
                }
                
                //now add/remove action has been performed successfully, now we save it backe in user defaults
                completion(save(favourites: retrivedFavorites))
            case.failure(let error):
                completion(error)
            }
        }
    }
    
    
    /*
     This is to retrive the favrouties array,
     Now here we are using encodables / decodeables resulgt type etc because where ever you store a custom object in user defaults
     it need to be encoded and decoded , meanwhile if you just store a something basic such as INT, BOOL etc you dont need to do that.
     */
    static func retriveFavorities(completed: @escaping(Result<[Follower], GFError>) -> Void) {
        /*
         Now when you save something in user defaults you need to give it and identifier , which is a key
         
         here .object is of type any? i.e xcode knows theres a object there but doesnt know what type , so we need to typecast it into data
         
         Here what we are saying is pull up data from favorites with given key
         */
        guard let favoritesData = defaults.object(forKey: Keys.favorites) as? Data else{
            /*
             We wont return a error here , because if this is nil means nothing has been stored here before,
             we return empty array
             */
            completed(.success([]))
            return
        }
        do
        {
            let decoder = JSONDecoder()
            let favorites = try decoder.decode([Follower].self, from: favoritesData)
            completed(.success(favorites))
        } catch {
            completed(.failure(.unableToFavorite))
        }
    }
    
    /*
     Here this function is to save data into user defaults ,
     now since it also requires decoding there can be a error , so we return gferror which is a optional since it can also be nil
     */
    static func save(favourites: [Follower]) -> GFError? {
        do {
            let encoder = JSONEncoder()
            let encodedFavorites = try encoder.encode(favourites)
            //saving data to user defaults
            defaults.set(encodedFavorites, forKey: Keys.favorites)
            return nil
        }
        catch {
            return .unableToFavorite
        }
    }

}
