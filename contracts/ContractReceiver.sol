pragma solidity ^0.4.9;

 /*
 * Contract that is working with ERC223 tokens
 */

 contract ContractReceiver {

    struct TKN {
        address sender; //调用合约的人
        uint value;
        bytes data;
        bytes4 sig; //签名
    }


    function tokenFallback(address _from, uint _value, bytes _data){
      TKN memory tkn;
      tkn.sender = _from;
      tkn.value = _value;
      tkn.data = _data;
      uint32 u = uint32(_data[3]) + (uint32(_data[2]) << 8) + (uint32(_data[1]) << 16) + (uint32(_data[0]) << 24);
      tkn.sig = bytes4(u);

      /* tkn变量是Ether交易的msg变量的模拟
      *  tkn.sender是发起这个令牌交易的人（类似于msg.sender）
      *  tkn.value发送的令牌数（msg.value的类比）
      *  tkn.data是令牌交易的数据（类似于msg.data）
      *  tkn.sig是4字节的功能签名
      *  如果令牌事务的数据是一个函数执行
      */
    }
}
