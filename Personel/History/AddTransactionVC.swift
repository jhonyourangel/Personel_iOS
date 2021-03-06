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
    
    let formatter = DateFormatter()
    
    @IBOutlet weak var durationLabel: UILabel!
    @IBOutlet weak var startTime: UILabel!
    @IBOutlet weak var endTime: UILabel!
    @IBOutlet weak var rangeCircularSlider: RangeCircularSlider!
    
    @IBOutlet weak var scrollView: UIScrollView!
    
    var selectedDate: Date? {
        didSet {
            formatter.dateFormat = "EEEE dd MMMM yyyy"
            self.monthLabel.text = formatter.string(from: self.selectedDate!)
        }
    }
    
    lazy var dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
        dateFormatter.dateFormat = "HH:mm"
        return dateFormatter
    }()
    
    @IBOutlet weak var projectNameBtn: TransitionButton!
    @IBOutlet weak var saveBtn: TransitionButton!
    @IBOutlet weak var calendarView: JTAppleCalendarView!
    @IBOutlet weak var monthLabel: UILabel!

    var projects: [Project]! = UserManager.projects
    
    var transaction: Transaction?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpcalendar()
        setupCircularSlider()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if transaction != nil {
            rangeCircularSlider.startPointValue = Date.secondsFrom(date: transaction!.startTime!)
            rangeCircularSlider.endPointValue = Date.secondsFrom(date: transaction!.endTime!)
            projectNameBtn.setTitle(transaction?.projectName, for: .normal)
            updateTexts(rangeCircularSlider)
        } else {
            projects = UserManager.projects
            if let projNameBtn = projectNameBtn.title(for: .normal), projNameBtn != "" {
                projectNameBtn.setTitle(projNameBtn, for: .normal)
            } else {
                projectNameBtn.setTitle(projects.first?.name, for: .normal)
            }
        }
        
    }
    
    func setUpcalendar() {
        selectedDate = transaction != nil ? transaction?.startTime : Date()
        calendarView.scrollToDate(selectedDate!)
        calendarView.selectDates([selectedDate!])
        calendarView.visibleDates { (visibleDates) in
            self.setupViewOfCalendar(visibleDates: visibleDates)
        }
        
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
        if selectedDate == nil { return }
        guard let projectName = projectNameBtn.title(for: .normal) else { return }

        UserManager.startTimeSlider = rangeCircularSlider.startPointValue
        UserManager.endTimeSlider = rangeCircularSlider.endPointValue

        let startDate = "\(Date.stringCETDateFrom(date: selectedDate!)) \(startTime.text!)"
        let endDate = "\(Date.stringCETDateFrom(date: selectedDate!)) \(endTime.text!)"
        let userId = UserManager().user?._id
        
        saveBtn.startAnimation()
        self.startLoader()
        
        Network.addTransaction(description: "no desc", startTime: startDate, endTime: endDate, userId: userId! , projectName: projectName) { (tran, statusCode, error) in
            self.saveBtn.stopAnimation()
            self.stopLoader()
            if error != nil {
                self.presentBanner(title: "error", message: (error?.localizedDescription)!)
                return
            }
            self.presentBanner(title: "trasaction saved", message: "")
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    func editTransaction() {
        // todo: save the edited transaction
        if selectedDate == nil { return }
        
        UserManager.startTimeSlider = rangeCircularSlider.startPointValue
        UserManager.endTimeSlider = rangeCircularSlider.endPointValue
        
        // if you eencouter issues just add :00 at the end as seconds
        let startDate = "\(Date.stringCETDateFrom(date: selectedDate!)) \(startTime.text!)"
        let endDate = "\(Date.stringCETDateFrom(date: selectedDate!)) \(endTime.text!)"
        let userId = UserManager().user?._id
        
        saveBtn.startAnimation()
        self.startLoader()
        
        Network.editTransaction(id: transaction!._id!,
                                description: "no desc",
                                startTime: startDate,
                                endTime: endDate,
                                userId: userId! ,
                                projectName: projectNameBtn.title(for: .normal)!,
                                billed: transaction!.billed!) { (tran, statusCode, error) in
            self.saveBtn.stopAnimation()
            self.stopLoader()
            if error != nil {
                self.presentBanner(title: "error", message: (error?.localizedDescription)!)
                return
            }
            self.presentBanner(title: "trasaction saved", message: "")
            self.navigationController?.popViewController(animated: true)
                                    
        }
    }
    
    func setupViewOfCalendar(visibleDates: DateSegmentInfo) {
        if visibleDates.monthDates.count == 0 { return }
        // not sure why i was resseting the date
        // each time i was scroling from one week to another
//        let date = visibleDates.monthDates.first!.date
//        selectedDate = date
//        print(selectedDate)
//        updateFullDate(date: date)
    }
    
//    func updateFullDate(date: Date) {
//        formatter.dateFormat = "EEEE dd MMMM yyyy"
//        monthLabel.text = formatter.string(from: date)
//
//        selectedDate = date
//    }
    
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
    
    @IBAction func changeProject () {
        self.performSegue(withIdentifier: "projectsVC", sender: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "projectsVC" {
            let destination = segue.destination as! ProjectsVC
            destination.delegate = self
        }
    }
}

extension AddTransactionVC: JTAppleCalendarViewDataSource {
    func configureCalendar(_ calendar: JTAppleCalendarView) -> ConfigurationParameters {
        
        formatter.dateFormat = "yyyy MM dd"
        formatter.timeZone = TimeZone(abbreviation: "CET")
        formatter.locale = Calendar.current.locale

        let startDate = formatter.date(from: "2017 05 01")!
        let endDate = formatter.date(from: "2022 11 01")!
        
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
        selectedDate = date
//        updateFullDate(date: date)

    }
    
    func calendar(_ calendar: JTAppleCalendarView, didDeselectDate date: Date, cell: JTAppleCell?, cellState: CellState) {
        print("deselected")
        handleCellSelected(view: cell, cellState: cellState)
        handleCellTextColor(view: cell, cellState: cellState)
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
        
        rangeCircularSlider.startPointValue = UserManager.startTimeSlider
        rangeCircularSlider.endPointValue = UserManager.endTimeSlider
        
        updateTexts(rangeCircularSlider)
    }
    
    
    @IBAction func updateTexts(_ sender: AnyObject) {
        
        adjustValue(value: &rangeCircularSlider.startPointValue)
        adjustValue(value: &rangeCircularSlider.endPointValue)
        
        
        let startT = TimeInterval(rangeCircularSlider.startPointValue)
        let st = Date(timeIntervalSinceReferenceDate: startT)
        startTime.text = dateFormatter.string(from: st)
        
        let endT = TimeInterval(rangeCircularSlider.endPointValue)
        let et = Date(timeIntervalSinceReferenceDate: endT)
        endTime.text = dateFormatter.string(from: et)
        
        let duration = endT - startT
        let durationDate = Date(timeIntervalSinceReferenceDate: duration)
        dateFormatter.dateFormat = "HH:mm"
        durationLabel.text = dateFormatter.string(from: durationDate)
        dateFormatter.dateFormat = "HH:mm"
    
    }
    
    func adjustValue(value: inout CGFloat) {
        let minutes = value / 60
        let adjustedMinutes =  ceil(minutes / 5.0) * 5
        value = adjustedMinutes * 60
    }
    
}

extension AddTransactionVC: ProjectsDelegate {
    func projectName(name: String) {
        projectNameBtn.setTitle(name, for: .normal)
        transaction?.projectName = name
    }
}


