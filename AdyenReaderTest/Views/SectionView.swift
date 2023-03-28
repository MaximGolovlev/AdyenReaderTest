//
//  SectionView.swift
//  AdyenReaderTest
//
//  Created by Maxim on 13.03.2023.
//

import UIKit


class SectionView: UIView {
    
    var tapHandler: ((SectionView) -> Void)?
    
    var container: UIStackView = {
        $0.axis = .horizontal
        $0.spacing = 20
        $0.alignment = .center
        return $0
    }(UIStackView())
    
    var label: UITextView = {
        $0.font = .systemFont(ofSize: 16)
        $0.isScrollEnabled = false
        $0.isEditable = false
        return $0
    }(UITextView())
    
    lazy var button: UIButton = {
        $0.titleLabel?.lineBreakMode = .byWordWrapping
        $0.addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)
        $0.snp.makeConstraints({ $0.width.equalTo(120) })
        return $0
    }(UIButton(type: .system))
    
    init(title: String? = nil, buttonTitle: String? = nil, tapHandler: ((SectionView) -> Void)?) {
        super.init(frame: .zero)
        
        self.label.text = title
        self.button.setTitle(buttonTitle, for: .normal)
        self.tapHandler = tapHandler
        
        addSubview(container)
        container.snp.makeConstraints({ $0.edges.equalToSuperview() })
        
        container.addArrangedSubviews([label, button])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc private func buttonTapped() {
        tapHandler?(self)
    }
}
