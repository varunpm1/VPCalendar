//
//  VPCalendarView.swift
//  VPCalendarExample
//
//  Created by Varun P M on 06/03/18.
//  Copyright © 2018 Varun P M. All rights reserved.
//

import UIKit

public enum VPCalendarDisplayType {
    case yearly
    case monthly
}

public enum VPMonth: Int {
    case january = 1
    case february
    case march
    case april
    case may
    case june
    case july
    case august
    case september
    case october
    case november
    case december
    
    func getMonthString() -> String {
        return "\(self)".capitalized
    }
}

public protocol VPCalendarViewProtocol {
    /// Color to be used to indicate the date/month/year. Defaults to `black`.
    var dateDisplayColor: UIColor { get set }
    
    /// Color to be used to indicate the current date/month/year. Defaults to `red`.
    var currentDateDisplayColor: UIColor { get set }
}

class VPCalendarView: UIView {
    /// Used to identify the display type needed currently. Defaults to `yearly` view.
    var calendarDisplayType: VPCalendarDisplayType = .yearly
    
    let monthDisplayVM = VPMonthDisplayVM()
    
    @IBOutlet weak fileprivate var contentView: UIView!
    @IBOutlet weak fileprivate var monthDisplayCollectionView: UICollectionView!
    
    private var currentYear = DateHelper.shared().currentYear
    private var currentMonth = DateHelper.shared().currentMonth
    private let numberOfMonthsInYear = 12
    private let padding: CGFloat = 8
    private let headerHeight: CGFloat = 44
    
    // Minimum gregorian year to avoid unwanted calendar issues
    private let minimumYear: Int = 1752
    
    // To avoid flickering, set this variable to difference between current year and minimum year initially and when changing scroll offset, reset it to 0.
    private var initialYear: Int = 0
    private var initialMonth: Int = 0
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupInitialUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        setupInitialUI()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    // Sets up initial UI
    private func setupInitialUI() {
        // For forcefully loading the nib if set in xib with changing the class name
        Bundle.main.loadNibNamed(String(describing: VPCalendarView.self), owner: self, options: nil)
        addSubview(contentView)
        contentView.frame = bounds
        
        if #available(iOS 11, *) {
            monthDisplayCollectionView.contentInsetAdjustmentBehavior = .never
        }
        
        DispatchQueue.main.async {
            self.initialYear = 0
            self.initialMonth = 0
            
            // Update the offset
            switch self.calendarDisplayType {
            case .yearly:
                self.monthDisplayCollectionView.setContentOffset(self.nearestOffset(), animated: false)
            case .monthly:
                self.monthDisplayCollectionView.setContentOffset(self.nearestOffset(), animated: false)
            }
        }
        
        initialYear = currentYear - minimumYear - 1
        
        switch calendarDisplayType {
        case .yearly:
            initialMonth = 0
        case .monthly:
            initialMonth = currentMonth - 1
        }
        
        monthDisplayCollectionView.register(UINib(nibName: String(describing: VPMonthDisplayCollectionViewCell.self), bundle: nil), forCellWithReuseIdentifier: String(describing: VPMonthDisplayCollectionViewCell.self))
        monthDisplayCollectionView.register(UINib(nibName: String(describing: VPYearDisplayCollectionReusableView.self), bundle: nil), forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: String(describing: VPYearDisplayCollectionReusableView.self))
        
