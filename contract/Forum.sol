pragma solidity ^0.4.24;

// Mortalパターン
import "../node_modules/openzeppelin-solidity/contracts/lifecycle/Destructible.sol";
// CircuitBreakerパターン
import "../node_modules/openzeppelin-solidity/contracts/lifecycle/Pausable.sol";

// 掲示板のコントラクト
contract Forum is Destructible, Pausable {
    
    // 投稿
    struct Contribution {
        // 名前
        string name;
        // メール
        string email;
        // 投稿内容
        string content;
    }
    
    // 掲示板タイトル
    string public title;
    
    // 投稿管理
    Contribution[] private contributions;
    
    // コンストラクタ
    constructor() public {
        title = "スマートコントラクト掲示板";
    }
    
    // タイトルを設定
    function setTitle(string _title) public onlyOwner {
        require(bytes(_title).length > 0);
        title = _title;
    }
    
    // 投稿
    function contribute(string _name, string _email, string _content) public whenNotPaused {
        // 投稿は1000件までとする
        require(contributions.length <= 1000);
        // 投稿内容は必須
        require(bytes(_content).length > 0);
        // 名前の置き換え
        if (bytes(_name).length == 0) {
            _name = "名無しさん";
        }
        // 投稿を作成して保存
        contributions.push(Contribution(_name, _email, _content));
    }
    
    // 投稿をインデックスから取得
    function getContribution(uint _index) public onlyOwner returns (string name, string email, string content) {
        return (contributions[_index].name, contributions[_index].email, contributions[_index].content);
    }
}