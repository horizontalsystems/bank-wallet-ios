import UIKit

class SendAmountRouter {

    static func module(coin: Coin) -> (UIView, ISendAmountModule) {
        let decimalParser = SendAmountDecimalParser()
        let interactor = SendAmountInteractor(localStorage: App.shared.localStorage, rateStorage: App.shared.grdbStorage, currencyManager: App.shared.currencyManager)
        let presenter = SendAmountPresenter(coin: coin, interactor: interactor, decimalParser: decimalParser)
        let sendView = SendAmountView(delegate: presenter)

        presenter.view = sendView

        return (sendView, presenter)
    }

}
