//
//  GithubAPIUsersResponseHandler_Tests.swift
//  GithubExplorerTests
//
//  Created by Misha Vrana on 28.06.2023.
//

import XCTest
import Combine
@testable import GithubExplorer

final class GithubAPIUsersResponseHandler_Tests: XCTestCase {
    
    var viewModel: GithubAPIUsersResponseHandler?
    var cancellables = Set<AnyCancellable>()

    override func setUpWithError() throws {
        viewModel = GithubAPIUsersResponseHandler()
        
    }

    override func tearDownWithError() throws {
        viewModel = nil
    }
    
    func test_GithubAPIUsersResponseHandler_loadUserData_shouldReturnItems() {
        // Given
        
        // When
        let expectation = XCTestExpectation(description: "Should return items after 5 seconds")
        
        viewModel?.$users
            .dropFirst()
            .sink { returnItems in
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        viewModel?.getUsers()
        
        // Then
        wait(for: [expectation], timeout: 5)
        XCTAssertGreaterThan(viewModel!.users.count, 0)
    }
    
    func test_GithubAPIUsersResponseHandler_loadMoreUsers_shouldReturnMoreItemsThanFromTheStart() {
        // Given
        let numberOfUsers = viewModel?.users.count ?? ViewModelConstants.pageLimit
        // When
        let expectation = XCTestExpectation(description: "Should return more than 20 items after 5 seconds")
        
        viewModel?.$users
            .dropFirst()
            .sink { returnItems in
                expectation.fulfill()
            }
            .store(in: &cancellables)

        viewModel?.loadMoreUsers()
        
        // Then
        wait(for: [expectation], timeout: 5)
        XCTAssertGreaterThan(viewModel!.users.count, numberOfUsers)
    }
    
}
