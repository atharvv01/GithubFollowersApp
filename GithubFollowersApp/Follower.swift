import Foundation
 
struct Follower : Codable , Hashable {
    //now here we need to match the name of entities to that in json response
    var login : String
    
    /*
     here although the name is 'avatar_url' since we use camel case in swift
     codable has it taken care of that it understands theres a underscore
     */
    var avatarUrl:String
}
