// SPDX-License-Identifier: MIT
pragma solidity >=0.7.0 <0.9.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract CurrencyExchange {

    address private owner;
    mapping(IERC20 => uint256) private exchangeRates;

    constructor() payable {
        owner = msg.sender;
    }

    modifier onlyOwner(){
        require(msg.sender==owner, "Only owner is allowed to do this operation");
        _;
    }
    modifier supportedToken(address token){
        require(exchangeRates[IERC20(token)] > 0, "Token exchange rate is not set");
        _;
    }

    function setRate(address token, uint256 rate) onlyOwner external {
       exchangeRates[IERC20(token)] = rate;
    }

    function getRate(address token) supportedToken(token) external view returns(uint256){
        return exchangeRates[IERC20(token)];
    }

    function getBalance(address token) supportedToken(token) onlyOwner external view returns (uint256)  {
        return IERC20(token).balanceOf(address(this));
    }

    function buyToken(address token, uint256 amount) supportedToken(token) external payable {
        require(exchangeRates[IERC20(token)] * amount <= msg.value, "Insufficient payment");
        require(IERC20(token).transfer(msg.sender, amount), "Transaction failed");
    }

    function sellToken(address token, uint256 amount) supportedToken(token) external {
        require(IERC20(token).transferFrom(msg.sender, address(this), amount), "Transaction failed");
        require(payable(msg.sender).send(exchangeRates[IERC20(token)] * amount), "Transaction failed");
    }
}