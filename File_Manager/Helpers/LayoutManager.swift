//
//  LayoutManager.swift
//  File_Manager
//
//  Created by Артем Калинкин on 31.01.2022.
//

import UIKit

final class LayoutManager
{
  
  static func createItem(
    wD: NSCollectionLayoutDimension,
    hD: NSCollectionLayoutDimension
  ) -> NSCollectionLayoutItem {
    NSCollectionLayoutItem(layoutSize: NSCollectionLayoutSize(widthDimension: wD, heightDimension: hD))
  }
  static func createHorizontalGroup(
    wD: NSCollectionLayoutDimension,
    hD: NSCollectionLayoutDimension,
    item: NSCollectionLayoutItem
  ) -> NSCollectionLayoutGroup {
    NSCollectionLayoutGroup.horizontal(layoutSize: NSCollectionLayoutSize(widthDimension: wD, heightDimension: hD), subitems: [item])
  }
  
  static func createSectionHeader(
    wD: NSCollectionLayoutDimension,
    hD: NSCollectionLayoutDimension
  ) -> NSCollectionLayoutBoundarySupplementaryItem {
    let headerFooterSize = NSCollectionLayoutSize(
      widthDimension: wD,
      heightDimension: hD)
    
    return NSCollectionLayoutBoundarySupplementaryItem(
      layoutSize: headerFooterSize,
      elementKind: UICollectionView.elementKindSectionHeader,
      alignment: .top)
  }
}
