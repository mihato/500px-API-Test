//
//  PhotoViewController.swift
//  500px API Test
//
//  Created by Michail Grebionkin on 13.02.17.
//  Copyright © 2017 mihato. All rights reserved.
//

import UIKit

class PhotoViewController: UIViewController, PhotoViewModelObserver {
    
    @IBOutlet var imageView: UIImageView?
    
    @IBOutlet var titleLabel: UILabel?
    
    @IBOutlet var subtitleLabel: UILabel?
    
    @IBOutlet var activityIndicator: UIActivityIndicatorView?
    
    var viewModel: PhotoViewModel?

    override func viewDidLoad() {
        super.viewDidLoad()

        self.titleLabel?.text = ""
        self.subtitleLabel?.text = ""
        self.viewModel?.observer = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        guard let viewModel = self.viewModel else {
            let _ = self.navigationController?.popViewController(animated: true)
            return
        }
        if viewModel.isDataLoaded {
            self.loadImage()
        } else {
            self.activityIndicator?.startAnimating()
            viewModel.load()
        }
    }
    
    func showError() {
        let alert = UIAlertController(title: NSLocalizedString("Error", comment:""),
                                      message: NSLocalizedString("Unfortunately an error occurred during image loading. Please try again later.", comment:""),
                                      preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment:""), style: .default, handler: { (_) in
            let _ = self.navigationController?.popViewController(animated: true)
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    func showData(image: UIImage) {
        self.imageView?.image = image
        guard let viewModel = self.viewModel else {
            return
        }
        self.titleLabel?.text = viewModel.title()
        self.subtitleLabel?.text = viewModel.subtitle()
    }
    
    func loadImage() {
        guard let viewModel = self.viewModel,
            let images = viewModel.images(),
            let photoImage = images.first else {
                self.showError()
                return
        }
        let loader = ImageLoader()
        if let image = loader.pictureFromCache(photo: photoImage) {
            self.showData(image: image)
        } else {
            self.activityIndicator?.startAnimating()
            loader.load(photo: photoImage, completionHandler: { (photoImage, image, error) in
                self.activityIndicator?.stopAnimating()
                if let _ = error {
                    self.showError()
                } else if let image = image {
                    self.showData(image: image)
                }
            })
        }
    }
    
    func viewModel(_ viewModel: PhotoViewModel, didFinishLoading error: Error?) {
        DispatchQueue.main.async {
            self.activityIndicator?.stopAnimating()
            if let _ = error {
                self.showError()
            } else {
                self.loadImage()
            }
        }
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
