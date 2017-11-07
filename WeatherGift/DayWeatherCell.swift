//
//  DayWeatherCell.swift
//  WeatherGift
//
//  Created by Linda Chen on 10/31/17.
//  Copyright © 2017 Synestha. All rights reserved.
//

import UIKit

private let dateFormatter: DateFormatter = {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "EEEE"
    print("**** Date Formatter just created in DayWeatherCell")
    return dateFormatter
}()

class DayWeatherCell: UITableViewCell {
    @IBOutlet weak var cellIcon: UIImageView!
    @IBOutlet weak var cellWeekday: UILabel!
    @IBOutlet weak var cellMaxTemp: UILabel!
    @IBOutlet weak var cellMinTemp: UILabel!
    @IBOutlet weak var cellSummary: UITextView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func update(with dailyForecast: WeatherLocation.DailyForecast, timeZone: String) {
        cellMaxTemp.text = String(format: "%2.f", dailyForecast.dailyMaxTemp) + "°"
        cellMinTemp.text = String(format: "%2.f", dailyForecast.dailyMinTemp) + "°"
        cellSummary.text = dailyForecast.dailySummary
        cellIcon.image = UIImage(named: dailyForecast.dailyIcon)

        let dateString = dailyForecast.dailyDate.format(timeZone: timeZone, dateFormatter:  dateFormatter)
        cellWeekday.text = dateString
    }
}

