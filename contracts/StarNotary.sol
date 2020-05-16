pragma solidity ^0.6.0;

//Importing openzeppelin-solidity ERC-721 implemented Standard
//import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC721/ERC721.sol";
import "../node_modules/openzeppelin-solidity/contracts/token/ERC721/ERC721.sol";

// StarNotary Contract declaration inheritance the ERC721 openzeppelin implementation
contract StarNotary is ERC721 {

    // Star data
    struct Star {
        string name;
    }

    // Implement Task 1 Add a name and symbol properties
    // name: Is a short name to your token
    // symbol: Is a short string like 'USD' -> 'American Dollar'
    string public constant StarName = "SuperStar";
    string public constant StarSymbol = "SS";
    constructor() ERC721(StarName,StarSymbol) public {
    }  

    // mapping the Star with the Owner Address
    mapping(uint256 => Star) public tokenIdToStarInfo;
    // mapping the TokenId and price
    mapping(uint256 => uint256) public starsForSale;

    // Create Star using the Struct
    function createStar(string memory _name, uint256 _tokenId) public {
        Star memory newStar = Star(_name);
        tokenIdToStarInfo[_tokenId] = newStar;
        _mint(msg.sender, _tokenId);
    }

    // Putting an Star for sale
    function putStarUpForSale(uint256 _tokenId, uint256 _price) public {
        require(ownerOf(_tokenId) == msg.sender, "You can't sale a Star you don't own");
        starsForSale[_tokenId] = _price;
    }

    // Owner to approve buyer before selling and transferring
    function approveCaller(address buyer, uint256 _tokenId) public returns (bool success) {
        approve(buyer, _tokenId);
		return true;
    }

    // Function that allows you to convert an address into a payable address
    function _make_payable(address x) internal pure returns (address payable) {
        return address(uint160(x));
    }

    // Function that allows a buyer to buy the star
    function buyStar(uint256 _tokenId) public  payable {
        require(starsForSale[_tokenId] > 0, "The Star should be up for sale");
        uint256 starCost = starsForSale[_tokenId];
        address ownerAddress = ownerOf(_tokenId);
        require(msg.value > starCost, "You need to have enough Ether");

        require(_isApprovedOrOwner(ownerAddress, _tokenId));
        safeTransferFrom(ownerAddress, msg.sender, _tokenId);
        address payable ownerAddressPayable = _make_payable(ownerAddress);
        ownerAddressPayable.transfer(starCost);
        if(msg.value > starCost) {
            msg.sender.transfer(msg.value - starCost);
        }
    }

    // Implement Task 1 lookUptokenIdToStarInfo
    function lookUptokenIdToStarInfo (uint _tokenId) public view returns (string memory) {
        require(bytes(tokenIdToStarInfo[_tokenId].name).length > 0, "Star not found");
        return tokenIdToStarInfo[_tokenId].name;
    }

    // Implement Task 1 Exchange Stars function
    function exchangeStars(uint256 _tokenId1, uint256 _tokenId2) public {
        //1. Passing to star tokenId you will need to check if the owner of _tokenId1 or _tokenId2 is the sender
        //2. You don't have to check for the price of the token (star)
        //3. Get the owner of the two tokens (ownerOf(_tokenId1), ownerOf(_tokenId1)
        //4. Use _transferFrom function to exchange the tokens.
        require(ownerOf(_tokenId1) == msg.sender || ownerOf(_tokenId2) == msg.sender, "You can't exchange a Star you don't own");
        
        address ownerAddress1 = ownerOf(_tokenId1);
        address ownerAddress2 = ownerOf(_tokenId2);

        require(_isApprovedOrOwner(ownerAddress1, _tokenId2));
        require(_isApprovedOrOwner(ownerAddress2, _tokenId1));

        safeTransferFrom(ownerAddress1, ownerAddress2, _tokenId1);
        safeTransferFrom(ownerAddress2, ownerAddress1, _tokenId2);
    }

    // Implement Task 1 Transfer Stars
    function transferStar(address _to1, uint256 _tokenId) public {
        //1. Check if the sender is the ownerOf(_tokenId)
        //2. Use the transferFrom(from, to, tokenId); function to transfer the Star
        require(ownerOf(_tokenId) == msg.sender, "You can't exchange a Star you don't own");

        require(_isApprovedOrOwner(msg.sender, _tokenId));

        safeTransferFrom(msg.sender, _to1, _tokenId);
    }

}