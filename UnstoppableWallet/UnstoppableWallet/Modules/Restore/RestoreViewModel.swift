import RxSwift
import RxRelay
import RxCocoa

class RestoreViewModel {
    private let service: RestoreService
    let selectCoins: Bool
    private let coinToEnable: Coin?

    private let openScreenRelay = PublishRelay<Screen>()
    private let finishRelay = PublishRelay<Void>()

    init(service: RestoreService, selectCoins: Bool, coinToEnable: Coin?) {
        self.service = service
        self.selectCoins = selectCoins
        self.coinToEnable = coinToEnable
    }

    private func restore(coins: [Coin] = []) {
        do {
            try service.restoreAccount(coins: coins)
            finishRelay.accept(())
        } catch {
            // restore should not be called before setting account type. No need to handle error
        }
    }

}

extension RestoreViewModel {

    var initialScreen: Screen {
        guard let predefinedAccountType = service.predefinedAccountType else {
            return .selectPredefinedAccountType
        }

        return .restoreAccountType(predefinedAccountType: predefinedAccountType)
    }

    var openScreenSignal: Signal<Screen> {
        openScreenRelay.asSignal()
    }

    var finishSignal: Signal<Void> {
        finishRelay.asSignal()
    }

    func onSelect(predefinedAccountType: PredefinedAccountType) {
        service.predefinedAccountType = predefinedAccountType
        openScreenRelay.accept(.restoreAccountType(predefinedAccountType: predefinedAccountType))
    }

    func onEnter(accountType: AccountType) {
        service.accountType = accountType

        if selectCoins, let predefinedAccountType = service.predefinedAccountType {
            openScreenRelay.accept(.selectCoins(predefinedAccountType: predefinedAccountType))
        } else {
            restore(coins: coinToEnable.map { [$0] } ?? [])
        }
    }

    func onSelect(coins: [Coin]) {
        restore(coins: coins)
    }

}

extension RestoreViewModel {

    enum Screen {
        case selectPredefinedAccountType
        case restoreAccountType(predefinedAccountType: PredefinedAccountType)
        case selectCoins(predefinedAccountType: PredefinedAccountType)
    }

}
