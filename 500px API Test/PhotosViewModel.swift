//
//  PhotosViewModel.swift
//  500px API Test
//
//  Created by Michail Grebionkin on 10.02.17.
//  Copyright © 2017 mihato. All rights reserved.
//

import Foundation

protocol PhotosViewModelObserver: class {
    func viewModel(_ viewModel: PhotosViewModel, didLoadItems count: Int)
    func viewModel(_ viewModel: PhotosViewModel, failed: Error)
}

class PhotosViewModel {
    
    var dispatcher = Dispatcher.default
    
    weak var observer: PhotosViewModelObserver?
    
    var page = 0
    
    var totalPages = 0
    
    var moreDataAvailable: Bool {
        return self.page < self.totalPages - 1
    }
    
    var perpage = 20
    
    var category: Category
    
    var photos = [Photo]()
    
    var numberOfItems: Int {
        return self.photos.count
    }
    
    var title: String {
        return self.category.rawValue
    }
    
    private(set) var isLoading = false
    
    private(set) var isDataLoaded = false
    
    init(category: Category) {
        self.category = category
    }
    
    func loadNextPage() {
        if self.isLoading {
            return
        }
        self.isLoading = true
        var request = GetPhotosListRequest(feature: .popular, page: self.page + 1)
        request.includeCategories = [self.category]
        request.perPage = self.perpage
        request.includePhotoSizes = [.crop600]
        request.onError = { error in
            self.isLoading = false
            self.observer?.viewModel(self, failed: error)
        }
        request.onSuccess = { data in
            self.isDataLoaded = true
            self.isLoading = false
            guard let currentPage = data["current_page"] as? Int,
                let totalPages = data["total_pages"] as? Int,
                let photosData = data["photos"] as? [[String: Any]] else {
                    self.observer?.viewModel(self, failed: PXError.unexpectedResponse)
                    return
            }
            self.page = currentPage
            self.totalPages = totalPages
            var itemsLoaded = 0
            for photoData in photosData {
                if let photo = Photo(data: photoData) {
                    itemsLoaded += 1
                    self.photos.append(photo)
                }
            }
            self.observer?.viewModel(self, didLoadItems: itemsLoaded)
        }
        self.dispatcher.perform(request: request)
    }
    
    func photo(atIndex index: Int) -> Photo? {
        guard index >= 0, index < self.numberOfItems else {
            return nil
        }
        return self.photos[index]
    }
    
    func title(atIndex index: Int) -> String? {
        return self.photo(atIndex: index)?.name
    }
    
    func subtitle(atIndex index: Int) -> String? {
        return self.photo(atIndex: index)?.user.fullName
    }
    
    func images(atIndex index: Int) -> [PhotoImage]? {
        return self.photo(atIndex: index)?.images
    }
    
}
