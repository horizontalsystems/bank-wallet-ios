import RxSwift
import RxRelay
import RxCocoa

class AddTokenViewModel {
    private let service: AddTokenService
    private let disposeBag = DisposeBag()

    private let loadingRelay = BehaviorRelay<Bool>(value: false)
    private let viewItemRelay = BehaviorRelay<ViewItem?>(value: nil)
    private let buttonVisibleRelay = BehaviorRelay<Bool>(value: false)
    private let cautionRelay = BehaviorRelay<Caution?>(value: nil)
    private let finishRelay = PublishRelay<Void>()

    init(service: AddTokenService) {
        self.service = service

        service.stateObservable.subscribeOn(ConcurrentDispatchQueueScheduler(qos: .userInitiated))
                .subscribe(onNext: { [weak self] state in
                    self?.sync(state: state)
                })
                .disposed(by: disposeBag)

        sync(state: service.state)
    }

    private func sync(state: AddTokenService.State) {
        if case .loading = state {
            loadingRelay.accept(true)
        } else {
            loadingRelay.accept(false)
        }

        switch state {
        case .alreadyExists(let coin):
            viewItemRelay.accept(viewItem(coin: coin))
        case .fetched(let coin):
            viewItemRelay.accept(viewItem(coin: coin))
        default:
            viewItemRelay.accept(nil)
        }

        if case .fetched = state {
            buttonVisibleRelay.accept(true)
        } else {
            buttonVisibleRelay.accept(false)
        }

        if case .failed(let error) = state {
            cautionRelay.accept(Caution(text: error.convertedError.localizedDescription, type: .error))
        } else if case .alreadyExists = state {
            cautionRelay.accept(Caution(text: "add_token.already_exists".localized, type: .warning))
        } else {
            cautionRelay.accept(nil)
        }
    }

    private func viewItem(coin: Coin) -> ViewItem {
        ViewItem(coinName: coin.title, symbol: coin.code, decimals: coin.decimal)
    }

}

extension AddTokenViewModel {

    var loadingDriver: Driver<Bool> {
        loadingRelay.asDriver()
    }

    var viewItemDriver: Driver<ViewItem?> {
        viewItemRelay.asDriver()
    }

    var buttonVisibleDriver: Driver<Bool> {
        buttonVisibleRelay.asDriver()
    }

    var cautionDriver: Driver<Caution?> {
        cautionRelay.asDriver()
    }

    var finishSignal: Signal<Void> {
        finishRelay.asSignal()
    }

    func onEnter(reference: String?) {
        service.set(reference: reference)
    }

    func onTapButton() {
        service.save()
        finishRelay.accept(())
    }

}

extension AddTokenViewModel {

    struct ViewItem {
        let coinName: String
        let symbol: String
        let decimals: Int
    }

}
