//
//  Recipe.swift
//  ListToDetailPractice
//
//  Created by Levi Davis on 9/11/20.
//  Copyright © 2020 Levi Davis. All rights reserved.
//

import Foundation

struct RecipeWrapper: Codable {
    let results: [Recipe]
}

struct Recipe: Codable {
    let id: Int
    let image: String
    let title: String
    
    var isSaved: Bool {
        guard let savedRecipes = try? RecipePersistenceManager.shared.getRecipes() else {return false}
        if savedRecipes.contains(where: {$0.id == self.id}) {
            return true
        }
        
        return false
    }
}

enum AppError: Error {
    case badURL
    case errorReturned
    case badResponse
    case badData
    case jsonParsingError
}

struct RecipeFetcher {
    static let shared = RecipeFetcher()
    
    func getRecipes(searchTerm: String, completion: @escaping (Result<[Recipe], AppError>) -> ()) {
        guard var urlComponents = URLComponents(string: "https://api.spoonacular.com/recipes/search") else {completion(.failure(.badURL)); return}
        urlComponents.queryItems = [
            URLQueryItem(name: "query", value: searchTerm),
            URLQueryItem(name: "number", value: "6"),
            URLQueryItem(name: "apiKey", value: Secret.recipeAPIKey)
        ]
        guard let url = urlComponents.url else {completion(.failure(.badURL)); return}
        
        let session = URLSession(configuration: .default)
        session.dataTask(with: url) { (data, response, error) in
            guard error == nil else {completion(.failure(.errorReturned)); return}
            guard let response = response as? HTTPURLResponse,
                Set(200...299).contains(response.statusCode) else {completion(.failure(.badResponse)); return}
            guard let data = data else {completion(.failure(.badData)); return}
            
            do {
                let results = try JSONDecoder().decode(RecipeWrapper.self, from: data).results
                completion(.success(results))
            } catch {
                completion(.failure(.jsonParsingError))
            }
            
        }.resume()
    }
    
}
