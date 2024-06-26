import Foundation

//here this means all cases will have string type values (RAW VLAUE CONCEPT - ENUM)
//here we also conform it error to use it in result (Swif5 concept)
enum GFError : String , Error {
    
    case invalidUsername = "This username created an invalid request. Please try again"
    case unableToComplete = "Unable to complete our request. Please check your internet connection"
    case invalidResponse = "Invalid response from the server please try again"
    case invalidData = "Data received from the server is invalid. Please try again"
}
