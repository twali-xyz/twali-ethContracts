// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/proxy/utils/Initializable.sol";

// TODO: Flow completion
// [x] Adding date on initalize 
// [x] date setting for completion -- not needed transaction is end date 
// [x] adding date check for completion
// [x] adding funds to contract and or Safe wallet address


contract TwaliContract is Initializable {

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

    // Status constant defaultChoice = Status.Draft;
    Status public currentStatus;
     
    address public owner;
    // expert address that is completion contract and recieving payment
    address public expert;
    // SOW metadata for work agreed terms 
    string public sowMetaData;
    // Werk is approved or not approved yet
    bool public werkApproved;
    // Werk had been paid out 
    bool public werkPaidOut;
    // contract creation date
    uint creationDate;
    // End date for werk completion 
    uint endDate;
    // Completion Date for submitted werk


    constructor() initializer{} 


    /*
    *  Modifiers
    */ 

    // hanlding expert function calls
    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can call this function");
        _;
    }

    // hanlding expert function calls
    modifier onlyExpert() {
        require(msg.sender == expert, "Only the Expert can call this function");
        _;
    }

    // // Transition status
    // modifier transitionStatus() {

    // }

    // Initilalize Clone contract - only called once in the clonefactory 
    function initialize(
        address _adminClient,
        address _expert,
        string memory _sowMetaData,
        bool _werkApproved, // move out and set in the initializer
        bool _werkPaidOut, // move out and set in the initializer
        uint _creationDate // move out and set in the initializer
    ) public initializer {
        require(!isInitialized, "Contract is already initialized");
        require(owner == address(0), "Can't do that the contract already initialized");
        owner = _adminClient;
        expert = _expert;
        sowMetaData = _sowMetaData;
        werkApproved = _werkApproved;
        werkPaidOut = _werkPaidOut;
        creationDate = _creationDate;
        currentStatus = Status.Active;
        // endDate = _endDate;
        isInitialized = true;
    }

    // Get status of contract 
    function getCurrentStatus() public view returns (Status) {
        return currentStatus;
    }


    // Set end date in days for smaller short term contracts
    function setEndDate_Days(uint numberOfDays) public onlyOwner {
        // require(now >= creationDate , "");
        endDate = block.timestamp + (numberOfDays * 1 days);
    }

    // Set end date in weeks for longer term contracts
    // UTC 0 -- Unix
    function setEndDate_Weeks(uint numberOfWeeks) public onlyOwner {
        endDate = block.timestamp + (numberOfWeeks * 1 weeks);
    }

    // Returns balance of contract
    function getBalance() public view returns (uint256) {
        return address(this).balance;
    }

    // Deposit funds to contract for Expert to be paid (escrow form of contract)
    function depositExpertPayment() public payable onlyOwner {
            // require(msg.value == amount, "Wrong amount sent");
    }


    // Twali / Admin to apporve submitted Werk 
    function approveWorkSubmitted() public onlyOwner {
        require(werkApproved == false && currentStatus != Status.Complete, "Werk was already apporved");
        require(block.timestamp <= endDate, "Past dealine for approval");
        currentStatus = Status.Complete;
        // TODO: balance to be paid == payment amount to expert
        uint256 balance = address(this).balance;
        payable(expert).transfer(balance);
    }

    // Expert to get payment post werk completion
    function getPayment() public onlyExpert {
        require(currentStatus == Status.Complete, "Werk is not completed to withdraw funds");
        currentStatus = Status.Complete;
        uint256 balance = address(this).balance;
        payable(msg.sender).transfer(balance);
    }


    // Events
    event Received(address, uint);
}