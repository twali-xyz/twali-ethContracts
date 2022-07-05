
// When running the script with `npx hardhat run npx hardhat run scripts/local-deploy-script.js --network rinkeby` you'll find the Hardhat
// Runtime Environment's members available in the global scope.
const hre = require("hardhat");

async function main() {

  // Deploy Twali's implementation contract 
  const TwaliImp = await hre.ethers.getContractFactory("TwaliContract");
  const deployedTwaliContract = await TwaliImp.deploy();
  await deployedTwaliContract.deployed();

  console.log("Twali Implementation contract deployed to:", deployedTwaliContract.address);

  // Deploys the Twali Clone Factory proxy contract with the base implementation contract address
  // after it has been deployed first.
  const TwaliFactory = await hre.ethers.getContractFactory("TwaliContractFactory");
  const deployedFactory = await TwaliFactory.deploy(deployedTwaliContract.address);
  await deployedFactory.deployed();

  console.log("Twali Clone contract deployed to:", deployedFactory.address);

}


main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
