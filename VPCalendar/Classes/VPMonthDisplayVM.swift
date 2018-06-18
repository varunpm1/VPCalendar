//
//  VPMonthDisplayVM.swift
//  VPCalendarExample
//
//  Created by Varun P M on 08/06/18.
//  Copyright © 2018 Varun P M. All rights reserved.
//

import UIKit

class VPMonthDisplayVM: VPCalendarViewProtocol {
    // Protocol confirming variables
    var dateDisplayColor: UIColor = UIColor.black
    var currentDateDisplayColor: UIColor = UIColor.red
    
    /// Month of the corresponding year. Starts from January.
    var month: VPMonth = .january
    
    /// Year index of the corresponding calendar.
    var yearIndex: Int = 0
    
    private var weekDay: Int = 0
    private var numberOfItems: Int = 0
    private let numberOfDaysInWeek: Int = 7
    private let headerHeight: CGFloat = 24
    
    func registerCells(forCollectionView collectionView: UICollectionView) {
        collectionView.register(UINib(nibName: String(describing: VPDayDisplayCollectionViewCell.self), bundle: Bundle(for: VPCalendarView.self)), forCellWithReuseIdentifier: String(describing: VPDayDisplayCollectionViewCell.self))
        collectionView.register(UINib(nibName: String(describing: VPMonthDisplayCollectionReusableView.self), bundle: Bundle(for: VPCalendarView.self)), forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: String(describing: VPMonthDisplayCollectionReusableView.self))
    }
    
    func updateItemCount(forCollectionView collectionView: UICollectionView) {
        // Add empty cells before the week day items count
        weekDay = DateHelper.shared().weekDay(inMonth: month.rawValue, andYear: yearIndex) - 1 // For 0 indexing
        numberOfItems = DateHelper.shared().days(inMonth: month.rawValue, andYear: yearIndex) + weekDay
        collectionView.reloadData()
    }
    
    func numberOfItems(in collectionView: UICollectionView) -> Int {
        return numberOfItems
    }
    
    func dayDisplayCell(in collectionView: UICollectionView, atIndexPath indexPath: IndexPath) -> VPDayDisplayCollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: String(describing: VPDayDisplayCollectionViewCell.self), for: indexPath) as! VPDayDisplayCollectionViewCell
        
        // Customize UI
        cell.currentDateDisplayView.layer.masksToBounds = true
        cell.currentDateDisplayView.layer.cornerRadius = min(cell.bounds.size.width / 2, cell.bounds.size.height / 2)
        cell.currentDateDisplayView.backgroundColor = UIColor.white
        cell.dayDisplayLabel.textColor = dateDisplayColor
        
        if DateHelper.shared().isCurrentDate(forYear: yearIndex, forMonth: month.rawValue, forDay: (indexPath.item + 1 - weekDay)) {
            cell.currentDateDisplayView.backgroundColor = currentDateDisplayColor
            cell.dayDisplayLabel.textColor = UIColor.white
        }
        
        // If the current cell is a dummy cell, then do not set any text. Else set the proper text
        let actualDay = indexPath.item - (weekDay - 1)
        if actualDay <= 0 {
            cell.dayDisplayLabel.text = ""
        } else {
            cell.dayDisplayLabel.text = "\(actualDay)"
        }
        
        return cell
    }
    
    func monthHeaderView(in collectionView: UICollectionView, atIndexPath indexPath: IndexPath) -> VPMonthDisplayCollectionReusableView {
        let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionElementKindSectionHeader, withReuseIdentifier: String(describing: VPMonthDisplayCollectionReusableView.self), for: indexPath) as! VPMonthDisplayCollectionReusableView
        
        if DateHelper.shared().isCurrentMonth(forYear: yearIndex, forMonth: month.rawValue) {
            headerView.monthDisplayLabel.textColor = currentDateDisplayColor
        } else {
            headerView.monthDisplayLabel.textColor = dateDisplayColor
        }
        
        headerView.monthDisplayLabel.text = month.getMonthString()
        
        return headerView
    }
    
    func sizeForDayDisplayCell(in collectionView: UICollectionView, withMaxSize size: CGSize) -> CGSize {
        // Here 6 is the worst case for number of weeks in any month, i.e., if a day starts at saturday/last day of the week and has 31 days, then there will be 6 weeks.
        return CGSize(width: floor(size.width / CGFloat(numberOfDaysInWeek)), height: floor((size.height - headerHeight) / 6))
    }
    
    func sizeForMonthHeaderView(in collectionView: UICollectionView, withMaxSize size: CGSize) -> CGSize {
        return CGSize(width: size.width, height: headerHeight)
    }
}
