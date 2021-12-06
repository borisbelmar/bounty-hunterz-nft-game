const { expect } = require('chai');

const MIN_BOUNTY = BigInt(1e18);

const setup = async () => {
  const [owner, ...wallets] = await ethers.getSigners();
  const contract = await ethers.getContractFactory("BountyHunterz");
  const deployed = await contract.deploy();

  return {
    owner,
    deployed,
    wallets,
    provider: ethers.provider
  }
}

describe('BountyHunterz contract deploy', () => {
  it('Testing initial state', async () => {
    const { deployed, owner } = await setup();
    const host = await deployed.host();
    const liquidity = await deployed.liquidity();

    expect(host).to.equal(owner.address);
    expect(liquidity).to.equal(0);
  })
})

describe('Testing Hunterz register process', () => {
  it('Hunter register and initial state', async () => {
    const { deployed, owner, wallets } = await setup();
    await deployed.registerHunter(0);
    const hunter0 = await deployed.hunterz(0);
    await deployed.connect(wallets[0]).registerHunter(1);
    const hunter1 = await deployed.hunterz(1);
    expect(hunter0.owner).to.equal(owner.address);
    expect(hunter0.totalPledge).to.equal(0);
    expect(hunter0.totalAttempts).to.equal(0);
    expect(hunter0.totalWins).to.equal(0);
    expect(hunter1.owner).to.equal(wallets[0].address);
    expect(hunter1.totalPledge).to.equal(0);
    expect(hunter1.totalAttempts).to.equal(0);
    expect(hunter1.totalWins).to.equal(0);
  })

  it('Cannot register the same hunterId twice', async () => {
    const { deployed } = await setup();
    await deployed.registerHunter(0);
    await expect(deployed.registerHunter(0)).to.be.revertedWith('Hunter already registered');
  })

  it('Hunter exists and is active', async () => {
    const { deployed } = await setup();
    await deployed.registerHunter(0);
    const hunter0Exists = await deployed.existentHunterz(0);
    const hunter0Blocked = await deployed.blockedHunterz(0);
    expect(hunter0Exists).to.equal(true);
    expect(hunter0Blocked).to.equal(false);
  })
})

describe('Testing Threat register process', () => {
  it('Threat register and initial state', async () => {
    const { deployed, owner, wallets } = await setup();

    await deployed.registerThreat(0, { value: MIN_BOUNTY });
    const threat0 = await deployed.threats(0);
    expect(threat0.owner).to.equal(owner.address);
    expect(threat0.totalWins).to.equal(0);
    expect(threat0.alive).to.equal(true);

    await deployed.connect(wallets[0]).registerThreat(1, { value: MIN_BOUNTY });
    const threat1 = await deployed.threats(1);
    expect(threat1.owner).to.equal(wallets[0].address);
    expect(threat1.totalWins).to.equal(0);
    expect(threat1.alive).to.equal(true);
  })

  it('Threat register bounty with fees check', async () => {
    const { deployed, owner, provider, wallets } = await setup();
    const ownerBalanceBeforeRegister = await provider.getBalance(owner.address);

    await deployed.connect(wallets[0]).registerThreat(0, { value: MIN_BOUNTY });
    const threat0 = await deployed.threats(0);
    const bountyWithFee = await deployed.getTotalWithFeeDiscounts(MIN_BOUNTY);
    expect(threat0.bounty).to.equal(bountyWithFee);

    const liquidityFee = await deployed.calculateLiquidityFee(MIN_BOUNTY);
    const liquidity = await deployed.liquidity();
    expect(liquidity).to.equal(liquidityFee);

    const ownerBalanceAfterFirstRegister = await provider.getBalance(owner.address);

    const hostFee = await deployed.calculateHostFee(MIN_BOUNTY);
    expect(ownerBalanceAfterFirstRegister).to.equal((BigInt(ownerBalanceBeforeRegister) + BigInt(hostFee)));

    const secondThreatBounty = MIN_BOUNTY + MIN_BOUNTY

    await deployed.connect(wallets[1]).registerThreat(1, { value: secondThreatBounty });
    const threat1 = await deployed.threats(1);
    const secondBountyWithFee = await deployed.getTotalWithFeeDiscounts(secondThreatBounty);
    expect(threat1.bounty).to.equal(secondBountyWithFee);

    const secondLiquidityFee = await deployed.calculateLiquidityFee(secondThreatBounty);
    const secondLiquidity = await deployed.liquidity();
    expect(secondLiquidity).to.equal(BigInt(secondLiquidityFee) + BigInt(liquidityFee));

    const ownerBalanceAfterSecondRegister = await provider.getBalance(owner.address);

    const secondHostFee = await deployed.calculateHostFee(secondThreatBounty);
    expect(ownerBalanceAfterSecondRegister).to.equal((BigInt(ownerBalanceAfterFirstRegister) + BigInt(secondHostFee)));
  })

  it('Cannot register the same threatId twice', async () => {
    const { deployed } = await setup();
    await deployed.registerThreat(0, { value: MIN_BOUNTY });
    await expect(deployed.registerThreat(0, { value: MIN_BOUNTY })).to.be.revertedWith('Threat already registered');
  })

  it('Threat exists and is active', async () => {
    const { deployed } = await setup();
    await deployed.registerThreat(0, { value: MIN_BOUNTY });
    const threat0Exists = await deployed.existentThreats(0);
    const threat0Blocked = await deployed.blockedThreats(0);
    expect(threat0Exists).to.equal(true);
    expect(threat0Blocked).to.equal(false);
  })

  it('Cannot register threat with a low bounty', async () => {
    const { deployed } = await setup();
    await expect(deployed.registerThreat(0, { value: MIN_BOUNTY - BigInt(1) })).to.be.revertedWith('The bounty is insignificant');
  })
})

