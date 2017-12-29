//
//  BARSlimeDotView_Swift.swift
//  BARSlimeDotView
//
//  Created by Barray on 2017/12/29.
//  Copyright © 2017年 Barray. All rights reserved.
//

import UIKit

let BARThemeColor = UIColor.red
let MOVEDOT_W:CGFloat  = 30.0
let FIXEDOT_SCALE_MIN:CGFloat = 0.25
let MAXDISTANCE:CGFloat = 180


class BARSlimeDotView_Swift: UIView {
    
    lazy var moveDot: CALayer = {
        let _moveDot = CALayer.init()
        _moveDot.frame = CGRect(x: 0, y: 0, width: MOVEDOT_W, height: MOVEDOT_W)
        _moveDot.cornerRadius = CGFloat(MOVEDOT_W/2)
        _moveDot.backgroundColor = BARThemeColor.cgColor
        return _moveDot
    }()
    
    lazy var fixedDot: CALayer = {
        let _fixedDot = CALayer.init()
        _fixedDot.frame = CGRect(x: 0, y: 0, width: MOVEDOT_W, height: MOVEDOT_W)
        _fixedDot.cornerRadius = CGFloat(MOVEDOT_W/2)
        _fixedDot.backgroundColor = BARThemeColor.cgColor
        return _fixedDot
    }()
    lazy var shapLayer: CAShapeLayer = {
        let _shapLayer = CAShapeLayer.init()
        _shapLayer.fillColor = BARThemeColor.cgColor;
        _shapLayer.position = CGPoint.init(x: 0, y: 0);
        return _shapLayer
    }()
    
    override init(frame: CGRect) {
        
        super.init(frame: frame)
        
        self.shapLayer.frame = CGRect(x: 0, y: 0, width: frame.width, height: frame.height)
        self.moveDot.position = CGPoint.init(x: frame.width/2, y: frame.height/2)
        self.fixedDot.position = CGPoint.init(x: frame.width/2, y: frame.height/2)
        self.layer.addSublayer(self.shapLayer)
        self.layer.addSublayer(self.moveDot)
        self.layer.addSublayer(self.fixedDot)
        
        let panGestrue = UIPanGestureRecognizer.init(target: self, action: #selector(panMoveDot(panGesture:)))
        self.addGestureRecognizer(panGestrue)
    }
    
    //MARK: - 绘制贝塞尔图形
    private func reloadBeziePath(){
        let r1 = self.fixedDot.frame.width/2.0
        let r2 = self.moveDot.frame.width/2.0
        
        let x1 = self.fixedDot.position.x
        let y1 = self.fixedDot.position.y
        let x2 = self.moveDot.position.x
        let y2 = self.moveDot.position.y
        
        let distance = sqrt(pow((x2 - x1), 2) + pow((y2 - y1), 2))
        
        let sinDegree = (x2 - x1) / distance
        let cosDegree = (y2 - y1) / distance
        
        let pointA = CGPoint(x: x1 - r1 * cosDegree, y: y1 + r1 * sinDegree)
        let pointB = CGPoint(x: x1 + r1 * cosDegree, y:  y1 - r1 * sinDegree)
        let pointC = CGPoint(x: x2 + r2 * cosDegree, y: y2 - r2 * sinDegree)
        let pointD = CGPoint(x: x2 - r2 * cosDegree, y:y2 + r2 * sinDegree)
        let pointN = CGPoint(x: pointB.x + (distance / 2) * sinDegree, y: pointB.y + (distance / 2) * cosDegree)
        let pointM = CGPoint(x: pointA.x + (distance / 2) * sinDegree, y: pointA.y + (distance / 2) * cosDegree)
        
        let path = UIBezierPath()
        path.move(to: pointA)
        path.addLine(to: pointB)
        path.addQuadCurve(to: pointC, controlPoint: pointN)
        path.addLine(to: pointD)
        path.addQuadCurve(to: pointA, controlPoint: pointM)
        self.shapLayer.path = path.cgPath
        self.shapLayer.isHidden = false
    }
    
    //MARK: - 计算圆心距
    private func getDistanceBetweenDots() ->CGFloat{
        let x1 = self.fixedDot.position.x
        let y1 = self.fixedDot.position.y
        let x2 = self.moveDot.position.x
        let y2 = self.moveDot.position.y
        
        let distance = sqrt(pow((x1-x2), 2)+pow((y1-y2), 2))
        
        return distance
    }
    
    //MARK: - 拖动手势
    @objc private func panMoveDot(panGesture:UIPanGestureRecognizer){
        switch panGesture.state {
        case UIGestureRecognizerState.changed:
            let location = panGesture.location(in: self)
            
            CATransaction.begin()
            CATransaction.setDisableActions(true)
            self.moveDot.position = location
            CATransaction.commit()
            
            let distance = self.getDistanceBetweenDots()
            if distance < MAXDISTANCE{
                var scale = (1 - distance/MAXDISTANCE)
                scale = max(scale, FIXEDOT_SCALE_MIN)
                CATransaction.begin()
                CATransaction.setDisableActions(true)
                self.fixedDot.isHidden = false
                self.fixedDot.setAffineTransform(CGAffineTransform(scaleX: scale, y: scale))
                CATransaction.commit()
                
                self.reloadBeziePath()
            } else{
                self.layerBroke()
            }
        case UIGestureRecognizerState.ended:
            let distance = self.getDistanceBetweenDots()
            if distance >= MAXDISTANCE{
                self.removeFromSuperview()
            } else{
                self.placeMoveDot()
            }
            
        default:
            break
        }
    }
    
    //MARK: - 贝塞尔图像破裂消失动画
    private func layerBroke(){
        self.shapLayer.path = nil
        UIView.animate(withDuration: 0.7, delay: 0, usingSpringWithDamping: 0.2, initialSpringVelocity: 0, options: UIViewAnimationOptions.beginFromCurrentState, animations: {
            CATransaction.begin()
            CATransaction.setDisableActions(true)
            self.fixedDot.setAffineTransform(CGAffineTransform(scaleX: 1, y: 1))
            CATransaction.commit()
        }) { (finished) in
            self.fixedDot.isHidden = true
        }
    }
    
    //MARK: - 还原到原位置
    private func placeMoveDot(){
        UIView.animate(withDuration: 0.25, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0, options: UIViewAnimationOptions.beginFromCurrentState, animations: {
            CATransaction.begin()
            CATransaction.setDisableActions(true)
            self.moveDot.position = CGPoint(x: self.frame.width/2, y: self.frame.height/2)
            self.shapLayer.isHidden = true
            self.moveDot.backgroundColor = BARThemeColor.cgColor
            CATransaction.commit()
        }) { (finished) in
            self.fixedDot.isHidden = false
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
}
