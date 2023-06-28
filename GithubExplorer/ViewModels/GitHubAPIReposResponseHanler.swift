//
//  GitHubAPIRepoResponseHanler.swift
//  GithubExplorer
//
//  Created by Misha Vrana on 20.06.2023.
//

import Foundation
import CoreData

class GitHubAPIRepoResponseHandler: ObservableObject {
    @Published var repos: [RepoEntity] = []
    @Published var isLoading: Bool = true
    @Published var error: Error?
    
    var user: UserEntity

    let manager = CoreDataManager.instance
    
    private var coreDateReposLimit = ViewModelConstants.pageLimit
    private let pageLimit = ViewModelConstants.pageLimit
    private var page = 1
    
    var baseURL: String = ""
    
    var urlString: String {
        "\(baseURL)?per_page=\(pageLimit)&page=\(page)"
    }
    
    var isFetchedForTheFirstTime = true
    
    init(user: UserEntity, url: String) {
        self.user = user
        self.baseURL = url
        getRepos()
    }

    // MARK: - REST Intents

    var allReposFetched = false
    
    @MainActor
    private func fetchRepos() async throws {
        isLoading = true
        
        do {
            guard let url = URL(string: urlString) else { throw UserErrors.invalidURL }
            let (data, response) = try await URLSession.shared.data(from: url)
            guard let response = response as? HTTPURLResponse  else { throw UserErrors.serverError }
            guard response.statusCode >= 200 && response.statusCode <= 299 else { throw UserErrors.serverError }
            guard let repos = try? JSONDecoder().decode([Repo].self, from: data) else { throw UserErrors.invalidData }
            
            if isFetchedForTheFirstTime && repos.isEmpty {
                throw UserErrors.repoIsEmpty
            }
            
            for repo in  repos {
                RepoEntity.updateReposInCoreData(from: repo, for: user, context: manager.context)
            }
           
            var allReposFetched: Bool {
                return repos.isEmpty
            }
            
            if allReposFetched {
                self.allReposFetched = true
            }
            isFetchedForTheFirstTime = false
        } catch {
            self.error = error
        }
        
        loadReposFromCache()
        
        isLoading = false
    }
    
    private func loadRepoData() {
        Task(priority: .medium) {
            try await fetchRepos()
        }
        loadReposFromCache()
    }
    
    private func fetchMore() {
        self.page += 1
        loadRepoData()
    }
    
    // MARK: - CoreData Intents
    
    private var coreDataReturnedTheLastRepo: Bool {
        return !repos.isEmpty && repos.count < coreDateReposLimit
    }
    
    private func loadReposFromCache() {
        isLoading = true
        let request = NSFetchRequest<RepoEntity>(entityName: "RepoEntity")
        request.sortDescriptors = [NSSortDescriptor (key: "ownerLogin", ascending: true)]
        request.predicate = NSPredicate(format: "ownerLogin = %@", user.login ?? "")
        request.fetchLimit = coreDateReposLimit
        
        do {
            self.repos = try manager.context.fetch(request)
        } catch {
            self.error = UserErrors.coreDataError
        }
        
        isLoading = false
    }
    
    private func increaseCoreDataReposLimit() {
        coreDateReposLimit += ViewModelConstants.pageLimit
    }
    
    // MARK: - Intents
    
    func getRepos() {
        loadReposFromCache()
        
        if repos.isEmpty && error == nil {
            if !allReposFetched {
                loadRepoData()
            }
        }
        
        if coreDataReturnedTheLastRepo && error == nil {
            if !allReposFetched {
                fetchMore()
            }
        }
    }
    
    func loadMoreRepos() {
        increaseCoreDataReposLimit()
        getRepos()
    }
    
    func handleRefresh() {
        allReposFetched = false
        coreDateReposLimit = ViewModelConstants.pageLimit
        error = nil
        repos = []
        page = 0
        getRepos()
    }
}
