pragma solidity ^0.4.24;

// オーナー管理コントラクト
contract Owned {
    
    // オーナー
    address public owner;
    
    // オーナー専用のmodifier
    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }
    
    // コンストラクタ
    constructor() public {
        owner == msg.sender;
    }
    
    // オーナーを設定
    function setOwner(address _owner) public onlyOwner {
        owner = _owner;
    }
}

// Mortalパターン
contract Mortal is Owned {
    
    // コントラクトを破棄 & オーナー送金
    function kill() public onlyOwner {
        selfdestruct(owner);
    }
}

// CircuitBreakerパターン
contract CircuitBreaker is Mortal {
    
    // コントラクト稼働フラグ
    bool public isActive = true;
    
    // コントラクト稼働制御modifier
    modifier active() {
        require(isActive);
        _;
    }
    
    // 稼働フラグを設定
    function setActice(bool _isActive) public onlyOwner {
        isActive = _isActive;
    }
}

// オークションのコントラクト
contract Auction is CircuitBreaker {
    
    // 最高提示者
    address public heighestBidder;
    // 最高提示額
    uint public heighestBid;
    
    // 提示者と提示額を管理
    mapping(address => uint) public bidderBalance;
    
    // 入札受付終了時間
    uint public receptionTime;
    
    // 入札受付中のmodifier
    modifier receptionOpen() {
        require(now <= receptionTime);
        _;
    }
    
    // 入札受付終了時間のmodifier
    modifier receptionClose() {
        require(now > receptionTime);
        _;
    }
    
    // コンストラクタ
    constructor(uint _receptionTime) public {
        // 終了時間を設定
        require(_receptionTime > 0);
        receptionTime = _receptionTime;
        
        heighestBidder = msg.sender;
        heighestBid = 0;
    }
    
    // 提示する
    function bid() public payable active receptionOpen {
        // 新規提示者と新規提示額を取得
        address newBidder = msg.sender;
        uint newBid = msg.value;
        // 最高提示額を超えることを確認
        require(newBid > heighestBid);
        // 提示者と提示額を管理
        bidderBalance[newBidder] += newBid;
        // 最高提示者と最高提示額を更新
        heighestBidder = newBidder;
        heighestBid = newBid;
    }
    
    // 提示額を引き出す
    function withdraw() public active receptionClose {
        // 返金者を取得
        address refundBidder = msg.sender;
        uint refundBid = bidderBalance[refundBidder];
        // 返金額が0よりも多いことを確認
        require(refundBid > 0);
        // 二重送金を防ぐために提示者管理を0にする
        bidderBalance[refundBidder] = 0;
        // 返金を行う
        refundBidder.transfer(refundBid);
    }
}