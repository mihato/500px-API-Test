//
//  PhotosCollectionViewController.swift
//  500px API Test
//
//  Created by Michail Grebionkin on 10.02.17.
//  Copyright © 2017 mihato. All rights reserved.
//

import UIKit

private let reuseIdentifier = "Cell"

class PhotosCollectionViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout, PhotosViewModelObserver {
    
    var viewModel: PhotosViewModel?

    var activityIndicator: UIView?
    
    var itemsInRow = 2
    
    var loadingImages = [URL: IndexPath]()
    
    deinit {
        ImageLoader().cancelLoading(urls: Array(self.loadingImages.keys))
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.collectionView?.register(UINib(nibName: "PhotoCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: reuseIdentifier)

        guard let viewModel = self.viewModel else {
            assertionFailure()
            let _ = self.navigationController?.popViewController(animated: true)
            return
        }
        self.title = viewModel.title
        
        self.activityIndicator = {
            let indicator = UIActivityIndicatorView(activityIndicatorStyle: .gray)
            indicator.translatesAutoresizingMaskIntoConstraints = false
            indicator.startAnimating()
            
            let bounds = self.collectionView?.bounds ?? CGRect.zero
            let view = UIView(frame: CGRect(x: 0, y: 0, width: bounds.width, height: indicator.bounds.height * 2))
            view.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(indicator)
            indicator.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
            view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-(space)-[view]-(space)-|", options: [], metrics: ["space": indicator.bounds.height / 2], views: ["view": indicator]))
            return view
        }()
        
        viewModel.observer = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        guard let viewModel = self.viewModel else {
            assertionFailure()
            let _ = self.navigationController?.popViewController(animated: true)
            return
        }
        viewModel.observer = self
        if !viewModel.isDataLoaded {
            self.showActivityIndicator()
            viewModel.loadNextPage()
        }
    }

    func showActivityIndicator() {
        guard let indicator = self.activityIndicator, indicator.superview == nil else {
            return
        }
        self.collectionView?.addSubview(indicator)
        self.collectionView?.trailingAnchor.constraint(equalTo: indicator.trailingAnchor).isActive = true
        self.collectionView?.leadingAnchor.constraint(equalTo: indicator.leadingAnchor).isActive = true
        self.collectionView?.centerXAnchor.constraint(equalTo: indicator.centerXAnchor).isActive = true
        self.collectionView?.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-(space)-[view]", options: [], metrics: ["space": self.collectionView?.contentSize.height ?? 0], views: ["view": indicator]))
        let insets = self.collectionView?.contentInset ?? UIEdgeInsets.zero
        self.collectionView?.contentInset = UIEdgeInsets(top: insets.top, left: insets.left, bottom: insets.bottom + indicator.bounds.height * 2, right: insets.right)
    }
    
    func hideActivityIndicator() {
        guard let indicator = self.activityIndicator else {
            return
        }
        indicator.removeFromSuperview()
        let insets = self.collectionView?.contentInset ?? UIEdgeInsets.zero
        self.collectionView?.contentInset = UIEdgeInsets(top: insets.top, left: insets.left, bottom: insets.bottom - indicator.bounds.height * 2, right: insets.right)
    }
    
    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "show",
            let viewController = segue.destination as? PhotoViewController,
            let indexPath = self.collectionView?.indexPathsForSelectedItems?.first,
            let photo = self.viewModel?.photo(atIndex: indexPath.item) {
            viewController.viewModel = PhotoViewModel(photo: photo)
        }
    }
    
    // MARK: -
    
    func viewModel(_ viewModel: PhotosViewModel, didLoadItems count: Int) {
        DispatchQueue.main.async {
            self.hideActivityIndicator()
            guard let viewModel = self.viewModel else {
                self.collectionView?.reloadData()
                return
            }
            let paths = (viewModel.numberOfItems - count ..< viewModel.numberOfItems).map({ IndexPath(item: $0, section: 0) })
            self.collectionView?.performBatchUpdates({ 
                self.collectionView?.insertItems(at: paths)
                }, completion: nil)
        }
    }
    
    func viewModel(_ viewModel: PhotosViewModel, failed: Error) {
        DispatchQueue.main.async {
            self.hideActivityIndicator()
            let alert = UIAlertController(title: NSLocalizedString("Error", comment: ""),
                                          message: NSLocalizedString("An error occurred during loading. Please, try again.", comment: ""),
                                          preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }

    // MARK: UICollectionViewDataSource

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.viewModel?.numberOfItems ?? 0
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! PhotoCollectionViewCell
    
        guard let viewModel = self.viewModel else {
            return cell
        }
        cell.titleLabel?.text = viewModel.title(atIndex: indexPath.item)
        cell.subtitleLabel?.text = viewModel.subtitle(atIndex: indexPath.item)
        if let images = viewModel.images(atIndex: indexPath.item), let photo = images.first {
            let loader = ImageLoader()
            if let image = loader.pictureFromCache(photo: photo) {
                cell.imageView?.image = image
            } else {
                self.loadingImages[photo.secureUrl] = indexPath
                loader.load(photo: photo, completionHandler: { (photo, image, error) in
                    guard let _ = image, let _indexPath = self.loadingImages[photo.secureUrl] else {
                        return
                    }
                    defer {
                        self.loadingImages.removeValue(forKey: photo.secureUrl)
                    }
                    DispatchQueue.main.async {
                        self.collectionView?.reloadItems(at: [_indexPath])
                    }
                })
            }
        }
        // shadow gradient frame correction
        cell.setNeedsLayout()
        cell.layoutIfNeeded()
    
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        guard let view = self.view else {
            return CGSize(width: 50, height: 50)
        }
        let sectionInset: UIEdgeInsets
        let inrowSpace: CGFloat
        if let layout = collectionViewLayout as? UICollectionViewFlowLayout {
            sectionInset = layout.sectionInset
            inrowSpace = layout.minimumInteritemSpacing
        } else {
            sectionInset = UIEdgeInsets.zero
            inrowSpace = 0
        }
        let width = (view.bounds.width - sectionInset.left - sectionInset.right - CGFloat(self.itemsInRow - 1) * inrowSpace) / CGFloat(self.itemsInRow)
        return CGSize(width: width, height: width)
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.performSegue(withIdentifier: "show", sender: nil)
    }
    
    // MARK: -
    
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let y = scrollView.contentOffset.y + scrollView.bounds.size.height - scrollView.contentInset.bottom
        let h = scrollView.contentSize.height
        let reload_distance = CGFloat(40)
        if let viewModel = self.viewModel,
            y > h + reload_distance && h > scrollView.bounds.size.height && viewModel.moreDataAvailable && !viewModel.isLoading {
            self.showActivityIndicator()
            viewModel.loadNextPage()
        }
    }
    
    
    // MARK: UICollectionViewDelegate

    /*
    // Uncomment this method to specify if the specified item should be highlighted during tracking
    override func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment this method to specify if the specified item should be selected
    override func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
    override func collectionView(_ collectionView: UICollectionView, shouldShowMenuForItemAt indexPath: IndexPath) -> Bool {
        return false
    }

    override func collectionView(_ collectionView: UICollectionView, canPerformAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) -> Bool {
        return false
    }

    override func collectionView(_ collectionView: UICollectionView, performAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) {
    
    }
    */

}
