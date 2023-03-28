//
//  TerminalPaymentScreen.swift
//  AdyenReaderTest
//
//  Created by Maxim on 14.03.2023.
//

import UIKit


class TerminalPaymentScreen: UIViewController, TransactionProvider {
    
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
        $0.text = "Please complete payment\nusing terminal"
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
    
    init(order: Order) {
        super.init(nibName: nil, bundle: nil)
        
        view.backgroundColor = .systemBackground
        
        priceLabel.text = order.totalString
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        progressLoader.startAnimating()
        progressLoader.alpha = 0
        configViews()
        checkPayment()
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
    
    func checkPayment() {
        Task { [weak self] in
            do {
                let order: Order = try await APIManager.checkAdyenPayment(orderUUID: orderUUID)
                    .makeRequest(logsHandler: { self?.handleLogs(message: $0) })
                LocalStorage.order = order
                if order.paymentStatus == "PAID" {
                    self?.completeTransaction(order: order)
                } else {
                    self?.continueChecking()
                }
            } catch let status as StatusMessage {
                
                switch status {
                case .InProgress:
                    progressLoader.alpha = 1
                    continueChecking()
                default :
                    progressLoader.alpha = 0
                    showAlert(message: status.title, cancelHandler: { _,_ in self?.dismiss(animated: true) })
                }
                
            } catch {
                showAlert(message: error.localizedDescription, cancelHandler: { _,_ in
                    self?.dismiss(animated: true)
                })
            }
        }
    }
    
    func continueChecking() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 2, execute: {
            self.checkPayment()
        })
    }
    
    func refreshViews() {
        
    }
    
    func completeTransaction(order: Order) {
        DispatchQueue.main.async {
            self.titleLabel.alpha = 0
            self.progressLoader.alpha = 0
            self.showAlert(title: "Transaction Completed Successfully!", message: order.uuid, cancelTitle: "Ok", cancelHandler: { _,_ in
                self.dismiss(animated: true)
            })
        }
    }
    
}
