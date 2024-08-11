// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;
contract Quiz{
    struct Quiz_item {
      uint id;
      string question;
      string answer;
      uint min_bet;
      uint max_bet;
   }
    uint public cnt;
    mapping(address => uint)[] public bets;
    uint public vault_balance;
    mapping(uint256 =>Quiz_item) public q_list;
    address my;
    constructor () {
        Quiz_item memory q;
        q.id = 1;
        q.question = "1+1=?";
        q.answer = "2";
        q.min_bet = 1 ether;
        q.max_bet = 2 ether;
        addQuiz(q);
        cnt = 1;
        my = address(this);
    }
    modifier chkUser() {
        require(msg.sender != address(1));
        _;
    }
    function addQuiz(Quiz_item memory q) public chkUser{
        uint id = q.id;
        q_list[id] = q;
        cnt += 1;
        bets.push();
    }

    function getAnswer(uint quizId) public view returns (string memory){
        return q_list[quizId].answer;
    }

    function getQuiz(uint quizId) public view returns (Quiz_item memory) {
        Quiz_item memory select = q_list[quizId];
        select.answer = "";
        return select;
    }

    function getQuizNum() public view returns (uint){
        return cnt;
    }
    
    function betToPlay(uint quizId) public payable {
        require(msg.value >= q_list[quizId].min_bet && msg.value <= q_list[quizId].max_bet, "Invalid bet amount");
        bets[quizId-1][msg.sender] += msg.value;
    }

    function solveQuiz(uint quizId, string memory ans) public returns (bool) {
        string memory sol = getAnswer(quizId);
        bool res = false;
        if(keccak256(abi.encodePacked(sol)) == keccak256(abi.encodePacked(ans))){
            res = true;
            bets[quizId-1][msg.sender] = bets[quizId-1][msg.sender] * 2;
        }
        else{
            vault_balance += bets[quizId-1][msg.sender];
            bets[quizId-1][msg.sender] = 0;
        }
        return res;
    }

    function claim() public {
        address payable to = payable(msg.sender);
        to.call{value:bets[0][msg.sender]}("");
    }
    
    fallback()external payable{
        vault_balance += msg.value;
    }

}
