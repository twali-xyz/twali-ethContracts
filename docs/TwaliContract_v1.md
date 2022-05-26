# Twali Contract Documention

Contract Version - `1.0`

This documentation gives a general layout and insight to the contracts state, naming conventions, and functional actions that can be preformed.


## Contract State Naming Conventions
This represents users within contract that entered into agreement.
    - `owner` is the address of the acting Client/Admin that has the ability to deploy contract, add scope of werk details, and issue funds for completed and approved werk.
    - `contract_expert` is the address of the acting Expert to paid to upon completing werk for the client/admin.
    - `contract_sowMetaData` is a string URI that holds the scope of werk details off-chain in it's entirety.
    - `contract_werkApproved` a `True` or `False` value signifying if werk has been approved by client/admin.
    - `contract_werkPaidOut` a `True` or `False` value signifying if expert has been paid for werk completed.
    - `contract_werkRefunded` a `True` or `False` value signifying if client/admin has been refunded in the event the contract is canceled.
    - `contract_start_date` & `contract_end_date` are date values that represents the length of time to complete werk.
    - `contract_payment_amount` is the amount the expert will be paid for the werk that they are completing for the client/admin.

## Contract Status
The stage of where the contract is between Client/Admin & Expert.
    - `Draft:` Contract is created and in is awaiting for application pool for `Expert` selection.
    - `Active:` Contract has selected `Expert` and is funded with `ETH` for payment for werk.
    - `Complete:` Contract has been approved by `Client`, and `Expert` has recieved payment for werk.
    - `Killed:` Contract werk is canceled in draft stage or no longer active and client is refunded.

## Actions that can be preformed 
The actions that can be preformed within the contract and who can interact with them.
- **Client/Admin** can `activateContract` to add a selected Expert and specifying amount they are to paid.
- **Client/Admin** can `approveWorkSubmitted` to approve submitted werk from expert and issue payment.
- **Client/Admin** can `killDraftContract` to terminate a contract if no expert has been selected to complete werk defined in contract.
- **Client/Admin** can `killActiveContract` to terminate contract an `Active` contract and be refunded for issued payment to contract.
- **Open Public View** can `Read` the defined state variables defined above in ***Contract State Naming Conventions**.


## Contract Deployment Details

Twali's contract can be viewd on both Ethereum's Network `Mainnet` & `Rinkeby Testnet`.


- Mainnet, `TwaliContract` contract is deployed at `0x89F891cc3D8cdfe76D6dd67bbbaE00DBf52457Fa`.
- Mainent, `TwaliCloneContract` contract is deployed at `0xD45C62150aDF02ab213274569443CaEe320866fA`.

- Rinkeby, `TwaliContract` contract is deployed at [0x9FaeE1817cDD6282a090bA4b084672e4C8402a5F](https://rinkeby.etherscan.io/address/0x9FaeE1817cDD6282a090bA4b084672e4C8402a5F#code).
- Rinkeby, `TwaliCloneContract` contract is deployed at [0xD31766Bba01E3cAA21D8eb2Db8830C78940Feb26](https://rinkeby.etherscan.io/address/0xD31766Bba01E3cAA21D8eb2Db8830C78940Feb26#code)