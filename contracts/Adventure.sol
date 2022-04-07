//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "./VillagerHelper.sol";

contract Adventure is VillagerHelper {
    struct Adventures {
        uint adventurerID;
    }

    modifier adventureTimeoutCheck() {
        require(adventureTimeoutChecker());
        _;
    }

    event AdventureSuccesful();
    event AdventureFailure();
    

    function adventureTimeoutChecker() internal view returns(bool) {
        bool check = true;
        Villagers[] storage myVillagers = ownerToTeam[msg.sender];
        for(uint i = 0; i<myVillagers.length; i++){
            if(myVillagers[i].adventureTimeout > block.timestamp){
                check = false;
            }
        }
        return check;
    }

    function embark() public adventureTimeoutCheck() {
        uint adventurerVictoryProb = 100;
        uint random = _makeRand();
        Villagers storage adventurer = ownerToTeam[msg.sender][random];
        if(adventurer.clan == Clans.defender){
            adventurerVictoryProb-= 35;
        }
        if(adventurer.clan == Clans.mage){
            adventurerVictoryProb+= 10;
        }
        if(adventurer.clan == Clans.sage){
            adventurerVictoryProb-= 20;
        }
        if(adventurer.clan == Clans.warrior){
            adventurerVictoryProb-= 45;
        }

        uint rand = (uint(keccak256(abi.encodePacked(msg.sender, block.timestamp))) % 100) + 1;
        if(rand <= adventurerVictoryProb){
            adventurer.level = adventurer.level + 10;
            emit AdventureSuccesful();
        } else {
            emit AdventureFailure();
        }

        adventurer.adventureTimeout = block.timestamp + 1 days;
    }
}