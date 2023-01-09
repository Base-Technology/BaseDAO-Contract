import { expect } from "chai";
import { BigNumber, Contract } from "ethers";
import { ethers } from "hardhat";
import { ContractType } from "hardhat/internal/hardhat-network/stack-traces/model";

describe("Airdorp", function () {
  let baseDAOTemplate: Contract;
  let baseDAO: Contract;
  let factory: Contract;
  let airdorpMod: Contract;
  let testToken: Contract;
  let accounts: any;

  beforeEach(async function () {
    accounts = await ethers.getSigners();
    const BaseDAO = await ethers.getContractFactory("BaseDAO");
    baseDAOTemplate = await BaseDAO.deploy();
    await baseDAOTemplate.deployed();
    const Factory = await ethers.getContractFactory("DAOFactory");
    factory = await Factory.deploy(baseDAOTemplate.address);
    await factory.deployed();
    const tx = await factory.createBaseDAO(accounts[0].address);
    const receipt = await tx.wait();
    baseDAO = BaseDAO.attach(receipt.events[0].args.DaoAddr);
    // accounts[0] is baseDAO's admin;
    const Airdorp = await ethers.getContractFactory("AirdropContract");
    airdorpMod = await Airdorp.deploy();
    await airdorpMod.deployed();
    // BaseToken
    const BaseToken = await ethers.getContractFactory("BaseToken");
    testToken = await BaseToken.deploy("BaseTokenTest", "BTT");
    await testToken.deployed();
  });

  it("test 1 : add airdorp module to baseDAO ", async function () {
    console.log("Create BaseDAO successfully, admin is ", accounts[0].address);
    expect(1).to.equal(1);
    await baseDAO.addModule(airdorpMod.address);
    console.log("ww 1");
    expect(true).to.equal(await baseDAO.modules(airdorpMod.address));
  });
  it("test 1.1: function test ", async function () {
    const value_recharge = BigNumber.from(200);
    await testToken.approve(baseDAO.address, value_recharge);
    await baseDAO.rechargeToken(testToken.address, value_recharge);
    console.log("Recharge Token   ", await testToken.balanceOf(baseDAO.address));
    expect(value_recharge).to.equal(await testToken.balanceOf(baseDAO.address));
    console.log("Add Module");
    await baseDAO.addModule(airdorpMod.address);
    console.log("Test: AirTransfer                start");
    const accountsArr = [accounts[1].address, accounts[2].address, accounts[3].address];
    const value_AT = BigNumber.from(10);
    await airdorpMod.AirTransfer(accountsArr, value_AT, baseDAO.address, testToken.address);

    expect(value_AT).to.equal(await testToken.balanceOf(accountsArr[0]));
    expect(value_AT).to.equal(await testToken.balanceOf(accountsArr[1]));
    expect(value_AT).to.equal(await testToken.balanceOf(accountsArr[2]));
    console.log("Test: AirTransfer                success");

    console.log("Test: AirTransferDiffValue       start");
    const accountsArr_Diff = [accounts[4].address, accounts[5].address, accounts[6].address];
    const value_Diff = [BigNumber.from(10), BigNumber.from(20), BigNumber.from(30)];
    await airdorpMod.AirTransferDiffValue(accountsArr_Diff, value_Diff, baseDAO.address, testToken.address);
    expect(value_Diff[0]).to.equal(await testToken.balanceOf(accountsArr_Diff[0]));
    expect(value_Diff[1]).to.equal(await testToken.balanceOf(accountsArr_Diff[1]));
    expect(value_Diff[2]).to.equal(await testToken.balanceOf(accountsArr_Diff[2]));
    console.log("Test: AirTransferDiffValue       success");
    console.log("Balance Check    ", await testToken.balanceOf(baseDAO.address));
    expect(BigNumber.from(110)).to.equal(await testToken.balanceOf(baseDAO.address));

    console.log("Test: withdrawalToken            start");
    const balance_before = [await testToken.balanceOf(accounts[0].address), await testToken.balanceOf(baseDAO.address)];
    await airdorpMod.withdrawalToken(baseDAO.address, testToken.address);
    const balance_after = [await testToken.balanceOf(accounts[0].address), await testToken.balanceOf(baseDAO.address)];
    console.log("Before:  ", balance_before);
    console.log("After:   ", balance_after);
    console.log("Test: withdrawalToken            success");
  });
});
