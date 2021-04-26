// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
//import "@chainlink/contracts/src/v0.8/dev/VRFConsumerBase.sol";

contract DPT is ERC721, Ownable {
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;
    Counters.Counter private _tmptokenIds;

    //intra file data - No token until approved
    mapping (uint256 => string) private _tmptokenURIs;
    mapping (uint256 => string) private _tmpinventorNames;
    mapping (uint256 => string) private _tmpinventionDate;
    mapping (uint256 => address) private _tmpinventorAddr;
    mapping (uint256 => address) private _tmpvalidatorAddr;
    mapping (uint256 => bool) private _tmptokenNotHandled;




    // URI holds sha256
    mapping (uint256 => string) private _tokenURIs;
    // Inventor Names
    mapping (uint256 => string) private _inventorNames;
    // Date Invented
    mapping (uint256 => string) private _inventionDate;
    // Inventor Address
    mapping (uint256 => address) private _inventorAddr;
    /* // if the token is approved or not
    mapping (uint256 => bool) private _tokenApproved; */
    // Validator Address
    mapping (uint256 => address) private _validatorAddr;
    // Delegate Address
    mapping (uint256 => address) private _delegateAddr;

    constructor() ERC721("Distributed Patent Token", "DPT") {}

    function filePatent(string memory sha256_hash, string memory inventor_name, string memory date) external returns (uint256) {
      _tmptokenIds.increment();
      uint256 newNftTokenId = _tmptokenIds.current();

      _tmptokenURIs[newNftTokenId] = sha256_hash;
      _tmpinventorNames[newNftTokenId] = inventor_name;
      _tmpinventionDate[newNftTokenId] = date;
      _tmpinventorAddr[newNftTokenId] = msg.sender;

      //the first patent is automatically approved
      if(newNftTokenId == 1){
        _tokenIds.increment();//both are at 1 now
        _mint(msg.sender, newNftTokenId);

        _tokenURIs[newNftTokenId] = sha256_hash;
        _inventorNames[newNftTokenId] = inventor_name;
        _inventionDate[newNftTokenId] = date;
        _inventorAddr[newNftTokenId] = msg.sender;
        _validatorAddr[newNftTokenId] = msg.sender;
        _delegateAddr[newNftTokenId] = msg.sender;
        _tmptokenNotHandled[newNftTokenId] = false;

      }
      else{
        //randomly select the validator
        _tmpvalidatorAddr[newNftTokenId] = _delegateAddr[1];
        _tmptokenNotHandled[newNftTokenId] = true;
      }
      return newNftTokenId;
    }



//************************ Helper Functions******************************/
    // Intializing the state variable
      uint randNonce = 0;

      // Defining a function to generate
      // a random number
      function randMod(uint256 _modulus) internal returns(uint256){
         // increase nonce
         randNonce++;
         return uint256(keccak256(abi.encodePacked(block.timestamp,  msg.sender, randNonce))) % _modulus;
       }

       // Defining a function to generate
       // a random number from 1 to the current patent in the chain
       function selectPatent() internal returns(uint256){
          return 1+randMod(_tokenIds.current());
        }



//************************ Handling Temporary Patents******************************/

    //returns the inventor of the patent
    function nextToApprove() public view returns (uint256 next_patent) {
    uint _j = 0;
    uint current_tmp = _tmptokenIds.current();

    for(_j = 2; _j <= current_tmp; _j++){
      if((_tmpvalidatorAddr[_j] == msg.sender)&&_tmptokenNotHandled[_j]){
        return _j;
      }
    }

    return 0;
    }
    //approves the patent making a new token for it
    function approvePatent(uint256 tmptokenId) external returns (bool) {
        if((_tmpvalidatorAddr[tmptokenId] == msg.sender)&&_tmptokenNotHandled[tmptokenId]){//makes sure only the validator can approve
            _tokenIds.increment();
            uint256 newNftTokenId = _tokenIds.current();
            _mint(_tmpinventorAddr[tmptokenId], newNftTokenId);

            _tokenURIs[newNftTokenId] =  _tmptokenURIs[tmptokenId];
            _inventorNames[newNftTokenId] = _tmpinventorNames[tmptokenId];
            _inventionDate[newNftTokenId] = _tmpinventionDate[tmptokenId];
            _inventorAddr[newNftTokenId] = _tmpinventorAddr[tmptokenId];
            _validatorAddr[newNftTokenId] = msg.sender;
            _delegateAddr[newNftTokenId] = msg.sender;

            _tmptokenNotHandled[tmptokenId] = false;
            return true;
        }
        else{
            return false;
        }
      }

      //denys the patent
      function denyPatent(uint256 tmptokenId) external returns (bool) {
          if((_tmpvalidatorAddr[tmptokenId] == msg.sender)&&_tmptokenNotHandled[tmptokenId] ){//makes sure only the validator can deny
              _tmptokenNotHandled[tmptokenId] = false;
              return true;
          }
          else{
              return false;
          }
        }

//************************ Handling Created Patents******************************/

      //returns the SHA 256 hash of the file holding the patent
    function tokenURI(uint256 tokenId) public view virtual override returns (string memory) {
        require(_exists(tokenId), "ERC721Metadata: URI query for nonexistent token");

        return _tokenURIs[tokenId];

      }

      //returns the inventor of the patent
   function tokenInventor(uint256 tokenId) public view returns (string memory) {
      require(_exists(tokenId), "ERC721Metadata: URI query for nonexistent token");

      return _inventorNames[tokenId];
    }

    //returns the date of creation of the patent
  function tokenDate(uint256 tokenId) public view returns (string memory) {
    require(_exists(tokenId), "ERC721Metadata: URI query for nonexistent token");

    return _inventionDate[tokenId];
  }

  //returns the delegate of the patent
  function currentDelegate(uint256 tokenId) public view returns (address delegate) {
    require(_exists(tokenId), "ERC721Metadata: URI query for nonexistent token");

    return _delegateAddr[tokenId];
  }

  //changes the delegate of the patent
  function changeCurrentDelegate(uint256 tokenId, address new_delegate) public  returns (bool success) {
    require(_exists(tokenId), "ERC721Metadata: URI query for nonexistent token");
    if(ownerOf(tokenId) == msg.sender){
       _delegateAddr[tokenId] =new_delegate;
      return true;
    }
    else{
      return false;
    }
  }



   function owns() public view returns (uint256[] memory) {
  /* function owns() public view returns (bytes32[] memory) { */
    uint256 count = 0;
    uint256 _j = 1;
    uint current_tmp = _tokenIds.current();

    for(_j = 1; _j <= current_tmp; _j++){
      if(ownerOf(_j) == msg.sender){
        count++;
      }
    }
    uint256[] memory foo = new uint256[](count);
    count = 0;
    for(_j = 1; _j <= current_tmp; _j++){
      if(ownerOf(_j) == msg.sender){
        foo[count++] = _j;
      }
    }
    return foo;
  }

}
