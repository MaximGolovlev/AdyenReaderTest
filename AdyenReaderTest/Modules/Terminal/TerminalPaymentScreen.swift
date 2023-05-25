//
//  TerminalPaymentScreen.swift
//  AdyenReaderTest
//
//  Created by Maxim on 14.03.2023.
//

import UIKit


class TerminalPaymentScreen: UIViewController, TerminalTransactionProvider {
    
    var terminal: Terminal
    
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
        $0.spacing = 40
        $0.alignment = .center
        return $0
    }(UIStackView())
    
    
    let priceLabel: UILabel = {
        $0.numberOfLines = 0
        $0.font = .systemFont(ofSize: 30)
       return $0
    }(UILabel())
    
    let titleLabel: UILabel = {
        $0.numberOfLines = 0
        $0.text = "Connecting to the Terminal..."
       return $0
    }(UILabel())
    
    let progressLoader: UIActivityIndicatorView = {
        $0.snp.makeConstraints({ $0.size.equalTo(CGSize(width: 100, height: 100)) })
        return $0
    }(UIActivityIndicatorView(style: .large))
    
    lazy var logsConsole: UITextView = {
        $0.isEditable = false
        $0.snp.makeConstraints({ $0.height.equalTo(400) })
        return $0
    }(UITextView())
    
    init(order: Order, terminal: Terminal) {
        self.terminal = terminal
        
        super.init(nibName: nil, bundle: nil)
        
        view.backgroundColor = .systemBackground
        
        priceLabel.text = order.totalString
        adyenManager.logsHandler = handleLogs(message:)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        progressLoader.startAnimating()
        progressLoader.alpha = 0
        configViews()
        
        makeTerminalTransactionWithPostTips(sourseView: titleLabel)
    }
    
    func configViews() {
        view.addSubview(mainContainer)
        mainContainer.snp.makeConstraints({
            $0.top.bottom.equalToSuperview().inset(20)
            $0.left.right.equalToSuperview().inset(20)
        })
        
        mainContainer.addArrangedSubviews([priceLabel, titleLabel, progressLoader, logsConsole])
        
        logsConsole.snp.makeConstraints({ $0.left.right.equalToSuperview() })
    }
    
    func refreshViews() {
        
    }
    
}

extension TerminalPaymentScreen {
    
    func showProgressLoader() {
        DispatchQueue.main.async {
            self.progressLoader.alpha = 1
        }
    }
    
    func hideProgressLoader() {
        DispatchQueue.main.async {
            self.progressLoader.alpha = 0
        }
    }
    
    func terminalTransactionWasInitiated() {
        DispatchQueue.main.async {
            self.titleLabel.text = "Please follow the instructions on the terminal..."
        }
    }
    
    func terminalTransactionSucceed(order: Order) {
        DispatchQueue.main.async {
            self.titleLabel.alpha = 0
            self.progressLoader.alpha = 0
            self.showAlert(title: "Transaction Completed Successfully!", message: order.uuid, cancelTitle: "Ok", cancelHandler: { _,_ in
                self.dismiss(animated: true)
            })
        }
    }
    
    func terminalTransactionFailed(message: String) {
        showAlert(message: message, cancelHandler: { [weak self] _,_ in
            self?.dismiss(animated: true)
        })
    }
    
    func checkingPayment() {
        DispatchQueue.main.async {
            self.titleLabel.text = "Checking payment..."
        }
    }
    
    func updatingTips() {
        DispatchQueue.main.async {
            self.titleLabel.text = "Updating tips..."
        }
    }
    
    func capturingPayment() {
        DispatchQueue.main.async {
            self.titleLabel.text = "Capturing payment..."
        }
    }
    
}


