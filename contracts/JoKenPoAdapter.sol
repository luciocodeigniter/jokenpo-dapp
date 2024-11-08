// SPDX-License-Identifier: MIT
pragma solidity ^0.8.27; // Define a versão do compilador Solidity a ser utilizada. 

import "./IJoKenPo.sol"; // Importa a interface IJoKenPo de outro arquivo. A interface define os métodos que o contrato deve implementar.

// O contrato `JoKenPoAdapter` atua como um adaptador para um contrato de jogo de Jokenpo.
// Ele usa a interface `IJoKenPo` para interagir com uma implementação externa de Jokenpo.
// A ideia é que a implementação de Jokenpo possa ser atualizada sem mudar o adaptador.
//! Note que esse adapter jamais podereá ser alterado depois que estiver na blockchain
contract JoKenPoAdapter {

    // Esta variável armazenará o endereço do contrato que implementa a interface `IJoKenPo`,
    // ou seja, o contrato atual/vigente
    IJoKenPo private joKenPo;

    // Endereço do proprietário do adaptador.
    // O proprietário é a pessoa que poderá realizar a atualização da implementação.
    address public immutable owner;

    // Construtor do contrato.
    // O construtor é executado apenas uma vez, quando o contrato é implantado na blockchain.
    constructor() {
        owner = msg.sender; // Define o endereço do criador do contrato como o proprietário.
    }

    function getAddress() external view returns(address) {
        return address(joKenPo);
    }

    function getResult() external view returns(string memory) {
        // só pode ser chamado se o owner já fez o upgrade do adapter
        // Se joKenPo for um contrato válido, então seu endereço será um valor diferente de 0x0.
        // ou seja, o novo contrato (a nova implementação do jogo Jokenpo) 
        // já foi implantado (deployado) na blockchain 
        // e o endereço desse contrato foi atribuído corretamente à variável joKenPo 
        // no contrato adaptador.
        require(address(joKenPo) != address(0), "You must upgrade first");
        return joKenPo.getResult();
    }

    // Função para atualizar a implementação do contrato JokenPo.
    // Somente o proprietário do contrato pode atualizar o endereço da implementação.
    function upgrade(address newImplementationAddress) external {
        // Verifica se o chamador da função é o proprietário do contrato.
        require(msg.sender == owner, "You do not have permission");

        // Verifica se o novo endereço fornecido não é zero (não pode ser um endereço vazio).
        require(
            newImplementationAddress != address(0),
            "Empty address is not permitted"
        );

        // Atualiza a instância de `IJoKenPo` com o novo endereço fornecido.
        // realiza uma conversão de tipo (casting) para transformar 
        // o endereço (newImplementationAddress) no tipo do contrato IJoKenPo. 
        // Essa conversão permite que o contrato JoKenPoAdapter interaja com o novo contrato 
        // de Jokenpo através da interface IJoKenPo.
        joKenPo = IJoKenPo(newImplementationAddress);
    }
}
