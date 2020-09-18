pragma solidity ^0.6.7;

import "../EthBackedToken.sol";
import "@openzeppelin/contracts/utils/Address.sol";

contract ExampleEthBackedToken is EthBackedToken {

    constructor(address _oracle) public EthBackedToken(_oracle, "EampleEthBackedToken", "EEBT") {
    }

    function fund() public payable {
        _mint(msg.value);
    }

    function withdraw(uint tokenAmount) public {
        uint ethAmount = _burn(tokenAmount);
        Address.sendValue(msg.sender, ethAmount);
    }
}