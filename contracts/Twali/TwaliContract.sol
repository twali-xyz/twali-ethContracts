// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "@openzeppelin/contracts/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";


contract TwaliContract is Initializable, ReentrancyGuard {

    // string public constant VERSION = "1.0.0";

    address public owner;
    // expert address that is completion contract and recieving payment
    address public contract_expert;
    // SOW metadata for work agreed terms 
    string public contract_sowMetaData;

    bool private isInitialized;
    // Werk is approved or not approved yet
    bool public contract_werkApproved; // unassigned variable has default value of 'false'
    // Werk has been paid out 
    bool public contract_werkPaidOut;
    // Werk was refunded 
    bool public contract_werkRefunded;
    // contract creation date
    uint contract_created_on;
    // experts start date in contract
    uint public contract_start_date;
    // End date for werk completion 
    uint public contract_end_date;
    // Completion Date for submitted werk
    // contract amount 
    uint256 public contract_payment_amount = 0.0 ether;

    /// @notice This contract has four 'status' stages that transitions through in a full contract cycle.
    /// Draft: Contract is in draft stage awaiting for applications and selection.
    /// Active: Contract is active and funded with pay out amount with a selected Contract Expert to complete werk.
    /// Complete: Contract werk is completed, approved by client, and Expert has recieved payment.
    /// Killed: Contract werk is canceled in draft stage or no longer active and client is refunded.
    enum Status { 
        Draft, Active, Complete, Killed
    }

    /// @notice Functions cannot be called at this time because it has passed or not in the correct stage.
    ///
    error FunctionInvalidWithCurrentStatus();
    /// @dev Status: This is a contracts current stage upon creation.
    Status public contract_currentStatus = Status.Draft;
  


    constructor() initializer{} 

    /*
    *  Modifiers
    */ 

    /// @notice onlyOwner(): This is added to selected function calls to check and ensure only the 'owner'(client) of the contract is calling the selected function.
    modifier onlyOwner() {
        require(
            msg.sender == owner, 
            "Only owner can call this function"
            );
        _;
    }

    /// @notice IsExpert(): This checks that the address being used it the expert address that is activated in the contract.
    modifier isExpert(
        address _expert
    ) {
        require(_expert == contract_expert, "Not contract expert address");
        _;
    }

    /// @notice isValid(): This checks that an address being passed into a function is a valid address.
    /// @dev isValid(): Can be used in any function call that passes in a address that is not the contract owner.
    /// @param _addr: is address string.
    modifier isValid(address _addr) {
        require(_addr != address(0), "Not a valid address");
        _;
    }

    /// @notice isStatus(): This is added to function calls can be called at certain stages,(e.g., only being able to call functions for 'Active' stage).
    /// @dev isStatus(): This is checking concurrently that a function call is being called at it's appropriate set stage order.
    /// @param _contract_currentStatus is setting the appropriate stage as a parameter check to function call.
    modifier isStatus(Status _contract_currentStatus) {
        if (contract_currentStatus != _contract_currentStatus)
            revert FunctionInvalidWithCurrentStatus();
        _;
    }


    modifier werkNotPaid() {
        require(contract_werkPaidOut != true, "Werk already paid out!");
        _;
    }


    modifier werkNotApproved() {
        require(contract_werkApproved != true, "Werk already approved!");
        _;
    }

    modifier isNotRefunded() {
        require(contract_werkRefunded != true, "Refunded already!");
        _;
    }

    /// @notice This is added to a function and once it is completed it will then move the contract to its next stage.
    /// @dev setNextStage(): Use's the function 'nextStage()' to transition to contracts next stage with one increment.
    modifier setNextStage() {
        _;
        nextStage();
    }


    // @dev initialize(): This creates a clone contract in the TwaliCloneFactory.sol contract.
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
        contract_sowMetaData = _sowMetaData;
        contract_werkApproved = false;
        contract_werkPaidOut = false;
        contract_created_on = _creationDate;
        contract_currentStatus = Status.Draft;
        isInitialized = true;
    }

    // Get status of contract 
    function getCurrentStatus() public view returns (Status) {
        return contract_currentStatus;
    }

     // @dev getBalance(): Simple get function that returns balance of contract.
    function getBalance() public view returns (uint256) {
        return address(this).balance;
    }

    // Refunds payment to Owner / Client of Contract
    // @dev refundClient():  
    function refundClient() 
        internal 
    {
        uint256 balance = address(this).balance;
        contract_payment_amount = 0;
        payable(owner).transfer(balance);
        contract_werkRefunded = true;

        emit RefundedPayment(owner, balance);
    }

    function nextStage() internal {
        contract_currentStatus = Status(uint(contract_currentStatus)+1);
    }

    // Set end date in days for smaller short term contracts
    // @param numberOfDays is passed in to set a short length contract
    function setEndDate_Days(uint numberOfDays) internal {
        // require(now >= creationDate , "");
        contract_end_date = contract_start_date + (numberOfDays * 1 days);
    }

    // Set end date in weeks for longer term contracts
    // UTC 0 -- Unix
    // @param numberOfWeeks is passed in to set a longer term contract
    function setEndDate_Weeks(uint numberOfWeeks) internal {
        contract_end_date = contract_start_date + (numberOfWeeks * 1 weeks);
    }

    function setContractPayout(uint256 _contract_payment_amount) internal {
        contract_payment_amount = _contract_payment_amount;
    }

    // Set Contract inactive 'killed'
    // @notice This will set a 'draft' contract to 'killed' stage if the contract needs to be closed.
    function killDraftContract() 
        external 
        onlyOwner
        isStatus(Status.Draft)
    {

        contract_currentStatus = Status.Killed;
    }

        // Deposit funds to contract for Expert to be paid (escrow form of contract)
    function depositExpertPayment(uint _amount) public payable {
        require(_amount <= msg.value, "Wrong amount of ETH sent");

        emit DepoistedExpertPaynment(msg.sender, msg.value);
    }

    // @dev activateContract(): Add's Expert and activates Contract
    // @param _contract_expert is the address of who is completing werk and receiving payment for werk completed.
    // @param _numberOfDays is passed in with approved expert to set an enddate estimation
    function activateContract(
        address _contract_expert, 
        uint _numberOfDays, 
        uint256 _contract_payment_amount)
        external
        payable 
        onlyOwner
        isValid(_contract_expert)
        isStatus(Status.Draft)
        setNextStage 
    { 
        contract_expert = _contract_expert;
        contract_start_date = block.timestamp;
        setEndDate_Days(_numberOfDays);
        contract_payment_amount = _contract_payment_amount;
        depositExpertPayment(_contract_payment_amount);
    

        emit ContractActivated(contract_expert, 
                               contract_start_date, 
                               contract_payment_amount);
    }

    // @notice Sets an active contract to 'killed' stage and refunds ETH in contract to the client, who is the set contract 'owner'.
    // @dev killActiveContract(): 

    function killActiveContract() 
        external 
        onlyOwner
        isNotRefunded 
        nonReentrant 
        isStatus(Status.Active) 
    {
        contract_currentStatus = Status.Killed;
        refundClient();
    }

    // Twali / Admin to apporve submitted Werk 
    function approveWorkSubmitted() 
        public 
        onlyOwner
        werkNotApproved
        werkNotPaid
        isStatus(Status.Active) 
        nonReentrant
        setNextStage 
    {
        // contract_currentStatus = Status.Complete;
        contract_werkApproved = true;
        uint256 balance = address(this).balance;
        contract_payment_amount = 0;
        payable(contract_expert).transfer(balance);
        contract_werkPaidOut = true;

        emit ReceivedPayout(contract_expert, 
                            balance, 
                            contract_werkPaidOut, 
                            contract_werkApproved);
    }


    fallback() external payable{}

    receive() external payable{}
    // Events
    event ReceivedPayout(address, uint, bool, bool);
    event RefundedPayment(address, uint);
    event ContractActivated(address, uint, uint);
    event DepoistedExpertPaynment(address, uint);
}