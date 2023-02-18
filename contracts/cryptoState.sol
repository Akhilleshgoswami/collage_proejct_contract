// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract RealState is ERC721, Ownable, ReentrancyGuard {
    using Counters for Counters.Counter;

    string public nameOf = "Govt of India  Cryptostate  Poratal";

    // this is contract's token collection name
    string public collectionName;
    // this is the contract's token symbol
    string public collectionNameSymbol;

    // total number of collection that to be created
    Counters.Counter private cryptoStateCouter;
    //listing price
    uint256 listingPrice = 0.1 ether;

    struct CryptoState {
        uint256 tokenId;
        string tokenName;
        string tokenURI;
        address payable mintedBy;
        address payable currentOwner;
        address payable perviousOwner;
        uint256 price;
        bool forSale;
        string placeAddress;
    }
    event CryptoStateItemCreate(
        uint256 tokenId,
        string tokenName,
        string tokenURI,
        address payable mintedBy,
        address payable currentowner,
        address payable oldowenr,
        uint256 price
    );
    // map cryptoStata's token id to cryptostate
    mapping(uint256 => CryptoState) public allCryptostate;
    // token validation
    mapping(string => bool) private tokenNameExists;
    //check if the token URI exists
    mapping(string => bool) private tokenURIExists;

    constructor() ERC721("CryptoState", "IND") {
        collectionName = name();
        collectionNameSymbol = symbol();
    }
// this function is used to transfer ether to govt account
 function withdraw() public payable onlyOwner {
        address payable _owner = payable(owner());
        _owner.transfer(address(this).balance);
    }
    // create new cryptostate
    // Creation

    function mintCryptoState(
        string memory _name,
        string memory _tokenURI,
        uint256 _price,
        string memory _placeAddress,
        address _owner,
        bool _forSell
    ) public payable onlyOwner nonReentrant {
        // address should to be valide
        require(msg.sender != address(0));
        // price must be grater then 0
        require(_price > 0, "Price must be at least 1 wei");
        // listing price should to be equal
        require(
            msg.value >= listingPrice,
            "Price must be equal to listing price"
        );

        //token URI must be uniqe
        require(!tokenURIExists[_tokenURI]);
        // token name must be uniqe
        require(!tokenNameExists[_name]);
        // increament the counter of cryptostate
        cryptoStateCouter.increment();
        //getting the current count
        uint256 tokenId = cryptoStateCouter.current();
        // mint the token
        _mint(_owner, tokenId);
        // set token URI (bind token id with the passed in token URI)
        // _setTokenURI(tokenId, _tokenURI);
        tokenURIExists[_tokenURI] = true;
        tokenNameExists[_name] = true;
        // creat a new crypto state (struct) and pass in new values
        CryptoState memory newCryptoState = CryptoState(
            tokenId,
            _name,
            _tokenURI,
            payable(msg.sender),
            payable(_owner),
            payable(address(0)),
            _price,
            _forSell,
            _placeAddress
        );
        // adding to the allCrypto state array
        allCryptostate[tokenId] = newCryptoState;
        // emit event
        emit CryptoStateItemCreate(
            tokenId,
            _name,
            _tokenURI,
            payable(msg.sender),
            payable(_owner),
            payable(address(0)),
            _price
        );
    }

    //getting the pricing list
    function getListingPrice() public view returns (uint256) {
        return listingPrice;
    }

    // get owner of the token
    function getTokenOwner(uint256 _tokenId) public view returns (address) {
        address _tokenOwer = ownerOf(_tokenId);
        return _tokenOwer;
    }

    // to feel after sometime
    function getTokenMetadata(uint256 _tokenId)
        public
        view
        returns (string memory)
    {
    string memory tokenMetaData = tokenURI(_tokenId);
    return tokenMetaData;
    }

    // get the number of token that created till the function is called
    function getNumberOfTokensMinted() public view returns (uint256) {
        uint256 totalNumberofTokensMinted = cryptoStateCouter.current();
        return totalNumberofTokensMinted;
    }

    // get the number of the token owned by the  caller of the function
    function TokenownedByaddress(address _owner) public view returns (uint256) {
        uint256 totalNumberofTokensowned = balanceOf(_owner);
        return totalNumberofTokensowned;
    }

    // returns if some token is exits or not
    function getTokenExists(uint256 _tokenId) public view returns (bool) {
        bool tokenExists = _exists(_tokenId);
        return tokenExists;
    }

    // buy the Cryptostate
    function buyToken(uint256 _tokenId) public payable {
        require(msg.sender != address(0), "address can't be null");
        // token it must be exits
        require(_exists(_tokenId), "token must be exits on the contract");
        // get the owner of the token
        address tokenOnwer = ownerOf(_tokenId);
        // we can not buy over own token
        require(msg.sender != tokenOnwer, "you can not buy your own token");
        // getting token form the block chain
        CryptoState memory cryptostate = allCryptostate[_tokenId];
        // the price must be equal to or greater then
        require(
            msg.value >= cryptostate.price,
            "please Enter full price to buy"
        );
        // it must be marked as for sale
        require(cryptostate.forSale);

        // tansfer the owner ship
        _transfer(tokenOnwer, msg.sender, _tokenId);
        // getting the current owner of the smart contract
        address payable sendTo = cryptostate.currentOwner;
        // sending the token worth to the owner of the  token
        sendTo.transfer(msg.value);
        //update  pervious owner
        cryptostate.perviousOwner = cryptostate.currentOwner;
        // update the current owner
        cryptostate.currentOwner = payable(msg.sender);

        // set and update the data of token
        allCryptostate[_tokenId] = cryptostate;
    }

    // change the price oft the token
    function changeTokenPrice(uint256 _tokenId, uint256 _newPrice)
        public
        payable
    {
        // address must not be empty
        require(msg.sender != address(0));

        require(msg.value >= listingPrice);

        address tokenOnwer = ownerOf(_tokenId);

        require(tokenOnwer == msg.sender);

        CryptoState storage  cryptostate = allCryptostate[_tokenId];
        //update the price
        cryptostate.price = _newPrice;

    }

    function toggleForSale(uint256 _tokenId) public payable {
        require(msg.sender != address(0));
        // require caller of the function is not an empty address
        // require that token should exist
        require(_exists(_tokenId));
        // get the token's owner
        address tokenOwner = ownerOf(_tokenId);
        // check that token's owner should be equal to the caller of the function
        require(tokenOwner == msg.sender);
        // get that token from all crypto boys mapping and create a memory of it defined as (struct => CryptoBoy)

        CryptoState storage cryptostate = allCryptostate[_tokenId];

        if (cryptostate.forSale) {
            cryptostate.forSale = false;
        } else {
            cryptostate.forSale = true;
        }
        // set and update that token in the mapping
        allCryptostate[_tokenId] = cryptostate;
    }
    // get all the sold proudct
    // we can do for this at front end
    // fetch my own NFT we can do for it on front-end
 
    
}