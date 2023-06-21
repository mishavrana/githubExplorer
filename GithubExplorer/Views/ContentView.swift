//
//  ContentView.swift
//  GithubExplorer
//
//  Created by Misha Vrana on 19.06.2023.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var gitHubAPIResponseHandler: GithubAPIUsersResponseHandler
    @State private var showAlert = false
    
    var body: some View {
        NavigationView {
            List {
                ForEach($gitHubAPIResponseHandler.users) { $user in
                    NavigationLink {
                        ReposView(user: user)
                    } label: {
                        UserRowView(user: user)
                            .onAppear {
                                if user.id == gitHubAPIResponseHandler.users.last?.id {
                                    gitHubAPIResponseHandler.loadMoreUsersFromCash()
                                }
                            }
                    }
                }
                if gitHubAPIResponseHandler.isLoading {
                    ProgressView()
                        .progressViewStyle(.circular)
                        .frame(maxWidth: .infinity, alignment: .center)
                }
                
            }
            .navigationTitle("GitHub Users")
            .refreshable {
                gitHubAPIResponseHandler.handleRefresh()
            }
            .onReceive(gitHubAPIResponseHandler.$error) { error in
                if error != nil {
                    showAlert.toggle()
                }
            }
            .alert(isPresented: $showAlert) {
                Alert(
                    title: Text("Error"),
                    message: Text(gitHubAPIResponseHandler.error?.localizedDescription ?? "")
                )
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Release cashe") {
                        gitHubAPIResponseHandler.freeCash()
                    }
                }
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(GithubAPIUsersResponseHandler())
    }
}
