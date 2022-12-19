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

contract VCStorage is Ownable {
    // TEE TLS root sovereign account
    address public teeCoordinator;
    // VCCallBack contract address
    address public callBack;
    // vcID => VC
    mapping(bytes32 => VC) internal vcStorage;

    struct VC {
        bytes32 proof;  //??? Is this type proper?
        // The timestamp of VC created, not the expired time
        uint32 timeStamp;
    }

    /**
    * @dev Throws if called by any account other than Updater.
    */
    modifier onlyUpdater() {
        require((teeCoordinator == _msgSender()) || (callBack == _msgSender()), "Not authentic updater");
        _;
    }

    /**
    * @param _teeCoordinator address of TEE TLS root sovereign account
    */
    constructor(address _teeCoordinator, address _callBack) {
        teeCoordinator = _teeCoordinator;
        callBack = _callBack;
    }

    function alterUpdater(address _teeCoordinator, address _callBack) public onlyOwner {
        teeCoordinator = _teeCoordinator;
        callBack = _callBack;
    }

    function updateVC(bytes32 vcId, bytes32 vcProof, uint32 timeStamp) public virtual onlyUpdater {
        require(timeStamp >= vcStorage[vcId].timeStamp, "Older Version VC Rejected");
        require(timeStamp <= block.timestamp, "Future VC Rejected");
        vcStorage[vcId].proof = vcProof;
        vcStorage[vcId].timeStamp = timeStamp;
    }

    function isVcStored(bytes32 vcId) public view returns (bool) {
        if (vcStorage[vcId].proof != 0) {
            return true;
        } else {
            return false;
        }
    }

    function queryVC(bytes32 vcId) public view returns (bytes32) {
        return vcStorage[vcId].proof;
    }
}