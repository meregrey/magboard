//
//  TagBarViewController.swift
//  Hook
//
//  Created by Yeojin Yoon on 2022/01/07.
//

import RIBs
import UIKit

protocol TagBarPresentableListener: AnyObject {
    func viewDidAppearFirst()
    func tagDidSelect(tag: Tag)
    func tagSettingsButtonDidTap()
}

final class TagBarViewController: UIViewController, TagBarPresentable, TagBarViewControllable {
    
    private var tags: [Tag] = []
    private var isFirstAppeared = true
    
    @AutoLayout private var containerView = UIView()
    
    @AutoLayout private var tagBarCollectionView: UICollectionView = {
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.scrollDirection = .horizontal
        flowLayout.minimumInteritemSpacing = .zero
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: flowLayout)
        collectionView.register(TagBarCollectionViewCell.self)
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.showsVerticalScrollIndicator = false
        collectionView.backgroundColor = .clear
        
        return collectionView
    }()
    
    @AutoLayout private var tagSettingsButton: UIButton = {
        let button = UIButton()
        button.setImage(Image.tagSettingsButton, for: .normal)
        button.imageView?.contentMode = .scaleAspectFit
        button.contentHorizontalAlignment = .fill
        button.contentVerticalAlignment = .fill
        button.tintColor = Asset.Color.primaryColor
        button.addTarget(self, action: #selector(tagSettingsButtonDidTap), for: .touchUpInside)
        return button
    }()
    
    private enum Image {
        static let tagSettingsButton = UIImage(systemName: "ellipsis")
    }
    
    private enum Metric {
        static let containerViewHeight = CGFloat(60)
        
        static let tagBarCollectionViewHeight = containerViewHeight
        static let tagBarCollectionViewLeading = CGFloat(10)
        static let tagBarCollectionViewTrailing = CGFloat(-16)
        
        static let tagSettingsButtonWidthHeight = CGFloat(26)
        static let tagSettingsButtonTrailing = CGFloat(-20)
    }
    
    weak var listener: TagBarPresentableListener?
    
    init() {
        super.init(nibName: nil, bundle: nil)
        configureViews()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        configureViews()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if isFirstAppeared {
            listener?.viewDidAppearFirst()
            isFirstAppeared = false
        }
    }
    
    func update(with tags: [Tag]) {
        self.tags = tags
        DispatchQueue.main.async {
            self.tagBarCollectionView.reloadData()
            self.tagBarCollectionView.selectItem(at: IndexPath(item: 0, section: 0), animated: false, scrollPosition: .left)
        }
    }
    
    func update(with currentTag: Tag) {
        guard let index = tags.firstIndex(of: currentTag) else { return }
        DispatchQueue.main.async {
            self.tagBarCollectionView.selectItem(at: IndexPath(item: index, section: 0), animated: true, scrollPosition: .centeredHorizontally)
        }
    }
    
    private func configureViews() {
        tagBarCollectionView.dataSource = self
        tagBarCollectionView.delegate = self
        
        view.addSubview(containerView)
        containerView.addSubview(tagBarCollectionView)
        containerView.addSubview(tagSettingsButton)
        
        NSLayoutConstraint.activate([
            containerView.widthAnchor.constraint(equalTo: view.widthAnchor),
            containerView.heightAnchor.constraint(equalToConstant: Metric.containerViewHeight),
            containerView.topAnchor.constraint(equalTo: view.topAnchor),
            containerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            containerView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            tagBarCollectionView.heightAnchor.constraint(equalToConstant: Metric.tagBarCollectionViewHeight),
            tagBarCollectionView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: Metric.tagBarCollectionViewLeading),
            tagBarCollectionView.trailingAnchor.constraint(equalTo: tagSettingsButton.leadingAnchor, constant: Metric.tagBarCollectionViewTrailing),
            tagBarCollectionView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            
            tagSettingsButton.widthAnchor.constraint(equalToConstant: Metric.tagSettingsButtonWidthHeight),
            tagSettingsButton.heightAnchor.constraint(equalToConstant: Metric.tagSettingsButtonWidthHeight),
            tagSettingsButton.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: Metric.tagSettingsButtonTrailing),
            tagSettingsButton.centerYAnchor.constraint(equalTo: containerView.centerYAnchor)
        ])
    }
    
    @objc
    private func tagSettingsButtonDidTap() {
        listener?.tagSettingsButtonDidTap()
    }
}

extension TagBarViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return tags.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: TagBarCollectionViewCell = collectionView.dequeueReusableCell(for: indexPath)
        cell.configure(with: tags[indexPath.item])
        return cell
    }
}

extension TagBarViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        listener?.tagDidSelect(tag: tags[indexPath.row])
        collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
    }
}

extension TagBarViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        return TagBarCollectionViewCell.fittingSize(with: tags[indexPath.item], height: Metric.containerViewHeight)
    }
}
