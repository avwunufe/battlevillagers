//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "hardhat/console.sol";
import "./@openzeppelin/contracts/access/Ownable.sol";


contract Villager is Ownable {

    enum Clans { warrior, defender, sage, mage }

    uint public teamMax;

    struct Villagers {
        string firstName;
        string lastName;
        uint16 level;
        uint16 winCount;
        uint16 lossCount;
        uint wonAdventures;
        uint lostAdventures;
        uint adventureTimeout;
        uint battleTimeout;
        Clans clan;

    }

    Villagers[] public villagers;
    event VillagerMinted(uint villagerId, string firstName, string lastName, address mYaddress);

    mapping (uint => address) villagerToOwner;
    mapping (address => uint) villagerCount;
    mapping (address => Villagers[]) ownerToTeam;
    mapping (address => mapping (uint => uint)) addressToTeamId;
    uint8 numberOfClans = 4;

    constructor(){
        teamMax = 4;
    }

    modifier onlyOwnerOf(uint _id){
        require(villagerToOwner[_id] == msg.sender);
        _;
    }

    function _makeRand() internal view returns(uint) {
        uint teamLength = ownerToTeam[msg.sender].length;
        uint random = (uint(keccak256(abi.encodePacked(msg.sender, block.timestamp))) % teamLength);
        return random;
    }

    function chooseClanRandomly() internal view returns(uint) {
        uint randClan = (uint(keccak256(abi.encodePacked(msg.sender, block.timestamp))) % numberOfClans);
        return randClan;
    }

    function mintVillager(string memory _firstName, string memory _lastName) public {
        require(villagerCount[msg.sender] == 0, "Initial villager already minted");
        uint8 clan = uint8(chooseClanRandomly());
        villagers.push(Villagers(_firstName, _lastName, 0, 0, 0, 0, 0, 0, 0, Clans(clan)));
        uint id = villagers.length - 1;
        villagerToOwner[id] = msg.sender;
        villagerCount[msg.sender]++;
        ownerToTeam[msg.sender].push(Villagers(_firstName, _lastName, 0, 0, 0, 0, 0, 0, 0, Clans(clan)));
        uint teamId = ownerToTeam[msg.sender].length - 1;
        addressToTeamId[msg.sender][id] = teamId;
        emit VillagerMinted(id, _firstName, _lastName, msg.sender);
    }


}
