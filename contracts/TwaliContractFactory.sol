//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/proxy/Clones.sol";


contract TwaliContractFactory {
        address public admin;
        address public contractImplementation;
        address[] public cloneContracts;

        event TwaliCloneCreated(address cloneAddress, address contractImplementation);

        function setImplementation(address _contractImplementation) public {
                contractImplementation = _contractImplementation;
                admin = msg.sender;
        }

        function createTwaliClone() public {
                require(msg.sender == admin, 'Only admin of Twali can clone contract');
                address clone = Clones.clone(contractImplementation);
                // init if needed
                cloneContracts.push(clone);
                emit TwaliCloneCreated(clone, contractImplementation);
        }
}