//
//  DDInfiniteScrollView.swift


import UIKit

@objc protocol DDInfiniteScrollViewDelegate : NSObjectProtocol {
    func infiniteScrollView(_ infiniteScrollView: DDInfiniteScrollView, temViewForOffset offset: Int) -> UIView;
    @objc optional func infiniteScrollView(_ infiniteScrollView: DDInfiniteScrollView, didEndScroll offset: Int);
}

@IBDesignable class DDInfiniteScrollView: UIView,UIScrollViewDelegate {
    let scrollView = UIScrollView.init();
    var itemsArray = Array<UIView>()
    
    private var reusableItemViews : [UIView] = Array();
    var offset = 0;
    weak var delegate : DDInfiniteScrollViewDelegate?;
    // MARK: - override
    override init(frame: CGRect) {
        super.init(frame: frame);
        self.renderUI();
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder);
        self.renderUI();
    }
    
    override func layoutSubviews() {
        super.layoutSubviews();
        updateFrame();
        reloadData();
    }
    
    //MARK: - delegate
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        resetContentOffset();
        if (self.delegate?.responds(to: #selector(DDInfiniteScrollViewDelegate.infiniteScrollView(_:didEndScroll:))))!{
            self.delegate?.infiniteScrollView!(self, didEndScroll: offset);
        }
    }
    
    //MARK: - public
    func dequeueReusableItemView() -> UIView? {
        if reusableItemViews.count > 0 {
            let itemView = reusableItemViews.first;
            reusableItemViews.removeFirst();
            return itemView;
        }
        return nil;
    }
    
    func changeOffset(newOffset : Int)  {
        offset = newOffset;
        reloadData();
    }
    
    func reloadData() {
        guard let delegate = self.delegate else {
            return;
        }
        reusableItemViews.removeAll();
        reusableItemViews.append(contentsOf: itemsArray);
        
        for index in -1...1 {
            let itemView = delegate.infiniteScrollView(self, temViewForOffset:offset + index);
            if !itemsArray.contains(itemView) {
                itemsArray.append(itemView);
                scrollView.addSubview(itemView)
            }
            itemView.frame.origin = CGPoint.init(x: scrollView.bounds.width * CGFloat(index + 1), y: 0);
        }
        scrollView.contentOffset = CGPoint.init(x: scrollView.bounds.width, y: 0);
        if (self.delegate?.responds(to: #selector(DDInfiniteScrollViewDelegate.infiniteScrollView(_:didEndScroll:))))!{
            self.delegate?.infiniteScrollView?(self, didEndScroll: offset);
        }
    }
    
    //MARK: - private
    func renderUI() {
        #if TARGET_INTERFACE_BUILDER
            self.scrollView.backgroundColor = UIColor.groupTableViewBackground;
        #endif
        
        scrollView.isPagingEnabled = true;
        scrollView.bounces = false;
        scrollView.showsHorizontalScrollIndicator = false;
        scrollView.delegate = self;
        self.addSubview(scrollView);
    }
    
    func updateFrame()  {
        scrollView.frame = self.bounds;
        scrollView.contentSize = CGSize.init(width: scrollView.bounds.width * 3, height: self.bounds.height);
    }
    
    private func resetContentOffset()  {
        guard let delegate = self.delegate else {
            return;
        }
        
        if itemsArray.count == 0 {
            return;
        }
        // 向左滑动
        if scrollView.contentOffset.x >= 2.0 * scrollView.bounds.width {
            
            offset += 1;
            let view0 = itemsArray[1];
            view0.frame.origin = CGPoint.init(x: 0, y: 0);
            
            let view1 = itemsArray[2];
            view1.frame.origin = CGPoint.init(x: scrollView.bounds.width , y: 0);
            
            reusableItemViews.append(itemsArray[0]);
            
            
            let nextView = delegate.infiniteScrollView(self, temViewForOffset: offset + 1);
            nextView.frame.origin = CGPoint.init(x: scrollView.bounds.width * 2 , y: 0);
            
            
            itemsArray[0] = view0;
            itemsArray[1] = view1;
            itemsArray[2] = nextView;
            
            
            scrollView.contentOffset = CGPoint.init(x: scrollView.bounds.width, y: 0);
            
            // 向右滑动
        } else if scrollView.contentOffset.x < scrollView.bounds.width {
            
            offset -= 1;
            
            let view1 = itemsArray[0];
            view1.frame.origin = CGPoint.init(x: scrollView.bounds.width, y: 0);
            
            let view2 = itemsArray[1];
            view2.frame.origin = CGPoint.init(x: scrollView.bounds.width * 2, y: 0);
            
            reusableItemViews.append(itemsArray[2]);
            let nextView = delegate.infiniteScrollView(self, temViewForOffset: offset - 1);
            nextView.frame.origin = CGPoint.init(x:  0, y: 0);
            
            itemsArray[0] = nextView;
            itemsArray[1] = view1;
            itemsArray[2] = view2;
            
            scrollView.contentOffset = CGPoint.init(x: scrollView.bounds.width, y: 0);
            
        } else {
            let view2 = itemsArray[2];
            view2.frame.origin = CGPoint.init(x: scrollView.bounds.width * 2 , y: 0);
            
            let view1 = itemsArray[1];
            view1.frame.origin = CGPoint.init(x: scrollView.bounds.width , y: 0);
            
            let view0 = itemsArray[0];
            view0.frame.origin = CGPoint.init(x: 0, y: 0);
        }
    }
}
