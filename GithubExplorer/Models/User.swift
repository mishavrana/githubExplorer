//
//  User.swift
//  GithubExplorer
//
//  Created by Misha Vrana on 19.06.2023.
//

import Foundation

struct User: Identifiable, Codable {
    let login: String
    let id: Int
    let nodeID: String
    let avatarURL: String
    let gravatarID: String
    let url, htmlURL, followersURL: String
    let followingURL, gistsURL, starredURL: String
    let subscriptionsURL, organizationsURL, reposURL: String
    let eventsURL: String
    let receivedEventsURL: String
    let type: UserTypeEnum
    let siteAdmin: Bool

        enum CodingKeys: String, CodingKey {
            case login, id
            case nodeID = "node_id"
            case avatarURL = "avatar_url"
            case gravatarID = "gravatar_id"
            case url
            case htmlURL = "html_url"
            case followersURL = "followers_url"
            case followingURL = "following_url"
            case gistsURL = "gists_url"
            case starredURL = "starred_url"
            case subscriptionsURL = "subscriptions_url"
            case organizationsURL = "organizations_url"
            case reposURL = "repos_url"
            case eventsURL = "events_url"
            case receivedEventsURL = "received_events_url"
            case type
            case siteAdmin = "site_admin"
        }
    
    var avatarURLFromString: URL? {
        return URL(string: avatarURL)
    }
}

enum UserTypeEnum: String, Codable {
    case organization = "Organization"
    case user = "User"
}

extension User {
    static let sample = User(
        login: "mojombo",
        id: 1,
        nodeID: "",
        avatarURL: "",
        gravatarID: "",
        url: "",
        htmlURL: "",
        followersURL: "",
        followingURL: "",
        gistsURL: "",
        starredURL: "",
        subscriptionsURL: "",
        organizationsURL: "",
        reposURL: "",
        eventsURL: "",
        receivedEventsURL: "",
        type: .user,
        siteAdmin: false
    )
}
