import {
  time,
  loadFixture,
} from "@nomicfoundation/hardhat-toolbox/network-helpers";
import { anyValue } from "@nomicfoundation/hardhat-chai-matchers/withArgs";
import { expect } from "chai";
import hre, { ethers } from "hardhat";

describe("JoKenPo test", function () {


  enum Options {
    NONE,
    ROCK,
    PAPER,
    SCISSORS // 0, 1, 2, 3
  }

  const DEFAULT_BID = ethers.parseEther("0.01");


  async function deployFixture() {
    const [owner, player1, player2] = await hre.ethers.getSigners();
    const JoKenPo = await hre.ethers.getContractFactory("JoKenPo");
    const joKenPo = await JoKenPo.deploy();
    return { joKenPo, owner, player1, player2 };
  }

  describe("Deployment", function () {

    it("Should get leaderbord", async function () {
      const { joKenPo, owner, player1, player2 } = await loadFixture(deployFixture);

      // preciso simular uma partida

      // jogada do player1
      const player1Instance = joKenPo.connect(player1);
      await player1Instance.play(Options.PAPER, { value: DEFAULT_BID });

      // jogada do player2
      const player2Instance = joKenPo.connect(player2);
      await player2Instance.play(Options.ROCK, { value: DEFAULT_BID });

      // agora consigo pegar o leaderboard
      const leaderboard = await joKenPo.getLeaderBoard();

      expect(leaderboard.length).to.equal(1n);

      // verificamos se o primeiro no ranking é player1, visto que ele ganhou a partida
      // pois `PAPER` embrulha `ROCK`
      expect(leaderboard[0].wallet).to.equal(player1.address);

      // e também verificamos se o número de vitórias está igual a `1`
      expect(leaderboard[0].wins).to.equal(1n);
    });


    it("Should set newBid", async function () {
      const { joKenPo, owner, player1 } = await loadFixture(deployFixture);
      const newBid = ethers.parseEther("0.02");
      await joKenPo.setBid(newBid);
      const updatedBid = await joKenPo.getBid();
      expect(updatedBid).to.equal(newBid);
    });


    it("Should FAIL set newBid (permission)", async function () {
      const { joKenPo, player1 } = await loadFixture(deployFixture);
      const player1Instance = joKenPo.connect(player1);
      const newBid = ethers.parseEther("0.02");
      await expect(player1Instance.setBid(newBid))
        .to.be.revertedWith('You do not have this permission');
    });


    it("Should set newCommission", async function () {
      const { joKenPo, owner, player1 } = await loadFixture(deployFixture);
      const newCommission = 11n;
      await joKenPo.setCommision(newCommission);
      const updatedCommission = await joKenPo.getCommission();
      expect(updatedCommission).to.equal(newCommission);
    });


    it("Should FAIL set newCommission (permission)", async function () {
      const { joKenPo, player1 } = await loadFixture(deployFixture);
      const player1Instance = joKenPo.connect(player1);
      const newCommission = 12n;
      await expect(player1Instance.setCommision(newCommission))
        .to.be.revertedWith('You do not have this permission');
    });


    it("Should play alone", async function () {
      const { joKenPo, owner, player1, player2 } = await loadFixture(deployFixture);

      // preciso simular uma partida

      // jogada do player1
      const player1Instance = joKenPo.connect(player1);
      await player1Instance.play(Options.PAPER, { value: DEFAULT_BID });

      const result = await joKenPo.getResult();
      expect(result).to.equal('Player 1 his/her option. Waiting player 2');
    });


    it("Should FAIL set newBid game in progress", async function () {
      const { joKenPo, player1 } = await loadFixture(deployFixture);

      const newBid = ethers.parseEther("0.02");
      const player1Instance = joKenPo.connect(player1);
      

      // jogada do player1
      await player1Instance.play(Options.PAPER, { value: DEFAULT_BID });

      // tentamos mudar o valor da aposta com jogo acontecendo
      await expect(joKenPo.setBid(newBid))
        .to.be.revertedWith('You cannot change the bid with a game in progress');
    });

    it("Should FAIL set newCommission game in progress", async function () {
      const { joKenPo, player1 } = await loadFixture(deployFixture);

      const newCommission = 12n;
      const player1Instance = joKenPo.connect(player1);
      

      // jogada do player1
      await player1Instance.play(Options.PAPER, { value: DEFAULT_BID });

      // tentamos mudar o valor da commission com jogo acontecendo
      await expect(joKenPo.setCommision(newCommission))
        .to.be.revertedWith('You cannot change the commission with a game in progress');
    });


    // jogar juntos
    it("Should play together", async function () {
      const { joKenPo, owner, player1, player2 } = await loadFixture(deployFixture);

      // jogada do player1
      const player1Instance = joKenPo.connect(player1);
      await player1Instance.play(Options.PAPER, { value: DEFAULT_BID });

      // jogada do player2
      const player2Instance = joKenPo.connect(player2);
      await player2Instance.play(Options.ROCK, { value: DEFAULT_BID });

      const result = await joKenPo.getResult();
      expect(result).to.equal('Paper wraps rock. Player 1 won');
    });


    it("Should FAIL play with owner", async function () {
      const { joKenPo, owner, player1, player2 } = await loadFixture(deployFixture);

      // jogada do player1
      const player1Instance = joKenPo.connect(player1);
      await player1Instance.play(Options.PAPER, { value: DEFAULT_BID });

      await expect(joKenPo.play(Options.ROCK, { value: DEFAULT_BID }))
      .to.be.revertedWith('The owner cannot play');
    });

    // não pode o mesmo jogador jogar em sequência
    it("Should FAIL play twice in a row", async function () {
      const { joKenPo, owner, player1, player2 } = await loadFixture(deployFixture);

      // jogada do player1
      const player1Instance = joKenPo.connect(player1);
      await player1Instance.play(Options.PAPER, { value: DEFAULT_BID });

      await expect(player1Instance.play(Options.ROCK, { value: DEFAULT_BID }))
      .to.be.revertedWith('Wait the another player');
    });

    it("Should FAIL play with wrong bid", async function () {
      const { joKenPo, owner, player1, player2 } = await loadFixture(deployFixture);

      // jogada do player1
      const player1Instance = joKenPo.connect(player1);
      await player1Instance.play(Options.PAPER, { value: DEFAULT_BID });

      // jogada do player2
      const player2Instance = joKenPo.connect(player2);

      await expect(player2Instance.play(Options.ROCK, { value: DEFAULT_BID - 1n }))
      .to.be.revertedWith('Invalid bid');
    });

  });

});
