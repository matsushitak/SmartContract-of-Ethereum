pragma solidity ^0.4.18;

// オークションのコントラクト
contract Auction {
    
    // 最高提示者
    address public heighestBidder;
    // 最高提示額
    uint public heighestBid;
    
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
        // 現在の最高提示者と最高提示額を退避
        address refundBidder = heighestBidder;
        uint refundBid = heighestBid;
        // 最高提示者と最高提示額を更新
        heighestBidder = newBidder;
        heighestBid = newBid;
        // 元の最高提示者に返金
        if (refundBidder.send(refundBid)) {
            revert();
        }
    }
}