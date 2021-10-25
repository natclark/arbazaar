`use strict`;

task(`faucet`, `Sends ETH to an address`).addPositionalParam(`receiver`, `The recipient address`).setAction(async ({receiver, }) => {
    if (network.name === `hardhat` || network.name === `localhost`) {
        const [sender] = await ethers.getSigners();
        const tx = await sender.sendTransaction({
            to: receiver,
            value: ethers.constants.WeiPerEther,
        });
        await tx.wait();
        console.log(`Sent 1 ETH to ${receiver}`);
    } else {
        console.log(`Wrong network. Must be hardhat (temporary) or localhost (persistent).`);
    }
});
