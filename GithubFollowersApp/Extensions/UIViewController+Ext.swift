/*
 NOTE: THIS IS A EXTENSION FOR UI VIEWCONTROLLER
 now we have created this extension since we can implement all the functionality that we want common for all view controllers
 eg : we want custom alert for all the view controller so we create a extension for it
 on another hand if we want a functionality only for particular vc or anything we can use sub class
 */
import UIKit

//making this variable a global since extensions cannot have variables declared in them
//also file private means only the members of this file can access that variable
fileprivate var containerView : UIView!

extension  UIViewController{
    
    /*
     Here we are presenting it on main thread because it is illegal to do it on sub thread ,
     if we dont do it here everytime alert is called we need to wrap to main thread there , it is better to do it here
     
     This function makes sure any vc can call this function
    */
    func presentGFAlertOnMainThread( title: String , message: String , buttonTitle: String ){
        //this function puts it on main thread
        DispatchQueue.main.async {
            let alertVC = GFAlertViewController(alertTitle: title, message: message, buttonTitle: buttonTitle)
            alertVC.modalPresentationStyle = .overFullScreen
            //animation while alert pops up
            alertVC.modalTransitionStyle = .crossDissolve
            self.present(alertVC, animated: true)
        }
    }
    
    /*
     Shows the loading screen
     */
    func showLoadingView(){
        //takes up the whole screen
        containerView = UIView(frame: view.bounds)
        view.addSubview(containerView)
        
        containerView.backgroundColor = .systemBackground
        containerView.alpha = 0
        
        //animates alpha from 0 - 0.8
        UIView.animate(withDuration: 0.25) {
            containerView.alpha = 0.8
        }
        
        //adds that loading indicator
        let activityIndicator = UIActivityIndicatorView(style: .large)
        containerView.addSubview(activityIndicator)
        containerView.translatesAutoresizingMaskIntoConstraints = false
        //centering the indicator
        NSLayoutConstraint.activate([
            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
        //starts animating
        activityIndicator.startAnimating()
    }
    
    //Dismiss loading screen
    func dismissLoadingView(){
        /*
         Since dismiss function will always be called after fetching a response which is a async process
         i.e on background thread , also the dismiss function will be called from background thread so we will
         shift it to main thread here
         */
        DispatchQueue.main.async {
            //removes container view from super view
            containerView.removeFromSuperview()
            //also setting container view to nil 
            containerView = nil
        }
    }
    
    /*
     Calling emptyStateView here coz multiple screens will use it
     */
    func showEmptyStateView(message : String , in view : UIView) {
        let emptyStateView = GFEmptyStateView(message: message)
        emptyStateView.frame = view.bounds
        view.addSubview(emptyStateView)
    }
}
