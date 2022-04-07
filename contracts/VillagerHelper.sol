//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "./Battle.sol";

contract VillagerHelper is Battle {
    uint upgradeFee = 0 ether;

    function setUpgradeFee(uint _fee) public {
        upgradeFee = _fee;
    }

    function levelUp(uint _id) public payable {
        require(msg.value >= upgradeFee);
        villagers[_id].level = villagers[_id].level + 10;
    }

    function getVillagersByOwner(address _owner) public view returns(Villagers[] memory) {
        return ownerToTeam[_owner];
    }
    
    function getVillagersIDByOwner(address _owner) public view returns(uint[] memory) {
        uint[] memory result = new uint[](villagerCount[_owner]);

        for(uint i = 0; i < villagers.length; i++){
           uint counter = 0;
            if(villagerToOwner[i] == _owner){
                result[counter] = i;
                counter++;
            }
        }

        return result;
    }
}