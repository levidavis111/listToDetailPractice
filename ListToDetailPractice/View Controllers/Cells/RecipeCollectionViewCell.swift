//
//  RecipeCollectionViewCell.swift
//  ListToDetailPractice
//
//  Created by Levi Davis on 9/11/20.
//  Copyright © 2020 Levi Davis. All rights reserved.
//

import UIKit

class RecipeCollectionViewCell: UICollectionViewCell {
    
    lazy var recipeImageView: UIImageView = {
        let imageView = UIImageView()
        return imageView
    }()
    
    lazy var recipeTitleLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        return label
    }()
    
    lazy var likeButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "heart"), for: .normal)
        button.addTarget(self, action: #selector(likeButtonPressed), for: .touchUpInside)
        return button
    }()
    
    var saveAction: (() -> ())?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.backgroundColor = .white
        addSubviews()
        constrainSubviews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func likeButtonPressed() {
        print("pressed")
        guard let saveAction = saveAction else {return}
        saveAction()
        if likeButton.image(for: .normal) == UIImage(systemName: "heart") {
            likeButton.setImage(UIImage(systemName: "heart.fill"), for: .normal)
        } else {
            likeButton.setImage(UIImage(systemName: "heart"), for: .normal)
        }
    }
    
    func setupCell(recipe: Recipe) {
        self.recipeTitleLabel.text = recipe.title
        ImageFetcher.shared.getImage(recipe: recipe) { (result) in
            switch result {
            case .failure(let error):
                print(error)
            case .success(let image):
                DispatchQueue.main.async {
                    self.recipeImageView.image = image
                }
            }
        }
    }
}

extension RecipeCollectionViewCell {
    private func addSubviews() {
        contentView.addSubview(recipeImageView)
        contentView.addSubview(recipeTitleLabel)
        contentView.addSubview(likeButton)
    }
    
    private func constrainSubviews() {
        constrainImageView()
        constrainRecipeLabel()
        constrainLikeButton()
    }
    
    private func constrainImageView() {
        recipeImageView.translatesAutoresizingMaskIntoConstraints = false
        [recipeImageView.centerYAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.centerYAnchor),
         recipeImageView.heightAnchor.constraint(equalToConstant:  80),
         recipeImageView.leadingAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.leadingAnchor, constant: 5),
         recipeImageView.widthAnchor.constraint(equalToConstant: 125)].forEach{$0.isActive = true}
    }
    
    private func constrainRecipeLabel() {
        recipeTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        [recipeTitleLabel.centerYAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.centerYAnchor),
         recipeTitleLabel.leadingAnchor.constraint(equalTo: recipeImageView.trailingAnchor, constant: 15),
         recipeTitleLabel.trailingAnchor.constraint(equalTo: likeButton.leadingAnchor, constant: -10)].forEach{$0.isActive = true}
    }
    
    private func constrainLikeButton() {
        likeButton.translatesAutoresizingMaskIntoConstraints = false
        [likeButton.topAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.topAnchor, constant: 10),
         likeButton.trailingAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.trailingAnchor, constant: -10),
         likeButton.heightAnchor.constraint(equalToConstant: 30),
         likeButton.widthAnchor.constraint(equalToConstant: 30)].forEach{$0.isActive = true}
    }
}
