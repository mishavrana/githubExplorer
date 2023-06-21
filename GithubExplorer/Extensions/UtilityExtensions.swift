//
//  UtilityExtensions.swift
//  GithubExplorer
//
//  Created by Misha Vrana on 20.06.2023.
//

import Foundation
import CoreData

// MARK: - UserEntity

extension UserEntity {
    static func fetchRequest(_ predicate: NSPredicate) -> NSFetchRequest<UserEntity> {
        let request = NSFetchRequest<UserEntity> (entityName: "UserEntity")
        request.sortDescriptors = [NSSortDescriptor (key: "login", ascending: true)]
        request.predicate = predicate
        return request
    }
}

extension UserEntity {
    static func updateUsersInCoreData(from user: User, context: NSManagedObjectContext) {
        let request = fetchRequest(NSPredicate(format: "login = %@", user.login))
        let results = (try? context.fetch(request)) ?? []
        let newUser = results.first ?? UserEntity(context: context)
        
        newUser.id = Int32(user.id)
        newUser.login = user.login
        newUser.avatarURL = user.avatarURL
        newUser.reposURL = user.reposURL
        
        try? context.save()
    }
}

extension UserEntity {
    var avatarURLFromString: URL? {
        return URL(string: avatarURL ?? "")
    }
}

// MARK: - RepoEntity

extension RepoEntity {
    static func fetchRequest(_ predicate: NSPredicate) -> NSFetchRequest<RepoEntity> {
        let request = NSFetchRequest<RepoEntity> (entityName: "RepoEntity")
        request.sortDescriptors = [NSSortDescriptor (key: "ownerLogin", ascending: true)]
        request.predicate = predicate
        return request
    }
}

extension RepoEntity {
    static func updateReposInCoreData(from repo: Repo, for user: UserEntity, context: NSManagedObjectContext) {
        let request = fetchRequest(NSPredicate(format: "name = %@", repo.name))
        let results = (try? context.fetch(request)) ?? []
        let newRepo = results.last ?? RepoEntity(context: context)
        
        newRepo.ownerLogin = repo.owner.login
        newRepo.name = repo.name
        newRepo.id = Int32(repo.id)
        newRepo.owner = user
        
        try? context.save()
    }
}
