import {ethers} from "hardhat";

describe("Token contract", function () {
    it('Stake', async () => {
        const [owner, addr1] = await ethers.getSigners();

        const tokenFactoryErc20 = await ethers.getContractFactory("ERC20");
        const tokenErc20 = await tokenFactoryErc20.deploy("S", "S", 10);
        console.log("Token simple ERC20 address:", tokenErc20.address);

        const tokenFactoryBridge = await ethers.getContractFactory("Bridge");
        const tokenBridge = await tokenFactoryBridge.deploy(tokenErc20.address, owner.address);
        console.log("Token bridge address:", tokenBridge.address);

        const chainId = 1;
        const amount = 5;
        tokenBridge.swap(addr1, amount, chainId);

        let nonce = Date.now();
        let msg = ethers.utils.solidityKeccak256(["address", "uint256", "uint256", "uint256"],
            [addr1.address, amount, chainId, nonce]
        );
        let signature = await owner.signMessage(ethers.utils.arrayify(msg));
        let sig = await ethers.utils.splitSignature(signature);

        tokenBridge.redeem(addr1.address, amount, chainId, nonce, sig.v, sig.r, sig.s);
    });
});
