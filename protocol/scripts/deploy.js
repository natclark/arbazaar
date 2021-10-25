`use strict`;

const hre = require(`hardhat`);
const fs = require(`fs`);

const main = async () => {
    let mockbuck;
    let buck;
    let arbazaar;

    if (network.name === `hardhat` || network.name === `localhost`) {
        const MockBUCK = await hre.ethers.getContractFactory(`MockBUCK`);
        mockbuck = await MockBUCK.deploy(
            `0xcfC142Bd3F53698caAD76F8c7187b166D47650a3` // Replace this with the address you use for local testing.
        );
        await mockbuck.deployed();
        console.log(`MockBUCK.sol deployed:`, mockbuck.address);

        const Arbazaar = await hre.ethers.getContractFactory(`Arbazaar`);
        arbazaar = await Arbazaar.deploy(
            `0x806fe7f07CfA4c2e26B802fB979D45321232B3CE`,
            mockbuck.address
        );
        await arbazaar.deployed();
        console.log(`Arbazaar.sol deployed:`, arbazaar.address);
    } else if (network.name === `arbitrumRinkeby`) {
        const BUCK = await hre.ethers.getContractFactory(`standardToken`);
        buck = await BUCK.deploy(
            `0x5407563772E12145512C523b4C8D0fD5F94d0f3E`, // Replace this with the address you use for Arbitrum Rinkeby testing.
            `Arbucks`,
            `BUCK`,
            18,
            hre.ethers.utils.parseEther(`100000000`)
        );
        await buck.deployed();
        console.log(`BUCK.sol deployed:`, buck.address);

        const Arbazaar = await hre.ethers.getContractFactory(`Arbazaar`);
        arbazaar = await Arbazaar.deploy(
            `0x806fe7f07CfA4c2e26B802fB979D45321232B3CE`,
            buck.address
        );
        await arbazaar.deployed();
        console.log(`Arbazaar.sol deployed:`, arbazaar.address);
    } else {
        const Arbazaar = await hre.ethers.getContractFactory(`Arbazaar`);
        arbazaar = await Arbazaar.deploy(
            `0x806fe7f07CfA4c2e26B802fB979D45321232B3CE`,
            `0xafd871f684f21ab9d7137608c71808f83d75e6fc`
        );
        await arbazaar.deployed();
        console.log(`Arbazaar.sol deployed:`, arbazaar.address);
    }

    const TemplateNFT = await hre.ethers.getContractFactory(`TemplateNFT`);
    const templatenft = await TemplateNFT.deploy(
        arbazaar.address,
        `Arbazaar`,
        `ARBZ`
    );
    await templatenft.deployed();
    console.log(`NFT.sol deployed:`, templatenft.address);

    let config = `export const addressMockBUCK = \`${(network.name === `hardhat` || network.name === `localhost` || network.name === `arbitrumRinkeby`) ? (network.name === `arbitrumRinkeby` ? buck.address : mockbuck.address) : `0xafd871f684f21ab9d7137608c71808f83d75e6fc`}\`;\nexport const addressArbazaar = \`${arbazaar.address}\`;\nexport const addressTemplateNFT = \`${templatenft.address}\`;\n`;

    fs.writeFileSync(`../ui/config.js`, JSON.parse(JSON.stringify(config)));
};

main().then(() => process.exit(0)).catch((error) => {
    console.error(error);
    process.exit(1);
});
