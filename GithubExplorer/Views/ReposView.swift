//
//  ReposView.swift
//  GithubExplorer
//
//  Created by Misha Vrana on 20.06.2023.
//

import SwiftUI

struct ReposView: View {
    @StateObject var gitHubAPIRepoResponseHandler: GitHubAPIRepoResponseHandler
    @State private var showAlert = false
    
    let user: UserEntity
    
    init(user: UserEntity) {
        self.user = user
        _gitHubAPIRepoResponseHandler = StateObject(wrappedValue: GitHubAPIRepoResponseHandler(user: user, url: user.reposURL ?? ""))
    }
    
    var body: some View {
        List {
            ForEach(gitHubAPIRepoResponseHandler.repos) { repo in
                Text("\(repo.name ?? "")")
                    .onAppear {
                        if repo.id == gitHubAPIRepoResponseHandler.repos.last?.id {
                            gitHubAPIRepoResponseHandler.loadMoreReposFromCash()
                        }
                    }
            }
            if gitHubAPIRepoResponseHandler.isLoading {
                ProgressView()
                    .progressViewStyle(.circular)
                    .frame(maxWidth: .infinity, alignment: .center)
            }
            
        }
        .navigationTitle("\(user.login ?? "")'s Repo")
        .onAppear {
            gitHubAPIRepoResponseHandler.user = user
        }
        .onReceive(gitHubAPIRepoResponseHandler.$error) { error in
            if error != nil {
                showAlert.toggle()
            }
        }
        .alert(isPresented: $showAlert) {
            Alert(
                title: Text("Error"),
                message: Text(gitHubAPIRepoResponseHandler.error?.localizedDescription ?? "")
            )
        }
        .refreshable {
            gitHubAPIRepoResponseHandler.handleRefresh()
        }
    }
}
