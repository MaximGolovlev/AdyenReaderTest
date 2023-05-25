//
//  TerminalViewController.swift
//  AdyenReaderTest
//
//  Created by Maxim on 14.03.2023.
//

import UIKit

class TerminalViewController: UIViewController, TransactionProvider {
    
    var adyenManager: AdyenManager {
        AdyenManager.shared
    }
    
    var orderUUID: String {
        LocalStorage.order?.uuid ?? ""
    }
    
    var menuItems: [MenuItem] {
        LocalStorage.menuItems
    }
    
    var mainContainer: UIStackView = {
        $0.axis = .vertical
        $0.spacing = 20
        return $0
    }(UIStackView())
    
    lazy var orderUUIDSection = SectionView(tapHandler: { [weak self] sectionView in
        self?.refreshOrder(request: OrderRequestMock())
    })
    
    lazy var menuItemSection = SectionView(tapHandler: { [weak self] sectionView in
        self?.fetchMenuItems(sourceView: sectionView.button)
    })
    
    lazy var terminalSection = SectionView(tapHandler: { [weak self] sectionView in
        self?.presentTerminalPicker(sourceView: sectionView.button) { [weak self] _ in
            self?.refreshViews()
        }
    })
    
    lazy var transactionButton: UIButton = {
        $0.setTitle("Make Transaction", for: .normal)
        $0.addTarget(self, action: #selector(makeTransactionTapped), for: .touchUpInside)
        return $0
    }(UIButton(type: .system))
    
    lazy var logsConsole: UITextView = {
        $0.isEditable = false
        $0.snp.makeConstraints({ $0.height.equalTo(400) })
        return $0
    }(UITextView())
    
    init() {
        super.init(nibName: nil, bundle: nil)
        
        view.backgroundColor = .systemBackground
        
        configViews()
        refreshViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configViews() {
        
        view.addSubview(mainContainer)
        mainContainer.snp.makeConstraints({
            $0.centerY.equalToSuperview().offset(-200)
            $0.left.right.equalToSuperview().inset(20)
        })
        
        view.addSubview(logsConsole)
        logsConsole.snp.makeConstraints({ $0.left.right.bottom.equalToSuperview() })
        
        mainContainer.addArrangedSubviews([terminalSection, menuItemSection, orderUUIDSection, transactionButton])

    }
    
    func refreshViews() {
        let terminalButtonTitle = orderUUID.isEmpty ? "Add new\nTerminal" : "Change\nTerminal"
        terminalSection.button.setTitle(terminalButtonTitle, for: .normal)
        terminalSection.label.text = LocalStorage.selectedTerminal?.poiid
        
        let menuItemButtonTitle = menuItems.isEmpty ? "Select\nMenu Items" : "Change\nMenu Items"
        menuItemSection.button.setTitle(menuItemButtonTitle, for: .normal)
        var items = menuItems.compactMap({ $0.description })
        LocalStorage.order?.tipsString.map({ items.append("tips: " + $0) })
        menuItemSection.label.text = items.compactMap({ $0.description }).joined(separator: "\n")
        
        let orderUUIDButtonTitle = orderUUID.isEmpty ? "Generate\nOrder UUID" : "Refresh\nOrder UUID"
        orderUUIDSection.button.setTitle(orderUUIDButtonTitle, for: .normal)
        orderUUIDSection.label.text = orderUUID
    }
    
    @objc private func makeTransactionTapped() {
    
        guard let order = LocalStorage.order else {
            showAlert(message: "Order is empty")
            return
        }
        
        guard order.paymentStatus == .unpaid else {
            showAlert(message: "Order has already been paid")
            return
        }
        
        guard let terminal = LocalStorage.selectedTerminal else {
            showAlert(message: "Please select a terminal")
            return
        }
        
        DispatchQueue.main.async {
            let vc = TerminalPaymentScreen(order: order, terminal: terminal)
            self.present(vc, animated: true)
        }
    }
}

