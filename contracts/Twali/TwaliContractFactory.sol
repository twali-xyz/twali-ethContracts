//SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;


// Implmenentation Contract import -- Twali's Base
import "./TwaliContract.sol";

// library imports
import "@openzeppelin/contracts/proxy/Clones.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract TwaliContractFactory is Ownable {

        // address public immutable ADMIN_ADDRESS;
        // Implementation contract
        address public contractImplementation;
        // Mapping of all clone deployments
        mapping(address => address[]) public cloneContracts;

        // Event trigger when new contract clone created
        event TwaliCloneCreated(address cloneAddress, address contractImplementation);

        constructor(address _contractImplementation) {
                contractImplementation = _contractImplementation;
                // ADMIN_ADDRESS = msg.sender;
        }

        // Creates a contract clone of the Logic `Implementation` Contract
        function createTwaliClone(string memory _sowMetaData) external onlyOwner {
                // require(msg.sender == owner, "Only admin of Twali can clone contract");
                address payable clone = payable(Clones.clone(contractImplementation));
                
                // Contract Initialized with admin address (Twali, SOW metadata URI, timestamp it was created)
                TwaliContract(clone).initialize(owner(), _sowMetaData, block.timestamp);
                cloneContracts[msg.sender].push(clone);
                emit TwaliCloneCreated(clone, contractImplementation);
        }

        // Return all created Clone contracrts
        function returnContractClones(address _admin) external view returns (address[] memory){
                return cloneContracts[_admin];
        }
}
