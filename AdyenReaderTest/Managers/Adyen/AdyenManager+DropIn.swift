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
                             dropInDelegate: DropInComponentDelegate?,
                             sessionDelegate: AdyenSessionDelegate,
                             presentationDelegate: PresentationDelegate) async throws -> (AdyenSession, DropInComponent) {
        
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
        
        let session = try await withUnsafeThrowingContinuation { continuation in
            
            DispatchQueue.main.async {
                AdyenSession.initialize(with: configuration, delegate: sessionDelegate, presentationDelegate: presentationDelegate) { result in
                    switch result {
                    case let .success(session):
                        continuation.resume(returning: session)
                    case let .failure(error):
                        continuation.resume(throwing: error)
                    }
                }
            }
            
        }
        
        let dropInConfiguration = DropInComponent.Configuration()
        // Some payment methods have additional required or optional configuration.
        // For example, an optional configuration to show the cardholder name field for cards.
        dropInConfiguration.card.showsHolderNameField = true
        dropInConfiguration.actionComponent.threeDS.delegateAuthentication = ConfigurationConstants.delegatedAuthenticationConfigurations
        dropInConfiguration.actionComponent.threeDS.requestorAppURL = URL(string: ConfigurationConstants.returnUrl)
        dropInConfiguration.card.billingAddress.mode = .postalCode
        
        let dropInComponent = DropInComponent(paymentMethods: session.sessionContext.paymentMethods,
                                              context: adyenContext,
                                              configuration: dropInConfiguration)

        // Set the session as the delegate.
        dropInComponent.delegate = session
        // If you support gift cards, set the session as the partial payment delegate.
        dropInComponent.partialPaymentDelegate = session
        
        
        return (session, dropInComponent)
    }
    
}

enum ConfigurationConstants {
    // swiftlint:disable explicit_acl
    // swiftlint:disable line_length

    /// Please use your own web server between your app and adyen checkout API.
    static let componentsEnvironment = Adyen.Environment.test

    static let appName = "Adyen Demo"

    static let reference = "Test Order Reference - iOS UIHost"

    static let returnUrl = "ui-host://payments"
    
    static let shopperReference = "iOS Checkout Shopper"

    static let shopperEmail = "checkoutShopperiOS@example.org"
    
    static let additionalData = ["allow3DS2": true, "executeThreeD": true]

    static var apiContext: APIContext {
        if let apiContext = try? APIContext(environment: componentsEnvironment, clientKey: clientKey) {
            return apiContext
        }
        // swiftlint:disable:next force_try
        return try! APIContext(environment: componentsEnvironment, clientKey: "local_DUMMYKEYFORTESTING")
    }

    static let clientKey = "{YOUR_CLIENT_KEY}"

    static let demoServerAPIKey = "{YOUR_DEMO_SERVER_API_KEY}"

    static let applePayMerchantIdentifier = "{YOUR_APPLE_PAY_MERCHANT_IDENTIFIER}"

    static let merchantAccount = "{YOUR_MERCHANT_ACCOUNT}"
    
    static let appleTeamIdentifier = "{YOUR_APPLE_DEVELOPMENT_TEAM_ID}"

    static let lineItems = [["description": "Socks",
                             "quantity": "2",
                             "amountIncludingTax": "300",
                             "amountExcludingTax": "248",
                             "taxAmount": "52",
                             "id": "Item #2"]]
    static var delegatedAuthenticationConfigurations: ThreeDS2Component.Configuration.DelegatedAuthentication {
        .init(localizedRegistrationReason: "Authenticate your card!",
              localizedAuthenticationReason: "Register this device!",
              appleTeamIdentifier: appleTeamIdentifier)
        
    }

    static var shippingMethods: [PKShippingMethod] = {
        var shippingByCar = PKShippingMethod(label: "By car", amount: NSDecimalNumber(5.0))
        shippingByCar.identifier = "car"
        shippingByCar.detail = "Tomorrow"

        var shippingByPlane = PKShippingMethod(label: "By Plane", amount: NSDecimalNumber(50.0))
        shippingByPlane.identifier = "plane"
        shippingByPlane.detail = "Today"
        
        return [shippingByCar, shippingByPlane]
    }()

}
