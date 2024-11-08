// SPDX-License-Identifier: MIT
pragma solidity ^0.8.27;

contract JoKenPo {
    // enumarator com as jogadas possíveis
    // `NONE` é a jogada padrão
    enum Options {
        NONE,
        ROCK,
        PAPER,
        SCISSORS // 0, 1, 2, 3
    }

    Options private choice1 = Options.NONE;

    // endereço do jogador 1 que nos ajuda a saber se alguém já iniciou o jogo
    address private player1;

    // para enviar mensagens para o usuário
    string private result = "";

    // isso se tornará `wei` na compilação do contrato
    uint256 private bid = 0.01 ether;

    uint8 private commission = 10; // percent

    // owner do contrato que não poderá ser alterado `immutable`
    // e que que é `payable`, pois receberá comissão de 10%
    address payable private immutable owner;

    // representa cada jogador
    struct Player {
        address wallet;
        uint32 wins;
    }

    // array de jogadores que ficará no `storage` do contrato
    Player[] public players;

    constructor() {
        owner = payable(msg.sender);
    }

    function getResult() external view returns(string memory) {
        return result;
    }

    // o `external` indica que essa função são será utilizada dentro do contrato
    // ou seja, se eu chamar essa função dentro do contrato dará erro
    // a vantagem de usar `external` é que consome menos gas
    function getBid() external view returns (uint256) {
        return bid;
    }

    function getCommission() external view returns(uint8) {
        return commission;
    }

    
    function setCommision(uint8 newComission) external {
        require(owner == msg.sender, "You do not have this permission");
        // também não podemos alterar o bid se tivermos um jogo em andamento
        // ou seja, o `player1` tem que estar vazio
        require(player1 == address(0), "You cannot change the commission with a game in progress");
        commission = newComission;
    }

    function setBid(uint256 newBid) external {
        require(owner == msg.sender, "You do not have this permission");
        // também não podemos alterar o bid se tivermos um jogo em andamento
        // ou seja, o `player1` tem que estar vazio
        require(player1 == address(0), "You cannot change the bid with a game in progress");
        bid = newBid;
    }

    // atualiza o array de jogadores para refletir o número de vitórias
    function updateWinner(address winner) private {
        // avaliamos se o `winner` já existe em `players`
        // caso sim, atualizamos o `wins`
        for (uint i = 0; i < players.length; i++) {
            if (players[i].wallet == winner) {
                players[i].wins++;
                return; // já retornamos
            }
        }

        // aqui ainda não foi registrado em `players`, então fazemos o `push`
        players.push(Player(winner, 1));
    }

    function finishGame(string memory newResult, address winner) private {
        address contractAddress = address(this);
        // convertemos o `winner` para `payable`
        // e transferimos a percentagem devida das apostas para o ganhador
        payable(winner).transfer((contractAddress.balance / 100) * (100 - commission));

        // e o restantes para o `owner`
        owner.transfer(contractAddress.balance);

        // atualizamos o winner
        updateWinner(winner);

        result = newResult;
        player1 = address(0);
        choice1 = Options.NONE;
    }

    function getBalance() public view returns (uint) {
        require(owner == msg.sender, "You do not have this permission");
        return address(this).balance;
    }

    // função é `payable`, então o usuário tem que enviar uma quantia em ether superior a `bid`
    //! note que essa função nunca é chamada dentro do contrato, por isso a deixamos como `external`
    function play(Options newChoice) external payable {
        // o owner não pode jogar. Isso seria injusto
        require(msg.sender != owner, "The owner cannot play");
        require(newChoice != Options.NONE, "Invalid choice");

        // não pode jogar duas vezes o mesmo jogador
        require(player1 != msg.sender, "Wait the another player");
        require(msg.value >= bid, "Invalid bid");

        // aqui testamos ainda não jogou
        if (choice1 == Options.NONE) {
            player1 = msg.sender;
            choice1 = newChoice;
            result = "Player 1 his/her option. Waiting player 2";
        }
        // aqui já temos um um jogador, portanto quem jogou agora
        // é o jogador 2. Nos resta gora fazer os testes
        // pra determinar quem ganhou
        else if (choice1 == Options.ROCK && newChoice == Options.SCISSORS) {
            finishGame("Rock breaks scissors. Player 1 won", player1);
        } else if (choice1 == Options.PAPER && newChoice == Options.ROCK) {
            finishGame("Paper wraps rock. Player 1 won", player1);
        } else if (choice1 == Options.SCISSORS && newChoice == Options.PAPER) {
            finishGame("Scissors cuts paper. Player 1 won", player1);
        } else if (choice1 == Options.SCISSORS && newChoice == Options.ROCK) {
            finishGame("Rock breaks scissors. Player 2 won", msg.sender);
        } else if (choice1 == Options.ROCK && newChoice == Options.PAPER) {
            finishGame("Paper wraps rock. Player 2 won", msg.sender);
        } else if (choice1 == Options.PAPER && newChoice == Options.SCISSORS) {
            finishGame("Scissors cuts paper. Player 2 won", msg.sender);
        } else {

            
            result = "Draw game. The prize was doubled.";

            // reiniciamos as variáveis de estado
            player1 = address(0);
            choice1 = Options.NONE;
        }
    }

    function getLeaderBoard() external view returns (Player[] memory) {
        // se temos apenas um jogador, então já retornamos os `players`
        if (players.length < 2) {
            return players;
        }

        // criamos um array temporário
        Player[] memory tempArray = new Player[](players.length);

        // fazemos o push no array temporário para cada um dos `players`
        for (uint i = 0; i < players.length; i++) {
            tempArray[i] = players[i];
        }

        // agora ordenamos criando um ranking por número de vitórias
        // usando o `implementação de Bubble Sort`
        // Loop externo que percorre todo o array até o penúltimo elemento
        for (uint i = 0; i < tempArray.length - 1; i++) {
            // Loop interno que percorre os elementos restantes, começando de i + 1
            // Isso garante que compararemos apenas elementos ainda não ordenados
            for (uint j = i + 1; j < tempArray.length; j++) {
                // Se o número de vitórias do elemento na posição i for menor que
                // o número de vitórias do elemento na posição j, realizamos uma troca
                if (tempArray[i].wins < tempArray[j].wins) {
                    // Armazena temporariamente o elemento na posição i
                    Player memory bigger = tempArray[i];
                    // Move o elemento da posição j para a posição i
                    tempArray[i] = tempArray[j];
                    // Coloca o elemento temporário (original de i) na posição j
                    tempArray[j] = bigger;
                }
            }
        }

        return tempArray;
    }
}
