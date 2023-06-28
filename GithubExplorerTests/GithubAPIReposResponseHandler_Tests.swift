//
//  GithubAPIReposResponseHandler_Tests.swift
//  GithubExplorerTests
//
//  Created by Misha Vrana on 28.06.2023.
//

import XCTest
import Combine
@testable import GithubExplorer

final class GithubAPIReposResponseHandler_Tests: XCTestCase {

    var gitHubAPIUsersResponseHandler: GithubAPIUsersResponseHandler?
    var cancellables = Set<AnyCancellable>()

    override func setUpWithError() throws {
        gitHubAPIUsersResponseHandler = GithubAPIUsersResponseHandler()
    }

    override func tearDownWithError() throws {
        gitHubAPIUsersResponseHandler = nil
    }
    
    func test_GithubAPIReposResponseHandler_loadRepoData_shouldReturnItems() {
        // Given
        let user = gitHubAPIUsersResponseHandler?.users.first
        
        // When
        XCTAssertTrue((user != nil))
        
        let gitHubAPIReposResponseHandler = GitHubAPIRepoResponseHandler(user: user!, url: user!.reposURL ?? "")
        let expectation = XCTestExpectation(description: "Should return items after 5 seconds")
        
        gitHubAPIReposResponseHandler.$repos
            .dropFirst()
            .sink { returnedItems in
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        gitHubAPIReposResponseHandler.getRepos()
        
        // Then
        wait(for: [expectation], timeout: 5)
        XCTAssertGreaterThan(gitHubAPIReposResponseHandler.repos.count, 0)
    }
    
    func test_GithubAPIReposResponseHandler_loadMoreRepos_shouldReturnMoreItemsThanFromStart() {
        // Given
        let numberOfRepos = gitHubAPIUsersResponseHandler?.users.count ?? ViewModelConstants.pageLimit

        // When
        let user = gitHubAPIUsersResponseHandler?.users.first
        XCTAssertTrue((user != nil))
        
        let gitHubAPIReposResponseHandler = GitHubAPIRepoResponseHandler(user: user!, url: user!.reposURL ?? "")
        let expectation = XCTestExpectation(description: "Should return items after 5 seconds")
        
        gitHubAPIReposResponseHandler.$repos
            .dropFirst()
            .sink { returnedItems in
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        gitHubAPIReposResponseHandler.loadMoreRepos()
        
        // Then
        wait(for: [expectation], timeout: 5)
        XCTAssertGreaterThan(gitHubAPIReposResponseHandler.repos.count, numberOfRepos)
    }
}
