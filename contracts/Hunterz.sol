// SPDX-License-Identifier: MIT

/**
  * TODO: Aún no implementado!
 */
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "./Base64.sol";
import "./HunterzDNA.sol";

contract Hunterz is ERC721, ERC721Enumerable, Ownable, HunterzDNA {
  using Counters for Counters.Counter;
  using Strings for uint256;

  Counters.Counter private _idCounter;
  uint256 constant public MAX_SUPPLY = 3000;
  uint256 constant public MINTING_PRICE = 1 * 10 ** 18;
  mapping(uint256 => uint256) public tokenDNA;

  constructor() ERC721("Hunterz", "PRS") {}

  function mint() public payable {
    uint256 current = _idCounter.current();
    require(current < MAX_SUPPLY, "Not Hunterz Lefts :(");
    require(msg.value >= MINTING_PRICE, "Not enought money");

    payable(owner()).transfer(MINTING_PRICE);

    // TODO: Use an oracle like Chainlink for production!
    tokenDNA[current] = deterministicPseudoRandomDNA(current, msg.sender);

    _safeMint(msg.sender, current);
    _idCounter.increment();
  }

  function getSupplyLeft() public view returns(uint256) {
    return MAX_SUPPLY - _idCounter.current();
  }

  function imageDataByDna(uint256 _dna) public view returns (string memory) {
    return string(abi.encodePacked(
      "<svg width='512' height='512' viewBox='0 0 512 512' fill='none' xmlns='http://www.w3.org/2000/svg'>",
      "<rect width='512' height='512' fill='#333333'/>",
      getPlanetSvg(_dna),
      getBodySvg(_dna),
      getHeadSvg(_dna),
      getEyesSvg(_dna),
      getMouthSvg(_dna),
      "<defs><clipPath id='clip512'><rect width='512' height='512' fill='white'/></clipPath></defs>",
      "</svg>"
    ));
  }

  // Override
  function tokenURI(uint256 _tokenId) override public view returns(string memory) {
    require(_exists(_tokenId), "Invalid token id");
    uint256 dna = tokenDNA[_tokenId];
    string memory imageData = imageDataByDna(dna);

    string memory jsonURI = Base64.encode(abi.encodePacked(
      '{"name": "Hunter #',
      _tokenId.toString(),
      '", "description": "Hunterz are randomly generated characters", "image_data": "',
      imageData,
      '", "attributes": []}'
    ));
    return string(abi.encodePacked("data:application/json;base64,", jsonURI));
  }

  // The following functions are overrides required by Solidity.
  function _beforeTokenTransfer(address from, address to, uint256 tokenId)
    internal
    override(ERC721, ERC721Enumerable)
  {
    super._beforeTokenTransfer(from, to, tokenId);
  }

  function supportsInterface(bytes4 interfaceId)
    public
    view
    override(ERC721, ERC721Enumerable)
    returns (bool)
  {
    return super.supportsInterface(interfaceId);
  }
}