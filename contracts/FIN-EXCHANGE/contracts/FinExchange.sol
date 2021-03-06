pragma solidity ^0.4.24;

import "../../FIN-ERC20/contracts/StandardToken.sol";
import "../../FIN-ERC20/contracts/MintableToken.sol";
import "../../OWNABLE/Ownable.sol";

/**
 * @title FinExchange
 * @dev The FinExchange contract has an ERC20Token contract address which
 * utilises transfer functions to tranfer tokens to the exchange escrow address
 */

contract FinExchange is Ownable{
    //A struct to store the seller details
    struct Seller {
        address sellerAddress;
        uint256 tokenDeposit;
    }
    mapping (bytes32 => Seller) sellers;
    event DEPOSIT(bytes32 indexed uuid,address indexed sellerAddress, uint256 tokenDeposit);
    event WITHDRAW(address[] receivers,uint256[] tokens);
    event SENT(address[] recipients,uint256[] amounts);

    MintableToken mintableToken;

    /**
    * @dev The FinExchange constructor sets the ERC20 token contract address
    * account.
    */
    constructor(MintableToken _mintableToken) public {
        mintableToken = _mintableToken;
    }

    /**
     * @dev Map a seller details to a uuid
     * @param _uuid is the unique identifer of a account
     * @param _tokens is the number of tokens the seller wants to sell
     */
    function deposit(bytes32 _uuid, address ethAddress, uint256 _tokens) public returns(bool){
        require(_uuid != "" && _tokens >0 , "Not valid parameters");
        sellers[_uuid] = Seller(ethAddress,_tokens);
        emit DEPOSIT(_uuid,ethAddress,_tokens);
        return true;
    }

    /**
     * @dev sends tokens to multiple address
     * @param _to array of addresss to send tokens
     * @param _tokens array of tokens to be sent
    */
    function withdraw(address[] _to,uint256[] _tokens) public onlyOwner{
        for(uint256 i=0; i<_to.length; i++) {
            mintableToken.transfer(_to[i],_tokens[i]);
        }
        emit WITHDRAW(_to,_tokens);
    }

    /**
     * @dev disaplys the seller details by UUID
     * @param _uuid is the unique identifer of a account
    */
    function getSeller(bytes32 _uuid) public view returns(address,uint256){
        return (sellers[_uuid].sellerAddress,sellers[_uuid].tokenDeposit);
    }

    /***
     * @dev send ethers to multiple address
     * @param _recipients array of eth addressess to send ethers
     * @param _amounts array of amounts to be sent to eth Addressess
    */
    function sendToMany(address[] _recipients, uint[] _amounts) public payable {
        uint totalAmount;
        for(uint i = 0; i< _amounts.length; i++){
            totalAmount += _amounts[i];
        }
        require(totalAmount == msg.value); //check that the amounts to be sent are equal to the total value of the transaction

        for(i = 0; i < _recipients.length; i++){
            _recipients[i].transfer(_amounts[i]);
        }
        emit SENT(_recipients,_amounts);
    }
}