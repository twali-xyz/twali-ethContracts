const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("TwaliContract", function () {
  it("Should return a proper deployed address after being deployed", async function () {
    const TwaliImp = await ethers.getContractFactory("TwaliContract");
    const deployedTwaliContract = await TwaliImp.deploy();
    await deployedTwaliContract.deployed();

    expect(await deployedTwaliContract.address).to.be.properAddress;

    // const setGreetingTx = await greeter.setGreeting("Hola, mundo!");

    // // wait until the transaction is mined
    // await setGreetingTx.wait();

    // expect(await greeter.greet()).to.equal("Hola, mundo!");
  });
});
``