export const addressMockBUCK = `0xafd871f684f21ab9d7137608c71808f83d75e6fc`;
export const addressArbazaar = `0x73471f4b65e8eDf4BbfA633D101f6Edb469b3A33`;
export const addressTemplateNFT = `0x2Edb24376A1A1Fc884D4eC1b29563085407DE0A2`;
export const keysCovalent = [`ckey_f02916bdd2b04038bc0808fb3bc`, `ckey_d352c426da2440829b38a40d615`, `ckey_af946cfd1d184e7b838b34a3074`, `ckey_68459dac8a6e4e65b467bea20eb`];

export const COVALENT_KEY = () => {
    return keysCovalent[Math.floor(Math.random() * 4)];
};
