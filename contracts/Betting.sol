pragma solidity 0.7.0;

contract Betting {
    
    /* DEFINING ALL THE STATE VARIABLES
       1. players - Array containing players address
       2. admin -  Contract admin
       3. totalBetAmount - Total Betting Amount from all PLayers
       4. isBetActive - Status of betting - Open, Close
       5. randomNumber - Random Number calculated to verify winners
    */
    address payable[] public  players;
    address payable public admin;
    uint256 public totalBetAmount;
    bool public isBetActive;
    bool public isAdminFeeDeducted;
    uint8 public randomNumber;
    
    /* Mapping between individual Players & their total bet amount
    */
    mapping(address => uint256) public playersTotalBet;
    
    /* Defining modifier for admin of Contract
    */
    modifier onlyAdmin() {
       require (admin == msg.sender, "Only Admin can perform this action");
        _;
    }
    
    /* Defining modifier for minimum betting amount
    */
    modifier minimumBetAmount() {
        require (msg.value >=  1 ether,"Minimum bet amount must be > 1 Ether");
        _;
    }
    
    /* Defining modifier for bet to be in Open state
    */
    modifier bettingStatus() {
        require(isBetActive == true, "Betting should be in Open state");
        _;
    }
    
    /* Defining modifier for Admin fee
    */
    modifier adminFeeDeducted() {
        require(isAdminFeeDeducted == false, "Admin Fee is already deducted once");
        _;
    }
    
    /* Defining modifier for so that Admin cannot bet amount
    */
    modifier adminNotEligible() {
        require(msg.sender != admin, "Admin is not eligible to bet");
        _;
    }
    
    /* Contract Constructor, runs once at contract deployment
        1. Setting admin of contract
        2. Betting is Open
    */
    constructor()  {
        admin = msg.sender;
        isBetActive = true;
        isAdminFeeDeducted = false;
    }

    /* This function will add players & their betting amount
        Validation - minimum betting Amount
        For Demo purpose minimum betting amount >= 1 Ether
        Adding Players address to array of players address 
        Incrementing totalBetAmount as per amount transferred by player
    */
    function betAmount() payable minimumBetAmount bettingStatus adminNotEligible public{
        players.push(msg.sender); 
        totalBetAmount = totalBetAmount + msg.value;
        playersTotalBet[msg.sender]+=msg.value;
    } 
    
    /* This function will give Smart Contract total balance amount
        Validation - only Admin can call this function
    */
    function getContractBalance() onlyAdmin public view returns(uint) {
        return address(this).balance;
    }

    /* This can be put in separate Smart Contract for code reusability
       Also we can use Chainlink - https://docs.chain.link/docs/get-a-random-number
       For Demo purpose we are not implmenting above 2
    
    // // returns a very big pseodo-random integer no.
    // function random() public view returns(uint256) {
    //     return uint8(uint256(keccak256(abi.encodePacked(block.difficulty, block.timestamp, players.length))))%100;
    // }
    */
    
    /* This function will deduct Smart Contract fee as .1% from totalBetAmount
       Validation : Only Admin can call this function
    */
    function fees() onlyAdmin adminFeeDeducted public{
        totalBetAmount = totalBetAmount - totalBetAmount/100;
        isAdminFeeDeducted = true;
    }


    /* This function will pick 2 players as winners and distribute amount as per below
       1. One winner will receive 2/3 of totalBetAmount from Contract balance
       2. Second winner will receive 1/3 of totalBetAmount from Contract balance
       3. Validation : 
                     Only Admin can call this function
                     Betting should be in open status
       4. We are generating number by calculating keccak256 of global variables available
       5. Random Number will be between 1 & 99
       6. Based on Random Number Range, only 2 players will get amount, 
       7. 3rd player will not receive any amount as per requirement specs
       8. For cross-check purpose returning Random Number, to be fair
       
       Note: Initially I thought of using odd/even number but this will be partial to 3rd player
             And one player will always be a loser
             So change the implmentation approach & adopted new one as above mentioned
             For 2 players game Odd-Even approach can be used
    */
    function selectWinner() onlyAdmin bettingStatus public{
        require(isAdminFeeDeducted == true,"Admin fee not yet deducted");
        randomNumber = uint8(uint256(keccak256(abi.encodePacked(block.difficulty, block.timestamp, players.length))))%100;

        /* DEPRECATED IMPLMENTATION as mentioned above
        
        // if (r % 2 == 0) {
        //     players[0].transfer(totalAmount*2/3);
        //     players[1].transfer(totalAmount*1/3);
        //   } 
        // else {
        //     players[1].transfer(totalAmount*2/3);
        //     players[0].transfer(totalAmount*1/3);
        // }
        */
        
        if (randomNumber >= 1 && randomNumber <= 33) {
            players[0].transfer(totalBetAmount*2/3);
            players[1].transfer(totalBetAmount*1/3);
                           } 
        else if (randomNumber > 33 && randomNumber <= 66) {
            players[1].transfer(totalBetAmount*2/3);
            players[2].transfer(totalBetAmount*1/3);
                                } 
        else {
            players[2].transfer(totalBetAmount*2/3);
            players[0].transfer(totalBetAmount*1/3);
             }
        
        totalBetAmount=0;
        isBetActive= false;
    }
 }