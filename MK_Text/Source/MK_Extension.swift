//
//  MK_Extension.swift
//  MK_Text
//
//  Created by MBP on 2018/1/25.
//  Copyright © 2018年 MBP. All rights reserved.
//

import Foundation
import CoreGraphics

#if os(macOS)
    import AppKit

    //MARK:- NSBezierPath 扩展
    public extension NSBezierPath{

        public var CGPath: CGPath
        {
            let path = CGMutablePath()
            var points = [CGPoint](repeating: .zero, count: 3)
            for i in 0 ..< self.elementCount {
                let type = self.element(at: i, associatedPoints: &points)
                switch type {
                case .moveToBezierPathElement: path.move(to: CGPoint(x: points[0].x, y: points[0].y) )
                case .lineToBezierPathElement: path.addLine(to: CGPoint(x: points[0].x, y: points[0].y) )
                case .curveToBezierPathElement: path.addCurve(to: CGPoint(x: points[2].x, y: points[2].y),
                                                              control1: CGPoint(x: points[0].x, y: points[0].y),
                                                              control2: CGPoint(x: points[1].x, y: points[1].y) )
                case .closePathBezierPathElement: path.closeSubpath()
                }
            }
            return path
        }
    }
#endif

//MARK:- 富文本扩展
extension NSAttributedString {

    ///获取富文本字符串的快捷方式
    var range:NSRange{
        get{
            return NSRange.init(location: 0, length: self.length)
        }
    }

    ///获取指定属性的值~
    func getAttributeValue<R>(name:NSAttributedStringKey)->R?{
        var res:R? = nil
        self.enumerateAttributes(in: self.range, options: NSAttributedString.EnumerationOptions.init(rawValue: 1)) { (dic, ran, boolP) in
            if let acc = dic[name] as? R {
                res = acc
            }
        }
        return res
    }
}

public extension NSMutableAttributedString {

    ///增加/修改属性的同时刷新Label
    public func mk_setAttrtbute(dic:[NSAttributedStringKey : Any], range: NSRange){
        self.addAttributes(dic, range: range)
        guard let label:MK_Label = self.getAttributeValue(name: NSAttributedStringKey.init(MK_Label.AttributeKey)) else { return }
        label.reDraw()
    }

}

extension MK_View {

    func getBoundsThreadSafe()->CGSize{
        if Thread.current.isMainThread {
            return self.bounds.size
        }
        var size:CGSize = CGSize.zero
        let sema = DispatchSemaphore.init(value: 0)
        OperationQueue.main.addOperation {
            size = self.bounds.size
            sema.signal()
        }
        _ = sema.wait(timeout: DispatchTime.now()+10)
        return size
    }
}

