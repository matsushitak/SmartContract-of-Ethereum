pragma solidity ^0.4.24;

contract Adoption {
    
    address[16] public adopters;

    // Adopting a pet
    function adopt(uint _petId) public returns (uint) {
        require(_petId >= 0 && _petId <= 15);
        adopters[_petId] = msg.sender;
        return _petId;
    }
    
    // Retrieving the adopters
    function getAdopters() public view returns (address[16]) {
      return adopters;
    }   
}
