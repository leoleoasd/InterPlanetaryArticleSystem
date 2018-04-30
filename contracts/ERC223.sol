pragma solidity ^0.4.9;

import "./ERC223_Base.sol";
import "./ContractReceiver.sol";

 /**
 * ERC23 token by Dexaran
 *
 * https://github.com/Dexaran/ERC23-tokens
 */


 /* https://github.com/LykkeCity/EthereumApiDotNetCore/blob/master/src/ContractBuilder/contracts/token/SafeMath.sol */
contract SafeMath {
    uint256 constant public MAX_UINT256 =
    0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF;

    function safeAdd(uint256 x, uint256 y) constant internal returns (uint256 z) {
        if (x > MAX_UINT256 - y) throw;
        return x + y;
    }

    function safeSub(uint256 x, uint256 y) constant internal returns (uint256 z) {
        if (x < y) throw;
        return x - y;
    }

    function safeMul(uint256 x, uint256 y) constant internal returns (uint256 z) {
        if (y == 0) return 0;
        if (x > MAX_UINT256 / y) throw;
        return x * y;
    }
}

//示例的智能合约代码
contract ERC223Token is ERC223, SafeMath {

  mapping(address => uint) balances;

  string public name;
  string public symbol;
  uint8 public decimals;
  uint256 public totalSupply;


  // 获取token的名称
  function name() constant returns (string _name) {
      return name;
  }
  // 获取token的符号
  function symbol() constant returns (string _symbol) {
      return symbol;
  }
  // 获取token精确到小数点后的位数
  function decimals() constant returns (uint8 _decimals) {
      return decimals;
  }
  // 获取token的发布总量
  function totalSupply() constant returns (uint256 _totalSupply) {
      return totalSupply;
  }


  // 当用户或其他合同想要转移资金时调用的功能。
  function transfer(address _to, uint _value, bytes _data, string _custom_fallback) returns (bool success) {
    //如果to是合约
    if(isContract(_to)) {
        if (balanceOf(msg.sender) < _value) throw; //如果当前的余额不够就抛出
        balances[msg.sender] = safeSub(balanceOf(msg.sender), _value);//发送者的余额做减法
        balances[_to] = safeAdd(balanceOf(_to), _value); //接收者的余额做加法
        ContractReceiver receiver = ContractReceiver(_to);   //初始化接收合约，构造函数参数为接收者的合约地址
        receiver.call.value(0)(bytes4(sha3(_custom_fallback)), msg.sender, _value, _data);
        Transfer(msg.sender, _to, _value, _data);
        return true;
    }
    else {
        return transferToAddress(_to, _value, _data);
    }
}


  // 当用户或其他合同想要转移资金时调用的功能。
  function transfer(address _to, uint _value, bytes _data) returns (bool success) {

    if(isContract(_to)) {
        return transferToContract(_to, _value, _data);
    }
    else {
        return transferToAddress(_to, _value, _data);
    }
}

  // 类似于ERC20传输的标准功能传输，没有_data。
  // 由于向后兼容性原因而增加。
  function transfer(address _to, uint _value) returns (bool success) {

    //类似于没有_data的ERC20传输的标准功能传输
    //由于向后兼容性原因而增加
    bytes memory empty;
    if(isContract(_to)) {//如果是合约
        return transferToContract(_to, _value, empty);
    }
    else {
        return transferToAddress(_to, _value, empty);
    }
}

  //组装定地址字节码。 如果存在字节码，那么_addr是一个合约。
  function isContract(address _addr) private returns (bool is_contract) {
      uint length;
      assembly {
            //检索目标地址上的代码大小，这需要汇编
            length := extcodesize(_addr)
      }
      return (length>0);
    }

  //当传递目标是一个地址时调用函数
  function transferToAddress(address _to, uint _value, bytes _data) private returns (bool success) {
    if (balanceOf(msg.sender) < _value) throw;
    balances[msg.sender] = safeSub(balanceOf(msg.sender), _value);
    balances[_to] = safeAdd(balanceOf(_to), _value);
    Transfer(msg.sender, _to, _value, _data);
    return true;
  }

  //当传递目标是一个合约时调用函数
  function transferToContract(address _to, uint _value, bytes _data) private returns (bool success) {
    if (balanceOf(msg.sender) < _value) throw;
    balances[msg.sender] = safeSub(balanceOf(msg.sender), _value);
    balances[_to] = safeAdd(balanceOf(_to), _value);
    ContractReceiver receiver = ContractReceiver(_to);
    receiver.tokenFallback(msg.sender, _value, _data); //必须要调用这个回调
    Transfer(msg.sender, _to, _value, _data);
    return true;
}


  //得到_owner的余额
  function balanceOf(address _owner) constant returns (uint balance) {
    return balances[_owner];
  }
}