describe('Testing Threat burning process', async () => {
  it('Threat burning state management', async () => {
    const { deployed } = await setup();
    await deployed.registerThreat(0, { value: MIN_BOUNTY });
    const threat0 = await deployed.threats(0);
    expect(threat0.alive).to.equal(true);
    await deployed.burnThreat(0);
    const threat0AfterDead = await deployed.threats(0);
    expect(threat0AfterDead.alive).to.equal(false);
  })

  it('Cannot burn a dead Threat', async () => {
    const { deployed } = await setup();
    await deployed.registerThreat(0, { value: MIN_BOUNTY });
    await deployed.burnThreat(0);
    await expect(deployed.burnThreat(0)).to.be.revertedWith('This threat is blocked or dead');
  })

  it('Threat burn value is correct without wins', async () => {
    const { deployed, provider, owner } = await setup();
    await deployed.registerThreat(0, { value: MIN_BOUNTY });
    const ownerBalance = await provider.getBalance(owner.address);
    const threat0 = await deployed.threats(0);
    const liquidityBeforeBurn = await deployed.liquidity();

    const tx = await deployed.burnThreat(0);
    const receipt = await tx.wait()
    const { effectiveGasPrice, gasUsed } = receipt
    const totalGasPrice = BigInt(effectiveGasPrice * gasUsed)
    const burnValue = await deployed.calculateThreatBurnValue(0);
    const ownerBalance2 = await provider.getBalance(owner.address);
    expect(ownerBalance2).to.equal(BigInt(ownerBalance) + BigInt(burnValue) - BigInt(totalGasPrice));

    const liquidityAfterBurn = await deployed.liquidity();
    expect(liquidityAfterBurn).to.equal(BigInt(liquidityBeforeBurn) + (BigInt(threat0.bounty) - BigInt(burnValue)));
  })
})

describe('Testing Strike open', async () => {
  it('Open a bounty strike a test initial state', async () => {
    const { deployed } = await setup();
    await deployed.registerThreat(0, { value: MIN_BOUNTY });
    await deployed.openBountyStrike(0);
    const threat0 = await deployed.threats(0);
    const strike0 = await deployed.strikes(0);
    expect(strike0.threatId).to.equal(0);
    expect(strike0.bounty).to.equal(threat0.bounty);
    expect(strike0.status).to.equal(0);
    expect(strike0.totalPledge).to.equal(0);
    const blockedThreat0 = await deployed.blockedThreats(0);
    expect(blockedThreat0).to.equal(true);
  })

  it('Cant open a strike with a blocked Threat', async () => {
    const { deployed } = await setup();
    await deployed.registerThreat(0, { value: MIN_BOUNTY });
    await deployed.openBountyStrike(0);
    await deployed.strikes(0);
    const blockedThreat0 = await deployed.blockedThreats(0);
    expect(blockedThreat0).to.equal(true);
    await expect(deployed.openBountyStrike(0)).to.be.revertedWith('This threat is blocked or dead');
  })

  it('Cant open a strike with a dead Threat', async () => {
    const { deployed } = await setup();
    await deployed.registerThreat(0, { value: MIN_BOUNTY });
    await deployed.burnThreat(0);
    await expect(deployed.openBountyStrike(0)).to.be.revertedWith('This threat is blocked or dead');
  })

  it('Cant open a strike if the sender isnt the owner', async () => {
    const { deployed, wallets } = await setup();
    await deployed.registerThreat(0, { value: MIN_BOUNTY });
    await expect(deployed.connect(wallets[0]).openBountyStrike(0)).to.be.revertedWith('Just the threat owner can use this method');
  })
})

describe('Testing strike covenants', () => {
  it('Register a new covenant and check initial state', async () => {
    const { deployed, owner } = await setup();
    await deployed.registerThreat(0, { value: MIN_BOUNTY });
    await deployed.openBountyStrike(0);
    await deployed.registerHunter(0);
    const threat0 = await deployed.threats(0);
    
    const PLEDGE_TICKET_PERCENT = await deployed.PLEDGE_TICKET_PERCENT();
    const minPledge = BigInt((BigInt(threat0.bounty) * BigInt(PLEDGE_TICKET_PERCENT)) / BigInt(100));
    await deployed.registerCovenantForStrike(0, 0, { value: minPledge });
    const strikeCovenantsCount = await deployed.getStrikeCovenantsCount(0);
    const covenantIndex = await deployed.strikeCovenants(0, 0);
    const covenant = await deployed.covenants(covenantIndex);
    expect(strikeCovenantsCount).to.be.equal(1);
    expect(covenant.leader).to.be.equal(owner.address);
    expect(covenant.pledge).to.be.equal(minPledge);
    const covenantHunter = await deployed.covenantsHunterz(covenantIndex, 0);
    expect(covenantHunter).to.be.equal(0);
  })

  it('Cant register a covenant if hunter is locked', async () => {
    const { deployed } = await setup();
    await deployed.registerThreat(0, { value: MIN_BOUNTY });
    await deployed.openBountyStrike(0);
    await deployed.registerHunter(0);
    const threat0 = await deployed.threats(0);
    const PLEDGE_TICKET_PERCENT = await deployed.PLEDGE_TICKET_PERCENT();
    const minPledge = BigInt((BigInt(threat0.bounty) * BigInt(PLEDGE_TICKET_PERCENT)) / BigInt(100));
    await deployed.registerCovenantForStrike(0, 0, { value: minPledge });
    expect(deployed.registerCovenantForStrike(0, 0, { value: minPledge })).to.be.revertedWith('This hunter is blocked');
  })
})