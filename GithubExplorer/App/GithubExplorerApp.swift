//
//  GithubExplorerApp.swift
//  GithubExplorer
//
//  Created by Misha Vrana on 19.06.2023.
//

import SwiftUI

@main
struct GithubExplorerApp: App {
    @StateObject private var gitHubAPIResponseHandler = GithubAPIUsersResponseHandler()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(gitHubAPIResponseHandler)
        }
    }
}