        if let flowLayout = (monthDisplayCollectionView.collectionViewLayout as? UICollectionViewFlowLayout) {
            flowLayout.sectionHeadersPinToVisibleBounds = true
        }
    }
    
    //MARK: Helper functions
    // Returns year for corresponding section
    private func getYear(forSection section: Int) -> Int {
        return (minimumYear + initialYear + section + 1)
    }
    
    // Returns month for corresponding item
    private func getMonth(forItem item: Int) -> VPMonth {
        return VPMonth(rawValue: initialMonth + item + 1)!
    }
    
    // Returns difference in current year and minimum year
    private func differenceInYears() -> CGFloat {
        return CGFloat(currentYear - minimumYear - 1)
    }
    
    // Returns yearly height for different calendar types
    private func yearHeight() -> CGFloat {
        switch calendarDisplayType {
        case .yearly:
            return monthDisplayCollectionView.bounds.size.height
        case .monthly:
            return (CGFloat(numberOfMonthsInYear) * (monthHeight() + padding) + headerHeight + padding)
        }
    }
    
    // Returns monthly height for different calendar types
    private func monthHeight() -> CGFloat {
        switch calendarDisplayType {
        case .yearly:
            // The number of items to be placed in a single column
            let numberOfRows: CGFloat = 4
            
            // Calculate the item size considering 3 items in a row and 4 items in a column. Subtract left, right, bottom and top paddings along with spacing between each cells.
            let availableHeight = (monthDisplayCollectionView.bounds.size.height - 2 * padding) - (numberOfRows - 1) * padding - headerHeight
            
            return floor(availableHeight / numberOfRows)
        case .monthly:
            return 200
        }
    }
    
    // Gets the nearest offset for the year/month view to scroll
    private func nearestOffset() -> CGPoint {
        switch self.calendarDisplayType {
        case .yearly:
            return CGPoint(x: 0, y: differenceInYears() * yearHeight())
        case .monthly:
            // Calculate each years content height by adding header height for each year and adding month height and padding for each month in a year and bottom padding for each year
            let changeInYearOffset = differenceInYears() * yearHeight()
            
            // Calculate each month's offset by calculating month offset from January and adding padding
            let changeInMonthOffset = CGFloat(currentMonth - 1) * (monthHeight() + padding)
            
            return CGPoint(x: 0, y: changeInYearOffset + changeInMonthOffset)
        }
    }
}

extension VPCalendarView: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 10000 // for infinite year
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // Defaults to number of months in a year
        return numberOfMonthsInYear
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: String(describing: VPMonthDisplayCollectionViewCell.self), for: indexPath) as! VPMonthDisplayCollectionViewCell
        
        cell.monthDisplayVM.dateDisplayColor = monthDisplayVM.dateDisplayColor
        cell.monthDisplayVM.currentDateDisplayColor = monthDisplayVM.currentDateDisplayColor
        cell.monthDisplayVM.month = getMonth(forItem: indexPath.item)
        cell.monthDisplayVM.yearIndex = getYear(forSection: indexPath.section)
        cell.monthDisplayVM.updateItemCount(forCollectionView: cell.monthDisplayCollectionView)
        cell.monthDisplayCollectionView.isUserInteractionEnabled = false
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: String(describing: VPYearDisplayCollectionReusableView.self), for: indexPath) as! VPYearDisplayCollectionReusableView
        let displayYear = getYear(forSection: indexPath.section)
        
        if DateHelper.shared().isCurrentYear(forYear: displayYear) {
            headerView.yearDisplayLabel.textColor = monthDisplayVM.currentDateDisplayColor
        } else {
            headerView.yearDisplayLabel.textColor = monthDisplayVM.dateDisplayColor
        }
        
        headerView.yearDisplayLabel.text = "\(displayYear)"
        
        return headerView
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: padding, left: padding, bottom: padding, right: padding)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return padding
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return padding
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        switch  calendarDisplayType {
        case .yearly:
            // The number of items to be placed in a single row
            let numberOfColumns: CGFloat = 3
            
            // Calculate the item size considering 3 items in a row and 4 items in a column. Subtract left, right, bottom and top paddings along with spacing between each cells.
            let availableWidth = (collectionView.bounds.size.width - 2 * padding) - (numberOfColumns - 1) * padding
            
            return CGSize(width: floor(availableWidth / numberOfColumns), height: monthHeight())
        case .monthly:
            // Top and bottom padding subtracted
            return CGSize(width: collectionView.bounds.size.width - 2 * padding, height: monthHeight())
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: collectionView.bounds.size.width, height: headerHeight)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        //FIXME: Handle
    }
    
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        if velocity.y != 0 {
            switch calendarDisplayType {
            case .yearly:
                // The offset returned is w.r.t minimumYear since offset 0 represents minimumYear
                currentYear = Int(round(targetContentOffset.pointee.y / yearHeight())) + minimumYear + 1
                targetContentOffset.pointee.y = nearestOffset().y
            case .monthly:
                // The offset returned is w.r.t minimumYear since offset 0 represents minimumYear
                currentYear = Int(targetContentOffset.pointee.y / yearHeight()) + minimumYear + 1
                
                // Calculate the month by subtracting the year contents
                let differenceInOffset = targetContentOffset.pointee.y - differenceInYears() * yearHeight()
                currentMonth = Int(round(differenceInOffset / (monthHeight() + padding))) + 1
                
                targetContentOffset.pointee.y = nearestOffset().y
            }
        }
    }
}
