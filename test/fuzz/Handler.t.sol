// SPDX-License-Identifier: MIT
// Handler is going to narrow down the way we call functions

pragma solidity ^0.8.18;

import {Test} from "forge-std/Test.sol";
import {DSCEngine} from "../../src/DSCEngine.sol";
import {DecentralizedStableCoin} from "../../src/DecentralizedStableCoin.sol";
import {ERC20Mock} from "@openzeppelin/contracts/mocks/ERC20Mock.sol";
import {MockV3Aggregator} from "../mocks/MockV3Aggregator.sol";
import {console} from "forge-std/console.sol";

// Price Feed

contract Handler is Test {
    DSCEngine dsce;
    DecentralizedStableCoin dsc;

    ERC20Mock weth;
    ERC20Mock wbtc;

    address[] public usersWithCollateralDeposited;
    MockV3Aggregator public ethUsdPriceFeed;

    uint256 MAX_DEPOSIT_SIZE = type(uint96).max; // the max uint96 value
    uint256 public timesAmountCollateralWasZero;
    uint256 public amountOfUsersWithCollateralDeposited;
    uint256 public totalRedeemedAmountCollateral;
    uint256 public timesAmountCollateralWasRedeemed;

    constructor(DSCEngine _dscEngine, DecentralizedStableCoin _dsc) {
        dsce = _dscEngine;
        dsc = _dsc;

        address[] memory collateralTokens = dsce.getCollateralTokens();
        weth = ERC20Mock(collateralTokens[0]);
        wbtc = ERC20Mock(collateralTokens[1]);

        ethUsdPriceFeed = MockV3Aggregator(dsce.getCollateralTokenPriceFeed(address(weth)));
    }

    // function depositCollateral(uint256 collateralSeed, uint256 amountCollateral) public {
    //     ERC20Mock collateral = _getCollateralFromSeed(collateralSeed);
    //     amountCollateral = bound(amountCollateral, 1, MAX_DEPOSIT_SIZE);

    //     vm.startPrank(msg.sender);
    //     collateral.mint(msg.sender, amountCollateral);
    //     collateral.approve(address(dsce), amountCollateral);
    //     dsce.depositCollateral(address(collateral), amountCollateral);
    //     vm.stopPrank();
    //     usersWithCollateralDeposited.push(msg.sender);
    //     amountOfUsersWithCollateralDeposited++;
    // }
    // right now redeem does not get called or with 0.

    function redeemCollateral(uint256 collateralSeed, uint256 redeemAmountCollateral) public {
        ERC20Mock collateral = _getCollateralFromSeed(collateralSeed);
        uint256 maxCollateralToRedeem = dsce.getCollateralBalanceOfUser(msg.sender, address(collateral));
        redeemAmountCollateral = bound(redeemAmountCollateral, maxCollateralToRedeem, maxCollateralToRedeem + 10);
        if (redeemAmountCollateral == 0) {
            timesAmountCollateralWasZero++;
            return;
        }
        dsce.redeemCollateral(address(collateral), redeemAmountCollateral);
        totalRedeemedAmountCollateral += redeemAmountCollateral;
        timesAmountCollateralWasRedeemed++;
        //console.log("collateral: ", collateral.address);
    }

    function getTimesAmountCollateralWasZero() public view returns (uint256) {
        return (timesAmountCollateralWasZero);
    }

    function getTimesAmountCollateralWasRedeemed() public view returns (uint256) {
        return (timesAmountCollateralWasRedeemed);
    }

    function getAmountOfUsersWithCollateralDeposited() public view returns (uint256) {
        return (amountOfUsersWithCollateralDeposited);
    }

    function getTotalRedeemedAmountCollateral() public view returns (uint256) {
        return (totalRedeemedAmountCollateral);
    }

    // Helper Functions

    function _getCollateralFromSeed(uint256 collateralSeed) private view returns (ERC20Mock) {
        if (collateralSeed % 2 == 0) {
            return weth;
        }
        return wbtc;
    }
}
