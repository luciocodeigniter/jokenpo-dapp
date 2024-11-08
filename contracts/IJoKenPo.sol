// SPDX-License-Identifier: MIT
pragma solidity ^0.8.27;

// interface é necessária para implementação do padrão `adpter`
// que proverá meios de criar novas versões do contrato sem afetar o usuários final,
// visto que os `adpaters` apontam para contrato vigente
interface IJoKenPo {
    // enumarator com as jogadas possíveis
    // `NONE` é a jogada padrão
    enum Options {
        NONE,
        ROCK,
        PAPER,
        SCISSORS // 0, 1, 2, 3
    }

    // representa cada jogador
    struct Player {
        address wallet;
        uint32 wins;
    }

    function getResult() external view returns(string memory);

    // o `external` indica que essa função são será utilizada dentro do contrato
    // ou seja, se eu chamar essa função dentro do contrato dará erro
    // a vantagem de usar `external` é que consome menos gas
    function getBid() external view returns (uint256);

    function getCommission() external view returns(uint8);

    function setCommision(uint8 newComission) external;

    function setBid(uint256 newBid) external;

    function getBalance() external view returns (uint);

    // função é `payable`, então o usuário tem que enviar uma quantia em ether superior a `bid`
    //! note que essa função nunca é chamada dentro do contrato, por isso a deixamos como `external`
    function play(Options newChoice) external payable;

    function getLeaderBoard() external view returns (Player[] memory);
}
