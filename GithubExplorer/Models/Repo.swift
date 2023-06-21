//
//  Repo.swift
//  GithubExplorer
//
//  Created by Misha Vrana on 20.06.2023.
//

import Foundation

struct Repo: Identifiable, Codable {
    let id: Int
    let name: String
    let owner: Owner
    
    struct Owner: Codable {
        let login: String
    }
}
