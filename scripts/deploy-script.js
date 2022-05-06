// We require the Hardhat Runtime Environment explicitly here. This is optional
// but useful for running the script in a standalone fashion through `node <script>`.
//
// When running the script with `npx hardhat run <script>` you'll find the Hardhat
// Runtime Environment's members available in the global scope.
const hre = require("hardhat");

async function main() {
  // Grab signer address
  // const accounts = await hre.ethers.getSigners();
  // console.log("owners address:", accounts[0].address);
  // const owner = accounts[0].address;
  // Deploy Twali's implementation contract 
  const TwaliImp = await hre.ethers.getContractFactory("TwaliContract");
  const deployedTwaliContract = await TwaliImp.deploy();
  await deployedTwaliContract.deployed();

  console.log("Twali Implementation contract deployed to:", deployedTwaliContract.address);

  // Deploys the Twali Clone Factory proxy contract with the base implementation contract address
  const TwaliFactory = await hre.ethers.getContractFactory("TwaliContractFactory");
  const deployedFactory = await TwaliFactory.deploy(deployedTwaliContract.address);
  await deployedFactory.deployed();

  console.log("Twali Clone contract deployed to:", deployedFactory.address);
  // Create test clone contracts with test data
  // await deployedFactory.createTwaliClone(owner, "https://contract-metadata.s3.amazonaws.com/v1/werkJson.json");
  // await deployedFactory.createTwaliClone(owner, "https://contract-metadata.s3.amazonaws.com/v1/werkJson.json");

  // Returns clone contract addresses
  // const getClones = await deployedFactory.returnContractClones(owner);
  // console.log("Contract Clones created:", getClones);

  // // Example getting a clone Contract by its address
  // const clone1 = await hre.ethers.getContractAt("TwaliContract", getClones[0]);

  // const metaData = await clone1.sowMetaData();
  // console.log(metaData);
}


main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
