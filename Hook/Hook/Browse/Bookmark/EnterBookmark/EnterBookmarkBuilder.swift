//
//  EnterBookmarkBuilder.swift
//  Hook
//
//  Created by Yeojin Yoon on 2022/01/27.
//

import CoreData
import RIBs

protocol EnterBookmarkDependency: Dependency {
    var context: NSManagedObjectContext { get }
    var selectedTagsStream: MutableStream<[Tag]> { get }
}

final class EnterBookmarkComponent: Component<EnterBookmarkDependency>, EnterBookmarkInteractorDependency {
    
    var context: NSManagedObjectContext { dependency.context }
    var selectedTagsStream: MutableStream<[Tag]> { dependency.selectedTagsStream }
}

// MARK: - Builder

protocol EnterBookmarkBuildable: Buildable {
    func build(withListener listener: EnterBookmarkListener) -> EnterBookmarkRouting
}

final class EnterBookmarkBuilder: Builder<EnterBookmarkDependency>, EnterBookmarkBuildable {
    
    override init(dependency: EnterBookmarkDependency) {
        super.init(dependency: dependency)
    }
    
    func build(withListener listener: EnterBookmarkListener) -> EnterBookmarkRouting {
        let component = EnterBookmarkComponent(dependency: dependency)
        let viewController = EnterBookmarkViewController()
        let interactor = EnterBookmarkInteractor(presenter: viewController, dependency: component)
        interactor.listener = listener
        return EnterBookmarkRouter(interactor: interactor, viewController: viewController)
    }
}
