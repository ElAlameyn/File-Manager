//
//  LayoutManager.swift
//  File_Manager
//
//  Created by Артем Калинкин on 31.01.2022.
//

import UIKit

final class LayoutManager {
  
  static let shared = LayoutManager()
  
  enum BaseSections: Int, CaseIterable {
    case title, category, recentFiles
    
    enum Category: Int {
      case images, videos, files
    }
  }
  
  enum FilesSections: Int, CaseIterable {
    case lastModified, main
  }
  
  private let baseSections = BaseSections.allCases
  private let filesSectons = FilesSections.allCases
  
  // MARK: - [FilesViewController]: Layout
  
  static func createFilesViewLayout() -> UICollectionViewLayout {
    let sectionProvider = {
      (sectionIndex: Int, layoutEnvironment: NSCollectionLayoutEnvironment)
      -> NSCollectionLayoutSection? in
      switch shared.filesSectons[sectionIndex] {
      case .lastModified:
        let item = LayoutManager.createItem(
          wD: .fractionalWidth(1.0),
          hD: .absolute(120))
          
        let group = LayoutManager.createHorizontalGroup(
          wD: .estimated(120),
          hD: .estimated(110),
          item: item)
        let section = NSCollectionLayoutSection(group: group)
        section.orthogonalScrollingBehavior = .continuousGroupLeadingBoundary
        section.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 20, bottom: 20, trailing: 10)
        section.interGroupSpacing = 17
        
        // Supplementary header view setup
        let sectionHeader = LayoutManager.createSectionHeader(
          wD: .fractionalWidth(1.0),
          hD: .estimated(30))
        
        section.boundarySupplementaryItems = [sectionHeader]
        return section
      case .main:
        let size = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(60))
        let item = NSCollectionLayoutItem(layoutSize: size)
        
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: size, subitems: [item])
        
        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = NSDirectionalEdgeInsets(top: 20, leading: 30, bottom: 80, trailing: 30)
        section.interGroupSpacing = 15
        
        let sectionHeader = LayoutManager.createSectionHeader(
          wD: .fractionalWidth(1.0),
          hD: .estimated(30))
        section.boundarySupplementaryItems = [sectionHeader]
        
        return section
      }
    }
    return UICollectionViewCompositionalLayout(sectionProvider: sectionProvider)
  }
  
  // MARK: - [BaseViewController]: Layout
  static func createBaseViewControllerLayout() -> UICollectionViewLayout {
    let sectionProvider = {
      (sectionIndex: Int, layoutEnvironment: NSCollectionLayoutEnvironment)
      -> NSCollectionLayoutSection? in
      switch shared.baseSections[sectionIndex] {
      case .title:
        let item = LayoutManager.createItem(
          wD: .fractionalWidth(1.0),
          hD: .fractionalHeight(1.0))
        let group = LayoutManager.createHorizontalGroup(
          wD: .fractionalWidth(1.0),
          hD: .estimated(120),
          item: item)
        return NSCollectionLayoutSection(group: group)
        
      case .category:
        let item = LayoutManager.createItem(
          wD: .fractionalWidth(1.0),
          hD: .fractionalHeight(1.0))
        let group = LayoutManager.createHorizontalGroup(
          wD: .estimated(130),
          hD: .estimated(150),
          item: item)
        let section = NSCollectionLayoutSection(group: group)
        section.orthogonalScrollingBehavior = .continuousGroupLeadingBoundary
        section.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 20, bottom: 20, trailing: 10)
        section.interGroupSpacing = 20
        
        // Supplementary header view setup
        let sectionHeader = LayoutManager.createSectionHeader(
          wD: .fractionalWidth(1.0),
          hD: .estimated(30))
        
        section.boundarySupplementaryItems = [sectionHeader]
        return section
        
      case .recentFiles:
        let item = LayoutManager.createItem(
          wD: .estimated(155),
          hD: .estimated(220))
        let group = LayoutManager.createHorizontalGroup(
          wD: .fractionalWidth(1.0),
          hD: .estimated(220),
          item: item)
        
        group.edgeSpacing = NSCollectionLayoutEdgeSpacing(leading: nil, top: nil, trailing: nil, bottom: NSCollectionLayoutSpacing.fixed(20))
        group.interItemSpacing = NSCollectionLayoutSpacing.flexible(10)
        
        let section = NSCollectionLayoutSection(group: group)
        section.orthogonalScrollingBehavior = .none
        section.contentInsets = NSDirectionalEdgeInsets(top: 20, leading: 20, bottom: 40, trailing: 20)
        
        let sectionHeader = LayoutManager.createSectionHeader(
          wD: .fractionalWidth(1.0),
          hD: .estimated(30))
        section.boundarySupplementaryItems = [sectionHeader]
        return section
      }
    }
    return UICollectionViewCompositionalLayout(sectionProvider: sectionProvider)
  }
  
}

extension LayoutManager {
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
  
  static func createVerticalGroup(
    wD: NSCollectionLayoutDimension,
    hD: NSCollectionLayoutDimension,
    item: NSCollectionLayoutItem
  ) -> NSCollectionLayoutGroup {
    NSCollectionLayoutGroup.vertical(layoutSize: NSCollectionLayoutSize(widthDimension: wD, heightDimension: hD), subitems: [item])
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
