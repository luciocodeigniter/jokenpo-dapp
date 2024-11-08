# Jokenpo Dapp

**Jokenpo Dapp** é uma aplicação descentralizada (Dapp) que implementa o famoso jogo de Pedra, Papel e Tesoura (*Jokenpo*) em um contrato inteligente usando Solidity. Esta Dapp inclui funcionalidades administrativas que apenas o proprietário (owner) do contrato pode executar, garantindo maior controle e segurança nas operações.

## Sobre o Projeto

O **Jokenpo Dapp** foi desenvolvido para explorar a implementação de jogos em blockchain, oferecendo uma experiência de jogo justa e transparente para os usuários. As funções administrativas permitem ao owner gerenciar aspectos específicos do jogo, como redefinir pontuações ou ajustar configurações iniciais, de forma exclusiva.

## Funcionalidades

- **Jogo de Jokenpo**: Os usuários podem escolher entre Pedra, Papel ou Tesoura e competir contra outros jogadores.
- **Funções Administrativas**: Apenas o owner do contrato inteligente possui acesso a funções especiais para configuração e gerenciamento do jogo.
- **Transparência e Imutabilidade**: Todas as ações e resultados são registrados na blockchain, oferecendo confiança aos jogadores.

## Como Funciona

1. **Escolha e Jogada**: Cada jogador escolhe sua jogada (Pedra, Papel ou Tesoura) e envia essa informação para o contrato inteligente.
2. **Determinação de Resultados**: O contrato compara as jogadas e determina o vencedor com base nas regras clássicas do jogo.
3. **Funções Administrativas**: O owner pode acessar funções exclusivas para realizar ações administrativas, como redefinir pontuações ou configurar parâmetros do jogo.

## Tecnologias Utilizadas

- **Solidity**: Para a criação e implementação do contrato inteligente.
- **Hardhat**: Para compilar, testar e fazer o deploy do contrato na blockchain.
- **Web3.js**: Para a interação com a blockchain Ethereum.
- **MetaMask**: Extensão de navegador para facilitar a conexão com a carteira dos usuários.
- **Node.js** e **Express** (opcional): Backend para interagir com o contrato.

## Contribuição

Contribuições são bem-vindas! Para contribuir, faça um fork do repositório, crie uma nova branch e envie um pull request.

