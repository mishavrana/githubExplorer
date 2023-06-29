//
//  UserErrors.swift
//  GithubExplorer
//
//  Created by Misha Vrana on 20.06.2023.
//

import Foundation

enum UserErrors: LocalizedError {
    case invalidURL
    case serverError
    case invalidData
    case repoIsEmpty
    case coreDataError
    case unkown(Error)
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return ""
        case .serverError:
            return "There was an error with the server. Please try again later"
        case .invalidData:
            return "The coin data is invalid. Please try again later"
        case .repoIsEmpty:
            return "The are no repos"
        case .coreDataError:
            return "Can't load from DB"
        case .unkown(let error):
            return error.localizedDescription
        }
    }
}
