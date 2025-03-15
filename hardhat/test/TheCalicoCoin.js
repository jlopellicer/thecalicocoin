const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("TheCalicoCoin - TCC", function () {
  let token, owner, addr1, addr2;

  beforeEach(async function () {
    const Token = await ethers.getContractFactory("TheCalicoCoin");
    token = await Token.deploy();
    [owner, addr1, addr2] = await ethers.getSigners();
  });

  describe("Deployment", function () {
    it("owner must have all supply", async function () {
      const balance = await token.balanceOf(owner.address);
      expect(balance).to.equal(10000000000000000000000000000n);
    });

    it("is valid totalSupply", async function () {
      const property = await token.totalSupply();
      expect(property).to.equal(10000000000000000000000000000n);
    });

    it("is valid name", async function () {
      const property = await token.name();
      expect(property).to.equal("The Calico Coin");
    });

    it("is valid symbol", async function () {
      const property = await token.symbol();
      expect(property).to.equal("TCC");
    });

    it("is valid decimals", async function () {
      const property = await token.decimals();
      expect(property).to.equal(18);
    });
  });

  describe("Transactions", function () {
    it("no taxes when transactions are done", async function () {
      const initialOwnerBalance = await token.balanceOf(owner.address);
      const initialAddr1Balance = await token.balanceOf(addr1.address);
      const initialAddr2Balance = await token.balanceOf(addr2.address);

      expect(initialOwnerBalance).to.equal(10000000000000000000000000000n);
      expect(initialAddr1Balance).to.equal(0n);
      expect(initialAddr2Balance).to.equal(0n);

      await token.transfer(addr1.address, 10000000000000000000n);
      await token.transfer(addr2.address, 20000000000000000000n);

      const newOwnerBalance = await token.balanceOf(owner.address);
      const newAddr1Balance = await token.balanceOf(addr1.address);
      const newAddr2Balance = await token.balanceOf(addr2.address);

      expect(newOwnerBalance).to.equal(9999999970000000000000000000n);
      expect(newAddr1Balance).to.equal(10000000000000000000n);
      expect(newAddr2Balance).to.equal(20000000000000000000n);

      const circulatingSupply = newOwnerBalance + newAddr1Balance + newAddr2Balance;
      expect(circulatingSupply).to.equal(10000000000000000000000000000n);

    });
  });

});
