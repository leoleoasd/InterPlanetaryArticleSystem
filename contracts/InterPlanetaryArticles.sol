pragma solidity ^0.4.9;
import "./ERC223.sol";
contract InterPlanetaryArticles is ERC223Token{
    string public name = "IPA Token";
    string public symbol = "IPAT";
    uint8 public decimals = 10;
    uint256 public totalSupply = 1e40;
    uint public tokenPrice = 1e4;
    address public owner;

    function InterPlanetaryArticles() public{
        owner = msg.sender;
    }

    modifier onlyowner(){
        require(msg.sender == owner);
        _;
    }

    function () public payable{
        uint tokenbuy = msg.value / tokenPrice;
        require(tokenbuy > 0);
        balances[msg.sender]=safeAdd(balances[msg.sender],tokenbuy);
    }

    function buy() public payable returns(uint){
        uint tokensbuy = msg.value / tokenPrice;
        require(tokensbuy > 0);
        balances[msg.sender]=safeAdd(balances[msg.sender],tokensbuy);
        return tokensbuy;
    }

    function transfer() public onlyowner{
        owner.transfer(this.balance);
    }

    function addBalance(uint money,address addr) public onlyowner returns (bool){
        balances[addr]=safeAdd(balances[addr],money);
        bytes memory empty;
        emit Transfer(msg.sender, addr, money, empty);
        return true;
    }

    function ckye() public onlyowner returns(uint){

    }

}
