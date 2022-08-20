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
    ERC20 public immutable token;

    mapping(bytes32 => uint256) _hashMessages;
    address private _validator;

    event swapInitialized(address indexed from, address indexed spender, uint256 value);

    constructor(address token_, address validator_) {
        stakingToken = ERC20(token_);
        _validator = validator_;
    }

    function swap(uint256 amount, address recipient) {

        //        роль бернора
        //        token.burn(amount);
        emit swapInitialized();
    }

    function redeem() {
        //        проверить, что сигнатура, которая пришла с бэка возвращает один и тот же адрес, то валидна функция
        //    checSign();
        //    mint
    }

    function checkSign(address sender, uint256 amount, uint256 chainId, uint256 nonce, uint8 v, bytes32 r, bytes32 s) returns (bool) {
        bytes32 digest = keccak256(
            abi.encodePacked(sender, amount, chainId, nonce)
        );

        bytes32 hashMsg = hashMessage(digest);
        uint256 count = _hashMessages[hashMsg];
        if (count != 0) {
            address addr = ECDSA.ecrecover(hashMsg, v, r, s);
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
