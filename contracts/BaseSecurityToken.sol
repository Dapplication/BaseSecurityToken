pragma solidity ^0.4.24;

import "./IBaseSecurityToken.sol";
import "./lib/ERC20.sol";


/**
 * @title BaseSecurityToken implementation
 * @dev see https://github.com/ethereum/EIPs/pull/1462
 */
contract BaseSecurityToken is IBaseSecurityToken, ERC20 {
    
    struct Document {
        bytes32 name;
        string uri;
        bytes32 contentHash;
    }

    mapping (bytes32 => Document) private documents;

    function transfer(address to, uint256 value) public returns (bool) {
        require(checkTransferAllowed(msg.sender, to, value) == STATUS_ALLOWED, "transfer must be allowed");
        return ERC20.transfer(to, value);
    }

    function transferFrom(address from, address to, uint256 value) public returns (bool) {
        require(checkTransferFromAllowed(from, to, value) == STATUS_ALLOWED, "transfer must be allowed");
        return ERC20.transferFrom(from, to, value);
    }

    function _mint(address account, uint256 amount) internal {
        require(checkMintAllowed(account, amount) == STATUS_ALLOWED, "mint must be allowed");
        ERC20._mint(account, amount);
    }

    function _burn(address account, uint256 amount) internal {
        require(checkBurnAllowed(account, amount) == STATUS_ALLOWED, "burn must be allowed");
        ERC20._burn(account, amount);
    }

    function attachDocument(bytes32 _name, string _uri, bytes32 _contentHash) external {
        require(_name.length > 0, "name of the document must not be empty");
        require(bytes(_uri).length > 0, "external URI to the document must not be empty");
        require(_contentHash.length > 0, "content hash is required, use SHA-1 when in doubt");
        require(documents[_name].name.length == 0, "document must not be existing under the same name");
        documents[_name] = Document(_name, _uri, _contentHash);
    }
   
    function lookupDocument(bytes32 _name) external view returns (string, bytes32) {
        Document storage doc = documents[_name];
        return (doc.uri, doc.contentHash);
    }

    // Uses status codes from ERC-1066
    byte private constant STATUS_ALLOWED = 0x11;

    function checkTransferAllowed (address, address, uint256) public view returns (byte) {
        // default
        return STATUS_ALLOWED;
    }
   
    function checkTransferFromAllowed (address, address, uint256) public view returns (byte) {
        // default
        return STATUS_ALLOWED;
    }
   
    function checkMintAllowed (address, uint256) public view returns (byte) {
        // default
        return STATUS_ALLOWED;
    }
   
    function checkBurnAllowed (address, uint256) public view returns (byte) {
        // default
        return STATUS_ALLOWED;
    }
}
