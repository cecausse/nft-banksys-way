const path = require('path')
const keccak256 = require('keccak256')
const { MerkleTree } = require('merkletreejs')

require('dotenv').config({ path: path.resolve(__dirname, '../.env') })

const RandomNumber = artifacts.require('../contractsRecover/RandomNumber/RandomNumberTest.sol')
const RepairTool = artifacts.require('../contractsRecover/RepairTool/RepairTool.sol')
const BanksysWay = artifacts.require('../contractsRecover/BanksysWay/BanksysWay.sol')
const chai = require('./setupChai.js')
const { start } = require('repl')
const expect = chai.expect

contract('../contracts/BanksyWay/BanksyWay', async (accounts) => {
  const [owner, alice, bob, charles, dave, ed] = accounts
  const whiteList = [alice, bob, charles]
  const startingPrice = 2000
  const endingPrice = 1100
  const levelPrice = 100
  const duration = 30
  const leafNodes = whiteList.map(addr => keccak256(addr))
  const merkleTree = new MerkleTree(leafNodes, keccak256, { sortPairs: true })
  const hexProofAlice = merkleTree.getHexProof(leafNodes[0])
  const hexProofBob = merkleTree.getHexProof(leafNodes[1])
  const hexProofCharles = merkleTree.getHexProof(leafNodes[2])

  before(async () => {
    rn = await RandomNumber.new()
    rt = await RepairTool.new(process.env.TOOLURI, rn.address)
    bw = await BanksysWay.new(process.env.NOTREVEALEDURI, process.env.HASHBASEURI, 6, rt.address, rn.address)
  })

  describe('Test of NFT', async () => {
    it('alice mint the first NFT, failed because paused', async () => {
      return expect(bw.whitelistMint(hexProofAlice, { from: alice })).to.eventually.be.rejectedWith("Sell has not begin yet");
    })
    it('owner set the whitelist', async () => {
      return expect(bw.setWhitelist(process.env.WHITELISTHASH, { from: owner })).to.eventually.be.fulfilled;
    })
    it('owner launch the sale', async () => {
      return expect(bw.startAuction(startingPrice, endingPrice, levelPrice, duration, { from: owner })).to.eventually.be.fulfilled;
    })
    it('alice mint the first NFT', async () => {
      await bw.whitelistMint(hexProofAlice, { from: alice, value: startingPrice - (startingPrice * 20 / 100) })
      const balanceAlice = await bw.balanceOf(alice)
      return expect(parseInt(balanceAlice)).to.be.equal(1)
    })

    it('dave try to mint wiht lower eth than require', async () => {
      return expect(bw.dutchMint(1, { from: dave, value: startingPrice - (startingPrice * 20 / 100) })).to.eventually.be.rejectedWith("ETH < price");
    })
    it('dave mint 2 NFT with good price', async () => {
      await bw.dutchMint(2, { from: dave, value: startingPrice * 2 })
      const balanceDave = await bw.balanceOf(dave)
      return expect(parseInt(balanceDave)).to.be.equal(2)
    })
    it('bob and charles mint on third phase 20% off', async () => {
      await bw.whitelistMint(hexProofBob, { from: bob, value: startingPrice - (startingPrice * 20 / 100) })
      await bw.whitelistMint(hexProofCharles, { from: charles, value: startingPrice - (startingPrice * 20 / 100) })
      const balanceBob = await bw.balanceOf(bob)
      return expect(parseInt(balanceBob)).to.be.equal(1)
    })

    it('ed try to mint, hes not whitelisted, should fail', async () => {
      return expect(bw.whitelistMint(hexProofAlice, { from: dave, value: startingPrice - (startingPrice * 20 / 100) })).to.eventually.be.rejectedWith("Invalide proof");
    })
    it('ed try to mint 2 NFT, should fail', async () => {
      return expect(bw.dutchMint(2, { from: dave, value: startingPrice * 2 })).to.eventually.be.rejectedWith("There is not enough NFT");
    })

    it('ed mint the last NFT', async () => {
      await bw.dutchMint(1, { from: ed, value: startingPrice })
      const balanceEd = await bw.balanceOf(ed)
      return expect(parseInt(balanceEd)).to.be.equal(1)
    })
    it('alice try to mint, should fail because all NFT are sold', async () => {
      return expect(bw.dutchMint(1, { from: alice, value: startingPrice })).to.to.eventually.be.rejectedWith("Sold out");
    })
    it('bob, charles mint her NFT', async () => {
      await bksyprblm.whitelistMint(hexProofBob, { from: bob, value: feeWhitelist })
      await bksyprblm.whitelistMint(hexProofCharles, { from: charles, value: feeWhitelist })
      const total = await bksyprblm.totalSupply()
      return expect(total.toNumber()).to.be.equal(3);
    })
    it('alice try to mint a second NFT', async () => {
      return expect(bksyprblm.whitelistMint(hexProofAlice, { from: alice, value: feeWhitelist })).to.eventually.be.rejectedWith("Already claimed");
    })
    it('ed try to mint', async () => {
      return expect(bksyprblm.mint({ from: ed, value: fee })).to.eventually.be.rejectedWith("Only whitelist people can buy right now");
    })
    it('whitelist over, owner pass on publc sale and alice, dave and ed mint', async () => {
      await bksyprblm.isWhitelistFinished(true, { from: owner })
      await bksyprblm.mint({ from: alice, value: fee })
      await bksyprblm.mint({ from: ed, value: fee })
      await bksyprblm.mint({ from: dave, value: fee })
      const balanceAlice = await bksyprblm.balanceOf(alice)
      return expect(parseInt(balanceAlice)).to.be.equal(2)
    })
    it('check the tokenURI, it\'s not revealed for now', async () => {
      return expect(bksyprblm.tokenURI(1)).to.eventually.be.equal(process.env.NOTREVEALEDURI)
    })
    it('owner set the wrong URI', async () => {
      return expect(bksyprblm.setBaseURI("wrongUri")).to.eventually.be.rejectedWith("This is not the right URI");
    })
    it('owner set the good URI', async () => {
      return expect(bksyprblm.setBaseURI(process.env.BASEURI)).to.eventually.be.fulfilled;
    })
    it('owner set revealed to true', async () => {
      return expect(bksyprblm.revealAndStartDestructionProcess({ from: owner })).to.eventually.be.fulfilled;
    })
    it('check the tokenURI after revealed', async () => {
      bobIndex = await bksyprblm.tokenOfOwnerByIndex(bob, 0);
      return expect(bksyprblm.tokenURI(bobIndex)).to.eventually.be.equal(process.env.BASEURI + "0/" + bobIndex + ".json")
    })
    it('owner withdraw money', async () => {
      balanceOwner = parseInt(await web3.eth.getBalance(owner))
      balanceContract = parseInt(await web3.eth.getBalance(bksyprblm.address))
      await bksyprblm.withdraw(fromOwner)
      balanceOwnerWithdraw = parseInt(await web3.eth.getBalance(owner))
      balanceContractWithdraw = parseInt(await web3.eth.getBalance(bksyprblm.address))
      return expect(balanceOwnerWithdraw).to.be.above(balanceOwner + balanceContract - (balanceOwner + balanceContract) * 1 / 100)
    })
    it('one NFT is destroyed, bob try to mint the solution', async () => {
      await bksyprblm.onlyForTest(fromOwner)
      return expect(bksysltn.mint(1, { from: bob })).to.eventually.be.rejectedWith("Not owner");
    })
    it('alice mint his solution', async () => {
      await bksysltn.mint(1, { from: alice })
      balanceAlice = parseInt(await bksysltn.balanceOf(alice))
      return expect(balanceAlice).to.be.equal(1);
    })
    it('alice sell his banksy Way to ed', async () => {
      await bksyprblm.transferFrom(alice, ed, 1, { from: alice })
      balanceAlice = parseInt(await bksyprblm.balanceOf(alice))
      balanceEd = parseInt(await bksyprblm.balanceOf(ed))
      expect(balanceEd).to.be.equal(2);
      return expect(balanceAlice).to.be.equal(1);
    })
    it('ed try to mint solution, should fail', async () => {
      return expect(bksysltn.mint(1, { from: ed })).to.eventually.be.rejectedWith("Already minted");
    })
  })
})
