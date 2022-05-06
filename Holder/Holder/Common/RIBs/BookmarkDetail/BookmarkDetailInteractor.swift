//
//  BookmarkDetailInteractor.swift
//  Holder
//
//  Created by Yeojin Yoon on 2022/03/11.
//

import LinkPresentation
import RIBs

protocol BookmarkDetailRouting: ViewableRouting {
    func attachBookmarkDetailSheet()
    func detachBookmarkDetailSheet()
}

protocol BookmarkDetailPresentable: Presentable {
    var listener: BookmarkDetailPresentableListener? { get set }
    func load(from url: URL)
    func updateToolbar(for isFavorite: Bool)
    func displayShareSheet(with metadata: LPLinkMetadata)
    func reload()
    func displayAlert(title: String, message: String?, action: Action?)
    func dismiss(_ completion: @escaping () -> Void)
}

protocol BookmarkDetailListener: AnyObject {
    func bookmarkDetailDidRemove()
    func bookmarkDetailBackwardButtonDidTap()
    func bookmarkDetailEditActionDidTap(bookmark: Bookmark)
    func bookmarkDetailDidRequestToDetach()
}

protocol BookmarkDetailInteractorDependency {
    var bookmark: Bookmark { get }
}

final class BookmarkDetailInteractor: PresentableInteractor<BookmarkDetailPresentable>, BookmarkDetailInteractable, BookmarkDetailPresentableListener {
    
    weak var router: BookmarkDetailRouting?
    weak var listener: BookmarkDetailListener?
    
    private let bookmarkRepository = BookmarkRepository.shared
    private let dependency: BookmarkDetailInteractorDependency
    
    private var bookmark: Bookmark { dependency.bookmark }
    
    init(presenter: BookmarkDetailPresentable, dependency: BookmarkDetailInteractorDependency) {
        self.dependency = dependency
        super.init(presenter: presenter)
        presenter.listener = self
    }
    
    override func didBecomeActive() {
        super.didBecomeActive()
        loadView()
    }
    
    override func willResignActive() {
        super.willResignActive()
    }
    
    func backwardButtonDidTap() {
        listener?.bookmarkDetailBackwardButtonDidTap()
    }
    
    func shareButtonDidTap() {
        LPMetadataProvider().startFetchingMetadata(for: bookmark.url) { metadata, _ in
            guard let metadata = metadata else { return }
            self.presenter.displayShareSheet(with: metadata)
        }
    }
    
    func favoriteButtonDidTap() {
        let result = bookmarkRepository.updateFavorites(for: bookmark.url)
        switch result {
        case .success(let isFavorite): presenter.updateToolbar(for: isFavorite)
        case .failure(_): NotificationCenter.post(named: NotificationName.didFailToProcessData)
        }
    }
    
    func showMoreButtonDidTap() {
        router?.attachBookmarkDetailSheet()
    }
    
    func didRemove() {
        listener?.bookmarkDetailDidRemove()
    }
    
    func bookmarkDetailSheetReloadActionDidTap() {
        router?.detachBookmarkDetailSheet()
        presenter.reload()
    }
    
    func bookmarkDetailSheetEditActionDidTap() {
        router?.detachBookmarkDetailSheet()
        listener?.bookmarkDetailEditActionDidTap(bookmark: bookmark)
    }
    
    func bookmarkDetailSheetDeleteActionDidTap() {
        let action = Action(title: LocalizedString.ActionTitle.delete) { [weak self] in
            self?.presenter.dismiss { self?.deleteBookmark() }
        }
        router?.detachBookmarkDetailSheet()
        presenter.displayAlert(title: LocalizedString.AlertTitle.deleteBookmark,
                               message: LocalizedString.AlertMessage.deleteBookmark,
                               action: action)
    }
    
    func bookmarkDetailSheetDidRequestToDetach() {
        router?.detachBookmarkDetailSheet()
    }
    
    private func loadView() {
        presenter.load(from: bookmark.url)
        presenter.updateToolbar(for: bookmark.isFavorite)
    }
    
    private func deleteBookmark() {
        let result = bookmarkRepository.delete(for: bookmark.url)
        switch result {
        case .success(()): listener?.bookmarkDetailDidRequestToDetach()
        case .failure(_): NotificationCenter.post(named: NotificationName.didFailToProcessData)
        }
    }
}
