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
    
    var user: UserEntity?
    var viewModel: GitHubAPIRepoResponseHandler?
    var usersViewModel = GithubAPIUsersResponseHandler()
    var cancellables = Set<AnyCancellable>()

    
    override func setUpWithError() throws {
        user = UserEntity.defaultValue
        user?.reposURL = "https://api.github.com/users/mojombo/repos"
        user?.login = "mojombo"
        user?.id = 1
        
        if let user = user {
            viewModel = GitHubAPIRepoResponseHandler(user: user, url: user.reposURL ?? "")
        }
    }

    override func tearDownWithError() throws {
        usersViewModel.releaseCache()
        viewModel = nil
    }
    
    func test_GithubAPIReposResponseHandler_loadReposData_shouldReturnItems() {
        // Given
        
        // When
        let expectation = XCTestExpectation(description: "Should return items after 10 seconds")
        
        viewModel?.$repos
            .sink { returnedItems in
                if returnedItems.count > 0 {
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)
            
        viewModel?.getRepos()
        
        // Then
        wait(for: [expectation], timeout: 10)
        XCTAssertGreaterThan(viewModel!.repos.count, 0)
    }
    
    func test_GithubAPIReposResponseHandler_loadMoreRepos_shouldReturnMoreItemsThanFromTheStart() {
        // Given
        
        // When
        let expectation1 = XCTestExpectation(description: "Should return items in 10 seconds")
        let expectation2 = XCTestExpectation(description: "Should return more than 20 items after 10 seconds")
        
        viewModel?.$repos
            .sink { returnedItems in
                if returnedItems.count > 0 {
                    expectation1.fulfill()
                }
            }
            .store(in: &cancellables)
            
        viewModel?.getRepos()
        
        wait(for: [expectation1], timeout: 10)
        XCTAssertGreaterThan(viewModel!.repos.count, 0)
        
        viewModel?.$repos
            .sink { returnedItems in
                if returnedItems.count > ViewModelConstants.pageLimit {
                    expectation2.fulfill()
                }
            }
            .store(in: &cancellables)
            
        viewModel?.loadMoreRepos()
        
        // Then 
        wait(for: [expectation2], timeout: 10)
        XCTAssertGreaterThan(viewModel!.repos.count, ViewModelConstants.pageLimit)
    }
    
}
