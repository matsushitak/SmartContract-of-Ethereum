pragma solidity ^0.4.24;

// Mortalパターン
import "../node_modules/openzeppelin-solidity/contracts/lifecycle/Destructible.sol";
// CircuitBreakerパターン
import "../node_modules/openzeppelin-solidity/contracts/lifecycle/Pausable.sol";

// 抽選のコントラクト
contract Lottery is Destructible, Pausable {
    
    // 応募者
    mapping(uint => address) public applicants;
    // 応募者数
    uint public applicantsCount;
    // 受付中フラグ
    bool public isReception;
    
    // 当選イベント
    event LotteryEvent(address prizewinner);
    
    // コンストラクタ
    constructor() public {
        // 初期化
        applicantsCount = 0;
        isReception = true;
    }
    
    // 応募する
    function apply() public whenNotPaused {
        // 受付中フラグを確認
        require(isReception);
        // すでに応募している人は無効
        for(uint i = 0; i < applicantsCount; i++) {
            require(applicants[i] != msg.sender);
        }
        // 応募者を管理する
        applicants[applicantsCount++] = msg.sender;
    }
    
    // 抽選する
    function lottery() public onlyOwner whenNotPaused {
        // 応募者が３人以上で抽選を行う
        require(applicantsCount >= 3);
        // 抽選する(タイムスタンプから求める)
        uint index = now % applicantsCount;
        
        // TODO:当選者に対して何かを行う
        LotteryEvent(applicants[index]);
        
        // 抽選終了
        isReception = false;
    }
}