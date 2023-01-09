import { expect } from "chai";
import exp from "constants";
import { BigNumber, Contract } from "ethers";
import { ethers } from "hardhat";

describe("BaseDAO", function () {
  let baseDAO: Contract;
  let baseDAO2: Contract;
  let factory: Contract;

  beforeEach(async function () {
    const BaseDAO = await ethers.getContractFactory("BaseDAO");
    baseDAO = await BaseDAO.deploy();
    await baseDAO.deployed();
    const Factory = await ethers.getContractFactory("DAOFactory");
    factory = await Factory.deploy(baseDAO.address);
    await factory.deployed();

    // baseDAO2 = BaseDAO.attach(baseDAO.address);
  });

  it("create BaseDAO by factory", async function () {
    const [addr1, addr2] = await ethers.getSigners();
    const tx = await factory.createBaseDAO(addr1.address);
    const receipt = await tx.wait();
    // for (const event of receipt.events) {
    //   console.log("Event ", event.event, " with args ", event.args);
    // }
    const daoAddr = receipt.events[0].args.DaoAddr;
    console.log("Event: ", receipt.events[0].args.DaoAddr, receipt.events[0].args._admin);
    // const test = await factory.returnTest();
    // console.log(daoAddr.data);

    const BaseDAO = await ethers.getContractFactory("BaseDAO");
    baseDAO2 = BaseDAO.attach(daoAddr);

    console.log("ADDRESS", factory.address, baseDAO.address, baseDAO2.address);
    // const BaseDAO = await ethers.getContractFactory("BaseDAO");
    expect(baseDAO2.address).to.equal(daoAddr);
    expect(await baseDAO2.administrator(addr1.address)).to.equal(true);
    expect(receipt.events[0].args._admin).to.equal(addr1.address);
    // expect().to.equal();
  });
});
