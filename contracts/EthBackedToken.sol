pragma solidity ^0.6.7;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/math/SafeMath.sol";
import "./WadMath.sol";
import "./oracles/IOracle.sol";

/**
 * @title EthBackedToken
 * @author Alex Roan (@alexroan)
 * @notice This contract represents a token which accepts ETH as collateral to mint and burn ERC20 tokens.
 * It's functions abstract all oracle, conversion, debt ratio and ETH buffer calculations, so that
 * inheriting contracts can focus on their minting and burning algorithms.
 */
contract EthBackedToken is ERC20 {
    using SafeMath for uint;
    using WadMath for uint;

    uint public constant WAD = 10 ** 18;

    uint public ethPool;        //default 0
    address public oracle;

    constructor(address _oracle, string memory _name, string memory _symbol) public ERC20(_name, _symbol) {
        oracle = _oracle;
    }

    /**
     * @notice Mint token from Eth. Inheriting contract must handle the Ether transfers.
     */
    function _mint(uint ethAmount) internal returns (uint) {
        uint tokenAmount = ethToToken(ethAmount);
        ethPool = ethPool.add(ethAmount);
        super._mint(msg.sender, tokenAmount);
        return tokenAmount;
    }

    /**
     * @notice Burn token for Eth. Inheriting contract must handle the Ether transfers.
     */
    function _burn(uint tokenAmount) internal returns (uint) {
        uint ethAmount = tokenToEth(tokenAmount);
        ethPool = ethPool.sub(ethAmount);
        super._burn(msg.sender, tokenAmount);
        return ethAmount;
    }

    /**
     * @notice Calculate the amount of ETH in the buffer
     *
     * @return ETH buffer
     */
    function ethBuffer() public view returns (int) {
        int buffer = int(ethPool) - int(tokenToEth(totalSupply()));
        require(buffer <= int(ethPool), "Underflow error");
        return buffer;
    }

    /**
     * @notice Calculate debt ratio of the current Eth pool amount and outstanding token
     * (the amount of token in total supply).
     *
     * @return Debt ratio.
     */
    function debtRatio() public view returns (uint) {
        if (ethPool == 0) {
            return 0;
        }
        return totalSupply().wadDiv(ethToToken(ethPool));
    }

    /**
     * @notice Convert ETH amount to token using the latest price of token
     * in ETH.
     *
     * @param _ethAmount The amount of ETH to convert.
     * @return The amount of token.
     */
    function ethToToken(uint _ethAmount) public view returns (uint) {
        if (_ethAmount == 0) {
            return 0;
        }
        return _oraclePrice().wadMul(_ethAmount);
    }

    /**
     * @notice Convert token amount to ETH using the latest price of token
     * in ETH.
     *
     * @param _tokenAmount The amount of token to convert.
     * @return The amount of ETH.
     */
    function tokenToEth(uint _tokenAmount) public view returns (uint) {
        if (_tokenAmount == 0) {
            return 0;
        }
        return _tokenAmount.wadDiv(_oraclePrice());
    }

    /**
     * @notice Retrieve the latest price of the price oracle.
     *
     * @return price
     */
    function _oraclePrice() internal view returns (uint) {
        return IOracle(oracle).latestPrice().mul(WAD).div(10 ** IOracle(oracle).decimalShift());
    }
}