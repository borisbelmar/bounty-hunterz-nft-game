const deploy = async () => {
  const [deployer] = await ethers.getSigners();

  console.log("Deploying the contract with account", deployer.address);

  const BountyHunterz = await ethers.getContractFactory("BountyHunterz");

  const deployed = await BountyHunterz.deploy();

  console.log("BountyHunterz has been deployed at: ", deployed.address);
};

deploy()
  .then(() => process.exit(0))
  .catch(err => {
    console.error(err);
    process.exit(1)
  });