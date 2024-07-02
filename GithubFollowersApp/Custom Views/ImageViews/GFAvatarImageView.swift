import UIKit

class GFAvatarImageView: UIImageView {

    let cache = NetworkManager.shared.cache
    
    //we will force unwrap here since we know image already exists in ur bundle
    let placeholderImage = UIImage(named: "avatar-placeholder")!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configure()
    {
        layer.cornerRadius = 10
        //this makes sure the image is bounded to the round edges of ui view 
        clipsToBounds = true
        image = placeholderImage
        translatesAutoresizingMaskIntoConstraints = false
    }
    
    func downloadImage(from urlString : String)
    {
        //now before downloading the image , we will check wether it is present in cache or not
        //converting string to nsstring
        let cacheKey = NSString(string: urlString)
        
        if let image = cache.object(forKey: cacheKey) {
            self.image = image
            return
        }
        
        //if we dont have cache image then run this
        
        guard let url = URL(string: urlString) else{
            return
        }
        let task = URLSession.shared.dataTask(with: url) { [weak self] data , response, error in
            
            guard let self = self else {
                return
            }
            if error != nil {
                return
            }
            guard let response = response as? HTTPURLResponse , response.statusCode == 200 else {
                return
            }
            guard let data = data else {
                return
            }
            guard let image = UIImage(data: data) else {
                return
            }
            
            //now once we have the image we also need to set it in cache
            self.cache.setObject(image, forKey: cacheKey)
            
            DispatchQueue.main.async {
                self.image = image
            }
        }
        task.resume()
    }
}
