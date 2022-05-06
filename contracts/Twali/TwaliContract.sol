// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

contract TwaliContract is Initializable, ReentrancyGuard {

    // string public constant VERSION = "1.0.0";

    bool private isInitialized;
    /*
    * @notice Contract has four status stages.
    *   `Draft`: Contract is in draft state awating counter signing event.
    *   `Active`: Contract active for werk started.
    *   `Complete`: Contract werk is completed and paided out.
    *   `Killed`: Contract werk is canceled and no longer active.
    */
    enum Status { 
        Draft, Active, Complete, Killed
    }

    Status public currentStatus;
  
    address public owner;
    // expert address that is completion contract and recieving payment
    address public expert;
    // SOW metadata for work agreed terms 
    string public sowMetaData;
    // Werk is approved or not approved yet
    bool public werkApproved;
    // Werk has been paid out 
    bool public werkPaidOut;
    // Werk was refunded 
    bool public werkRefunded;
    // Approval if expert can withdraw from contract
    bool expertWithdraw;
    // contract creation date
    uint creationDate;
    // experts start date in contract
    uint public startDate;
    // End date for werk completion 
    uint public endDate;
    // contract amount 
    uint256 public werkPaymountAmount = 0.0 ether;


    constructor() initializer{} 

    /*
    *  Modifiers
    */ 

    // handling Owner only function calls
    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can call this function");
        _;
    }

    // validates if expert can widtdraw from contract
    modifier validateExpertWithdraw() {
        require(expertWithdraw == true, "Not approved to widthdraw from contract");
        _;
    }

    // hanlding expert function calls
    modifier onlyExpert() {
        require(msg.sender == expert, "Only the Expert can call this function");
        _;
    }
 
    // @dev initilalize() creates a clone contract in the clone factory
    // @param _adminClient the address of the contract owner/admin who is the acting client
    // @param _sowMetaData Scope of work of the contract as a IPFS string
    // @param _creationDate is passed in from clone factory as new contract is created
    function initialize(
        address _adminClient,
        string memory _sowMetaData,
        uint _creationDate
    ) public initializer {
        require(!isInitialized, "Contract is already initialized");
        require(owner == address(0), "Can't do that the contract already initialized");
        owner = _adminClient;
        sowMetaData = _sowMetaData;
        werkApproved = false;
        werkPaidOut = false;
        creationDate = _creationDate;
        currentStatus = Status.Draft;
        isInitialized = true;
    }

    // Get status of contract 
    function getCurrentStatus() public view returns (Status) {
        return currentStatus;
    }

     // Returns balance of contract
    function getBalance() public view returns (uint256) {
        return address(this).balance;
    }

    // Set end date in days for smaller short term contracts
    // @param numberOfDays is passed in to set a short length contract
    function setEndDate_Days(uint numberOfDays) internal {
        // require(now >= creationDate , "");
        endDate = startDate + (numberOfDays * 1 days);
    }

    // Set end date in weeks for longer term contracts
    // UTC 0 -- Unix
    // @param numberOfWeeks is passed in to set a longer term contract
    function setEndDate_Weeks(uint numberOfWeeks) internal {
        endDate = startDate + (numberOfWeeks * 1 weeks);
    }

    function setContractPayout(uint256 _werkPaymountAmount) internal {
        werkPaymountAmount = _werkPaymountAmount;
    }

    // Deposit funds to contract for Expert to be paid (escrow form of contract)
    function depositExpertPayment() public payable onlyOwner {
        require(werkPaymountAmount <= msg.value, "Wrong amount of ETH sent");

        emit DepoistedExpertPaynment(msg.sender, msg.value);
    }

    // @dev Add's Expert and activates Contract
    // @param _expert address of who is completing werk and reciving payment for werk completed
    // @param _numberOfDays is passed in with approved expert to set an enddate estimation
    function activateContract(address _expert, uint _numberOfDays, uint256 _werkPaymountAmount) external onlyOwner {
            require(_expert != address(0), "Can't do that");
            require(currentStatus == Status.Draft, "Contract already activated");
            expert = _expert;
            startDate = block.timestamp;
            setEndDate_Days(_numberOfDays);
            werkPaymountAmount = _werkPaymountAmount;
    
            emit ContractActivated(expert, startDate);
    }

    // Approve Expert to widtdraw from Contract
    function approveExpertWithdraw() external onlyOwner {
        require(expertWithdraw == false, "Withdraw already");
        expertWithdraw = true;
    }

    // Twali / Admin to apporve submitted Werk 
    function approveWorkSubmitted() public onlyOwner nonReentrant {
        require(werkApproved == false && currentStatus != Status.Complete, "Werk was already apporved");
        require(block.timestamp <= endDate, "Past dealine for approval");
        currentStatus = Status.Complete;
        werkApproved = true;
        uint256 balance = address(this).balance;
        werkPaymountAmount = 0;
        payable(expert).transfer(balance);
        werkPaidOut = true;

        emit ReceivedPayout(expert, balance);
    }

    // Expert to get payment post werk completion
    function getPayment() public validateExpertWithdraw onlyExpert {
        require(currentStatus == Status.Complete, "Werk is not completed to withdraw funds");
        currentStatus = Status.Complete;
        uint256 balance = address(this).balance;
        payable(msg.sender).transfer(balance);
    }

    // Refunds payment to Owner / Client of Contract 
    function refundClient() external onlyOwner nonReentrant {
        require(address(this).balance > 0, "No ETH in contract to refund");
        require(!werkRefunded);
        require(currentStatus != Status.Active, "Werk was not funded to with withdraw ETH");
        currentStatus = Status.Killed;
        uint256 balance = address(this).balance;
        werkPaymountAmount = 0;
        payable(owner).transfer(balance);
        werkRefunded = true;

        emit RefundedContract(owner, balance);
    }

    // Set Contract inactive 'killed'
    function killContract() external onlyOwner {
        require(address(this).balance == 0, "ETH still in contract can not kill contract");
        currentStatus = Status.Killed;
    }

    fallback() external payable{}

    receive() external payable{}
    // Events
    event ReceivedPayout(address, uint);
    event RefundedContract(address, uint);
    event ContractActivated(address, uint);
    event DepoistedExpertPaynment(address, uint);
}