//
//  AdyenManager+DropIn.swift
//  AdyenReaderTest
//
//  Created by Maxim on 26.05.2023.
//

import UIKit
import Adyen
import AdyenSession
import AdyenDropIn
import PassKit
import AdyenActions

extension AdyenManager {
    
    func makeDropinComponent(orderId2: String, target: TransactionProvider,
                             paymentSheetDelegate: PaymentSheetDelegate?) async throws -> (AdyenSession, DropInComponent) {
        
        self.paymentSheetDelegate = paymentSheetDelegate
        
        let sessionData: DropInSessionResponse = try await APIManager.fetchAdyenSession(orderId2: orderId2)
            .makeRequest(logsHandler: { target.handleLogs(message: $0) })
        
        let clientKey = "test_WRAWFJORGBFD7FYTCT2VGF7ZWAVZ2EE2"
        
        // Set the client key and environment in an instance of APIContext.
        let apiContext = try APIContext(environment: Adyen.Environment.test, clientKey: clientKey) // Set the environment to a live one when going live.
        // Create the amount with the value in minor units and the currency code.
        let amount = Amount(value: 1000, currencyCode: "USD")
        // Create the payment object with the amount and country code.
        let payment = Payment(amount: amount, countryCode: "US")
        // Create an instance of AdyenContext, passing the instance of APIContext, payment object, and optional analytics configuration.
        var analytics = AnalyticsConfiguration()
        analytics.isEnabled = true
        let adyenContext = AdyenContext(apiContext: apiContext, payment: payment, analyticsConfiguration: analytics)
        
        let configuration = AdyenSession.Configuration(sessionIdentifier: sessionData.id, // The id from the API response.
                                                       initialSessionData: sessionData.sessionData, // The sessionData from the API response.
                                                       context: adyenContext)
        
        let session = try await initializeAdyenSession(configuration: configuration, delegate: self, presentationDelegate: self)
        
        let dropInConfiguration = DropInComponent.Configuration()
        dropInConfiguration.card.showsHolderNameField = true
        dropInConfiguration.allowsSkippingPaymentList = true
        
        let dropInComponent = DropInComponent(paymentMethods: session.sessionContext.paymentMethods,
                                              context: adyenContext,
                                              configuration: dropInConfiguration)

        // Set the session as the delegate.
        dropInComponent.delegate = session
        // If you support gift cards, set the session as the partial payment delegate.
        dropInComponent.partialPaymentDelegate = session
        
        self.adyenSession = session
        self.dropInComponent = dropInComponent
        
        return (session, dropInComponent)
    }
    
    private func initializeAdyenSession(configuration: AdyenSession.Configuration, delegate: AdyenSessionDelegate, presentationDelegate: PresentationDelegate) async throws -> AdyenSession {
        return try await withCheckedThrowingContinuation { continuation in
            Task { @MainActor in
                AdyenSession.initialize(with: configuration, delegate: delegate, presentationDelegate: presentationDelegate) { result in
                    switch result {
                    case let .success(session):
                        continuation.resume(returning: session)
                    case let .failure(error):
                        continuation.resume(throwing: error)
                    }
                }
            }
        }
    }
    
}


extension AdyenManager: AdyenSessionDelegate {
    
    func didComplete(with resultCode: SessionPaymentResultCode, component: Adyen.Component, session: AdyenSession) {
        
        switch resultCode {
        case .authorised, .pending, .received:
            dropInComponent?.viewController.dismiss(animated: true) {
                self.paymentSheetDelegate?.paymentSheetSucceed()
            }
        case .refused:
            dropInComponent?.stopLoading()
            self.paymentSheetDelegate?.paymentSheetFailed(error: AdyenManagerErrors.refused)
        case .cancelled:
            dropInComponent?.viewController.dismiss(animated: true) {
                self.paymentSheetDelegate?.paymentSheetClosed()
            }
        case .error:
            break
        case .presentToShopper:
            break
        }
    }
    
    func didFail(with error: Error, from component: Adyen.Component, session: AdyenSession) {

        if let error = error as? Adyen.ComponentError {
            switch error {
            case .cancelled:
                dropInComponent?.viewController.dismiss(animated: true) {
                    self.paymentSheetDelegate?.paymentSheetClosed()
                }
            case .paymentMethodNotSupported:
                paymentSheetDelegate?.paymentSheetFailed(error: error)
            }
        } else {
            paymentSheetDelegate?.paymentSheetFailed(error: error)
        }
    }
    
}

extension AdyenManager: PresentationDelegate {
    func present(component: Adyen.PresentableComponent) {
        print("present")
    }

}
