//
//  CAGradientLayer+GradientBG.swift
//  SiriSpeech
//
//  Created by Wei Zhou on 14/12/2016.
//  Copyright © 2016 Wei Zhou. All rights reserved.
//

import UIKit

extension CAGradientLayer {
    
    func GradientLayer() -> CAGradientLayer {
        //定义渐变的颜色，多色渐变太魔性了，我们就用两种颜色
        let topColor = UIColor(red: (238/255.0), green: (88/255.0), blue: (238/255.0), alpha: 1)
        let buttomColor = UIColor(red: (251/255.0), green: (133/255.0), blue: (116/255.0), alpha: 1)
        
        //将颜色和颜色的位置定义在数组内
        let gradientColors: [CGColor] = [topColor.cgColor, buttomColor.cgColor]
        let gradientLocations: [CGFloat] = [0.0, 1.0]
        
        //创建CAGradientLayer实例并设置参数
        let gradientLayer: CAGradientLayer = CAGradientLayer()
        gradientLayer.colors = gradientColors
        gradientLayer.locations = gradientLocations as [NSNumber]?
        
        return gradientLayer
    }
}
