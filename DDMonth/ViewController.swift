//
//  ViewController.swift


import UIKit

class ViewController: UIViewController,DDInfiniteScrollViewDelegate,DDMonthViewDelegate {
    
    @IBOutlet weak var monthInfo: UILabel!
    @IBOutlet weak var infiniteScrollView: DDInfiniteScrollView!
    
    let currentDayInfo = DDDateCal.currentDateInfo();
    override func viewDidLoad() {
        super.viewDidLoad()
        infiniteScrollView?.delegate = self;
        self.selectedDateInfo = currentDayInfo;
        
    }
    
    func infiniteScrollView(_ infiniteScrollView: DDInfiniteScrollView, didEndScroll index: Int) {
        let newInfo = DDDateCal.offsetMonth(year: self.currentDayInfo.year,month: self.currentDayInfo.month, offset: index);
        let chinsesDateInfo = DDDateCal.transfromDateTomChinseDate(inputDate: (newInfo.year,newInfo.month,1));
        
        monthInfo.text = "\(newInfo.year)年\(newInfo.month)月  \(chinsesDateInfo?.year ?? "未知")年\(chinsesDateInfo?.month ?? "未知")";
    }

    func infiniteScrollView(_ infiniteScrollView: DDInfiniteScrollView, temViewForOffset offset: Int) -> UIView {
        var monthView:DDMonthView!;
        if let view = infiniteScrollView.dequeueReusableItemView()  {
            monthView = view as! DDMonthView;
        } else {
            monthView = DDMonthView()
            monthView.contentInsert = UIEdgeInsets.init(top: 0, left: 10, bottom: 0, right: 10);
            monthView.delegate = self;
        }
        if (monthView.bounds != infiniteScrollView.bounds) {
            monthView.bounds = infiniteScrollView.bounds;
        }

        let newInfo = DDDateCal.offsetMonth(year: self.currentDayInfo.year,month: self.currentDayInfo.month, offset: offset);
        monthView.updateMonthView(WithMonthInfo: (year: newInfo.year, month: newInfo.month));
        
        return monthView;
    }
    
    func monthView(monthView: DDMonthView, shouldUpdateItem item: UIButton) {
        if self.selectedDateInfo != nil && item.dateInfo != nil && item.dateInfo! == self.selectedDateInfo! {
            item.layer.borderColor = #colorLiteral(red: 0.8032942414, green: 0.5744761229, blue: 0.9348348379, alpha: 1);
            item.layer.borderWidth = 1;
        } else {
            item.layer.borderWidth = 0;
        }
    }
    @IBAction func backToday(_ sender: Any) {
        self.selectedDateInfo = DDDateCal.currentDateInfo();
        infiniteScrollView?.changeOffset(newOffset: 0);
    }
    
    private var _selectedDateInfo : DDDateCal.DDDateInfo?
    var selectedDateInfo : DDDateCal.DDDateInfo? {
        set {
            _selectedDateInfo = newValue;
            infiniteScrollView.reloadData();
        }
        get {
            return _selectedDateInfo;
        }
    };
}

