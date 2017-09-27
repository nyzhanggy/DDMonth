//
//  DDMonthView.swift


import UIKit
private var kDateInfo = "dateInfo";
private var kMonthType = "monthType";

enum DDMonthType {
    case current
    case last
    case next
}
extension  UIButton {
    var dateInfo : (year: Int, month: Int, day: Int)? {
        set {
            objc_setAssociatedObject(self, &kDateInfo, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        }
        
        get {
            
            return objc_getAssociatedObject(self, &kDateInfo) as? (year: Int, month: Int, day: Int);
        }
    };
    
    var monthType : DDMonthType? {
        set {
            objc_setAssociatedObject(self, &kMonthType, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        }
        
        get {
            return objc_getAssociatedObject(self, &kMonthType) as? DDMonthType;
        }
    };
}


@objc protocol DDMonthViewDelegate : NSObjectProtocol  {
    
    @objc optional func monthView(monthView:DDMonthView, didSelectedItem item:UIButton);
    @objc optional func monthView(monthView:DDMonthView, shouldUpdateItem item:UIButton)
}

@IBDesignable class DDMonthView: UIView {

    var itemViewsArray:[UIButton] = Array();
    var delegate: DDMonthViewDelegate?;
    var contentInsert : UIEdgeInsets?;
    
    override init(frame: CGRect) {
        super.init(frame: frame);
        self.renderUI();
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder);
        self.renderUI();
    }
    
   private func renderUI()  {
        for _ in 0..<6*7 {
            let btn = UIButton.init(type: UIButtonType.custom)
            btn.titleLabel?.font = UIFont.systemFont(ofSize: 12);
            
            btn.setTitleColor(UIColor.black, for: .normal);
            btn.addTarget(self, action: #selector(buttonClick(btn:)), for: .touchUpInside);
            self.addSubview(btn);
            itemViewsArray.append(btn);
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews();
        let insert = self.contentInsert ?? UIEdgeInsets.zero;
        
        let width = frame.width - insert.left - insert.right;
        let height = frame.height - insert.top - insert.bottom;
        let itemWidth = Double(width / 7 * 0.7);
        
        let rowGap = (Double(height) - 6 * itemWidth)/5
        let colGap = (Double(width) - 7 * itemWidth)/6;
        
        for (index,btn) in self.itemViewsArray.enumerated() {
            let row = index / 7;
            let col = index % 7;
            btn.layer.cornerRadius = CGFloat(itemWidth/2.0);
            btn.frame = CGRect.init(x: Double(col) * (itemWidth + colGap) + Double(insert.left), y: Double(row) * (itemWidth + rowGap) + Double(insert.top), width: itemWidth, height: itemWidth);
        }
    }
    
    func updateMonthView(WithMonthInfo monthInfo: (year: Int, month: Int)) {

        // 上一个月的数据
        var lastMonth = monthInfo.month - 1;
        var lastYear = monthInfo.year;
        if lastMonth <= 0 {
            lastMonth = 12 - lastMonth;
            lastYear -= 1;
        }
        let lastMonthDetailInfo = DDDateCal.monthInfo(year: lastYear, month: lastMonth);
        
        // 下一个月的数据
        var nextMonth = monthInfo.month + 1;
        var nextYear = monthInfo.year;
        if nextMonth > 12 {
            nextMonth = nextMonth - 12;
            nextYear += 1;
        }
        
        //当前月信息
        let monthDetailInfo = DDDateCal.monthInfo(year: monthInfo.year, month: monthInfo.month);
        let startIndex = monthDetailInfo.firstWeekDay == 7 ? 0 : monthDetailInfo.firstWeekDay;
        let endIndex = monthDetailInfo.dayCount - 1 + startIndex;
        
        for (index,btn) in itemViewsArray.enumerated() {
            let day = index - startIndex + 1;
            if index < startIndex { // 上个月
                btn.setTitleColor(UIColor.lightGray, for: .normal)
                let lastDay = day + lastMonthDetailInfo.dayCount;
                btn.setTitle(String.init(format: "%d", lastDay), for: .normal);
                
                btn.dateInfo = (lastYear,lastMonth,lastDay);
                btn.monthType = .last;
                
            } else if  index > endIndex { // 下个月
                btn.setTitleColor(UIColor.lightGray, for: .normal)
                let nextDay = day - monthDetailInfo.dayCount;
                btn.setTitle(String.init(format: "%d", nextDay), for: .normal);
                
                btn.dateInfo = (nextYear,nextMonth,nextDay);
                btn.monthType = .next;
                
            } else {// 当前月
                btn.setTitle(String.init(format: "%d", day), for: .normal);
                btn.setTitleColor(UIColor.black  , for: .normal);
                
                btn.dateInfo = (monthInfo.year,monthInfo.month,day);
                btn.monthType = .current;
            }
            
            if (self.delegate?.responds(to: #selector(DDMonthViewDelegate.monthView(monthView:shouldUpdateItem:))))! {
                self.delegate?.monthView?(monthView: self, shouldUpdateItem: btn);
            }
        }
    }
    
    @objc func buttonClick(btn:UIButton)  {
        if (self.delegate?.responds(to: #selector(DDMonthViewDelegate.monthView(monthView:didSelectedItem:))))! {
            self.delegate?.monthView?(monthView: self, didSelectedItem: btn);
        }
    }
    
}
