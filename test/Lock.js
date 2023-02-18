const CryptoState = artifacts.require("./CryptoState.sol");

contract("CryptoState", ([deployer, author, tipper]) => {
  let Cryptostate;

  before(async () => {
    Cryptostate = await CryptoState.deployed();
    console.log(Cryptostate)
  });

  describe("deployment", async () => {
    it("deploys successfully", async () => {
      const address = await Cryptostate.address;
      assert.notEqual(address, 0x0);
      assert.notEqual(address, "");
      assert.notEqual(address, null);
      assert.notEqual(address, undefined);
    });

    it("has a name", async () => {
      const name = await Cryptostate.nameOf();
      assert.equal(name,  "Govt of India  Cryptostate  Poratal");
    });
  
    it("putting state on Cryptostate", async () => {
      let listingPrice = await Cryptostate.getListingPrice()
      listingPrice = listingPrice.toString();
      const created = await Cryptostate.mintCryptoState("goswami  Niwas",
      "agiri5375@gmai.com",
      100,
      "city Bhopal Mp 456333",
      "0xFFcf8FDEE72ac11b5c542428B35EEF5769C409f0",
      1,{value:listingPrice}
      );
  await Cryptostate.mintCryptoState("goswami  Niwas3",
      "agiri53@gmai.com3",
      1002,
      "city Bhopal Mp 4563333",
      "0xFFcf8FDEE72ac11b5c542428B35EEF5769C409f0",
      1,{value:listingPrice}
      );
    });
  
    it("getting Cryptostate owners", async () => {
  
      let reslut = await Cryptostate.TokenownedByaddress("0xFFcf8FDEE72ac11b5c542428B35EEF5769C409f0")
      console.log('this is duck :',reslut)
    });
    it("getting Cryptostate", async () => {
  
      let reslut = await Cryptostate.allCryptostate(1)
      console.log('this is :',reslut)
    });
  });
});
