//
//  PhotoViewModel.swift
//  500px API Test
//
//  Created by Michail Grebionkin on 13.02.17.
//  Copyright © 2017 mihato. All rights reserved.
//

import Foundation

protocol PhotoViewModelObserver: class {
    func viewModel(_ viewModel: PhotoViewModel, didFinishLoading error: Error?)
}

class PhotoViewModel {
    
    var dispatcher = Dispatcher.default
    
    var photo: Photo?
    
    let photoId: Int
    
    fileprivate var loadingRequest: Request?
    
    var isLoading: Bool {
        return self.loadingRequest != nil
    }
    
    var isDataLoaded: Bool {
        return self.photo != nil
    }
    
    weak var observer: PhotoViewModelObserver?
    
    init(photo: Photo) {
        self.photoId = photo.id
        self.load()
    }
    
    func load() {
        guard self.loadingRequest == nil else {
            return
        }
        var request = GetPhotoRequest(id: self.photoId)
        request.onSuccess = { data in
            self.loadingRequest = nil
            guard let photoData = data["photo"] as? [String: Any],
                let photo = Photo(data: photoData) else {
                    self.observer?.viewModel(self, didFinishLoading: PXError.unexpectedResponse)
                    return
            }
            self.photo = photo
            self.observer?.viewModel(self, didFinishLoading: nil)
        }
        request.onError = { error in
            self.loadingRequest = nil
            self.observer?.viewModel(self, didFinishLoading: error)
        }
        self.loadingRequest = request
        self.dispatcher.perform(request: request)
    }
    
    func title() -> String? {
        return self.photo?.name
    }
    
    func subtitle() -> String? {
        return self.photo?.user.fullName
    }
    
    func images() -> [PhotoImage]? {
        return self.photo?.images
    }
    
}
