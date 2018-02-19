//
//  AddTransactionVC.swift
//  Personel
//
//  Created by Ion Utale on 11/02/2018.
//  Copyright © 2018 Ion Utale. All rights reserved.
//

import UIKit
import TransitionButton
import JTAppleCalendar
import HGCircularSlider

class AddTransactionVC: ViewController {
    
    let formater = DateFormatter()
    
    @IBOutlet weak var durationLabel: UILabel!
    @IBOutlet weak var bedtimeLabel: UILabel!
    @IBOutlet weak var wakeLabel: UILabel!
    @IBOutlet weak var rangeCircularSlider: RangeCircularSlider!
    
    lazy var dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
        dateFormatter.dateFormat = "hh:mm a"
        return dateFormatter
    }()
    
    @IBOutlet weak var saveBtn: TransitionButton!
    @IBOutlet weak var calendarView: JTAppleCalendarView!
    @IBOutlet weak var monthLabel: UILabel!

    var projects: [Project]! = UserManager.projects
    
    var selectedProjectId: String! = ""
    var transaction: Transaction?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpcalendar()
        calendarView.scrollToDate(Date())
        calendarView.selectDates([Date()])
        calendarView.visibleDates { (visibleDates) in
            self.setupViewOfCalendar(visibleDates: visibleDates)
        }
    }
    
    func setUpcalendar() {
        calendarView.ibCalendarDelegate = self
        calendarView.ibCalendarDataSource = self

        calendarView.minimumLineSpacing = 0.0
        calendarView.minimumInteritemSpacing = 0.0
     
    }
    
    @IBAction func saveTransaction() {
        if transaction?._id == nil {
            addTransaction()
            return
        }
        editTransaction()
    }
    
    func addTransaction() {
        let startDate = "" //"\(stringDateTF.text!) \(Date.timeFrom(date:startTimePicker.date))"
        let endDate = "" // "\(stringDateTF.text!) \(Date.timeFrom(date:endTimePicker.date))"
        let userId = UserManager().user?._id
        
        saveBtn.startAnimation()
        self.startLoader()
        
        Network.addTransaction(description: "no desc", startTime: startDate, endTime: endDate, userId: userId! , projectId: selectedProjectId) { (tran, statusCode, error) in
            self.saveBtn.stopAnimation()
            self.stopLoader()
            if error != nil {
                self.presentBanner(title: "error", message: (error?.localizedDescription)!)
                return
            }
            self.presentBanner(title: "trasaction saved", message: "")
            
        }
    }
    
    func editTransaction() {
        // todo: save the edited transaction
    }
    
    func setupViewOfCalendar(visibleDates: DateSegmentInfo) {
        if visibleDates.monthDates.count == 0 { return }
        let date = visibleDates.monthDates.first!.date
        
        updateFullDate(date: date)
    }
    
    func updateFullDate(date: Date) {
        formater.dateFormat = "EEEE dd MMMM yyyy"
        monthLabel.text = formater.string(from: date)
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
    
    func handleCellSelected(view: JTAppleCell?, cellState: CellState) {
        guard let cell = view as? CalendarCell else { return }
        cell.selectedView.isHidden = !cellState.isSelected
    }
}

extension AddTransactionVC: JTAppleCalendarViewDataSource {
    func configureCalendar(_ calendar: JTAppleCalendarView) -> ConfigurationParameters {
        
        formater.dateFormat = "yyyy MM dd"
        formater.timeZone = Calendar.current.timeZone
        formater.locale = Calendar.current.locale

        let startDate = formater.date(from: "2017 05 01")!
        let endDate = formater.date(from: "2022 11 01")!
        
        let parameters = ConfigurationParameters(startDate: startDate,
                                                 endDate: endDate,
                                                 numberOfRows: 1,
                                                 generateInDates: .off,
                                                 generateOutDates: .off,
                                                 firstDayOfWeek: .monday,
                                                 hasStrictBoundaries: false )
        return parameters
    }
}

extension AddTransactionVC: JTAppleCalendarViewDelegate {
    func calendar(_ calendar: JTAppleCalendarView, willDisplay cell: JTAppleCell, forItemAt date: Date, cellState: CellState, indexPath: IndexPath) {
        print("bohh")
    }
    
    func calendar(_ calendar: JTAppleCalendarView, cellForItemAt date: Date, cellState: CellState, indexPath: IndexPath) -> JTAppleCell {
        let cell = calendar.dequeueReusableJTAppleCell(withReuseIdentifier: "CalendarCell", for: indexPath) as! CalendarCell
        handleCellSelected(view: cell, cellState: cellState)
        handleCellTextColor(view: cell, cellState: cellState)
        return cell
    }
    
    func calendar(_ calendar: JTAppleCalendarView, didSelectDate date: Date, cell: JTAppleCell?, cellState: CellState) {
        print("selected")
        handleCellSelected(view: cell, cellState: cellState)
        handleCellTextColor(view: cell, cellState: cellState)
        updateFullDate(date: date)

    }
    
    func calendar(_ calendar: JTAppleCalendarView, didDeselectDate date: Date, cell: JTAppleCell?, cellState: CellState) {
        print("deselected")
        handleCellSelected(view: cell, cellState: cellState)
        handleCellTextColor(view: cell, cellState: cellState)
        updateFullDate(date: date)

    }
    
    func calendar(_ calendar: JTAppleCalendarView, didScrollToDateSegmentWith visibleDates: DateSegmentInfo) {
        setupViewOfCalendar(visibleDates: visibleDates)
    }
    
}
// MARK: - circular slider
extension AddTransactionVC {
    
    
    func setupCircularSlider() {
        let dayInSeconds = 24 * 60 * 60
        rangeCircularSlider.maximumValue = CGFloat(dayInSeconds)
        
        rangeCircularSlider.startPointValue = 1 * 60 * 60
        rangeCircularSlider.endPointValue = 8 * 60 * 60
        
        updateTexts(rangeCircularSlider)
    }
    
    
    @IBAction func updateTexts(_ sender: AnyObject) {
        
        adjustValue(value: &rangeCircularSlider.startPointValue)
        adjustValue(value: &rangeCircularSlider.endPointValue)
        
        
        let bedtime = TimeInterval(rangeCircularSlider.startPointValue)
        let bedtimeDate = Date(timeIntervalSinceReferenceDate: bedtime)
        bedtimeLabel.text = dateFormatter.string(from: bedtimeDate)
        
        let wake = TimeInterval(rangeCircularSlider.endPointValue)
        let wakeDate = Date(timeIntervalSinceReferenceDate: wake)
        wakeLabel.text = dateFormatter.string(from: wakeDate)
        
        let duration = wake - bedtime
        let durationDate = Date(timeIntervalSinceReferenceDate: duration)
        dateFormatter.dateFormat = "HH:mm"
        durationLabel.text = dateFormatter.string(from: durationDate)
        dateFormatter.dateFormat = "hh:mm a"
    }
    
    func adjustValue(value: inout CGFloat) {
        let minutes = value / 60
        let adjustedMinutes =  ceil(minutes / 5.0) * 5
        value = adjustedMinutes * 60
    }
}


