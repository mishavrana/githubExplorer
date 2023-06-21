//
//  UserView.swift
//  GithubExplorer
//
//  Created by Misha Vrana on 20.06.2023.
//

import SwiftUI

struct UserRowView: View {
    let user: UserEntity
    
    var body: some View {
        HStack(spacing: 10) {
            Text("\(user.id)").monospacedDigit()
            
            AsyncImage(url: user.avatarURLFromString) { image in
                image
                    .resizable()
                    .scaledToFit()
                    .frame(width: 32, height: 32)
                    .clipShape(Circle())
            } placeholder: {
                Circle()
                    .frame(width: 32, height: 32)
                    .background(Color(.systemGray5))
            }
            
            Text(user.login ?? "")
        }
    }
}
