pragma solidity ^0.8.0;

contract Lottery {
    address public owner;
    uint public ticketPrice;
    uint public prizePool;
    uint public drawDate;
    mapping(address => uint) public tickets;

    event LotteryDrawn(address winner, uint prize);

    constructor(uint _ticketPrice, uint _prizePool, uint _drawDate) {
        owner = msg.sender;
        ticketPrice = _ticketPrice;
        prizePool = _prizePool;
        drawDate = _drawDate;
    }

    function buyTicket() payable public {
        require(msg.value == ticketPrice, "Ticket price is not correct");
        require(block.timestamp < drawDate, "Lottery draw has already taken place");

        tickets[msg.sender]++;
        prizePool += msg.value;
    }

    function drawLottery() public {
        require(msg.sender == owner, "Only the owner can draw the lottery");
        require(block.timestamp >= drawDate, "Lottery draw has not taken place yet");

        uint winningTicket = uint(keccak256(abi.encodePacked(block.timestamp, block.difficulty, block.coinbase, block.gaslimit, block.number))) % (tickets.length + 1);

        address winner;
        uint i = 0;
        for (address player : tickets) {
            if (i == winningTicket) {
                winner = player;
                break;
            }
            i++;
        }

        uint prize = prizePool;
        prizePool = 0;

        emit LotteryDrawn(winner, prize);
        payable(winner).transfer(prize);
    }
}
