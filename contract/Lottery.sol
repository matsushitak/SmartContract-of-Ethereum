pragma solidity ^0.4.24;

// Mortalパターン
import "../node_modules/openzeppelin-solidity/contracts/lifecycle/Destructible.sol";
// CircuitBreakerパターン
import "../node_modules/openzeppelin-solidity/contracts/lifecycle/Pausable.sol";

// 抽選のコントラクト
contract Lottery is Destructible, Pausable {
    
    // コンストラクタ
    constructor() public {
        
    }
    
    // 応募する
    function apply() public payable whenNotPaused {
        
    }
    
    // 抽選する
    function lottery() public onlyOwner whenNotPaused {
        
    }
}