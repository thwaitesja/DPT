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
    mapping (uint256 => uint256) private _tmptokenSHAs;
    mapping (uint256 => string) private _tmptokenTitles;
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
    // sha256
    mapping (uint256 => uint256) private _tokenSHAs;
    // Titles
    mapping (uint256 => string) private _tokenTitles;
    // Validator Address
    mapping (uint256 => address) private _validatorAddr;
    // Delegate Address
    mapping (uint256 => address) private _delegateAddr;

    // Buyer Address
    mapping (uint256 => address) private _buyerAddr;
    // Buying Price
    mapping (uint256 => uint256) private _buyingPrice;

    constructor() ERC721("Distributed Patent Token", "DPT") {}

    function filePatent(string memory title, uint256 sha256_hash, string memory uri_loc, string memory inventor_name, string memory date) external returns (uint256) {
      _tmptokenIds.increment();
      uint256 newNftTokenId = _tmptokenIds.current();


      _tmptokenTitles[newNftTokenId] = title;
      _tmptokenSHAs[newNftTokenId] = sha256_hash;
      _tmptokenURIs[newNftTokenId] = uri_loc;
      _tmpinventorNames[newNftTokenId] = inventor_name;
      _tmpinventionDate[newNftTokenId] = date;
      _tmpinventorAddr[newNftTokenId] = msg.sender;

      //the first patent is automatically approved
      if(newNftTokenId == 1){
        _tokenIds.increment();//both are at 1 now
        _mint(msg.sender, newNftTokenId);

        _tokenTitles[newNftTokenId] = _tmptokenTitles[newNftTokenId];
        _tokenSHAs[newNftTokenId] = _tmptokenSHAs[newNftTokenId];
        _tokenURIs[newNftTokenId] = uri_loc;
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
  /* function uintToString(uint v) internal  returns (string str) {
      uint maxlength = 100;
      bytes memory reversed = new bytes(maxlength);
      uint i = 0;
      while (v != 0) {
          uint remainder = v % 10;
          v = v / 10;
          reversed[i++] = bytes1(uint8(48 + remainder));
      }
      bytes memory s = new bytes(i);
      for (uint j = 0; j < i; j++) {
          s[j] = reversed[i - 1 - j];
      }
      str = string(s);
  } */

  function appendUintToString(string memory inStr, uint v) internal pure returns (string memory) {
      uint maxlength = 100;
      bytes memory reversed = new bytes(maxlength);
      uint i = 0;
      while (v != 0) {
          uint remainder = v % 10;
          v = v / 10;
          reversed[i++] = bytes1(uint8(48 + remainder));
      }
      bytes memory inStrb = bytes(inStr);
      bytes memory s = new bytes(inStrb.length + i);
      uint j;
      for (j = 0; j < inStrb.length; j++) {
          s[j] = inStrb[j];
      }
      for (j = 0; j < i; j++) {
          s[j + inStrb.length] = reversed[i - 1 - j];
      }
      return string(s);
  }


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


  //returns the SHA 256 hash of the file holding the tmp patent
  function tmptokenURI(uint256 tokenId) public view  returns (string memory) {
     if((msg.sender == _tmpvalidatorAddr[tokenId])){
          return _tmptokenURIs[tokenId];
     }
     else{
        return "https://www.youtube.com/watch?v=dQw4w9WgXcQ";
     }
  }

  //returns the inventor of the tmp patent
  function tmptokenInventor(uint256 tokenId) public view returns (string memory) {
      return _tmpinventorNames[tokenId];
  }

  //returns the date of creation of the tmp patent
  function tmptokenDate(uint256 tokenId) public view returns (string memory) {
      return _tmpinventionDate[tokenId];
  }

  //returns the title of the tmp patent
  function tmptokenTitle(uint256 tokenId) public view returns (string memory) {
      return _tmptokenTitles[tokenId];
  }

  //returns the sha 256 of the tmp patent
  function tmptokenSHA(uint256 tokenId) public view returns (uint256) {
      return _tmptokenSHAs[tokenId];
  }


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

            _tokenTitles[newNftTokenId] = _tmptokenTitles[tmptokenId];
            _tokenSHAs[newNftTokenId] = _tmptokenSHAs[tmptokenId];
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
    //returns the number of patents
    function patentCap() public view returns (uint256) {
      return _tokenIds.current();
    }

      //returns the SHA 256 hash of the file holding the patent
    function tokenURI(uint256 tokenId) public view virtual override returns (string memory) {
        require(_exists(tokenId), "ERC721Metadata:  query for nonexistent token");
        return _tokenURIs[tokenId];

      }

      //returns the inventor of the patent
   function tokenInventor(uint256 tokenId) public view returns (string memory) {
      require(_exists(tokenId), "ERC721Metadata: URI query for nonexistent token");
      return _inventorNames[tokenId];
    }

    //returns the date of creation of the patent
  function tokenDate(uint256 tokenId) public view returns (string memory) {
    require(_exists(tokenId), "ERC721Metadata: query for nonexistent token");
    return _inventionDate[tokenId];
  }

  //returns the SHA256 of the patent
  function tokenSHA(uint256 tokenId) public view returns (uint256) {
    require(_exists(tokenId), "ERC721Metadata: query for nonexistent token");
    return _tokenSHAs[tokenId];
  }

    //returns the title of the patent
  function tokenTitle(uint256 tokenId) public view returns (string memory) {
    require(_exists(tokenId), "ERC721Metadata: query for nonexistent token");
    return _tokenTitles[tokenId];
  }



  //returns the delegate of the patent
  function currentDelegate(uint256 tokenId) public view returns (address delegate) {
    require(_exists(tokenId), "ERC721Metadata: query for nonexistent token");

    return _delegateAddr[tokenId];
  }

  //changes the delegate of the patent
  function changeCurrentDelegate(uint256 tokenId, address new_delegate) public  returns (bool success) {
    require(_exists(tokenId), "ERC721Metadata: query for nonexistent token");
    if(ownerOf(tokenId) == msg.sender){
       _delegateAddr[tokenId] =new_delegate;
      return true;
    }
    else{
      return false;
    }
  }





  //makes a list of all the patent Ids a person owns
   function owns() public view returns (string memory) {
    uint256 _j = 1;
    uint current_tmp = _tokenIds.current();

    string memory message = "[ ";

    for(_j = 1; _j <= current_tmp; _j++){
      if(ownerOf(_j) == msg.sender){
           message = appendUintToString( message, _j);
           message = string(abi.encodePacked(message, " "));
      }
    }
    message = string(abi.encodePacked(message, "]"));
    return message;

  }




//initializes a trade
 function trade_init(uint256 tokenId) public payable returns (bool) {
   if(msg.value > _buyingPrice[tokenId]){//if a higher bid
       trade_cancel(tokenId);
      _buyingPrice[tokenId] = msg.value;
      _buyerAddr[tokenId] = msg.sender;
      return true;
   }
   else{//else rebate the money
      payable(msg.sender).transfer(msg.value);
      return false;
   }
}

//view a trade price
 function current_trade_offer(uint256 tokenId) public view returns (uint256) {
   require(_exists(tokenId), "ERC721Metadata: query for nonexistent token");
   return _buyingPrice[tokenId];
 }


//confirm a trade
 function trade_confirm(uint256 tokenId, uint256 money) public returns (bool) {
   if(ownerOf(tokenId) == msg.sender){
     if(money <= _buyingPrice[tokenId]){
        uint256 tmp = _buyingPrice[tokenId];
        // Buying Price to 0
        _buyingPrice[tokenId] = 0;
        payable(msg.sender).transfer(tmp*4/5);
        payable(_inventorAddr[tokenId]).transfer(tmp/10);
        payable(_delegateAddr[tokenId]).transfer(tmp/10);

        transferFrom(msg.sender, _buyerAddr[tokenId], tokenId);

        /* emit Transfer(msg.sender, _buyerAddr[tokenId], tokenId); */
        // Buyer Address to 0
        _buyerAddr[tokenId] = address(0);
        return true;
     }
   }
   return false;
}

//cancel a trade
 function trade_cancel(uint256 tokenId) public returns (bool) {
   uint256 tmp = _buyingPrice[tokenId];
   // Buying Price to 0
   _buyingPrice[tokenId] = 0;

   payable(_buyerAddr[tokenId]).transfer(tmp);

   // Buyer Address to 0
   _buyerAddr[tokenId] = address(0);
   return true;
}

}
