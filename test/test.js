const { ethers, waffle } = require("hardhat");

var owner;
var userWallet;

describe("Create UserWallet", function() {
    it("Create account", async function() {
        [owner] = await ethers.getSigners();

        userWallet = ethers.Wallet.createRandom();
        userWallet = userWallet.connect(ethers.provider);
        var tx = await owner.sendTransaction({
            to: userWallet.address,
            value: ethers.utils.parseUnits("100", 18)
        });
        await tx.wait();
    });
});

describe("TKT&Staking deploy", function() {

    it("Deploying", async function() {
        const [deployer] = await ethers.getSigners();
        const token = await ethers.getContractFactory("TKT");
        tokenContract = await token.deploy(ethers.utils.parseEther("1000"));
        await tokenContract.deployed();

        const Staking = await ethers.getContractFactory("Staking");
        stakingContract = await Staking.deploy(tokenContract.address, ethers.utils.parseEther("1"));
        await stakingContract.deployed();

        let tx;

        tx = await tokenContract.approve(stakingContract.address, "0xfffffffffffffffffffffffff");
        await tx.wait();

        tx = await stakingContract.deposit(ethers.utils.parseEther("10"));
        await tx.wait();
        console.log(await stakingContract.getReward(deployer.address));
    });

});