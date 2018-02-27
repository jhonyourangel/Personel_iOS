//
//  CalendarView.swift
//  Personel
//
//  Created by Ion Utale on 26/02/2018.
//  Copyright © 2018 Ion Utale. All rights reserved.
//

import UIKit
import JTAppleCalendar
import TransitionButton

protocol CalendarDelegate {
    func selectedRange(beginRangeDate: Date, endRangeDate: Date)
}

class CalendarVC: ViewController {
    let formatter = DateFormatter()
    var selectedDate: Date?

    @IBOutlet weak var cancelBtn: TransitionButton!
    @IBOutlet weak var selectBtn: TransitionButton!
    @IBOutlet weak var calendarView: JTAppleCalendarView!
    @IBOutlet weak var monthLabel: UILabel!

    var rangeDates: [Date]! = []
    var delegate: CalendarDelegate!
    
    static func makeVCFromStoryboard() -> CalendarVC {
        return UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "CalendarVC") as! CalendarVC
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpcalendar()
    }
    
    func setUpcalendar() {
        let today = Date()
        rangeDates.append(today)
        calendarView.scrollToDate(today)
        calendarView.selectDates([today])
        calendarView.allowsMultipleSelection = true
        calendarView.isRangeSelectionUsed = true

        calendarView.visibleDates { (visibleDates) in
            self.setupViewOfCalendar(visibleDates: visibleDates)
        }
        
        calendarView.ibCalendarDelegate = self
        calendarView.ibCalendarDataSource = self
        
        calendarView.minimumLineSpacing = 0.0
        calendarView.minimumInteritemSpacing = 0.0
    }
    
    @IBAction func selectDateRange() {
        rangeDates.sort()
        delegate.selectedRange(beginRangeDate: rangeDates.first!, endRangeDate: rangeDates.last!)
    }
    
    @IBAction func cancel() {
        self.dismiss(animated: true, completion: nil)
    }
    
    func setupViewOfCalendar(visibleDates: DateSegmentInfo) {
        if visibleDates.monthDates.count == 0 { return }
        let date = visibleDates.monthDates.first!.date
        
        updateFullDate(date: date)
    }
    
    func updateFullDate(date: Date) {
        formatter.dateFormat = "EEEE dd MMMM yyyy"
        monthLabel.text = formatter.string(from: date)
        
        selectedDate = date
    }
    
    func handleCellTextColor(view: JTAppleCell?, cellState: CellState) {
        guard let cell = view as? CalendarCell else { return }
        cell.customText.text = cellState.text
        
        if cellState.isSelected {
            cell.customText.textColor = .white
        } else {
            cell.customText.textColor = cellState.dateBelongsTo == .thisMonth ? .black : .gray
        }
    }
    
    func handleCellSelected(view: JTAppleCell?, date: Date, cellState: CellState) {
        guard let cell = view as? CalendarCell else { return }
        cell.selectedView.isHidden = !cellState.isSelected

        if !cell.selectedView.isHidden {
            rangeDates.append(date)
        } else {
            if let index = rangeDates.index(of: date) {
                rangeDates.remove(at: index)
            }
        }
    }
}


extension CalendarVC: JTAppleCalendarViewDelegate, JTAppleCalendarViewDataSource {
    func calendar(_ calendar: JTAppleCalendarView, willDisplay cell: JTAppleCell, forItemAt date: Date, cellState: CellState, indexPath: IndexPath) {
        // nothing to do yet
    }
    
    func configureCalendar(_ calendar: JTAppleCalendarView) -> ConfigurationParameters {
        
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.timeZone = Calendar.current.timeZone
        formatter.locale = Calendar.current.locale
        
        let startDate = formatter.date(from: "2017-10-01")
        let endDate = formatter.date(from: "2020-10-01")

        let parameters = ConfigurationParameters(startDate: startDate!,
                                                 endDate: endDate!,
                                                 //numberOfRows: 1,
                                                 //generateInDates: .off,
                                                 //generateOutDates: .off,
                                                 firstDayOfWeek: .monday
                                                 //hasStrictBoundaries: false
        )
        return parameters
    }
    
    func calendar(_ calendar: JTAppleCalendarView, cellForItemAt date: Date, cellState: CellState, indexPath: IndexPath) -> JTAppleCell {
        let cell = calendar.dequeueReusableJTAppleCell(withReuseIdentifier: "customCell", for: indexPath) as! CalendarCell
        
        handleCellSelected(view: cell, date: date, cellState: cellState)
        handleCellTextColor(view: cell, cellState: cellState)

        return cell
    }
    
    func calendar(_ calendar: JTAppleCalendarView, didSelectDate date: Date, cell: JTAppleCell?, cellState: CellState) {
        print("selected")
        handleCellSelected(view: cell, date: date, cellState: cellState)
        handleCellTextColor(view: cell, cellState: cellState)
        updateFullDate(date: date)
    }
    
    func calendar(_ calendar: JTAppleCalendarView, didDeselectDate date: Date, cell: JTAppleCell?, cellState: CellState) {
        print("deselected")
        handleCellSelected(view: cell, date: date, cellState: cellState)
        handleCellTextColor(view: cell, cellState: cellState)
    }
    
    func calendar(_ calendar: JTAppleCalendarView, didScrollToDateSegmentWith visibleDates: DateSegmentInfo) {
        setupViewOfCalendar(visibleDates: visibleDates)
    }
}
