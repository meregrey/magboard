//
//  FavoritesViewController.swift
//  Hook
//
//  Created by Yeojin Yoon on 2022/01/02.
//

import RIBs
import UIKit

protocol FavoritesPresentableListener: AnyObject {}

final class FavoritesViewController: UIViewController, FavoritesPresentable, FavoritesViewControllable, NavigationRootViewControllable {
    
    private enum Image {
        static let tabBarItem = UIImage(systemName: "bookmark")
        static let tabBarItemSelected = UIImage(systemName: "bookmark.fill")
    }

    weak var listener: FavoritesPresentableListener?
    
    init() {
        super.init(nibName: nil, bundle: nil)
        configureViews()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        configureViews()
    }
    
    func popGestureDidRecognize() {}
    
    private func configureViews() {
        title = LocalizedString.ViewTitle.favorites
        tabBarItem = UITabBarItem(title: nil,
                                  image: Image.tabBarItem,
                                  selectedImage: Image.tabBarItemSelected)
    }
}
