// time lock contract
// limited withdrawal amounts in a certain time period

// @todo: multisig withdrawals
// @todo: sms notifications
import './Libraries/SafeMath.sol';

pragma solidity 0.4.23;

contract SafeContract {
	 using SafeMath for uint256;

	address owner;
	mapping (address => Safe) mySafe;

	event Withdrawal(address _addr, uint _value);

	struct Safe{
		uint balance;
		uint resetTime; // eg. 1 week, 1 month
		uint maxWithdrawal; //max withdrawal allowed within a time period
		uint canWithdraw;
		uint lastReset;
	}

	constructor() public {
		owner = msg.sender;
	}

	function init(uint _resetTime, uint _maxWithdrawal) public payable {
		mySafe[msg.sender].balance = msg.value;
		mySafe[msg.sender].resetTime = _resetTime;
		mySafe[msg.sender].maxWithdrawal = _maxWithdrawal;
		mySafe[msg.sender].canWithdraw = _maxWithdrawal;
		mySafe[msg.sender].lastReset = block.timestamp;
	}

	function deposit() public payable {
		mySafe[msg.sender].balance = mySafe[msg.sender].balance.add(msg.value);
	}

	function withdraw(address _to, uint _value) public  {
		if(now - mySafe[msg.sender].resetTime > mySafe[msg.sender].lastReset){
			require(mySafe[msg.sender].maxWithdrawal >= _value);
			mySafe[msg.sender].lastReset = now;
		}
		else {
			require(mySafe[msg.sender].canWithdraw >= _value);
		}
		mySafe[msg.sender].canWithdraw = mySafe[msg.sender].canWithdraw.sub(_value);
		_to.transfer(_value);
		emit Withdrawal(_to, _value);
	}
}