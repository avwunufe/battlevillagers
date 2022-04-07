//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "./Villagers.sol";

contract Battle is Villager {

    struct Battles {
        uint attackerID;
        uint defenderID;
        Clans attackerClan;
        Clans defenderClan;
        bool completed;
    }

    Battles[] internal battles;
    mapping (address => uint[]) battleIds;

    modifier battleTimeoutCheck() {
        require(battleTimeoutChecker());
        _;
    }
    function battleTimeoutChecker() internal view returns(bool) {
        bool check = true;
        Villagers[] storage myVillagers = ownerToTeam[msg.sender];
        for(uint i = 0; i<myVillagers.length; i++){
            if(myVillagers[i].battleTimeout > block.timestamp){
                check = false;
            }
        }
        return check;
    }

    // mapping (uint => mapping (bool => Battles)) battleStats;

    function pickWinner(uint _victor, uint _loser, uint _lastBattleID) internal {
        Villagers storage winner = villagers[_victor];
        Villagers storage loser = villagers[_loser];
        winner.winCount++;
        loser.lossCount++;
        Battles storage lastBattle = battles[_lastBattleID];
        lastBattle.completed = true;
        winner.battleTimeout = block.timestamp + 1 days;
        loser.battleTimeout = block.timestamp + 1 days;
    }

    function attack(uint _attacker, uint _victim) external battleTimeoutCheck() {
        Villagers storage victim = villagers[_victim];
        address victimOwner = villagerToOwner[_victim];
        // uint teamLength = ownerToTeam[msg.sender].length;
        // uint random = (uint(keccak256(abi.encodePacked(msg.sender, block.timestamp))) % teamLength);
        uint random = _makeRand();
        Villagers storage attacker = ownerToTeam[msg.sender][random];
        Clans attackerClan = attacker.clan;
        Clans defenderClan = victim.clan;
        battles.push(Battles(_attacker, _victim, attackerClan, defenderClan, false));
        uint id = battles.length - 1;
        battleIds[msg.sender].push(id);
        battleIds[victimOwner].push(id);
    }

    function defend() external {
        // uint battleIdLength = battleIds[msg.sender].length - 1;
        // uint teamLength = ownerToTeam[msg.sender].length;
        uint random = _makeRand();
        Villagers storage defender = ownerToTeam[msg.sender][random];
        uint lastBattleID = battleIds[msg.sender][battleIds[msg.sender].length - 1];
        Battles storage lastBattle = battles[lastBattleID];
        lastBattle.defenderClan = defender.clan;
        require(lastBattle.completed == false, "This battle is already finished");
        uint attackerVictoryProb = 50;
        uint defenderVictoryProb = 50; 
        if(lastBattle.attackerClan == Clans.warrior){
            attackerVictoryProb+= 30;
            defenderVictoryProb-= 30;
        }
        if(lastBattle.attackerClan == Clans.defender){
            attackerVictoryProb-= 10;
            defenderVictoryProb+= 10;
        }
        if(lastBattle.attackerClan == Clans.mage){
            attackerVictoryProb+= 20;
            defenderVictoryProb-= 20;
        }
        if(lastBattle.attackerClan == Clans.sage){
            attackerVictoryProb+= 5;
            defenderVictoryProb-= 5;
        }
        if(lastBattle.defenderClan == Clans.warrior){
            attackerVictoryProb-= 10;
            defenderVictoryProb+= 10;
        }
        if(lastBattle.defenderClan == Clans.defender){
            attackerVictoryProb-= 30;
            defenderVictoryProb+= 30;
        }
        if(lastBattle.defenderClan == Clans.mage){
            attackerVictoryProb+= 5;
            defenderVictoryProb-= 5;
        }
        if(lastBattle.defenderClan == Clans.sage){
            attackerVictoryProb-= 20;
            defenderVictoryProb+= 20;
        }

        computeWinner(attackerVictoryProb, lastBattle.attackerID, lastBattle.defenderID, lastBattleID);
    }

    function computeWinner(uint _attackerVictoryProb, uint _attackerID, uint _defenderID, uint _battleID) internal {
        uint rand = (uint(keccak256(abi.encodePacked(msg.sender, block.timestamp))) % 100) + 1;
        if(rand <= _attackerVictoryProb){
            pickWinner(_attackerID, _defenderID, _battleID);
        } else {
            pickWinner(_defenderID, _attackerID, _battleID);
        }
    }

}