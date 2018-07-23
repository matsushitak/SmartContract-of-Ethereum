pragma solidity ^0.4.24;

// Mortalパターン
import "../node_modules/openzeppelin-solidity/contracts/lifecycle/Destructible.sol";
// CircuitBreakerパターン
import "../node_modules/openzeppelin-solidity/contracts/lifecycle/Pausable.sol";

// 掲示板のコントラクト
contract Forum is Destructible, Pausable {
    
    // 投稿
    struct Contribution {
        // 投稿者
        address contributor;
        // 名前
        string name;
        // メール
        string email;
        // 投稿内容
        string content;
    }
    
    // 投稿管理
    Contribution[] private contributions;
    
    // 掲示板タイトル
    string public title;
    
    // 更新イベント
    event UpdateEvent(uint index, string content);
    // 削除イベント
    event DeleteEvent(uint index);
    
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
        contributions.push(Contribution(msg.sender, _name, _email, _content));
    }
    
    // 投稿をインデックスから取得
    function getContribution(uint _index) public onlyOwner returns (string name, string email, string content) {
        return (contributions[_index].name, contributions[_index].email, contributions[_index].content);
    }
    
    // 投稿をインデックスから更新
    function updateContribution(uint _index, string _content) public {
        require(msg.sender == contributions[_index].contributor);
        contributions[_index] = Contribution(msg.sender, contributions[_index].name, contributions[_index].email, _content);
        UpdateEvent(_index, _content);
    }
    
    // 投稿をインデックスから削除
    function deleteContribution(uint _index) public {
        require(msg.sender == contributions[_index].contributor);
        delete contributions[_index];
        DeleteEvent(_index);
    }
}