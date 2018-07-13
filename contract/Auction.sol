pragma solidity ^0.4.18;

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
    function Owned() public {
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
    function setActice(bool _isActive) onlyOwner {
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
    
    // コンストラクタ
    function Auction() payable {
        heighestBidder = msg.sender;
        heighestBid = 0;
    }
    
    // 提示する
    function bid() public payable {
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
    function withdraw() public {
        // 返金者を取得
        address refundBidder = msg.sender;
        uint refundBid = bidderBalance[refundBidder];
        // 返金額が0よりも多いことを確認
        require(refundBid > 0);
        // 返金を行う
        if (refundBidder.send(refundBid)) {
            bidderBalance[refundBidder] = 0;
        } else {
            revert();
        }
    }
}