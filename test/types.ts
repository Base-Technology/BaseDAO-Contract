import type { SignerWithAddress } from "@nomiclabs/hardhat-ethers/dist/src/signer-with-address";

import type { BaseDAO } from "../types/BaseDAO";
import type { BaseToken } from "../types/BaseToken.sol";
import type { Greeter } from "../types/Greeter";

type Fixture<T> = () => Promise<T>;

declare module "mocha" {
  export interface Context {
    greeter: Greeter;
    loadFixture: <T>(fixture: Fixture<T>) => Promise<T>;
    signers: Signers;

    baseDAO: BaseDAO;
    baseToken: BaseToken;
  }
}

export interface Signers {
  admin: SignerWithAddress;
}
