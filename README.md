# NewRussiaToken (NRT)

**Chain:** Polygon (Chain ID: 137)  
**Contract:** [0xE61FEb2c3278A6094571ce12177767221cA4b661](https://polygonscan.com/address/0xE61FEb2c3278A6094571ce12177767221cA4b661)  
**Decimals:** 18  
**Symbol:** NRT  
**Website:** [newrussiatoken.netlify.app](https://newrussiatoken.netlify.app/)  

---

## 🎯 Project Mission
NewRussiaToken (NRT) is a blockchain-based platform designed to support independent Russian organizations through cryptocurrency donations.

Donors receive a **non-transferable commemorative token (NRT)** as proof of their support.  
This asset is **not tradable** and serves purely as a reputational badge.

---

## ⚙️ How the Smart Contract Works

### NRT Token
- **Non-Transferable:** `transfer` and `transferFrom` are disabled — NRT cannot be sold or sent to others.
- **Burnable:** Holders can destroy (burn) their tokens voluntarily.
- **Minting on Donation:** Donors receive NRT equivalent to the donation amount in USD (USDT value).

### Donation Process
1. User calls `donate` or `donatePreset`, specifying token and amount.
2. Funds are sent only to **whitelisted recipients**.
3. Donation amount is converted to a USDT equivalent (based on admin-set rates).
4. NRT is minted to the donor’s address.

---

## 📋 Whitelists
- **Token Whitelist:** USDT, USDC, DAI (ERC20 on Polygon).
- **Recipient Whitelist:** Only verified beneficiary addresses can receive donations.

---

## 🔐 Security
- **Re-entrancy protection** with `nonReentrant` modifier.
- **Overflow protection** via Solidity 0.8.x built-in checks.
- **Safe ERC20 handling** compatible with tokens like USDT.

---

## 📎 Resources
- **Smart Contract:** [Polygonscan Verified Code](https://polygonscan.com/address/0xE61FEb2c3278A6094571ce12177767221cA4b661#code)
- **Website:** [newrussiatoken.netlify.app](https://newrussiatoken.netlify.app/)
- **Snapshot Voting:** [snapshot.box/#/s:newrussia.eth](https://snapshot.box/#/s:newrussia.eth)
- **GitHub Discussions:** [github.com/NRT314/donate-site/discussions](https://github.com/NRT314/donate-site/discussions)

---

## 📜 License
MIT License
