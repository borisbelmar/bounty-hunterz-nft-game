const { expect } = require('chai');

const MAX_SUPPLY = 3000;
const MINTING_PRICE = BigInt(1e18);

const setup = async () => {
  const [owner] = await ethers.getSigners();
  const Hunterz = await ethers.getContractFactory("Hunterz");
  const deployed = await Hunterz.deploy();

  return {
    owner,
    deployed
  }
}

describe('Hunterz NFT Deploy', () => {
  it('Testing constructor', async () => {
    const { deployed } = await setup();
    const currentSupply = await deployed.totalSupply();

    expect(currentSupply).to.equal(0);
  })
})

describe('Hunterz NFT Minting', () => {
  it('Mints a new token and assigns it to owner', async () => {
    const { owner, deployed } = await setup();

    await deployed.mint({ value: MINTING_PRICE });

    const ownerOfMinted = await deployed.ownerOf(0);
    
    expect(ownerOfMinted).to.equal(owner.address);
  })

  it('Show correct current supply and left supply', async () => {
    const { deployed } = await setup();

    await Promise.all([
      deployed.mint({ value: MINTING_PRICE }),
      deployed.mint({ value: MINTING_PRICE })
    ])

    const currentSupply = await deployed.totalSupply();
    const supplyLeft = await deployed.getSupplyLeft();

    expect(currentSupply).to.equal(2);
    expect(supplyLeft).to.equal(MAX_SUPPLY - 2);
  })

  // FIXME: No se como hacer este test para ver la cantidad de mints!
  // it('Has mint limit', async () => {
  //   const { deployed } = await setup();

  //   await Promise.all(Array(MAX_SUPPLY).fill(0).map(() => deployed.mint({ value: MINTING_PRICE })))

  //   await expect(deployed.mint({ value: MINTING_PRICE })).to.be.revertedWith('Not Hunterz Lefts :(');
  // })

  it('Pay for minting', async () => {
    const { deployed } = await setup();

    await deployed.mint({ value: MINTING_PRICE })
    await expect(deployed.mint({ value: MINTING_PRICE - BigInt(1) })).to.be.revertedWith('Not enought money');
  })
})

describe('Hunterz Token URI', () => {
  it('Return valid metadata', async () => {
    const { deployed } = await setup();

    await deployed.mint({ value: MINTING_PRICE });

    const tokenURI = await deployed.tokenURI(0);
    const stringifiedTokenURI = await tokenURI.toString();

    const [,base64JSON] = stringifiedTokenURI.split('data:application/json;base64,');
    const stringifiedMetadata = Buffer.from(base64JSON, 'base64').toString('ascii')
    
    const metadata = JSON.parse(stringifiedMetadata);

    console.log(metadata)

    expect(metadata).to.have.all.keys('name', 'description', 'image_data', 'attributes');
  })

  it('Images and DNA are unique by address and id', async () => {
    const { deployed } = await setup();

    await Promise.all([
      deployed.mint({ value: MINTING_PRICE }),
      deployed.mint({ value: MINTING_PRICE })
    ])

    const [dna0, dna1] = await Promise.all([
      deployed.tokenDNA(0),
      deployed.tokenDNA(1)
    ])

    expect(dna0).to.not.equal(dna1);

    const [image0, image1] = await Promise.all([
      deployed.imageDataByDna(dna0),
      deployed.imageDataByDna(dna1)
    ])

    expect(image0).to.not.equal(image1);
  })
})