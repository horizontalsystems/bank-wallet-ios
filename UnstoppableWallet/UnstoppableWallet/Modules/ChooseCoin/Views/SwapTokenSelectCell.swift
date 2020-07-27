import UIKit
import SnapKit
import ThemeKit

class SwapTokenSelectCell: ThemeCell {
    private let leftCoinView = LeftCoinCellView()
    private let balanceView = RightValueCellView()

    override public init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

//        backgroundColor = .clear

        contentView.addSubview(leftCoinView)
        leftCoinView.snp.makeConstraints { maker in
            maker.leading.top.bottom.equalToSuperview()
        }

        contentView.addSubview(balanceView)
        balanceView.snp.makeConstraints { maker in
            maker.leading.equalTo(leftCoinView.snp.trailing)
            maker.trailing.centerY.equalToSuperview().inset(CGFloat.margin2x)
        }

        balanceView.setContentCompressionResistancePriority(.required, for: .horizontal)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    func bind(coin: Coin, balance: String?, last: Bool) {
        super.bind(last: last)
        leftCoinView.bind(coinTitle: coin.title, coinCode: coin.code, blockchainType: nil)
        balanceView.bind(text: balance, highlighted: true)
    }

}