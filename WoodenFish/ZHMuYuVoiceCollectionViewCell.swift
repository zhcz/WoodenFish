//
//  ZHMuYuVoiceCollectionViewCell.swift
//  swiftDemo2
//
//  Created by Hao  Zhang on 2023/2/4.
//  Copyright © 2023 张浩. All rights reserved.
//

import UIKit
//import RandomColorSwift
import FluentDarkModeKit
import SnapKit

class ZHMuYuVoiceCollectionViewCell: UICollectionViewCell {
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(btn)
        contentView.addSubview(deleteBtn)
        btn.snp.makeConstraints { make in
            make.left.top.bottom.right.equalTo(0)
        }
        deleteBtn.snp.makeConstraints { make in
            make.right.equalTo(btn.snp.left).offset(15)
            make.bottom.equalTo(btn.snp.top).offset(15)
            make.height.width.equalTo(20)
        }
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    lazy var btn: QMUIButton = {
        var btn = QMUIButton()
        btn.backgroundColor = UIColor(.dm,light:.tableViewBgC,dark:.tableViewBgC_dark_dark)
        btn.setTitleColor(UIColor(.dm,light:.black,dark:.white), for: UIControl.State.normal)
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 13)
        btn.layer.cornerRadius = (kScreenWidth-150)/8
        btn.setImage(UIImage.init(systemName: "music.note"), for: UIControl.State.normal)
        btn.spacingBetweenImageAndTitle = 3
        btn.imagePosition = .left
        btn.isEnabled = false
        btn.layer.borderColor = UIColor.red.cgColor
        return btn
    }()
    
    lazy var deleteBtn: QMUIButton = {
        var deleteBtn = QMUIButton(type: .custom)
        deleteBtn.setImage(UIImage.init(systemName: "xmark",withConfiguration: UIImage.SymbolConfiguration(pointSize: 15, weight: .regular, scale: .small)), for: UIControl.State.normal)
        deleteBtn.backgroundColor = .red
        deleteBtn.tintColor = .white
        deleteBtn.isHidden = true
        deleteBtn.layer.cornerRadius = 10
        deleteBtn.layer.masksToBounds = true
        return deleteBtn
    }()
}

