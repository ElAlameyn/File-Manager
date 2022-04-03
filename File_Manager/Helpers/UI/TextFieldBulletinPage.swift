
import UIKit
import BLTNBoard
import Combine

class TextFieldBulletinPage: BLTNPageItem {
  
  var textField: UITextField!
  var textInputHandler: ((TextFieldBulletinPage, String?) -> Void)? = nil
  
  override func makeViewsUnderTitle(with interfaceBuilder: BLTNInterfaceBuilder) -> [UIView]? {
    textField = interfaceBuilder.makeTextField(placeholder: "First and Last Name", returnKey: .done, delegate: self)
    textField.heightAnchor.constraint(equalToConstant: 50).isActive = true
    textField.borderStyle = .roundedRect
    return [textField]
  }
  
  override public func tearDown() {
    super.tearDown()
    textField?.delegate = nil
  }
  
  override public func actionButtonTapped(sender: UIButton) {
    textField.resignFirstResponder()
    super.actionButtonTapped(sender: sender)
  }
  
  override func alternativeButtonTapped(sender: UIButton) {
    textField.resignFirstResponder()
    super.alternativeButtonTapped(sender: sender)
  }
  
  func textPublisher() -> AnyPublisher<String, Never> {
    NotificationCenter.default
      .publisher(for: UITextField.textDidEndEditingNotification, object: textField)
      .map { $0.object as? UITextField }
      .map { $0?.text ?? "" }
      .eraseToAnyPublisher()
  }
}

// MARK: - UITextFieldDelegate

extension TextFieldBulletinPage: UITextFieldDelegate {

  private func isInputValid(text: String?) -> Bool {
    text == nil || text!.isEmpty ? false : true
  }
  
  internal func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
    true
  }
  
  internal func textFieldShouldReturn(_ textField: UITextField) -> Bool {
    textField.resignFirstResponder()
    return true
  }
  
  internal func textFieldDidEndEditing(_ textField: UITextField) {
    if isInputValid(text: textField.text) {
      textInputHandler?(self, textField.text)
    } else {
      textField.backgroundColor = UIColor.red.withAlphaComponent(0.3)
      textField.placeholder = "Bad Input!"
    }
  }
  
}
