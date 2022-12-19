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

import "./VCInterface.sol";

contract dummyVCConsumer is Context {
    // VC Storage contract
    address public vcCallBack;
    /**
    * @dev Throws if called by any account other than vcCallBack.
    */
    modifier onlyCallBack() {
        require(vcCallBack == _msgSender(), "Ownable: caller is not vcCallBack");
        _;
    }
    
    event vcRequest(bool digestResult);

    function QuerySomethingAndEmitEvent(bytes32 vcId) public {
        _requestVC(vcId);
    }

    function _requestVC(bytes32 vcId) internal {
        bytes32 result = IVCCallBack(vcCallBack).request(bytes32(uint(1)), vcId, false, address(this));

        if (result != 0) {
            _mainLogic(result);
        }
    }

    function _mainLogic(bytes32 vcProof) internal {
        emit vcRequest(vcProof > bytes32(uint256(999)));
    }
}