// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract TutorialRewards {
    struct Tutorial {
        uint256 id;
        string title;
        address author;
        uint256 ratingCount;
        uint256 totalRating;
        uint256 rewardPool;
    }

    mapping(uint256 => Tutorial) public tutorials;
    mapping(address => mapping(uint256 => bool)) public hasRated;

    uint256 public nextTutorialId;
    address public owner;
    uint256 public rewardPerRating;

    event TutorialAdded(uint256 id, string title, address author);
    event TutorialRated(uint256 id, uint256 rating, address rater);
    event RewardClaimed(uint256 id, address author, uint256 reward);

    modifier onlyOwner() {
        require(msg.sender == owner, "Not authorized");
        _;
    }

    constructor(uint256 _rewardPerRating) {
        owner = msg.sender;
        rewardPerRating = _rewardPerRating;
    }

    function addTutorial(string memory _title) public {
        tutorials[nextTutorialId] = Tutorial(
            nextTutorialId,
            _title,
            msg.sender,
            0,
            0,
            0
        );
        emit TutorialAdded(nextTutorialId, _title, msg.sender);
        nextTutorialId++;
    }

    function rateTutorial(uint256 _id, uint256 _rating) public {
        require(_rating >= 1 && _rating <= 5, "Rating must be between 1 and 5");
        require(!hasRated[msg.sender][_id], "Already rated this tutorial");

        Tutorial storage tutorial = tutorials[_id];
        require(tutorial.id == _id, "Tutorial not found");

        tutorial.ratingCount++;
        tutorial.totalRating += _rating;
        tutorial.rewardPool += rewardPerRating;
        hasRated[msg.sender][_id] = true;

        emit TutorialRated(_id, _rating, msg.sender);
    }

    function claimReward(uint256 _id) public {
        Tutorial storage tutorial = tutorials[_id];
        require(tutorial.author == msg.sender, "Only author can claim rewards");
        require(tutorial.rewardPool > 0, "No rewards available");

        uint256 reward = tutorial.rewardPool;
        tutorial.rewardPool = 0;
        payable(msg.sender).transfer(reward);

        emit RewardClaimed(_id, msg.sender, reward);
    }

    function depositFunds() public payable onlyOwner {}

    function getAverageRating(uint256 _id) public view returns (uint256) {
        Tutorial storage tutorial = tutorials[_id];
        require(tutorial.ratingCount > 0, "No ratings yet");
        return tutorial.totalRating / tutorial.ratingCount;
    }
}
