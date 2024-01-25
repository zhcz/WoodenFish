//
//  ZHMuYuVoiceView.swift
//  swiftDemo2
//
//  Created by Hao  Zhang on 2023/2/4.
//  Copyright © 2023 张浩. All rights reserved.
//

import UIKit
import FluentDarkModeKit
import SnapKit

class ZHMuYuVoiceView: UIView {
    typealias CellClickBlock = (_ index:Int) -> Void
    var currentPath : IndexPath = IndexPath(row: 0, section: 0)
    var cellClicked : CellClickBlock?
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.addSubview(collectionView)
        collectionView.snp.makeConstraints { make in
            make.left.right.top.bottom.equalToSuperview()
        }
        self.addSubview(mView)
        mView.snp.makeConstraints { make in
            make.left.right.top.bottom.equalToSuperview()
        }
    }
    lazy var mView: UIView = {
        var mView = UIView()
        mView.isHidden = true
        mView.backgroundColor = UIColor(white: 0, alpha: 0.5)
        return mView
    }()
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    private lazy var listCVLayout : UICollectionViewFlowLayout = {
        let collectionFlowLayout = UICollectionViewFlowLayout()
        collectionFlowLayout.sectionInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        collectionFlowLayout.itemSize = CGSize(width: (kScreenWidth-150)/4, height: (kScreenWidth-150)/4)
//       collectionFlowLayout.animator.delegate = self
        collectionFlowLayout.minimumInteritemSpacing = 10
        collectionFlowLayout.minimumLineSpacing = 10
           return collectionFlowLayout
       }()
    lazy var collectionView: UICollectionView = {
        let view = UICollectionView(frame: .zero, collectionViewLayout: self.listCVLayout)
        view.layer.cornerRadius = 10
        view.translatesAutoresizingMaskIntoConstraints = false
        view.showsVerticalScrollIndicator = false
        view.showsHorizontalScrollIndicator = false
        view.delegate = self
        view.dataSource = self
        view.register(ZHMuYuVoiceCollectionViewCell.self, forCellWithReuseIdentifier: ZHMuYuVoiceCollectionViewCell.reuseIdentifier)
        view.backgroundColor = .clear
        return view
    }()
}
extension ZHMuYuVoiceView: UICollectionViewDataSource,UICollectionViewDelegate,UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 4
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell : ZHMuYuVoiceCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: ZHMuYuVoiceCollectionViewCell.reuseIdentifier, for: indexPath) as! ZHMuYuVoiceCollectionViewCell
        
        cell.btn.setTitle(String(indexPath.row+1), for: UIControl.State.normal)
        if indexPath == currentPath {
            cell.btn.layer.borderWidth = 1
        }else{
            cell.btn.layer.borderWidth = 0
        }
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        guard cell is ZHMuYuVoiceCollectionViewCell else { return }
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath == currentPath { return }
        let cell : ZHMuYuVoiceCollectionViewCell = collectionView.cellForItem(at: indexPath)! as! ZHMuYuVoiceCollectionViewCell
        cell.btn.layer.borderWidth = 1
        let lastCell : ZHMuYuVoiceCollectionViewCell = collectionView.cellForItem(at: currentPath)! as! ZHMuYuVoiceCollectionViewCell
        lastCell.btn.layer.borderWidth = 0
        currentPath = indexPath
        cellClicked!(indexPath.row+1)
    }
}
