//
//  UserFetcher.swift
//  GithubExplorer
//
//  Created by Misha Vrana on 19.06.2023.
//

import Combine
import CoreData
import Foundation

class GithubAPIUsersResponseHandler: ObservableObject {
    @Published var users: [UserEntity] = []
    @Published var isLoading: Bool = true
    @Published var error: Error?
    
    let manager = CoreDataManager.instance
    
    private var coreDateUsersLimit = ViewModelConstants.pageLimit
    private let pageLimit = ViewModelConstants.pageLimit
    private var page = 0
    
    let baseURL = "https://api.github.com/users"
    
    var urlString: String {
        return "\(baseURL)?per_page=\(pageLimit)&since=\(page)"
    }

    init() {
        getUsers()
    }
    
    // MARK: - REST Intents
    
    var allUsersFetched = false
    
    @MainActor
    private func fetchUsers() async throws {
        isLoading = true
        do {
            guard let url = URL(string: urlString) else { throw UserErrors.invalidURL }
            let (data, response) = try await URLSession.shared.data(from: url)
            guard let response = response as? HTTPURLResponse  else { throw UserErrors.serverError }
            guard response.statusCode >= 200 && response.statusCode <= 299 else { throw UserErrors.serverError }
            guard let users = try? JSONDecoder().decode([User].self, from: data) else { throw UserErrors.invalidData }
            for user in users {
                UserEntity.updateUsersInCoreData(from: user, context: manager.context)
            }
            
            var allUsersFetched: Bool {
                return users.isEmpty
            }
            
            if allUsersFetched {
                self.allUsersFetched = true
            }
        } catch {
            self.error = error
        }
        
        loadUsersFromCache()
        
        isLoading = false
    }

    private func loadUsersData() {
        Task(priority: .medium) {
            try await fetchUsers()
        }
    }
    
    private func fetchMore() {
        self.page = Int(self.users.last?.id ?? 0)
        self.loadUsersData()
    }
    
    // MARK: - CoreData Intents
    
    private var coreDataReturnedTheLastUser: Bool {
        return !users.isEmpty && users.count < coreDateUsersLimit
    }
    
    private func loadUsersFromCache() {
        isLoading = true
        
        let request = NSFetchRequest<UserEntity>(entityName: "UserEntity")
        request.fetchLimit = coreDateUsersLimit
        
        do {
            self.users = try manager.context.fetch(request)
        } catch {
            self.error = UserErrors.coreDataError
        }
        
        isLoading = false
    }
    
    private func increaseCoreDataUserLimit() {
        coreDateUsersLimit += ViewModelConstants.pageLimit
    }
    
    private func releaseUsersCache() {
          let fetchRequest1: NSFetchRequest<NSFetchRequestResult> = UserEntity.fetchRequest()
          let batchDeleteRequest1 = NSBatchDeleteRequest(fetchRequest: fetchRequest1)
        _ = try? manager.context.execute(batchDeleteRequest1)
        
    }
    
    // MARK: - Intents
    
    func getUsers() {
        loadUsersFromCache()
        
        if users.isEmpty && error == nil {
            if !allUsersFetched {
                loadUsersData()
            }
        }
        
        if coreDataReturnedTheLastUser && error == nil {
            if !allUsersFetched {
                fetchMore()
            }
        }
    }
    
    func loadMoreUsers() {
        increaseCoreDataUserLimit()
        getUsers()
    }
    
    func handleRefresh() {
        allUsersFetched = false
        coreDateUsersLimit = ViewModelConstants.pageLimit
        users = []
        error = nil
        page = 0
        getUsers()
    }
    
    func releaseCache() {
        releaseUsersCache()
        handleRefresh()
    }
}

