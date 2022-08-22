// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.15;

import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "hardhat/console.sol";
import "./ERC20.sol";

contract Bridge {

    //подпись проходоит через пользователя, алгоритм писать не нужно
    //signature = address, amount, nonce, chainId
    //реализовать добавление/удаление нового токена
    //реализовать работу моста с разными сетями по chain_id
    //хэширование должно проходить еще по олному дополнительному элементу, по адресу сети
    //нужно записать заранее адрес валидатора, чтобы проверить сигнатуру
    //нужно будет хранить хэш в мапе, чтобы проверять, что по данной сигнатуре было или не было обращение. из-за этого нужно добавлять none(current timestamp)

    mapping(address => ERC20) private _tokens;
    mapping(bytes32 => uint256) _hashMessages;
    address private immutable _validator;

    event swapInitialized(address indexed from, address indexed spender, uint256 amount);

    constructor(address validator_) {
        _validator = validator_;
    }

    function addToken(address tokenAddress) public {
        ERC20 token = ERC20(tokenAddress);
        _tokens[tokenAddress] = token;
    }

    function removeToken(address token) public {
        delete _tokens[token];
    }

    function addNetwork(uint256 chainId) public {

    }

    function removeNetwork(uint256 chainId) public {

    }

    function swap(address tokenAddress, address sender, uint256 amount) public {
        ERC20 token = _tokens[tokenAddress];
        token.burn(amount);
        emit swapInitialized(msg.sender, sender, amount);
    }

    function redeem(address tokenAddress, address recipient, uint256 amount, uint256 chainId, uint256 nonce,
        uint8 v, bytes32 r, bytes32 s) public {

        ERC20 token = _tokens[tokenAddress];
        if (_checkSign(recipient, amount, chainId, nonce, v, r, s)) {
            token.mint(amount);
        }
    }

    function _checkSign(address recipient, uint256 amount, uint256 chainId, uint256 nonce, uint8 v, bytes32 r, bytes32 s)
    internal virtual returns (bool) {

        bytes32 digest = keccak256(
            abi.encodePacked(recipient, amount, chainId, nonce)
        );

        bytes32 hashMsg = hashMessage(digest);
        uint256 count = _hashMessages[hashMsg];
        if (count != 0) {
            address addr = ECDSA.recover(hashMsg, v, r, s);
            return addr == _validator;
        } else {
            _hashMessages[hashMsg] = count + 1;
            return false;
        }
    }

    function hashMessage(bytes32 message) private pure returns (bytes32) {
        bytes memory prefix = "\x19Ethereum Signed Message:\n32";
        return keccak256(abi.encodePacked(prefix, message));
    }
}
