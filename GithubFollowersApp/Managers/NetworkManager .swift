import UIKit

//here we are creating this singleton class so that a singke instance is used by everyone
class NetworkManager {
    
    static let shared = NetworkManager()
    
    //this is the base url for the api
    private let baseURL = "https://api.github.com/users/"
    
    //we are intializing cache here so that we have a single instance and not a new instance is created everytime cell is reused
    let cache = NSCache<NSString, UIImage>()
    
    private init() {}
    
    /*
     Here for completed closure we either get array of list of followers or error message but since we using
     enums for error message we pass the name of that enum
     */
    //func getFollowers (for username : String , page : Int , completed : @escaping ([Follower]? , ErrorMessage?) -> Void
    
    /*
     This is another way where we use a new way in closures , since before escaping closure could return any of two(followers or
     errorMessage ) while both being optional it was like hendeling 4 cases but by using results there or only two possiblites
     1.Success 2.Failure
     */
    func getFollowers (for username : String , page : Int , completed : @escaping (Result<[Follower] , GFError>) -> Void)
    {
        let endpoint = baseURL + "\(username)/followers?per_page&page=\(page)"
        //now we cant pass this directly we need to convert it to url object
        
        /*
         We are using gaurd let to check wather we recived a valid url, if so we can convert it further,
         if not we will not show custom alert directly from here, since it wont be called on main thread which is illegal
         instead we will send error message as a string to view controller who is responsible for ui management
         */
        
        guard let url = URL(string: endpoint) else{
            /*
             Now since this is a closure asking for two return values , one is followers and another is error message as string ]
             followers will be nil since url wasnt valid and we didnt get array of followers as a response
             */
            completed(.failure(.invalidUsername))
            return
        }
        
        //now that we have a valid url lets get data from it
        //in below block of code we will handle data / response / error
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            
            //now since all three (data, response,error ) are optionals we will use if let to check them
            
            if let _ = error {
                //now since error usually occures when internet connection is bad we will pass in this error message
                completed(.failure(.unableToComplete))
                return
            }
            
            /*
             Here firstly we are checking if response is equal to response of httpurl and then checking if the status code is
             equal to 200 i.e of it is succesfull it wont enter the scope else it will (means it was not successfull
             */
            guard let response = response as? HTTPURLResponse , response.statusCode == 200 else{
                completed(.failure(.invalidResponse))
                return
            }
            
            guard let data = data else{
                completed(.failure(.invalidData))
                return
            }
            
            /*
             Now that we have data , we can start parsing or performing operations on it
             now encoders and decoders user try catch for error handeling
             so do block has a try where if it fails i catches error in catch block
             */
            do
            {
                let decoder = JSONDecoder()
                //now remember we had methods in decoder to handle the conversion of camel case to snake case this is where we set that
                decoder.keyDecodingStrategy = .convertFromSnakeCase
                //now we will decode the followers
                /*
                 What below line means is we will tey decoding the array of followers from the data that we get after api runs
                 */
                let followers = try decoder.decode([Follower].self, from: data)
                //if everything is succesfull we will have array of followers and no error message
                completed(.success(followers))
            } catch {
                //now if try in above block fails it will throw error in this block
                completed(.failure(.invalidData))
            }
            
        }
        
        //this is what will start a network call
        task.resume()
    }
}
