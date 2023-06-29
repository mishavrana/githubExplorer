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
        viewModel?.releaseCache()
        viewModel = nil
    }
    
    func test_GithubAPIUsersResponseHandler_loadUserData_shouldReturnItems() {
        // Given
        
        // When
        let expectation = XCTestExpectation(description: "Should return items after 5 seconds")
        
        viewModel?.$users
            .sink { returnItems in
                if returnItems.count > 0 {
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)
        
        viewModel?.getUsers()
        
        // Then
        wait(for: [expectation], timeout: 10)
        XCTAssertGreaterThan(viewModel!.users.count, 0)
    }
    
    func test_GithubAPIUsersResponseHandler_loadMoreUsers_shouldReturnMoreItemsThanFromTheStart() {
        // Given
        
        // When
        let expectation1 = XCTestExpectation(description: "Should return items in 10 seconds")
        let expectation2 = XCTestExpectation(description: "Should return more than 20 items after 10 seconds")
    
        viewModel?.$users
            .sink { returnItems in
                if returnItems.count > 0 {
                    expectation1.fulfill()
                }
            }
            .store(in: &cancellables)
        
        viewModel?.getUsers()
        
        wait(for: [expectation1], timeout: 10)
        XCTAssertGreaterThan(viewModel!.users.count, 0)
        
        viewModel?.$users
            .sink { returnItems in
                if returnItems.count > ViewModelConstants.pageLimit {
                    expectation2.fulfill()
                }
            }
            .store(in: &cancellables)
        
        viewModel?.loadMoreUsers()
        
        // Then
        wait(for: [expectation2], timeout: 10)
        XCTAssertGreaterThan(viewModel!.users.count, ViewModelConstants.pageLimit)
    }
    
}
