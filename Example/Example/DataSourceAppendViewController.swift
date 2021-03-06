//
//  DataSourceAppendViewController.swift
//  Example
//
//  Created by JiongXing on 2019/11/29.
//  Copyright © 2019 JiongXing. All rights reserved.
//

import UIKit
import Lantern

class DataSourceAppendViewController: BaseCollectionViewController {

    override var name: String { "无限新增图片" }
    
    override var remark: String { "浏览过程中不断新增图片，变更数据源，刷新UI" }
    
    override func makeDataSource() -> [ResourceModel] {
        makeLocalDataSource()
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.jx.dequeueReusableCell(BaseCollectionViewCell.self, for: indexPath)
        cell.imageView.image = self.dataSource[indexPath.item].localName.flatMap { UIImage(named: $0) }
        return cell
    }
    
    override func openLantern(with collectionView: UICollectionView, indexPath: IndexPath) {
        let lantern = Lantern()
        lantern.numberOfItems = {
            self.dataSource.count
        }
        lantern.reloadCellAtIndex = { context in
            let lanternCell = context.cell as? LanternImageCell
            let indexPath = IndexPath(item: context.index, section: indexPath.section)
            lanternCell?.imageView.image = self.dataSource[indexPath.item].localName.flatMap { UIImage(named: $0) }
        }
        lantern.transitionAnimator = LanternZoomAnimator(previousView: { index -> UIView? in
            let path = IndexPath(item: index, section: indexPath.section)
            let cell = collectionView.cellForItem(at: path) as? BaseCollectionViewCell
            return cell?.imageView
        })
        // 监听页码变化
        lantern.didChangedPageIndex = { index in
            // 已到最后一张
            if index == self.dataSource.count - 1 {
                self.appendMoreData(lantern: lantern)
            }
        }
        lantern.scrollDirection = .vertical
        lantern.pageIndex = indexPath.item
        lantern.show()
    }
    
    private func appendMoreData(lantern: Lantern) {
        var randomIndexes = (0..<6).map { $0 }
        randomIndexes.shuffle()
        randomIndexes.forEach { index in
            let model = ResourceModel()
            model.localName = "local_\(index)"
            dataSource.append(model)
        }
        collectionView.reloadData()
        // TODO: UIScrollView的pageEnable特性原因，不能很好衔接，效果上有点问题，还未解决
        lantern.reloadData()
    }
}

