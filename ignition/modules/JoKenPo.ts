// This setup uses Hardhat Ignition to manage smart contract deployments.
// Learn more about it at https://hardhat.org/ignition

import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";

const JoKenPoModule = buildModule("JoKenPoModule", (m) => {
  const joKenPo = m.contract("JoKenPo");
  return { joKenPo };
});

export default JoKenPoModule;
