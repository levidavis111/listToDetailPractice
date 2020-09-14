//
//  ImageFetcher.swift
//  ListToDetailPractice
//
//  Created by Levi Davis on 9/11/20.
//  Copyright © 2020 Levi Davis. All rights reserved.
//

import UIKit

enum ImageError: Error {
    case badURL
    case errorReturned
    case badResponse
    case badData
    case jsonParsingError
    case imageError
}

struct ImageFetcher {
    static let shared = ImageFetcher()
    func getImage(recipe: Recipe, completion: @escaping (Result<UIImage, ImageError>) -> ()) {
        guard let url = URL(string: "https://spoonacular.com/recipeImages/\(recipe.id)-240x150.jpg") else {completion(.failure(.badURL)); return}
        
        let session = URLSession(configuration: .default)
        session.dataTask(with: url) { (data, response, error) in
            guard error == nil else {completion(.failure(.errorReturned)); return}
            guard let response = response as? HTTPURLResponse,
                Set(200...299).contains(response.statusCode) else {completion(.failure(.badResponse)); return}
            guard let data = data else {completion(.failure(.badData)); return}
            guard let image = UIImage(data: data) else {completion(.failure(.imageError)); return}
            completion(.success(image))
        }.resume()
    }
}
