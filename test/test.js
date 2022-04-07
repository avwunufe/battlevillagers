const { expect, assert } = require("chai");
const { Contract } = require("ethers");
const { ethers, artifacts } = require("hardhat");

const Ownership = artifacts.require("Ownership");

contract("Ownership", (accounts)=>{
    let contractInstance;
    let [alice, bob] = accounts;
    beforeEach(async ()=>{
        contractInstance = await Ownership.new();
    })
    it("should mint a new Villager", async()=>{
        let result = await contractInstance.mintVillager("Happy","Corbin", {from: alice});
        // assert.equal(result.receipt.status, true);
        assert.equal(result.logs[0].args.firstName, "Happy");
        // console.log(result.logs[0].args.firstName);
    });
    context("using the one step scenario", async()=>{
        it("should transfer zombie directly", async()=>{
            let result = await contractInstance.mintVillager("Happy","Corbin", {from: alice});
            let id = result.logs[0].args.villagerId.toNumber();
            await contractInstance.transferFrom(alice, bob, id, {from: alice});
            const newOwner = await contractInstance.ownerOf(id);
            expect(newOwner).to.equal(bob);
        })
    })

    context("using the one step scenario", async()=>{
        it("should approve then transfer zombie", async()=>{
            let result = await contractInstance.mintVillager("Happy","Corbin", {from: alice});
            let id = result.logs[0].args.villagerId.toNumber();
            await contractInstance.approve(bob, id, {from: alice});
            await contractInstance.transferFrom(alice, bob, id, {from: bob});
            const newOwner = await contractInstance.ownerOf(id);
            expect(newOwner).to.equal(bob);
        })
    })
});