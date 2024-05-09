// contracts/MyNFT.sol
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";

contract MyNFT is ERC721URIStorage, Ownable {
    using Counters for Counters.Counter;
    Counters.Counter private tokenIds;
    Counters.Counter private userIds;


    struct nftStruct {
        uint256 tokenId;
        address payable owner;
        string title;
        string description;
        string image;
        string tokenUri;
    }

    mapping(uint256 => nftStruct) private nfts;
    mapping(address => uint256 []) private nftOwners;

    event NftStructCreated(
        uint256 indexed tokenId,
        address payable owner,
        string title,
        string description,
        string image
    );

    constructor() ERC721("NFT MINTO", "MINTO's NFT collection") {
        tokenIds.increment();
        userIds.increment();
    }
    

    function setNft(
        uint256 _tokenId,
        string memory _title,
        string memory _description,
        string memory _tokenURI,
        string memory _image
    ) private {

        nfts[_tokenId].tokenId = _tokenId;
        nfts[_tokenId].owner = payable(msg.sender);
        nfts[_tokenId].title = _title;
        nfts[_tokenId].description = _description;
        nfts[_tokenId].tokenUri = _tokenURI;
        nfts[_tokenId].image = _image;

        emit NftStructCreated(
            _tokenId,
            payable(msg.sender),
            _title,
            _description,
            _image
        );
    }
    /// @dev this function mints received NFTs
    /// @param _tokenURI the new token URI for the magazine cover
    /// @param _title the name of the magazine cover
    /// @param _description detailed information on the magazine NFT
    /// @param _image image
    // /// @return tokenId of the created NFT
    function createNft(
        string memory _tokenURI,
        string memory _title,
        string memory _description,
        string memory _image
    ) public  {
        
        uint256 newTokenId = tokenIds.current();
        _mint(msg.sender, newTokenId);
        _setTokenURI(newTokenId, _tokenURI);
        nftOwners[msg.sender].push(newTokenId);
        setNft(newTokenId, _title, _description, _tokenURI, _image);
        tokenIds.increment();
    }


    
    // not use
    /// @dev fetches NFT magazines that a specific user has created
    /// @return nftStruct[] list of nfts created by a user with their metadata
    // function getNfts() public view returns (nftStruct[] memory) {
    //     uint256 nftCount = tokenIds.current();
    //     nftStruct[] memory nftSubs = new nftStruct[](nftCount);
    //     for (uint256 i = 1; i < nftCount; i++) {
    //         if (nfts[i].owner == payable(msg.sender)) {
    //             nftSubs[i] = nfts[i];
    //         }
    //     }

    //     return nftSubs;
    // }

    /// @dev fetches NFT magazines that a specific user has created
    /// @return nftStruct[] list of nfts created by a user with their metadata
    function getNfts() public view returns (nftStruct[] memory){
        uint256 nftCount = tokenIds.current();
        nftStruct[] memory myNfts = new nftStruct[](nftCount);
        uint256 j = 0;
        for (uint256 i = 1; i < nftCount; i++){
            if (ownerOf(i) == msg.sender){
                myNfts[j] = nfts[i];
                j++;
            }
        }
        nftStruct[] memory returnMyNFts = new nftStruct[](j);
        for (uint256 i = 0; i < j; i++){
            returnMyNFts[i] = myNfts[i];
        }
        return returnMyNFts;
    }

    /// @dev fetches details of a particular NFT magazine subscription
    /// @param _tokenId The token ID of the NFT Magazine
    /// @return nftStruct NFT data of the specific token ID
    function getIndividualNFT (
        uint256 _tokenId
    ) public view returns (nftStruct memory) {
        return nfts[_tokenId];
    }

    function getNftsByAddress (address owner) public view returns(uint256[] memory){
        require(owner != address(0), "ERC721: address zero is not a valid owner");
        return nftOwners[owner];
    }

    function sendNft(address from, address  payable to, uint256 tokenId) public returns(uint256){
        safeTransferFrom(from, to, tokenId);
        // owner 소유자 변경
        nfts[tokenId].owner = to;
        return tokenId;
    }

    function getNftsCount() public view returns(uint256){
        return tokenIds.current();
    }

    function createAndSendNft(string memory _tokenURI, string memory _title,
            string memory _description, string memory _image, address from, address payable to) 
        public returns(uint256){
        uint256 newTokenId = tokenIds.current();
        _mint(from, newTokenId);
        _setTokenURI(newTokenId, _tokenURI);
        nftOwners[from].push(newTokenId);
        setNft(newTokenId, _title, _description, _tokenURI, _image);
        tokenIds.increment();
        
        safeTransferFrom(from, to, newTokenId);
        nfts[newTokenId].owner = to;
        return newTokenId;
    }
}