//
//  RecipeDetailViewController.swift
//  ListToDetailPractice
//
//  Created by Levi Davis on 9/11/20.
//  Copyright © 2020 Levi Davis. All rights reserved.
//

import UIKit

class RecipeDetailViewController: UIViewController {
    
    var recipe: Recipe?
    
    lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        return imageView
    }()
    
    lazy var titleLabel: UILabel = {
        let label = UILabel()
        return label
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        addSubviews()
        constrainSubviews()
        setUpView()
    }
    
    private func setUpView() {
        guard let recipe = recipe else {return}
        titleLabel.text = recipe.title
        ImageFetcher.shared.getImage(recipe: recipe) { (result) in
            switch result {
            case .failure(let error):
                print(error)
            case .success(let image):
                DispatchQueue.main.async {[weak self] in
                    self?.imageView.image = image
                }
            }
        }
    }
}

extension RecipeDetailViewController {
    private func addSubviews() {
        view.addSubview(imageView)
        view.addSubview(titleLabel)
    }
    
    private func constrainSubviews() {
        constrainImageView()
        constrainTitleLabel()
    }
    
    private func constrainImageView() {
        imageView.translatesAutoresizingMaskIntoConstraints = false
        [imageView.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
         imageView.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor),
         imageView.heightAnchor.constraint(equalToConstant: 250),
         imageView.widthAnchor.constraint(equalToConstant: 350)].forEach{$0.isActive = true}
    }
    
    private func constrainTitleLabel() {
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        [titleLabel.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
         titleLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 20)].forEach{$0.isActive = true}
    }
}
