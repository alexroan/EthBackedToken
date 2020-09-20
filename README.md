# EthBackedToken

A Framework for Ethereum Backed ERC20 tokens. EthBackedToken is an ERC20 compliant framework for creating stable tokens that have a collateral backing in ETHER. 

Contracts that extend `EthBackedToken` have access to functions which provide stats such as:

* Current Debt Ratio
* Eth Buffer (the amount of excess ETHER in the collateral pool)
* Current Price (using an oracle)
* Coversion prices (Token -> ETH, ETH -> Token)
