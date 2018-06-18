//
//  VPMonthDisplayCollectionViewCell.swift
//  VPCalendarExample
//
//  Created by Varun P M on 08/03/18.
//  Copyright © 2018 Varun P M. All rights reserved.
//

import UIKit

class VPMonthDisplayCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var monthDisplayCollectionView: UICollectionView!
    
    let monthDisplayVM = VPMonthDisplayVM()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        monthDisplayVM.registerCells(forCollectionView: monthDisplayCollectionView)
    }
}

extension VPMonthDisplayCollectionViewCell: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return monthDisplayVM.numberOfItems(in: collectionView)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        return monthDisplayVM.dayDisplayCell(in: collectionView, atIndexPath: indexPath)
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        return monthDisplayVM.monthHeaderView(in: collectionView, atIndexPath: indexPath)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return monthDisplayVM.sizeForDayDisplayCell(in: collectionView, withMaxSize: bounds.size)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return monthDisplayVM.sizeForMonthHeaderView(in: collectionView, withMaxSize: bounds.size)
    }
}
