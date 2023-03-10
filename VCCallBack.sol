// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
// File: @openzeppelin/contracts/GSN/Context.sol

/*
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with GSN meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

// File: @openzeppelin/contracts/access/Ownable.sol

/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * By default, the owner account will be the one that deploys the contract. This
 * can later be changed with {transferOwnership}.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */
abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor () {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

import "./VCInterface.sol";

contract VCCallBack is Ownable {
    // TEE TLS root sovereign account
    address public teeCoordinator;
    // VC Storage contract
    address public vcStorage;

    event VCUpdatePending(bytes32 indexed messageId, bytes32 indexed vcId, address callBackAddress, bool storageUpdate);
    /**
    * @dev Throws if called by any account other than teeCoordinator.
    */
    modifier onlyTEE() {
        require(teeCoordinator == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    /**
    * @param _teeCoordinator address of TEE TLS root sovereign account
    */
    constructor(address _teeCoordinator) {
        teeCoordinator = _teeCoordinator;
    }

    function alterTeeCoordinator(address _teeCoordinator) public onlyOwner {
        teeCoordinator = _teeCoordinator;
    }

    function linkVcStorage(address _vcStorage) public onlyOwner {
        vcStorage = _vcStorage;
    }

    function request(bytes32 messageId, bytes32 vcId, bool storageUpdate, address callBackAddress) public returns (bytes32 vcProofOrZero) {
        if (IVCStorage(vcStorage).isVcStored(vcId) && !(storageUpdate)) {
            return IVCStorage(vcStorage).queryVC(vcId);
        } else {
            emit VCUpdatePending(messageId, vcId, callBackAddress, storageUpdate);
            return 0;
        }
    }
}