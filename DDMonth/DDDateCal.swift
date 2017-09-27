//
//  DDDateCal.swift


import UIKit

class DDDateCal: NSObject {
    typealias DDDateInfo = (year: Int, month: Int, day: Int);
    
    /// 两天之间的间隔天数    
    class func dayInterval(startDate :Date?,endDate:Date?) -> Int {
        if  startDate != nil &&  endDate != nil  {
            let cal = Calendar.current;
            return cal.dateComponents([.day], from: startDate!, to: endDate!).day!;
        }
        
        return 0;
    }
    
    class func currentDateInfo() ->DDDateInfo {
        let cal = Calendar.current;
        let date = Date();
        let year = cal.component(.year, from: date);
        let month = cal.component(.month, from: date);
        let day = cal.component(.day, from: date);
        return (year,month,day);
    }
    
    class func transfromDateTomChinseDate(inputDate: DDDateInfo?) -> (year: String ,month: String ,day: String)? {
        if inputDate == nil {
            return nil;
        }
        let chineseNumber = ["十","一","二","三","四","五","六","七","八","九",]
        let heavenlyStems = ["癸","甲","乙","丙","丁","戊","己","庚","辛","壬"];
        let earthlyBranches = ["亥","子","丑","寅","卯","辰","巳","午","未","申","酉","戌"]
        
        var chineseDay = "";
        var chineseMonth = "";
        var chineseYear = "";
        
        if let date = self.transfromDateInfoToDate(dateInfo: inputDate!) {
            let chineseCal = Calendar.init(identifier: .chinese);
            let dateComponents = chineseCal.dateComponents([.year,.month,.day], from: date);
            if let day = dateComponents.day {
                var preString = "初"
                if day > 10 && day < 20 {
                    preString = "十"
                } else if day  == 20  {
                    preString = "二"
                } else if day > 20 && day < 30 {
                    preString = "廿"
                } else if day > 30{
                    preString = "三"
                }
            
                let contentStr = chineseNumber[day % 10];
               
                chineseDay = preString + contentStr;
            }
            
            if let month = dateComponents.month {
                var preString = ""
                if month > 10 {
                    preString = "十"
                }
                chineseMonth = preString + chineseNumber[month % 10] + "月"
            }
            
            if let year = dateComponents.year {
                chineseYear = heavenlyStems[year % 10] + earthlyBranches[year % 12];
            }
            return (chineseYear,chineseMonth,chineseDay );
        }
        
        return nil;
    }
    
    /// 某一个月前后偏移之后的月份
    class func offsetMonth(year: Int,month: Int, offset: Int) -> (year: Int,month: Int) {
        var newMonth = month + offset;
        var newYear = year;
        
        if newMonth > 12 {
            // 后几年
            newYear += newMonth / 12
            if newMonth % 12 == 0 {
                newYear -= 1;
            }
            
        } else if newMonth <= 0{
            // 前几年
            newYear -= 1;
            newYear += newMonth / 12 ;
        }
        
        newMonth =  newMonth % 12 <= 0 ?   newMonth % 12 + 12 :  newMonth % 12;
        return (newYear,newMonth);
        
    }
    
    /// 某一个天前后偏移之后的日期
    class func offsetDay(originDay: DDDateInfo, offset: Int) -> DDDateInfo {
        
        var newDay = originDay.day + offset;
        var newMonth = originDay.month;
        var newYear = originDay.year;
        
        while true {
            var dayCount = self.monthInfo(year: newYear, month: newMonth).dayCount;
            if newDay > 0 {
                if dayCount >= newDay {
                    break;
                }
                newDay -= dayCount;
                newMonth += 1;
                if newMonth == 13 {
                    newMonth = 1;
                    newYear += 1;
                }
            } else {
                newMonth -= 1;
                if newMonth == 0 {
                    newMonth = 12;
                    newYear -= 1;
                }
                dayCount = self.monthInfo(year: newYear, month: newMonth).dayCount;
                newDay += dayCount;
                if newDay > 0 {
                    break;
                }
            }
            
        }
        
        return (newYear,newMonth,newDay);
    }
    
    /// 获取某月的其实星期和天数
    class func monthInfo(year : Int ,month : Int) -> (firstWeekDay : Int, dayCount :Int) {
        if let date = self.transfromDateInfoToDate(dateInfo: (year,month,1))  {
            let cal = Calendar.current;
            let weekday = cal.component(.weekday, from: date) - 1;
            return (weekday == 0 ? 7 : weekday, cal.range(of: .day, in: .month, for: date)?.count ?? 0);
        }
        return (0,0);
    }
    
    class func transfromDateInfoToDate(dateInfo: DDDateInfo?) -> Date? {
        if dateInfo == nil {
            return nil;
        }
        let dateFormatter =  DateFormatter();
        dateFormatter.dateFormat = "YYYY-MM-dd"
        if let timeString = self.transfromDateInfoToDateString(dateInfo: dateInfo) {
            return dateFormatter.date(from: timeString);
        }
        return nil;
    }
    
    class func transformDateToDateInfo(date : Date) -> DDDateCal.DDDateInfo{
        let cal = Calendar.current;
        let year = cal.component(.year, from: date);
        let month = cal.component(.month, from: date);
        let day = cal.component(.day, from: date);
        return (year,month,day);

    }
    
   class func transfromDateToString(date: Date?) -> String? {
        if date == nil {
            return nil;
        }
        let dateFormatter =  DateFormatter();
        dateFormatter.dateFormat = "YYYY-MM-dd"
        return dateFormatter.string(from: date!);
    }
    
    class func transfromDateInfoToDateString(dateInfo: DDDateInfo?) -> String? {
        if dateInfo == nil {
            return nil;
        }
        return String.init(format: "%04d-%02d-%02d", dateInfo!.year,dateInfo!.month,dateInfo!.day);

    }
    
}
