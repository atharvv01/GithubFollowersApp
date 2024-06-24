/*
 NOTE: THIS IS A EXTENSION FOR UI VIEWCONTROLLER
 now we have created this extension since we can implement all the functionality that we wanr common for all view controllers
 eg : we wont custom alert for all the view controller so we create a extension for it
 on another hand if we want a functionality only for particular vc or anything we can use sub class
 */
import UIKit

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
}
