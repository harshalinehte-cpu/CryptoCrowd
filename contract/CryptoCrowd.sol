// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @title CryptoCrowd
 * @dev A simple crowdfunding contract where users can create and fund projects.
 */
contract CryptoCrowd {
    struct Project {
        address payable owner;
        string title;
        string description;
        uint goalAmount;
        uint raisedAmount;
        bool completed;
    }

    Project[] public projects;

    event ProjectCreated(uint projectId, address owner, string title, uint goalAmount);
    event Funded(uint projectId,  address funder, uint amount);
    event ProjectCompleted(uint projectId, uint totalRaised);

    // Create a new crowdfunding project
    function createProject(string memory _title, string memory _description, uint _goalAmount) external {
        require(_goalAmount > 0, "Goal must be greater than 0");

        projects.push(Project({
            owner: payable(msg.sender),
            title: _title,
            description: _description,
            goalAmount: _goalAmount,
            raisedAmount: 0,
            completed: false
        }));

        emit ProjectCreated(projects.length - 1, msg.sender, _title, _goalAmount);
    }

    // Fund a project with Ether
    function fundProject(uint _projectId) external payable {
        require(_projectId < projects.length, "Invalid project ID");
        require(msg.value > 0, "Must send some Ether");

        Project storage p = projects[_projectId];
        require(!p.completed, "Project already completed");

        p.raisedAmount += msg.value;
        emit Funded(_projectId, msg.sender, msg.value);

        // If goal reached, mark project completed and transfer funds
        if (p.raisedAmount >= p.goalAmount) {
            p.completed = true;
            p.owner.transfer(p.raisedAmount);
            emit ProjectCompleted(_projectId, p.raisedAmount);
        }
    }

    // View all projects
    function getAllProjects() external view returns (Project[] memory) {
        return projects;
    }
}
