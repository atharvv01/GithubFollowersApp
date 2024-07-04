import XCTest
@testable import GithubFollowersApp // Replace 'YourApp' with the name of your app module

final class NetworkManagerTests: XCTestCase {
    
    
    // MARK: - Tests for getFollowers
    
    func testGetFollowersSuccess() {
        // Arrange
        let networkManager = NetworkManager.shared
        let expectation = self.expectation(description: "Followers fetched successfully")
        
        // Act
        networkManager.getFollowers(for: "atharvv01", page: 1) { result in
            // Assert
            switch result {
            case .success(let followers):
                XCTAssertNotNil(followers)
                XCTAssertGreaterThan(followers.count, 0)
            case .failure:
                XCTFail("Expected success, but got failure")
            }
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 5, handler: nil)
    }
    
    
    func testGetFollowersInvalidResponse() {
        // Arrange
        let networkManager = NetworkManager.shared
        let expectation = self.expectation(description: "Invalid response error")
        
        // Act
        networkManager.getFollowers(for: "@sg%", page: 1) { result in
            // Assert
            switch result {
            case .success:
                XCTFail("Expected failure, but got success")
            case .failure(let error):
                XCTAssertEqual(error, .invalidResponse)
            }
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 5, handler: nil)
    }
    
}
