//
//  RecipePersistenceManager.swift
//  ListToDetailPractice
//
//  Created by Levi Davis on 9/11/20.
//  Copyright © 2020 Levi Davis. All rights reserved.
//

import Foundation

struct RecipePersistenceManager {
    static let shared = RecipePersistenceManager()
    private let persistenceHelper = PersistenceHelper<Recipe>(fileName: "recipe.plist")
    
    func getRecipes() throws -> [Recipe] {
        try persistenceHelper.getObjects()
    }
    
    func saveRecipe(_ recipe: Recipe) throws {
        try persistenceHelper.save(newElement: recipe)
    }
    
    func deleteRecipe(_ recipes: [Recipe], index: Int) throws {
        try persistenceHelper.delete(elements: recipes, index: index)
    }
    
}
