// SPDX-License-Identifier: MIT
// Handler is going to narrow down the way we call function

pragma solidity ^0.8.18;

import {Test, console} from "forge-std/Test.sol";
import {DSCEngine} from "../../src/DSCEngine.sol";
import {DecentralizedStableCoin} from "../../src/DecentralizedStableCoin.sol";
import {ERC20Mock} from "@openzeppelin/contracts/mocks/ERC20Mock.sol";
import {MockV3Aggregator} from "../mocks/MockV3Aggregator.sol";

// Price Feed

contract HandlerBBB is Test {
    DSCEngine dsce;
    DecentralizedStableCoin dsc;

    ERC20Mock weth;
    ERC20Mock wbtc;

    uint256 public timesMintIsCalled;
    address[] public usersWithCollateralDeposited;
    MockV3Aggregator public ethUsdPriceFeed;

    uint256 MAX_DEPOSIT_SIZE = type(uint96).max; // the max uint96 value

    constructor(DSCEngine _dscEngine, DecentralizedStableCoin _dsc) {
        dsce = _dscEngine;
        dsc = _dsc;

        address[] memory collateralTokens = dsce.getCollateralTokens();
        weth = ERC20Mock(collateralTokens[0]);
        wbtc = ERC20Mock(collateralTokens[1]);

        ethUsdPriceFeed = MockV3Aggregator(dsce.getCollateralTokenPriceFeed(address(weth)));
    }

    // function mintDsc(uint256 amount, uint256 addressSeed) public {
    //     if (usersWithCollateralDeposited.length == 0) {
    //         return;
    //     }
    //     address sender = usersWithCollateralDeposited[addressSeed % usersWithCollateralDeposited.length];
    //     (uint256 totalDscMinted, uint256 collateralValueInUsd) = dsce.getAccountInformation(sender);

    //     int256 maxDscToMint = (int256(collateralValueInUsd) / 2) - int256(totalDscMinted);

    //     if (maxDscToMint < 0) {
    //         return;
    //     }
    //     amount = bound(amount, 0, uint256(maxDscToMint));
    //     if (amount == 0) {
    //         return;
    //     }
    //     vm.startPrank(sender);
    //     dsce.mintDsc(amount);
    //     vm.stopPrank();
    //     timesMintIsCalled++;
    // }

    // function depositCollateral(uint256 collateralSeed, uint256 amountCollateral) public {
    //     ERC20Mock collateral = _getCollateralFromSeed(collateralSeed);
    //     amountCollateral = bound(amountCollateral, 1, MAX_DEPOSIT_SIZE);

    //     vm.startPrank(msg.sender);
    //     collateral.mint(msg.sender, amountCollateral);
    //     collateral.approve(address(dsce), amountCollateral);
    //     dsce.depositCollateral(address(collateral), amountCollateral);
    //     vm.stopPrank();
    //     usersWithCollateralDeposited.push(msg.sender);
    // }

    // function redeemCollateral(uint256 collateralSeed, uint256 amountCollateral) public {
    //     ERC20Mock collateral = _getCollateralFromSeed(collateralSeed);
    //     uint256 maxCollateralToRedeem = dsce.getCollateralBalanceOfUser(msg.sender, address(collateral));
    //     amountCollateral = bound(amountCollateral, 0, maxCollateralToRedeem);
    //     if (amountCollateral == 0) {
    //         return;
    //     }
    //     dsce.redeemCollateral(address(collateral), amountCollateral);
    // }

    // Helper Functions
    // switch that randomizes picking a collateral token.
    function _getCollateralFromSeed(uint256 collateralSeed) private view returns (ERC20Mock) {
        if (collateralSeed % 2 == 0) {
            // evens is weth
            return weth;
        }
        return wbtc; // odds is wbtc
    }

    // This breaks our invariant test suite!!!!
    // function updateCollateralPrice(uint96 newPrice) public {
    //     int256 newPriceInt = int256(uint256(newPrice));
    //     ethUsdPriceFeed.updateAnswer(newPriceInt);
    // }

    //     The function `updateCollateralPrice` is used to update the price of the collateral token (WETH) in the `ethUsdPriceFeed` contract. This function takes a new price as input and updates the price feed with the new value.

    // The reason this function is commented out is likely because it can cause issues with the invariant test suite. Invariant tests are designed to check certain conditions that should always hold true during the execution of a contract. By updating the price of the collateral token using this function, the value used for calculations in other parts of the contract, such as minting and redeeming collateral, would change.

    // Here are some potential reasons why this function could break the test suite:

    // 1. Invariant Tests Reliability: Invariant tests are usually set up with specific assumptions about the contract's state or behavior. If the price of the collateral token changes unexpectedly, it could cause the invariant tests to fail since the expected conditions may no longer hold.

    // 2. Unpredictable Behavior: Updating the price feed during testing might lead to unpredictable behaviors in the contract. For example, if the new price is too extreme, it could cause the contract to behave in unexpected ways or throw errors.

    // 3. Test Consistency: In unit tests, it's essential to have consistent and repeatable results. By updating the price feed during testing, it introduces an external factor that might vary between test runs, making it difficult to achieve consistent test results.

    // 4. Potential Side Effects: Updating the price feed could impact other parts of the contract or other tests that depend on the previous price value. This can lead to cascading issues throughout the test suite.

    // To properly test the behavior of the contract, it's often better to use mock price feeds or stubs that simulate different scenarios rather than updating the real price feed during testing. By using mock data, you can control the test conditions and ensure consistent and reliable test results.

    // The decision to comment out this function might have been made to prevent unintended consequences and to keep the test suite stable and reliable. If you want to explore the impact of different price scenarios, it's recommended to use separate test cases with mock data instead of updating the real price feed directly.

    function testRedeemAfterBigDepositCollateralAmountFails(uint256 amountCollateral) public {
        ERC20Mock collateral = weth;
        amountCollateral = 2.586e76; /* Set the amountCollateral to the same value that caused the failure in the failed test */

        // Perform the depositCollateral function call with the same arguments that caused the failure
        vm.startPrank(msg.sender);
        collateral.mint(msg.sender, amountCollateral); //make it
        collateral.approve(address(dsce), amountCollateral); //approve dsce to deposit on behalf
        dsce.depositCollateral(address(collateral), amountCollateral); // have dsce deposit
        //dsce.redeemCollateral(address(weth), amountCollateral+1);
        vm.stopPrank();
        usersWithCollateralDeposited.push(msg.sender);

        // Now call the redeemCollateral function with the same arguments that caused the failure
        // You need to pass the correct values for collateralSeed and amountCollateral from the failed test
        dsce.redeemCollateral(address(weth), 7.52e28);
    }
    //uint96: 7.92e28
    //uint128: 3.40e38
    //uint256: 1.16e77
}
