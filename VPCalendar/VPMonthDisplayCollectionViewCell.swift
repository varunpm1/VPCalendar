//
//  VPMonthDisplayCollectionViewCell.swift
//  VPCalendarExample
//
//  Created by Varun P M on 08/03/18.
//  Copyright © 2018 Varun P M. All rights reserved.
//

import UIKit

class VPMonthDisplayCollectionViewCell: UICollectionViewCell, VPCalendarViewProtocol {
    // Protocol confirming variables
    var dateDisplayColor: UIColor = UIColor.black
    var currentDateDisplayColor: UIColor = UIColor.red
    
    /// Month of the corresponding year. Starts from January.
    var month: VPMonth = .january
    
    /// Year index of the corresponding calendar.
    var yearIndex: Int = 0
    
    @IBOutlet weak var monthDisplayCollectionView: UICollectionView!
    
    private var weekDay: Int = 0
    private var numberOfItems: Int = 0
    private let numberOfDaysInWeek: Int = 7
    private let headerHeight: CGFloat = 24
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        monthDisplayCollectionView.register(UINib(nibName: String(describing: VPDayDisplayCollectionViewCell.self), bundle: nil), forCellWithReuseIdentifier: String(describing: VPDayDisplayCollectionViewCell.self))
        monthDisplayCollectionView.register(UINib(nibName: String(describing: VPMonthDisplayCollectionReusableView.self), bundle: nil), forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: String(describing: VPMonthDisplayCollectionReusableView.self))
    }
    
    func updateItemCount() {
        // Add empty cells before the week day items count
        weekDay = DateHelper.shared().weekDay(inMonth: month.rawValue, andYear: yearIndex) - 1 // For 0 indexing
        numberOfItems = DateHelper.shared().days(inMonth: month.rawValue, andYear: yearIndex) + weekDay
        monthDisplayCollectionView.reloadData()
    }
}

extension VPMonthDisplayCollectionViewCell: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return numberOfItems
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
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
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionElementKindSectionHeader, withReuseIdentifier: String(describing: VPMonthDisplayCollectionReusableView.self), for: indexPath) as! VPMonthDisplayCollectionReusableView
        
        if DateHelper.shared().isCurrentMonth(forYear: yearIndex, forMonth: month.rawValue) {
            headerView.monthDisplayLabel.textColor = currentDateDisplayColor
        } else {
            headerView.monthDisplayLabel.textColor = dateDisplayColor
        }
        
        headerView.monthDisplayLabel.text = month.getMonthString()
        
        return headerView
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        // Here 6 is the worst case for number of weeks in any month, i.e., if a day starts at saturday/last day of the week and has 31 days, then there will be 6 weeks.
        return CGSize(width: floor(bounds.size.width / CGFloat(numberOfDaysInWeek)), height: floor((bounds.size.height - headerHeight) / 6))
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: bounds.size.width, height: headerHeight)
    }
}
