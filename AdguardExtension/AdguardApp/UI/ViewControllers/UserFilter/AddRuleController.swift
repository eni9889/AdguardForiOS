/**
       This file is part of Adguard for iOS (https://github.com/AdguardTeam/AdguardForiOS).
       Copyright © Adguard Software Limited. All rights reserved.
 
       Adguard for iOS is free software: you can redistribute it and/or modify
       it under the terms of the GNU General Public License as published by
       the Free Software Foundation, either version 3 of the License, or
       (at your option) any later version.
 
       Adguard for iOS is distributed in the hope that it will be useful,
       but WITHOUT ANY WARRANTY; without even the implied warranty of
       MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
       GNU General Public License for more details.
 
       You should have received a copy of the GNU General Public License
       along with Adguard for iOS.  If not, see <http://www.gnu.org/licenses/>.
 */

import Foundation

protocol AddRuleControllerDelegate {
    func addRule(rule: String)
    func importRules()
}

class AddRuleController: UIViewController, UITextViewDelegate {
    
    var delegate : AddRuleControllerDelegate?
    var blacklist = false
    
    @IBOutlet weak var contentView: RoundrectView!
    
    @IBOutlet weak var ruleTextView: UITextView!
    @IBOutlet weak var rulePlaceholderLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var editCaption: UILabel!
    
    @IBOutlet weak var keyboardHeightLayoutConstraint: NSLayoutConstraint!
    
    @IBOutlet var themableLabels: [ThemableLabel]!
    
    let theme: ThemeServiceProtocol = ServiceLocator.shared.getService()!
    
    // MARK: - View Controller life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(self.keyboardNotification(notification:)),
                                               name:
            UIResponder.keyboardWillChangeFrameNotification,
                                               object: nil)
        
        titleLabel.text = ACLocalizedString(blacklist ? "add_blacklist_rule_title" : "add_whitelist_domain_title", "")
        editCaption.text = ACLocalizedString(blacklist ? "add_blacklist_rule_caption" : "add_whitelist_domain_caption", "")
        
        ruleTextView.keyboardType = blacklist ? .default : .URL
        ruleTextView.textContainer.lineFragmentPadding = 0
        ruleTextView.textContainerInset = UIEdgeInsets(top: 12, left: 0, bottom: 0, right: 0)
        
        setupTheme()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        ruleTextView.becomeFirstResponder()
        rulePlaceholderLabel.text = ACLocalizedString(blacklist ? "add_blacklist_rule_placeholder" : "add_whitelist_domain_placeholder", "")
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        if touch.view != contentView {
            dismiss(animated: true, completion: nil)
        }
        else {
            super.touchesBegan(touches, with: event)
        }
    }
    
    @objc func keyboardNotification(notification: NSNotification) {
        if let userInfo = notification.userInfo {
            let endFrame = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue
            let endFrameY = endFrame?.origin.y ?? 0
            let duration:TimeInterval = (userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? NSNumber)?.doubleValue ?? 0
            let animationCurveRawNSN = userInfo[UIResponder.keyboardAnimationCurveUserInfoKey] as? NSNumber
            let animationCurveRaw = animationCurveRawNSN?.uintValue ?? UIView.AnimationOptions.curveEaseInOut.rawValue
            let animationCurve:UIView.AnimationOptions = UIView.AnimationOptions(rawValue: animationCurveRaw)
            if endFrameY >= UIScreen.main.bounds.size.height {
                self.keyboardHeightLayoutConstraint?.constant = 0.0
            } else {
                self.keyboardHeightLayoutConstraint?.constant = endFrame?.size.height ?? 0.0
            }
            UIView.animate(withDuration: duration,
                           delay: TimeInterval(0),
                           options: animationCurve,
                           animations: { self.view.layoutIfNeeded() },
                           completion: nil)
        }
    }
    
    // MARK: - Actions
    
    @IBAction func saveAction(_ sender: Any) {
        delegate?.addRule(rule: ruleTextView.text!)
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func cancelAction(_ sender: Any) {
        
        dismiss(animated: true) {
        }
    }
    
    // MARK: - TextViewDelegateMethods

    func textViewDidChange(_ textView: UITextView) {
        rulePlaceholderLabel.isHidden = textView.text != ""
    }

    // MARK: - privat methods
    
    private func setupTheme() {
        contentView.backgroundColor = theme.popupBackgroundColor
        rulePlaceholderLabel.textColor = theme.placeholderTextColor
        theme.setupPopupLabels(themableLabels)
        theme.setupTextView(ruleTextView)
    }
}
