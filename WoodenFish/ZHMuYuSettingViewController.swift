//
//  ZHMuYuSettingViewController.swift
//  swiftDemo2
//
//  Created by zhanghao on 2023/2/1.
//  Copyright © 2023 张浩. All rights reserved.
//

import UIKit
import FluentDarkModeKit
import SnapKit
class ZHMuYuSettingViewController: UIViewController {
    typealias SettingCompletionBlock = (_ voiceOn:Bool,_ vibrateOn:Bool,_ index:Int,_ color:UIColor,_ vibrateSize:String,_ autoplayOn:Bool,_ autoTime:Double,_ voiceIndex:Int,_ floatTitle:String) -> Void
    var settingCompletion : SettingCompletionBlock?
    var itemArr : NSMutableArray = []
    var timeArr : NSMutableArray = [0.3,0.5,1.0,1.5,2.0]
    var timeItemArr : NSMutableArray = []
    var currentColor : UIColor = UIColor(.dm, light: .black, dark: .white)
    var type : Int = 0
    var autoTime : Double = 1.0
    var voiceIndex : Int = 1
    override func viewDidLoad() {
        super.viewDidLoad()
        initData()
        setupUI()
    }
    func setupUI() {
        self.view.resignFirstResponder()
        self.view.backgroundColor = UIColor(.dm, light: .white, dark: .tableViewBgC_dark)
        view.addSubview(voiceL)
        view.addSubview(voiceSwitch)
        view.addSubview(voiceView)
        view.addSubview(vibrateL)
        view.addSubview(vibrateSwitch)
        view.addSubview(vibrateSizeL)
        view.addSubview(typeBtn)
        view.addSubview(colorL)
        view.addSubview(colorBtn)
        view.addSubview(muBtn)
        view.addSubview(autoplayL)
        view.addSubview(autoplaySwitch)
        view.addSubview(timeBtn)
        view.addSubview(floatTitleL)
        view.addSubview(floatTitleTF)
        
        voiceL.snp.makeConstraints { make in
            make.left.equalTo(30)
            make.top.equalTo(50)
        }
        voiceSwitch.snp.makeConstraints { make in
            make.right.equalTo(-20)
            make.centerY.equalTo(voiceL)
        }
        voiceView.snp.makeConstraints { make in
            make.left.equalTo(50)
            make.right.equalTo(-50)
            make.top.equalTo(voiceL.snp.bottom).offset(25)
            make.height.equalTo(self.voiceSwitch.isOn ? (kScreenWidth-150)/4+20 : 0)
        }
        vibrateL.snp.makeConstraints { make in
            make.top.equalTo(voiceView.snp.bottom).offset(25)
            make.left.equalTo(voiceL)
        }
        vibrateSwitch.snp.makeConstraints { make in
            make.right.equalTo(voiceSwitch)
            make.centerY.equalTo(vibrateL)
        }
        vibrateSizeL.snp.makeConstraints { make in
            make.left.equalTo(vibrateL)
            make.top.equalTo(vibrateL.snp.bottom).offset(50)
        }
        typeBtn.snp.makeConstraints { make in
            make.right.equalTo(-20)
            make.centerY.equalTo(vibrateSizeL)
            make.height.equalTo(36)
            make.width.equalTo(70)
        }
        colorL.snp.makeConstraints { make in
            make.left.equalTo(vibrateSizeL)
            make.top.equalTo(vibrateSizeL.snp.bottom).offset(50)
        }
        colorBtn.snp.makeConstraints { make in
            make.right.equalTo(vibrateSwitch)
            make.centerY.equalTo(colorL)
            make.width.height.equalTo(36)
        }
        muBtn.snp.makeConstraints { make in
            make.right.equalTo(colorBtn.snp.left).offset(-20)
            make.centerY.equalTo(colorBtn)
            make.height.width.equalTo(50)
        }
        autoplayL.snp.makeConstraints { make in
            make.left.equalTo(colorL)
            make.top.equalTo(colorL.snp.bottom).offset(50)
        }
        autoplaySwitch.snp.makeConstraints { make in
            make.right.equalTo(voiceSwitch)
            make.centerY.equalTo(autoplayL)
        }
        timeBtn.snp.makeConstraints { make in
            make.right.equalTo(autoplaySwitch.snp.left).offset(-20)
            make.centerY.equalTo(autoplaySwitch)
            make.height.equalTo(36)
            make.width.equalTo(70)
        }
        floatTitleL.snp.makeConstraints { make in
            make.left.equalTo(autoplayL)
            make.top.equalTo(autoplayL.snp.bottom).offset(50)
        }
        floatTitleTF.snp.makeConstraints { make in
            make.centerY.equalTo(floatTitleL)
            make.right.equalTo(autoplaySwitch)
            make.height.equalTo(36)
            make.width.equalTo(100)
        }
    }
    func setVoice() {
//        voiceView.snp.updateConstraints { make in
//            make.height.equalTo(self.voiceSwitch.isOn ? (kScreenWidth-150)/4+20 : 0)
//        }
        voiceView.currentPath = IndexPath(row: voiceIndex-1, section: 0)
        voiceView.collectionView.reloadData()
    }
    lazy var voiceView: ZHMuYuVoiceView = {
        var voiceView = ZHMuYuVoiceView()
        voiceView.backgroundColor = UIColor(.dm, light: .white, dark: .tableViewBgC_dark)
        voiceView.layer.cornerRadius = 10
        voiceView.cellClicked = { [self] index in
            voiceIndex = index
        }
        return voiceView
    }()
    lazy var muBtn: QMUIButton = {
        var muBtn = QMUIButton(type: .custom)
        muBtn.layer.cornerRadius = 25
        muBtn.layer.borderColor = UIColor(.dm,light:.black,dark:.white).cgColor
        muBtn.layer.borderWidth = 1
        muBtn.setImage(UIImage(named: "muyumu"), for: UIControl.State.normal)
        muBtn.tag = 0
        muBtn.addTarget(self, action: #selector(muBtnAction(btn:)), for: .touchUpInside)
      
        return muBtn
    }()
    lazy var colorBtn: QMUIButton = {
        var colorBtn = QMUIButton(type: .custom)
        colorBtn.layer.cornerRadius = 18
        colorBtn.layer.borderColor = UIColor(.dm,light:.black,dark:.white).cgColor
        colorBtn.layer.borderWidth = 0
        colorBtn.tag = 1
        colorBtn.addTarget(self, action: #selector(colorBtnAction(btn:)), for: .touchUpInside)
        return colorBtn
    }()
    lazy var floatTitleL: QMUILabel = {
        var floatTitleL = QMUILabel()
        
        floatTitleL.textColor = UIColor(.dm,light:.black,dark:.white)
        floatTitleL.font = UIFont.systemFont(ofSize: 15)
        floatTitleL.text = "弹出文字"
        return floatTitleL
    }()
    lazy var colorL: QMUILabel = {
        var colorL = QMUILabel()
        colorL.textColor = UIColor(.dm,light:.black,dark:.white)
        colorL.font = UIFont.systemFont(ofSize: 15)
        colorL.text = "颜色"
        return colorL
    }()
    lazy var voiceL: QMUILabel = {
        var voiceL = QMUILabel()
        voiceL.textColor = UIColor(.dm,light:.black,dark:.white)
        voiceL.font = UIFont.systemFont(ofSize: 15)
        voiceL.text = "声音"
        return voiceL
    }()
    lazy var vibrateL: QMUILabel = {
        var vibrateL = QMUILabel()
        vibrateL.textColor = UIColor(.dm,light:.black,dark:.white)
        vibrateL.font = UIFont.systemFont(ofSize: 15)
        vibrateL.text = "震动"
        return vibrateL
    }()
    lazy var vibrateSizeL: QMUILabel = {
        var vibrateSizeL = QMUILabel()
        vibrateSizeL.textColor = UIColor(.dm,light:.black,dark:.white)
        vibrateSizeL.font = UIFont.systemFont(ofSize: 15)
        vibrateSizeL.text = "震动大小"
        return vibrateSizeL
    }()
    lazy var autoplayL: QMUILabel = {
        var autoplayL = QMUILabel()
        autoplayL.textColor = UIColor(.dm,light:.black,dark:.white)
        autoplayL.font = UIFont.systemFont(ofSize: 15)
        autoplayL.text = "自动"
        return autoplayL
    }()
    lazy var floatTitleTF: QMUITextField = {
        var floatTitleTF = QMUITextField()
        floatTitleTF.textColor = UIColor(.dm,light:.black,dark:.white)
        floatTitleTF.font = UIFont.systemFont(ofSize: 15)
        floatTitleTF.backgroundColor = UIColor(.dm,light:.tableViewBgC,dark:.tableViewBgC_dark_dark)
        floatTitleTF.layer.cornerRadius = 10
        let frame = CGRect(x: 0, y: 0, width: 15, height: 36)
        floatTitleTF.leftView = UIView(frame: frame)
        floatTitleTF.leftViewMode = .always
        floatTitleTF.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        return floatTitleTF
    }()
    lazy var autoplaySwitch: UISwitch = {
        var autoplaySwitch = UISwitch()
        autoplaySwitch.onTintColor = UIColor(.dm,light:.tableViewBgC,dark:.black)
//        voiceSwitch.isOn = self.voiceOn
        autoplaySwitch.addTarget(self, action: #selector(autoplaySwitchAction(sender:)), for: .valueChanged)
        return autoplaySwitch
    }()
    lazy var voiceSwitch: UISwitch = {
        var voiceSwitch = UISwitch()
        voiceSwitch.onTintColor = UIColor(.dm,light:.tableViewBgC,dark:.black)
//        voiceSwitch.isOn = self.voiceOn
        voiceSwitch.addTarget(self, action: #selector(voiceSwitchAction(sender:)), for: .valueChanged)
        return voiceSwitch
    }()
    lazy var vibrateSwitch: UISwitch = {
        var vibrateSwitch = UISwitch()
        vibrateSwitch.onTintColor = UIColor(.dm,light:.tableViewBgC,dark:.black)
//        vibrateSwitch.isOn = self.vibrateOn
        vibrateSwitch.addTarget(self, action: #selector(vibrateSwitchAction(sender:)), for: UIControl.Event.valueChanged)
        return vibrateSwitch
    }()
    lazy var typeBtn: QMUIButton = {
        var typeBtn = QMUIButton()
        typeBtn.backgroundColor = UIColor(.dm,light:.tableViewBgC,dark:.tableViewBgC_dark_dark)
        typeBtn.layer.cornerRadius = 8.0
        typeBtn.setTitleColor(UIColor(.dm,light:.black,dark:.white), for: UIControl.State.normal)
        typeBtn.titleLabel?.font = UIFont.systemFont(ofSize: 15)
        typeBtn.setTitle("小", for: UIControl.State.normal)
        typeBtn.addTarget(self, action: #selector(typeBtnAction(btn:)), for: .touchUpInside)
      
        let largeConfig = UIImage.SymbolConfiguration(pointSize: 15, weight: .regular, scale: .small)
        typeBtn.setImage(UIImage.init(systemName: "chevron.down",withConfiguration: largeConfig), for: UIControl.State.normal)
        typeBtn.setImage(UIImage.init(systemName: "chevron.up",withConfiguration: largeConfig), for: UIControl.State.selected)
        typeBtn.tintColor = UIColor(.dm,light:.black,dark:.white)
        typeBtn.spacingBetweenImageAndTitle = 5
        typeBtn.imagePosition = .right
        return typeBtn
    }()
    lazy var timeBtn: QMUIButton = {
        var timeBtn = QMUIButton()
        timeBtn.isHidden = true
        timeBtn.backgroundColor = UIColor(.dm,light:.tableViewBgC,dark:.tableViewBgC_dark_dark)
        timeBtn.layer.cornerRadius = 8.0
        timeBtn.setTitleColor(UIColor(.dm,light:.black,dark:.white), for: UIControl.State.normal)
        timeBtn.titleLabel?.font = UIFont.systemFont(ofSize: 15)
        timeBtn.setTitle(String(format:"%.1f",autoTime)+"秒", for: UIControl.State.normal)
        timeBtn.addTarget(self, action: #selector(timeBtnAction(btn:)), for: .touchUpInside)
        let largeConfig = UIImage.SymbolConfiguration(pointSize: 15, weight: .regular, scale: .small)
        timeBtn.setImage(UIImage.init(systemName: "chevron.down",withConfiguration: largeConfig), for: UIControl.State.normal)
        timeBtn.setImage(UIImage.init(systemName: "chevron.up",withConfiguration: largeConfig), for: UIControl.State.selected)
        timeBtn.tintColor = UIColor(.dm,light:.black,dark:.white)
        timeBtn.spacingBetweenImageAndTitle = 5
        timeBtn.imagePosition = .right
        return timeBtn
    }()
    lazy var popupByWindow: QMUIPopupMenuView = {
        popupByWindow = QMUIPopupMenuView()
        popupByWindow.automaticallyHidesWhenUserTap = true
        popupByWindow.tintColor = .white
        popupByWindow.backgroundColor = .tableViewBgC_dark
        popupByWindow.shouldShowItemSeparator = true
        popupByWindow.items = (itemArr as! [QMUIPopupMenuBaseItem])
        popupByWindow.sourceView = typeBtn
        popupByWindow.didHideBlock = { [self] success in
            typeBtn.isSelected = false
        }
        popupByWindow.itemConfigurationHandler = { aMenuView,aItem,section,index in
            let item : QMUIPopupMenuButtonItem = aItem as! QMUIPopupMenuButtonItem
            item.highlightedBackgroundColor = .tableViewBgC_dark_dark
        }
        return popupByWindow
    }()
    lazy var timePopupByWindow: QMUIPopupMenuView = {
        timePopupByWindow = QMUIPopupMenuView()
        timePopupByWindow.automaticallyHidesWhenUserTap = true
        timePopupByWindow.tintColor = .white
        timePopupByWindow.backgroundColor = .tableViewBgC_dark_dark
        timePopupByWindow.shouldShowItemSeparator = true
        timePopupByWindow.items = (timeItemArr as! [QMUIPopupMenuBaseItem])
        timePopupByWindow.sourceView = timeBtn
        timePopupByWindow.didHideBlock = { [self] success in
            timeBtn.isSelected = false
        }
        timePopupByWindow.itemConfigurationHandler = { aMenuView,aItem,section,index in
        }
        return timePopupByWindow
    }()
    func initData() {
        let arr = ["小","中","大","柔和","激烈"]
        for str in arr {
            let item = QMUIPopupMenuButtonItem.init(image: nil, title: str)
            item.handler = { [self] aItem in
                typeBtn.isSelected = false
                typeBtn.setTitle(aItem.title, for: UIControl.State.normal)
                popupByWindow.hideWith(animated: true)
            }
            itemArr.add(item)
        }
//        let arr2 = ["0.3秒","0.5秒","1.0秒","1.5秒","2.0秒"]
        for str in timeArr {
            let time : String = String(format:"%.1f",str as! Double)
            let item = QMUIPopupMenuButtonItem.init(image: nil, title: (time + "秒"))
            item.handler = { [self] aItem in
                var str : String = aItem.title!
                str = String(str.prefix(str.count-1))
                autoTime = Double(str)!
                timeBtn.isSelected = false
                timeBtn.setTitle(aItem.title, for: UIControl.State.normal)
                timePopupByWindow.hideWith(animated: true)
            }
            timeItemArr.add(item)
        }
    }
    func initData(_ type:Int,_ color:UIColor) {
        self.type = type
        self.currentColor = color
        colorBtn.backgroundColor = color
        if type == 0 {
            muBtn.layer.borderWidth = 1
            colorBtn.layer.borderWidth = 0
        }
        if type == 1 {
            muBtn.layer.borderWidth = 0
            colorBtn.layer.borderWidth = 1
        }
    }
    @objc func timeBtnAction(btn:QMUIButton){
        btn.isSelected = !btn.isSelected
        timePopupByWindow.showWith(animated: true)
    }
    @objc func typeBtnAction(btn:QMUIButton) {
        btn.isSelected = !btn.isSelected
        popupByWindow.showWith(animated: true)
    }
    @objc func colorBtnAction(btn:QMUIButton){
        btn.layer.borderWidth = 0
        colorBtn.layer.borderWidth = 1
        type = 1
        let picker = UIColorPickerViewController()
        picker.selectedColor = currentColor // Setting the Initial Color of the Picker
        picker.delegate = self
        self.present(picker, animated: true, completion: nil)
    }
    @objc func muBtnAction(btn:QMUIButton) {
        btn.layer.borderWidth = 1
        colorBtn.layer.borderWidth = 0
        type = 0
    }
    @objc private func textFieldDidChange(_ textField: UITextField) {
        
    }
    @objc func autoplaySwitchAction(sender:UISwitch) {
        print(sender.isOn)
        UIView.animate(withDuration: 0.3, delay: 0, options: UIView.AnimationOptions.curveEaseInOut) { [self] in
            timeBtn.isHidden = !sender.isOn
            timeBtn.backgroundColor = UIColor(.dm,light:.tableViewBgC_dark,dark:.tableViewBgC_dark_dark)
        }
    }
    @objc func voiceSwitchAction(sender:UISwitch) {
        
        UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 15) { [self] in
            
            if sender.isOn {
                voiceView.snp.updateConstraints { make in
                   make.height.equalTo((kScreenWidth-150)/4+20)
                 }
                voiceView.isHidden = false
            }else{
                voiceView.snp.updateConstraints { make in
                    make.height.equalTo(0)
                 }
                voiceView.isHidden = true
            }
        }
        setVoice()
    }
    @objc func vibrateSwitchAction(sender:UISwitch) {
//        self.vibrateOn = sender.isOn
    }
}
extension ZHMuYuSettingViewController: PanModalPresentable {
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    var panScrollable: UIScrollView? {
        return nil
    }
    var longFormHeight: PanModalHeight {
        return .maxHeightWithTopInset(kScreenHeight/4)
    }
    var anchorModalToLongForm: Bool {
        return false
    }
    func panModalWillDismiss(){
        settingCompletion!(voiceSwitch.isOn, vibrateSwitch.isOn, type, currentColor, typeBtn.titleLabel?.text! ?? "小", autoplaySwitch.isOn,autoTime,voiceIndex,floatTitleTF.text!)
    }
}
extension ZHMuYuSettingViewController : UIColorPickerViewControllerDelegate
{
    func colorPickerViewControllerDidFinish(_ viewController: UIColorPickerViewController)
    {
        currentColor = viewController.selectedColor
        colorBtn.backgroundColor = currentColor
    }
}
  
