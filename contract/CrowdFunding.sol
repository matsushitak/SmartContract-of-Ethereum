pragma solidity ^0.4.18;

// クラウドファンディングのコントラクト
contract CrowdFunding {

    // オーナーのモデル
    struct Owner {
        // オーナーのアドレス
        address mAddress;
    }

    // 投資家のモデル
    struct Investor {
        // 投資家のアドレス
        address mAddress;
        // 投資額
        uint mAmount;
    }

    // キャンペーンのモデル
    struct Promotion {
        // ステータス
        Status mStatus;
        // 投資の達成額
        uint mTotalAmount;
        // 投資の目標額
        uint mGoalAmount;
        // 締切日
        uint mFinishDate;
    }

    // ファンディングの状態
    enum Status {
        // まだ始まっていない状態
        WAIT,
        // ファンディングをおこなっている状態
        FUND,
        // ファンディングが成功した状態
        SUCCESS,
        // ファンディングが失敗した状態
        FAILURE
    }

    // オーナー
    Owner public mOwner;
    // プロモーション
    Promotion public mPromotion;
    // 投資家の数
    uint public mInvestorsConunt;
    // 投資家管理用のマップ
    mapping (uint => Investor) public mInvesters;

    // オーナー限定のアクセス修飾子を作成
    modifier onlyOwner() {
        require(msg.sender == mOwner.mAddress);
        _;
    }

    // コンストラクタ
    function CrowdFunding(uint duration, uint goalAmount) public {
        mOwner.mAddress =  msg.sender;
        mPromotion.mStatus = Status.FUND;
        mPromotion.mTotalAmount = 0;
        mPromotion.mGoalAmount = goalAmount;
        mPromotion.mFinishDate = now + duration;
    }

    // キャンペーンが終了しているかどうか
    function isPromotionEnded() public view returns (bool) {
        return mPromotion.mStatus == Status.SUCCESS || mPromotion.mStatus == Status.FAILURE;
    }

    // 投資する際に呼び出される関数
    function fund() payable public {
        // キャンペーンが終わっていれば処理を中断させる
        require(!isPromotionEnded());

        Investor storage investor = mInvesters[mInvestorsConunt++];
        investor.mAddress = msg.sender;
        investor.mAmount = msg.value;
        mPromotion.mTotalAmount += investor.mAmount;
    }

    // 目標額に達したかを確認して、キャンペーンの成果における適切な処理を行う
    function checkGoalReached() public onlyOwner {
        // キャンペーンが終わっていれば処理を中断させる
        require(!isPromotionEnded());

        // 締め切り前の場合は処理を中断する
        require(now >= mPromotion.mFinishDate);

        // キャンペーンの成果における適切な処理を行う
        if (mPromotion.mTotalAmount >= mPromotion.mGoalAmount) {
            // キャンペーン成功
            mPromotion.mStatus = Status.SUCCESS;
            // オーナー送金する
            if (!mOwner.mAddress.send(address(this).balance)) {
                revert();
            }
        } else {
            // キャンペーン失敗
            mPromotion.mStatus = Status.FAILURE;
            // 投資家返金する
            uint i = 0;
            while (i <= mInvestorsConunt) {
                if (!mInvesters[i].mAddress.send(mInvesters[i].mAmount)) {
                    revert();
                }
                i++;
            }
        }
    }

    // コントラクトを破棄する
    function kill() public onlyOwner {
        selfdestruct(mOwner.mAddress);
    }
}
