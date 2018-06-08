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

class VPCalendarView: UIView, VPCalendarViewProtocol {
    /// Used to identify the display type needed currently. Defaults to `yearly` view.
    var calendarDisplayType: VPCalendarDisplayType = .yearly
    
    // Protocol confirming variables
    var dateDisplayColor: UIColor = UIColor.black
    var currentDateDisplayColor: UIColor = UIColor.red
    
    @IBOutlet weak fileprivate var contentView: UIView!
    @IBOutlet weak fileprivate var monthDisplayCollectionView: UICollectionView!
    
    private let currentYear = DateHelper.shared().currentYear
    private let padding: CGFloat = 8
    private let headerHeight: CGFloat = 44
    
    // Minimum gregorian year to avoid unwanted calendar issues
    private let minimumYear: Int = 1752
    
    // To avoid flickering, set this variable to difference between current year and minimum year initially and when changing scroll offset, reset it to 0.
    private var initialYear: Int = 0
    
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
            self.monthDisplayCollectionView.setContentOffset(CGPoint(x: 0, y: CGFloat(self.currentYear - self.minimumYear - 1) * self.bounds.size.height), animated: false)
        }
        
        initialYear = currentYear - minimumYear - 1
        monthDisplayCollectionView.register(UINib(nibName: String(describing: VPMonthDisplayCollectionViewCell.self), bundle: nil), forCellWithReuseIdentifier: String(describing: VPMonthDisplayCollectionViewCell.self))
        monthDisplayCollectionView.register(UINib(nibName: String(describing: VPYearDisplayCollectionReusableView.self), bundle: nil), forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: String(describing: VPYearDisplayCollectionReusableView.self))
    }
    
    //MARK: Helper functions
    // Returns year for corresponding section
    private func getYear(forSection section: Int) -> Int {
        return (minimumYear + initialYear + section + 1)
    }
}

extension VPCalendarView: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 10000 // for infinite year
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // Defaults to number of months in a year
        return 12
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: String(describing: VPMonthDisplayCollectionViewCell.self), for: indexPath) as! VPMonthDisplayCollectionViewCell
        
        cell.dateDisplayColor = dateDisplayColor
        cell.currentDateDisplayColor = currentDateDisplayColor
        cell.month = VPMonth(rawValue: indexPath.item + 1)!
        cell.yearIndex = getYear(forSection: indexPath.section)
        cell.updateItemCount()
        cell.monthDisplayCollectionView.isUserInteractionEnabled = false
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: String(describing: VPYearDisplayCollectionReusableView.self), for: indexPath) as! VPYearDisplayCollectionReusableView
        let displayYear = getYear(forSection: indexPath.section)
        
        if DateHelper.shared().isCurrentYear(forYear: displayYear) {
            headerView.yearDisplayLabel.textColor = currentDateDisplayColor
        } else {
            headerView.yearDisplayLabel.textColor = dateDisplayColor
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
        // The number of items to be placed in a single row
        let numberOfColumns: CGFloat = 3
        
        // The number of items to be placed in a single column
        let numberOfRows: CGFloat = 4
        
        // Calculate the item size considering 3 items in a row and 4 items in a column. Subtract left, right, bottom and top paddings along with spacing between each cells.
        let availableWidth = (bounds.size.width - 2 * padding) - (numberOfColumns - 1) * padding
        let availableHeight = (bounds.size.height - 2 * padding) - (numberOfRows - 1) * padding - headerHeight
        return CGSize(width: floor(availableWidth / numberOfColumns), height: floor(availableHeight / numberOfRows))
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: bounds.size.width, height: headerHeight)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        //FIXME: Handle
    }
    
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        if velocity.y != 0 {
            targetContentOffset.pointee.y = round(targetContentOffset.pointee.y / scrollView.bounds.size.height) * scrollView.bounds.size.height
        }
    }
}
