//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "./Adventure.sol";
import "./@openzeppelin/contracts/token/ERC721/ERC721.sol";


contract Ownership is Adventure, ERC721 {
    constructor() ERC721("GameItem", "ITM") {}

    mapping (uint => mapping (address => bool)) approvals;

    function balanceOf(address _add) public override view returns(uint){
        return villagerCount[_add];
    }

    function ownerOf(uint _id) public override view returns(address){
        return villagerToOwner[_id];
    }

    function transferFrom( address from, address to, uint256 tokenId) public override {
        // require(from == msg.sender);
        // require(villagerToOwner[tokenId] == msg.sender);
        require(approvals[tokenId][to] || villagerToOwner[tokenId] == msg.sender, "Unauthorized transfer");
        require(ownerToTeam[to].length < teamMax, "Recipient cannot receive more tokens at this time");
        uint teamIndex = addressToTeamId[from][tokenId];
        Villagers[] storage teamMembers = ownerToTeam[from];
        teamMembers[teamIndex] = teamMembers[teamMembers.length - 1];
        teamMembers.pop();
        villagerCount[from]--;
        villagerToOwner[tokenId] = to;
        ownerToTeam[to].push(villagers[tokenId]);
        villagerCount[to]++;
        delete addressToTeamId[from][tokenId];
        addressToTeamId[to][tokenId] = ownerToTeam[to].length - 1;
        emit Transfer(from, to, tokenId);
    }

    function approve(address to, uint256 tokenId) public override onlyOwnerOf(tokenId) {
        approvals[tokenId][to] = true;
        emit Approval(msg.sender, to, tokenId);
    }
    function disapprove(address to, uint256 tokenId) public onlyOwnerOf(tokenId) {
        approvals[tokenId][to] = false;
    }
}