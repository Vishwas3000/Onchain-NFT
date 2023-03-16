// SPDX-License-Identifier: MIT

pragma solidity ^0.8.7;

import "@chainlink/contracts/src/v0.8/interfaces/VRFCoordinatorV2Interface.sol";
import "@chainlink/contracts/src/v0.8/VRFConsumerBaseV2.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

error RandomIpfsNFT__RangeOutOfBounce();
error RandomIpfsNFT__NeedMoreETHSend();
error RandomIpfsNFT__TransferFailed();

contract RandomIpfsNFT is VRFConsumerBaseV2, ERC721URIStorage, Ownable {
    enum Breed {
        PUG,
        SHIBA_INU,
        ST_BERNARD
    }
    // VRF variables
    VRFCoordinatorV2Interface private immutable i_vrfCoordinator;
    uint64 private immutable i_subscriptionId;
    bytes32 private immutable i_gasLane;
    uint32 private immutable i_callbackGasLimit;
    uint16 private constant REQUEST_CONFORMATIONS = 3;
    uint32 private constant NUM_WORDS = 1;

    // VRF helper
    mapping(uint256 => address) public s_requestIdToSender;

    // NFT vairable
    uint256 public s_tokenCounter;
    string[] internal s_dogTokenUri;
    uint256 internal immutable i_mintFee;

    uint256 internal constant MAX_CHANCE_VALUE = 100;

    //Events
    event NftRequested(uint256 indexed requestId, address requester);
    event NftMinted(uint256 indexed requestId, Breed DogBreed, address minter);

    constructor(
        address vrfCoordinatorV2,
        uint64 _subscriptionId,
        bytes32 _gasLane,
        uint32 _callbackGasLimit,
        string[3] memory dogTokenUri,
        uint256 mintFee
    ) VRFConsumerBaseV2(vrfCoordinatorV2) ERC721("Random Ipfs NFT", "RIN") {
        i_vrfCoordinator = VRFCoordinatorV2Interface(vrfCoordinatorV2);
        i_subscriptionId = _subscriptionId;
        i_gasLane = _gasLane;
        i_callbackGasLimit = _callbackGasLimit;
        s_dogTokenUri = dogTokenUri;
        i_mintFee = mintFee;
    }

    function requestNft() public payable returns (uint256 requestId) {
        if (msg.value < i_mintFee) {
            revert RandomIpfsNFT__NeedMoreETHSend();
        }

        requestId = i_vrfCoordinator.requestRandomWords(
            i_gasLane,
            i_subscriptionId,
            REQUEST_CONFORMATIONS,
            i_callbackGasLimit,
            NUM_WORDS
        );
        s_requestIdToSender[requestId] = msg.sender;
        emit NftRequested(requestId, msg.sender);
    }

    function fulfillRandomWords(
        uint256 requestId,
        uint256[] memory randomWord
    ) internal override {
        address dogOwner = s_requestIdToSender[requestId];
        uint256 newTokenId = s_tokenCounter;

        uint256 moddedRng = randomWord[0] % MAX_CHANCE_VALUE;
        Breed dogBreed = getBreedFromModdedRng(moddedRng);
        s_tokenCounter += 1;

        _safeMint(dogOwner, newTokenId);
        _setTokenURI(newTokenId, s_dogTokenUri[uint256(dogBreed)]);
        emit NftMinted(requestId, dogBreed, dogOwner);
    }

    function getBreedFromModdedRng(
        uint256 moddedRng
    ) public pure returns (Breed) {
        uint256 cumulativeSum = 0;
        uint256[3] memory chanceArray = getChanceArray();
        for (uint256 i = 0; i < chanceArray.length; i++) {
            // Pug = 0 - 9  (10%)
            // Shiba-inu = 10 - 39  (30%)
            // St. Bernard = 40 = 99 (60%)
            if (moddedRng >= cumulativeSum && moddedRng < chanceArray[i]) {
                return Breed(i);
            }
            cumulativeSum = chanceArray[i];
        }
        revert RandomIpfsNFT__RangeOutOfBounce();
    }

    function withdraw() public onlyOwner {
        uint256 amount = address(this).balance;
        (bool success, ) = payable(msg.sender).call{value: amount}("");
        if (!success) {
            revert RandomIpfsNFT__TransferFailed();
        }
    }

    function getChanceArray() public pure returns (uint256[3] memory) {
        return [10, 30, MAX_CHANCE_VALUE];
    }

    function getMintFee() public view returns (uint256) {
        return i_mintFee;
    }

    function getDogTokenUri(uint256 index) public view returns (string memory) {
        return s_dogTokenUri[index];
    }

    function getTokenCounter() public view returns (uint256) {
        return s_tokenCounter;
    }
}
