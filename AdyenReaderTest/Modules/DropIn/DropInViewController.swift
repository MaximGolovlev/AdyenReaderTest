//
//  DropInViewController.swift
//  AdyenReaderTest
//
//  Created by Maxim on 26.05.2023.
//

import UIKit
import AdyenSession
import Adyen
import AdyenDropIn


class DropInViewController: UIViewController, TransactionProvider {
    
    var adyenManager: AdyenManager {
        AdyenManager.shared
    }
    
    lazy var logsConsole: UITextView = {
        $0.isEditable = false
        $0.snp.makeConstraints({ $0.height.equalTo(400) })
        return $0
    }(UITextView())
    
    var orderUUID: String {
        LocalStorage.order?.uuid ?? ""
    }
    
    var orderID2: String {
        LocalStorage.order?.id2 ?? ""
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
    
    lazy var showDropInButton: UIButton = {
        $0.setTitle("Show Drop In", for: .normal)
        $0.addTarget(self, action: #selector(showDropInTapped), for: .touchUpInside)
        return $0
    }(UIButton(type: .system))
    
    private var dropInComponent: DropInComponent?
    private var adyenSession: AdyenSession?
    
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
        
        mainContainer.addArrangedSubviews([menuItemSection, orderUUIDSection, showDropInButton])

    }
    
    func refreshViews() {
        let menuItemButtonTitle = menuItems.isEmpty ? "Select\nMenu Items" : "Change\nMenu Items"
        menuItemSection.button.setTitle(menuItemButtonTitle, for: .normal)
        var items = menuItems.compactMap({ $0.description })
        LocalStorage.order?.tipsString.map({ items.append("tips: " + $0) })
        menuItemSection.label.text = items.compactMap({ $0.description }).joined(separator: "\n")
        
        let orderUUIDButtonTitle = orderUUID.isEmpty ? "Generate\nOrder UUID" : "Refresh\nOrder UUID"
        orderUUIDSection.button.setTitle(orderUUIDButtonTitle, for: .normal)
        orderUUIDSection.label.text = orderUUID
    }
    
    
    @objc func showDropInTapped() {
        Task {
            do {
                let (adyenSession, dropInComponent) = try await adyenManager.makeDropinComponent(orderId2: orderID2, target: self, dropInDelegate: self, sessionDelegate: self, presentationDelegate: self)
                self.dropInComponent = dropInComponent
                self.adyenSession = adyenSession
                self.present(dropInComponent.viewController, animated: true)
                
            } catch {
                self.showAlert(message: error.localizedDescription)
            }
        }
    }

}

extension DropInViewController: DropInComponentDelegate {
    
    func didSubmit(_ data: Adyen.PaymentComponentData, from component: Adyen.PaymentComponent, in dropInComponent: Adyen.AnyDropInComponent) {
        
    }

    func didProvide(_ data: Adyen.ActionComponentData, from component: Adyen.ActionComponent, in dropInComponent: Adyen.AnyDropInComponent) {
        
    }
    
    func didComplete(from component: Adyen.ActionComponent, in dropInComponent: Adyen.AnyDropInComponent) {
        
    }
    
    func didFail(with error: Error, from component: Adyen.PaymentComponent, in dropInComponent: Adyen.AnyDropInComponent) {
        
    }
    
    func didFail(with error: Error, from component: Adyen.ActionComponent, in dropInComponent: Adyen.AnyDropInComponent) {
        
    }
    
    func didFail(with error: Error, from dropInComponent: Adyen.AnyDropInComponent) {
        
    }
    
    func didCancel(component: PaymentComponent, from dropInComponent: AnyDropInComponent) {
        dropInComponent.viewController.dismiss(animated: true)
    }
    
}


extension DropInViewController: AdyenSessionDelegate {
    
    func didComplete(with resultCode: SessionPaymentResultCode, component: Adyen.Component, session: AdyenSession) {
        
    }
    
    func didFail(with error: Error, from component: Adyen.Component, session: AdyenSession) {
        
    }
    
//    func handlerForPayments(in component: PaymentComponent, session: AdyenSession) -> AdyenSessionPaymentsHandler? {
//        return self
//    }
//
    
}

extension DropInViewController: AdyenSessionPaymentsHandler {
    
    func didSubmit(_ paymentComponentData: Adyen.PaymentComponentData, from component: Adyen.Component, dropInComponent: Adyen.AnyDropInComponent?, session: AdyenSession) {
        
        
    }
}


extension DropInViewController: PresentationDelegate {
    func present(component: Adyen.PresentableComponent) {
        print("present")
    }

}
