async function main () {
    // We get the contract to deploy
    const Adventure = await ethers.getContractFactory('Adventure');
    console.log('Deploying Villages...');
    const adventure = await Adventure.deploy();
    await adventure.deployed();
    console.log('Adventure deployed to:', adventure.address);
  }
  
  main()
    .then(() => process.exit(0))
    .catch(error => {
      console.error(error);
      process.exit(1);
    });