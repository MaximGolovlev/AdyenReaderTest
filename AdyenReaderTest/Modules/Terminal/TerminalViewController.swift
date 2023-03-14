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
    
    var mainContainer: UIStackView = {
        $0.axis = .vertical
        $0.spacing = 20
        return $0
    }(UIStackView())
    
    lazy var orderUUIDSection = SectionView(tapHandler: { [weak self] sectionView in
        self?.refreshOrder()
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
        
        adyenManager.logsHandler = handleLogs(message:)
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
        
        mainContainer.addArrangedSubviews([orderUUIDSection, transactionButton])

    }
    
    func refreshViews() {
        let orderUUIDButtonTitle = orderUUID.isEmpty ? "Generate\nOrder UUID" : "Refresh\nOrder UUID"
        orderUUIDSection.button.setTitle(orderUUIDButtonTitle, for: .normal)
        
        orderUUIDSection.label.text = orderUUID
    }
    
    @objc private func makeTransactionTapped() {
    
        guard LocalStorage.order?.paymentStatus == "UNPAID" else {
            showAlert(message: "Order has already been paid")
            return
        }
        
        self.makeTerminalTransaction() {
            DispatchQueue.main.async {
                let vc = TerminalPaymentScreen()
                self.present(vc, animated: true)
            }
        }
    }
}
