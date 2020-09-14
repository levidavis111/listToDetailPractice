//
//  RecipeCollectionViewController.swift
//  ListToDetailPractice
//
//  Created by Levi Davis on 9/11/20.
//  Copyright © 2020 Levi Davis. All rights reserved.
//

import UIKit
private enum ReuseIdentifiers: String {
    case recipeCell
}
class RecipeCollectionViewController: UIViewController {
    
    var recipes = [Recipe]() {
        didSet {
            DispatchQueue.main.async {[weak self] in
                self?.checkEmpty()
                self?.collectionView.reloadData()
            }
        }
    }
    
    var favedRecipes = [Recipe]() {
        didSet {
            DispatchQueue.main.async {[weak self] in
                self?.collectionView.reloadData()
            }
        }
    }
    
    var searchTerm: String = ""
    
    private lazy var searchBar: UISearchBar = {
        let searchBar = UISearchBar()
        searchBar.delegate = self
        searchBar.showsCancelButton = true
        return searchBar
    }()
    
    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout.init()
        layout.scrollDirection = .vertical
        layout.itemSize = CGSize(width: self.view.frame.width, height: 150)
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(RecipeCollectionViewCell.self, forCellWithReuseIdentifier: ReuseIdentifiers.recipeCell.rawValue)
        return collectionView
    }()
    
    private lazy var emptylabel: UILabel = {
        let label = UILabel()
        label.text = "Please search for recipes!"
        label.font = UIFont(descriptor: .preferredFontDescriptor(withTextStyle: .largeTitle), size: 22)
        label.textColor = .black
        label.textAlignment = .center
        label.isHidden = true
        return label
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .lightGray
        addSubviews()
        constrainSubviews()
        checkEmpty()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        getFavedRecipes()
    }
    
    private func getData(searchTerm: String) {
        RecipeFetcher.shared.getRecipes(searchTerm: searchTerm) { (result) in
            switch result {
            case .failure(let error):
                print(error)
            case .success(let results):
                DispatchQueue.main.async {[weak self] in
                    self?.recipes = results
                }
            }
        }
    }
    
    private func getFavedRecipes() {
        do {
            favedRecipes = try RecipePersistenceManager.shared.getRecipes()
        } catch {
            print(error)
        }
    }

    private func checkEmpty() {
        if recipes.count == 0 {
            collectionView.isHidden = true
            emptylabel.isHidden = false
        } else {
            collectionView.isHidden = false
            emptylabel.isHidden = true
        }
    }
    
    private func saveRecipetoFaves(recipe: Recipe) {
        do {
            try RecipePersistenceManager.shared.saveRecipe(recipe)
            getFavedRecipes()
        } catch {
            print(error)
        }
    }
    
    private func deleteFavedRecipe(index: Int) {
        do {
            try RecipePersistenceManager.shared.deleteRecipe(favedRecipes, index: index)
            getFavedRecipes()
        } catch {
            print(error)
        }
    }
}

extension RecipeCollectionViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return recipes.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ReuseIdentifiers.recipeCell.rawValue, for: indexPath) as? RecipeCollectionViewCell else {return UICollectionViewCell()}
        let recipe = recipes[indexPath.row]
        let favedImage = UIImage(systemName: "heart.fill")
        let unfavedImage = UIImage(systemName: "heart")
        cell.setupCell(recipe: recipe)
        recipe.isSaved == true ? cell.likeButton.setImage(favedImage, for: .normal) : cell.likeButton.setImage(unfavedImage, for: .normal)
        cell.saveAction = {
            switch recipe.isSaved {
            case true:
                if let index = self.favedRecipes.firstIndex(where: {$0.id == recipe.id}) {
                    self.deleteFavedRecipe(index: index)
                }
            case false:
                self.saveRecipetoFaves(recipe: recipe)
            }
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let detailVC = RecipeDetailViewController()
        detailVC.recipe = recipes[indexPath.row]
        navigationController?.pushViewController(detailVC, animated: true)
    }
}

extension RecipeCollectionViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let text = searchBar.text else {checkEmpty(); return}
        guard text != "" else {checkEmpty(); return}
        getData(searchTerm: text)
        searchBar.resignFirstResponder()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
}

extension RecipeCollectionViewController {
    private func addSubviews() {
        view.addSubview(searchBar)
        view.addSubview(collectionView)
        view.addSubview(emptylabel)
    }
    
    private func constrainSubviews() {
        constrainSearchBar()
        constrainCollectionView()
        constrainEmptyLabel()
    }
    
    private func constrainSearchBar() {
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        [searchBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
         searchBar.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
         searchBar.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor)].forEach{$0.isActive = true}
    }
    
    private func constrainCollectionView() {
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        [collectionView.topAnchor.constraint(equalTo: searchBar.bottomAnchor),
         collectionView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
         collectionView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
         collectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)].forEach{$0.isActive = true}
    }
    
    private func constrainEmptyLabel() {
        emptylabel.translatesAutoresizingMaskIntoConstraints = false
        [emptylabel.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
         emptylabel.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor)].forEach{$0.isActive = true}
    }
}
