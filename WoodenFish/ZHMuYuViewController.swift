//
//  ZHMuYuViewController.swift
//  swiftDemo2
//
//  Created by zhanghao on 2023/1/31.
//  Copyright © 2023 张浩. All rights reserved.
//

import UIKit
import SwiftUI
import FluentDarkModeKit
import SnapKit

class ZHMuYuViewController: UIViewController {
    var imgV : UIImageView!
    var num : Int = 0
    var voiceOn : Bool! = true//
    var vibrateOn : Bool! = true//
    var autoplayOn : Bool! = false//
    var floatLabel : UILabel!
    let labelW : CGFloat = 70.0
    let labelH : CGFloat = 30.0
    let labelX : CGFloat = kScreenWidth/2-70/2
    let moveS : CGFloat = 60.0
    var vibrateSize : String = "小"
    var floatTitle : String = "功德+1"
    var type : Int = 0
    var color : UIColor = UIColor(.dm, light: .black, dark: .white)
    var timer = Timer()
    var autoTime : Double = 1.0
    var voiceIndex : Int = 1
    var isDarkModel = UserDefaults.standard.value(forKey: "isDarkModel")
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        timer.invalidate()
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        initData()
        setupUI()
    }
    func initData() {
        type = 0
        color = UIColor(.dm, light: .black, dark: .white)
        if let muyuType = UserDefaults.standard.value(forKey: "muyuType"){
            type = (muyuType as! Int)
        }
        if let muyuColor = UserDefaults.standard.value(forKey: "muyuColor"){
            color = UIColor.init(hexString: muyuColor as! String)!
        }
    }
    func setupUI() {
        self.view.backgroundColor = UIColor(.dm, light: .white, dark: .tableViewBgC_dark)
        
        
        let darkBtn = QMUIButton(type: UIButton.ButtonType.custom)
        darkBtn.frame = CGRectMake(0, 0, 30, 30)
        darkBtn.tintColor = UIColor(.dm, light: .black, dark: .white)
        darkBtn.layer.cornerRadius = 10
        darkBtn.setImage(UIImage.init(systemName: "moon.fill"), for: UIControl.State.normal)
        darkBtn.setImage(UIImage.init(systemName: "sun.min.fill"), for: UIControl.State.selected)
//        DMTraitCollection.override.userInterfaceStyle
        if isDarkModel as? String == "dark" {
            darkBtn.isSelected = true
            DMTraitCollection.setOverride(DMTraitCollection(userInterfaceStyle: .dark), animated: true)
        }else{
            darkBtn.isSelected = false
            
            DMTraitCollection.setOverride(DMTraitCollection(userInterfaceStyle: .light), animated: true)
        }
        self.navigationItem.leftBarButtonItem = UIBarButtonItem.init(customView: darkBtn)
      
        darkBtn.addTarget(self, action: #selector(darkBtnAction(btn:)), for: .touchUpInside)
        
        
        let largeConfig = UIImage.SymbolConfiguration(pointSize: 22, weight: .regular, scale: .small)
        let settingBtn = QMUIButton()
        settingBtn.setImage(UIImage.init(systemName: "gearshape",withConfiguration: largeConfig), for: UIControl.State.normal)
        settingBtn.tintColor = UIColor(.dm, light: .black, dark: .white)
        self.navigationItem.rightBarButtonItem = UIBarButtonItem.init(customView: settingBtn)
        settingBtn.addTarget(self, action: #selector(settingBtnAction), for: .touchUpInside)
    
        imgV = UIImageView()
        view.addSubview(imgV)
        imgV.frame = CGRect.init(x: 0, y: 0, width: 200, height: 200)
        imgV.center.x = view.center.x
        imgV.center.y = view.center.y 
        imgV.tintColor = .red
        if let muyuNum = UserDefaults.standard.value(forKey: "muyuNum"){
            let numStr : Int = muyuNum as! Int
            num = numStr
        }
        setImgColor(type, color)
        view.addSubview(numberCounter)
        if let str = UserDefaults.standard.value(forKey: "floatTitle"){
            let floatTitleStr : String = str as! String
            self.floatTitle = floatTitleStr
        }
    }
    @objc func darkBtnAction(btn:QMUIButton) {
        WoodenFish.systemVibration(style: .soft)
        btn.isSelected = !btn.isSelected
        DMTraitCollection.setOverride(DMTraitCollection(userInterfaceStyle: btn.isSelected ? .dark : .light), animated: true)
        UserDefaults.standard.setValue(btn.isSelected ? "dark" : "light", forKey: "isDarkModel")
    }
    
    @objc func settingBtnAction() {
        let settingVC: PanModalPresentable.LayoutType = ZHMuYuSettingViewController()
        let setVC = settingVC as! ZHMuYuSettingViewController
        setVC.voiceSwitch.isOn = self.voiceOn
        setVC.vibrateSwitch.isOn = self.vibrateOn
        setVC.autoplaySwitch.isOn = self.autoplayOn
        setVC.autoTime = self.autoTime
        setVC.floatTitleTF.text = self.floatTitle
        setVC.typeBtn.setTitle(vibrateSize, for: UIControl.State.normal)
        setVC.timeBtn.isHidden = !self.autoplayOn
        setVC.voiceView.isHidden = !self.voiceOn
        
//        setVC.voiceView.mView.isHidden = !self.voiceOn
        setVC.voiceIndex = voiceIndex
        setVC.setVoice()
        setVC.settingCompletion = { [self] voiceOn,vibrateOn,type,color,vibrateSize,autoplayOn,autoTime,voiceIndex,floatTitle in
            self.voiceOn = voiceOn
            self.vibrateOn = vibrateOn
            self.type = type
            self.color = color
            self.vibrateSize = vibrateSize
            self.autoTime = autoTime
            self.voiceIndex = voiceIndex
            self.floatTitle = floatTitle
            UserDefaults.standard.setValue(type, forKey: "muyuType")
            UserDefaults.standard.setValue(color.hexString, forKey: "muyuColor")
            UserDefaults.standard.setValue(floatTitle, forKey: "floatTitle")
            setImgColor(type,color)
            self.autoplayOn = autoplayOn
            if autoplayOn {
                self.timer = Timer.scheduledTimer(withTimeInterval: autoTime, repeats: true, block: { [self] _ in
                    playAction()
                })
            }else{
                timer.invalidate()
            }
        }
        setVC.initData(type, color)
        self.presentPanModal(settingVC)
    }
    func setImgColor(_ index : Int, _ color : UIColor) {
        imgV.tintColor = color
        if index == 0 {
            var image = UIImage(named: "muyumu")
            let templateImage = image!.withRenderingMode(.alwaysOriginal)
            image = templateImage
            imgV.image = image
        }else if index == 1 {
            let lightImage = UIImage(named: "muyuhei")!
            let darkImage = UIImage(named: "muyubai")!
            var image = UIImage(.dm, light: lightImage, dark: darkImage)
            let templateImage = image.withRenderingMode(.alwaysTemplate)
            image = templateImage
            imgV.image = image
        }else{
            
        }
    }
    private lazy var numberCounter: NumberScrollCounter = {
        let numberCounter = NumberScrollCounter(value: String(num), scrollDuration: 0.3, prefix: "", suffix: "", font:UIFont.systemFont(ofSize: 30), textColor: UIColor(.dm, light: .black, dark: .white), gradientColor: .clear, gradientStop: 0.2)
        numberCounter.frame = CGRect.init(x: 0, y: 100, width: 0, height: 50)
        numberCounter.center.x = view.center.x - String(num).textWidth(fontSize: 30, height: 30)/2
        return numberCounter
    }()
    func systemSound() {
        //建立的SystemSoundID对象
        var soundID:SystemSoundID = 0
        //获取声音地址
        let path = Bundle.main.path(forResource: "muyu"+String(voiceIndex), ofType: "mp3")
        //地址转换
        let baseURL = NSURL(fileURLWithPath: path!)
        //赋值
        AudioServicesCreateSystemSoundID(baseURL, &soundID)
        //播放声音
        AudioServicesPlaySystemSound(soundID)
    }
    func systemVibration() {
        let impact = UIImpactFeedbackGenerator(style: systemVibrationSize(vibrateSize))
        impact.impactOccurred()
    }
    func systemVibrationSize(_ str:String)->UIImpactFeedbackGenerator.FeedbackStyle {
        switch str {
        case "小":
            return UIImpactFeedbackGenerator.FeedbackStyle.light
        case "中":
           return UIImpactFeedbackGenerator.FeedbackStyle.medium
        case "大":
           return UIImpactFeedbackGenerator.FeedbackStyle.heavy
        case "柔和":
           return UIImpactFeedbackGenerator.FeedbackStyle.soft
        case "激烈":
           return UIImpactFeedbackGenerator.FeedbackStyle.rigid
        default:
           return UIImpactFeedbackGenerator.FeedbackStyle.light
        }
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        playAction()
    }
    func playAction(){
        if voiceOn {
            systemSound()
        }
        if vibrateOn {
            systemVibration()
        }
        if !autoplayOn {
            num = num + 1
            numberCounter.setValue("\(num)")
            numberCounter.center.x = view.center.x - String(num).textWidth(fontSize: 30, height: 30)/2
            UserDefaults.standard.set(num, forKey: "muyuNum")
        }
        DispatchQueue.main.async { [self] in
            UIView.animate(withDuration: 0.2, delay: 0) { [self] in
                imgV.size = CGSizeMake(210, 210)
            }completion: { [self] bool in
                imgV.size = CGSizeMake(200, 200)
            }
            floatLabel = UILabel()
            floatLabel.text = self.floatTitle
            floatLabel.textColor = UIColor(.dm, light: .black, dark: .white)
            floatLabel.font = UIFont.systemFont(ofSize: 15)
            floatLabel.alpha = 0.0
            view.addSubview(floatLabel)
            floatLabel.frame = CGRect.init(x: labelX, y: imgV.qmui_top+30, width: labelW, height: labelH)
            let animation:CAKeyframeAnimation = CAKeyframeAnimation()
            animation.duration = 1.0
            animation.keyPath = "opacity"
            let valuesArray:[NSNumber] = [NSNumber(value: 0.95 as Float),
                                                 NSNumber(value: 0.90 as Float),
                                                 NSNumber(value: 0.88 as Float),
                                                 NSNumber(value: 0.85 as Float),
                                                 NSNumber(value: 0.35 as Float),
                                                 NSNumber(value: 0.05 as Float),
                                                 NSNumber(value: 0.0 as Float)]
            animation.values = valuesArray
            animation.fillMode = CAMediaTimingFillMode.forwards
            animation.isRemovedOnCompletion = true
            let startPoint = CGPoint(x:labelX , y:imgV.qmui_top+30)//曲线开始位置
            let endPoint = CGPoint(x: labelX - randomCGFloatNumber(lower: -moveS,upper: moveS), y: imgV.qmui_top-150)//曲线终点位置
            let controlPoint = CGPoint(x: labelX - randomCGFloatNumber(lower: -moveS,upper: moveS), y:imgV.qmui_top-50)//曲线中间位置
            let layer = CAShapeLayer()
            let quxianPath = UIBezierPath()
            quxianPath.move(to: startPoint) //首先移动到初始点
            quxianPath.addQuadCurve(to: endPoint, controlPoint: controlPoint) //定义终点点和中间点
            layer.path = quxianPath.cgPath
            layer.fillColor = UIColor.clear.cgColor
            layer.strokeColor = UIColor.green.cgColor
            //获取贝塞尔曲线的路径
            let animationPath = CAKeyframeAnimation.init(keyPath: "position")
            animationPath.path = quxianPath.cgPath
            animationPath.rotationMode = .none
            animationPath.isRemovedOnCompletion = true
            let scaleAnimation = CABasicAnimation(keyPath: "transform.scale")
            //开始时的倍率
            scaleAnimation.fromValue = 1.0
            //结束时的倍率
            scaleAnimation.toValue = 1.5
            scaleAnimation.duration = 1
            scaleAnimation.repeatCount = 1
            scaleAnimation.autoreverses = true
            let animationGroup:CAAnimationGroup = CAAnimationGroup()
            animationGroup.animations = [animationPath,animation,scaleAnimation]
            animationGroup.duration = 1.0;
            animationGroup.delegate = self
            animationGroup.fillMode = CAMediaTimingFillMode.forwards;
            animationGroup.isRemovedOnCompletion = true
            floatLabel.layer.add(animationGroup, forKey: nil)
        }
    }
     func randomIntNumber(lower: Int = 0,upper: Int = Int(UInt32.max)) -> Int {
        return lower + Int(arc4random_uniform(UInt32(upper - lower)))
    }
     func randomIntNumber(range: Range<Int>) -> Int {
        return randomIntNumber(lower: range.lowerBound, upper: range.upperBound)
    }
    func randomCGFloatNumber(lower: CGFloat = 0,upper: CGFloat = 1) -> CGFloat {
        let result = CGFloat(arc4random_uniform(UInt32(upper - lower + 1))) + lower
        return result
//        return CGFloat(Float(arc4random()) / Float(UInt32.max)) * (upper - lower) + lower
    }
}
extension ZHMuYuViewController : CAAnimationDelegate {
    func animationDidStart(_ anim: CAAnimation) {
//        floatLabel.isHidden = false
//        floatLabel.removeFromSuperview()
    }
    func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        print(flag)
//        floatLabel.removeFromSuperview()
        if flag {
//            floatLabel.removeFromSuperview()
        }
    }
}

