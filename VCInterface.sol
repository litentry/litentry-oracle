// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
interface IVCStorage {
    function alterUpdater(address _teeCoordinator, address _callBack) external;
    function updateVC(bytes32 vcId, bytes32 vcProof, uint32 timeStamp) external;
    function isVcStored(bytes32 vcId) external view returns (bool);
    function queryVC(bytes32 vcId) external view returns (bytes32);
}

interface IVCCallBack {
    function alterTeeCoordinator(address _teeCoordinator) external;
    function linkVcStorage(address _vcStorage) external;
    function request(bytes32 messageId, bytes32 vcId, bool storageUpdate, address callBackAddress) external returns (bytes32 vcProofOrZero); 

    event VCUpdatePending(bytes32 indexed messageId, bytes32 indexed vcId, address callBackAddress, bool storageUpdate);
}