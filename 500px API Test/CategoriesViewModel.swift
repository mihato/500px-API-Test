//
//  CategoriesViewModel.swift
//  500px API Test
//
//  Created by Michail Grebionkin on 09.02.17.
//  Copyright © 2017 mihato. All rights reserved.
//

import Foundation

class CategoriesViewModel {
    
    var categories: [Category] = [
        .uncategorized, .abstract, .animals, .blackAndWhite,
        .celebrities, .cityAndArchitecture, .commercial, .concert,
        .family, .fashion, .film, .fineArt, .food, .journalism,
        .landscapes, .macro, .nature, .nude, .people, .performingArts,
        .sport, .stillLife, .street, .transportation, .travel,
        .underwater, .urbarExploration, .wedding
    ]
    
    var numberOfItems: Int {
        return self.categories.count
    }
    
    func category(atIndex index: Int) -> Category? {
        guard index >= 0, index < self.numberOfItems else {
            return nil
        }
        return self.categories[index]
    }
    
    func title(atIndex index: Int) -> String? {
        return self.category(atIndex: index)?.rawValue
    }
    
}
