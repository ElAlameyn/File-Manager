//
//  DocumentPicker.swift
//  File_Manager
//
//  Created by Артем Калинкин on 30.04.2022.
//

import UIKit
import Combine

final class DocumentPicker: NSObject {
  private var pickerController: UIDocumentPickerViewController?
  private weak var presentationController: UIViewController?
  var document = PassthroughSubject<Document?, Never>()
  
  private var cancellables = Set<AnyCancellable>()

  func picker() -> UIDocumentPickerViewController {
    let picker = UIDocumentPickerViewController(forOpeningContentTypes: [.item])
    picker.delegate = self
    picker.allowsMultipleSelection = false
    return picker
  }
}

extension DocumentPicker: UIDocumentPickerDelegate {
  func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
    guard let url = urls.first else { return }
    let shouldStop = url.startAccessingSecurityScopedResource()
    defer { if shouldStop { url.stopAccessingSecurityScopedResource() } }
    let doc = Document(fileURL: url)
    document.send(doc)
    
  }
}

extension DocumentPicker {
  final class Document: UIDocument {
    
    var data: Data?
    
    override func contents(forType typeName: String) throws -> Any {
      guard let data = data else { return Data() }
      return try NSKeyedArchiver.archivedData(withRootObject: data, requiringSecureCoding: true)
    }
    
    override func load(fromContents contents: Any, ofType typeName: String?) throws {
      guard let data = contents as? Data else { return }
      self.data = data
    }
  }
}

extension URL {
  var isDirectory: Bool! {
    (try? resourceValues(forKeys: [.isDirectoryKey]).isDirectory)
  }
}

