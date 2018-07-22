pragma solidity ^0.4.24;

// Mortalパターン
import "../node_modules/openzeppelin-solidity/contracts/lifecycle/Destructible.sol";
// CircuitBreakerパターン
import "../node_modules/openzeppelin-solidity/contracts/lifecycle/Pausable.sol";

// 掲示板のコントラクト
contract Forum is Destructible, Pausable {
    
    // コンストラクタ
    constructor() public {
        
    }
}