// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.15;

import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "hardhat/console.sol";
import "./ERC20.sol";

contract Bridge {

    ERC20 private immutable _token;
    address private immutable _validator;

    mapping(bytes32 => uint256) _hashMessages;

    event swapInitialized(address indexed from, address indexed spender, uint256 amount);

    constructor(address tokenAddress_, address validator_) {
        _validator = validator_;
        _token = ERC20(tokenAddress_);
    }

    function swap(address sender, uint256 amount, uint256 chainId) public {
        //        как указать в какую имееено сеть отправить
        _token.burn(amount);
        emit swapInitialized(msg.sender, sender, amount);
    }

    function redeem(address recipient, uint256 amount, uint256 chainId, uint256 nonce,
        uint8 v, bytes32 r, bytes32 s) public {

        if (_checkSign(recipient, amount, chainId, nonce, v, r, s)) {
            _token.mint(amount);
        }
    }

    function _checkSign(address recipient, uint256 amount, uint256 chainId, uint256 nonce, uint8 v, bytes32 r, bytes32 s)
    internal virtual returns (bool) {

        bytes32 digest = keccak256(
            abi.encodePacked(recipient, amount, chainId, nonce)
        );

        bytes32 hashMsg = _hashMessage(digest);
        uint256 count = _hashMessages[hashMsg];
        if (count == 0) {
            address addr = ECDSA.recover(hashMsg, v, r, s);
            return addr == _validator;
        } else {
            _hashMessages[hashMsg] = count + 1;
            return false;
        }
    }

    function _hashMessage(bytes32 message) private pure returns (bytes32) {
        bytes memory prefix = "\x19Ethereum Signed Message:\n32";
        return keccak256(abi.encodePacked(prefix, message));
    }
}
