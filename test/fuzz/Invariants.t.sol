// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import {Test, console} from "forge-std/Test.sol";
import {StdInvariant} from "forge-std/StdInvariant.sol";
import {DeployDSC} from "../../script/DeployDSC.s.sol";
import {DSCEngine} from "../../src/DSCEngine.sol";
import {DecentralizedStableCoin} from "../../src/DecentralizedStableCoin.sol";
import {HelperConfig} from "../../script/HelperConfig.s.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {Handler} from "./Handler.t.sol";
import {StdCheats} from "forge-std/StdCheats.sol";
import {ERC20Mock} from "@openzeppelin/contracts/mocks/ERC20Mock.sol";

contract InvariantsTest is StdInvariant, Test {
    DeployDSC deployer;
    DSCEngine dsce;
    DecentralizedStableCoin dsc;
    HelperConfig helperConfig;
    address ethUsdPriceFeed;
    address btcUsdPriceFeed;
    address weth;
    address wbtc;
    Handler handler;

    function setUp() external {
        deployer = new DeployDSC(); // we run the deploy script which will run the HelperConfig(), DecentralizedStableCoin(), and the DSCEngine().
        (dsc, dsce, helperConfig) = deployer.run(); //running deploy will return (dsc, dsce, helperConfig) objects. (DecentralizedStableCoin, DSCEngine, HelperConfig)
        (ethUsdPriceFeed,, weth, wbtc,) = helperConfig.activeNetworkConfig();
        handler = new Handler(dsce, dsc);
        targetContract(address(handler));
    }

    // function invariant_ProtocolMustHaveMoreThanTotalSupply() public view {
    //     uint256 totalSupply = dsc.totalSupply();
    //     uint256 totalWethDeposited = IERC20(weth).balanceOf(address(dsce));
    //     uint256 totalWbtcDeposited = IERC20(wbtc).balanceOf(address(dsce));
    //     uint256 wethValue = dsce.getUsdValue(weth, totalWethDeposited);
    //     uint256 wbtcValue = dsce.getUsdValue(wbtc, totalWbtcDeposited);
    //     uint256 amountRedeemed = dsce.getUsdValue(weth, totalWethDeposited + totalWbtcDeposited);
    //     uint256 timesAmountCollateralWasZero = handler.getTimesAmountCollateralWasZero();
    //     uint256 amountOfUsersWithCollateralDeposited = handler.getAmountOfUsersWithCollateralDeposited();
    //     uint256 totalCollateralDeposited = wethValue + wbtcValue;
    //     //321231955747157833148424860484000
    //     //319072302902107591761300334681000

    //     console.log("totalSupply:", totalSupply);
    //     console.log("totalWethDeposited:", totalWethDeposited);
    //     console.log("totalWbtcDeposited:", totalWbtcDeposited);
    //     console.log("wethValue:", wethValue);
    //     console.log("wbtcValue:", wbtcValue);
    //     console.log("amountRedeemed:", amountRedeemed);
    //     console.log("timesAmountCollateralWasZero: ", timesAmountCollateralWasZero);
    //     console.log("amountOfUsersWithCollateralDeposited: ", amountOfUsersWithCollateralDeposited);
    //     console.log("totalCollateralDeposited: ", totalCollateralDeposited);

    //     assert(wethValue + wbtcValue >= totalSupply);

    // }

    function invariant_userCanNeverRedeemMoreThanTheirCollateral() public view {
        // uint256 totalSupply = dsc.totalSupply();
        uint256 totalWethDeposited = IERC20(weth).balanceOf(address(dsce));
        uint256 totalWbtcDeposited = IERC20(wbtc).balanceOf(address(dsce));
        uint256 wethValue = dsce.getUsdValue(weth, totalWethDeposited);
        uint256 wbtcValue = dsce.getUsdValue(wbtc, totalWbtcDeposited);
        // uint256 amountRedeemed = dsce.getUsdValue(weth, totalWethDeposited + totalWbtcDeposited);
        uint256 timesAmountCollateralWasZero = handler.getTimesAmountCollateralWasZero();
        uint256 amountOfUsersWithCollateralDeposited = handler.getAmountOfUsersWithCollateralDeposited();
        uint256 totalCollateralDeposited = wethValue + wbtcValue;
        uint256 totalRedeemedAmountCollateral = handler.getTotalRedeemedAmountCollateral();
        uint256 timesAmountCollateralWasRedeemed = handler.getTimesAmountCollateralWasRedeemed();
        //321231955747157833148424860484000
        //319072302902107591761300334681000

        // console.log("totalSupply:", totalSupply);
        // console.log("totalWethDeposited:", totalWethDeposited);
        // console.log("totalWbtcDeposited:", totalWbtcDeposited);
        // console.log("wethValue:", wethValue);
        // console.log("wbtcValue:", wbtcValue);
        // console.log("amountRedeemed:", amountRedeemed);
        console.log("timesAmountCollateralWasZero: ", timesAmountCollateralWasZero);
        console.log("amountOfUsersWithCollateralDeposited: ", amountOfUsersWithCollateralDeposited);
        console.log("totalCollateralDeposited: ", totalCollateralDeposited);
        console.log("totalRedeemedAmountCollateral: ", totalRedeemedAmountCollateral);
        console.log("timesAmountCollateralWasRedeemed: ", timesAmountCollateralWasRedeemed);

        assert(totalRedeemedAmountCollateral <= totalCollateralDeposited);
    }

    // function invariant_userCanNeverRedeemMoreThanTheirCollateral() public view {
    //     amountRedeemed[user] =
    //     amountCollateral[user] = s_collateralDeposited[token][user]
    //     console.log("timesAmountCollateralWasZero: ", timesAmountCollateralWasZero);
    //     console.log("amountCollateral: ", amountCollateral);
    //     console.log("usersWithCollateralDeposited: ", usersWithCollateralDeposited.length);

    //     assert(amountRedeemed[user] <= amountCollateral[user]);
    // }
}

// bigBagBoogy: So I think this would be the most basic thing a noob would try to exploit.
// function invariant_userCanNeverRedeemMoreThanTheirCollateral() public {
//     // 1. We should first create a user.
//     vm.startPrank(user); // 1 user must do deposit  2 user must then do redeem deposit
//     // 2. We should give him balance
//     ERC20Mock(weth).mint(user, amountCollateral);
//     ERC20Mock(weth).approve(address(dsce), amountCollateral);
//     // 3. The user should deposit collateral.
//     dsce.depositCollateral(address(weth), amountCollateral); //ChatGPT3.5 !  Who calls this function in the way this is written now? Answer: DSCEngine does this because it has been approved to do so on behalf of the user by the line: "ERC20Mock(weth).approve(address(dsce), amountCollateral);"
//     uint256 collateralAmountOfUser = dsce.getCollateralAmountOfUser(user, address(weth));
//     console.log(collateralAmountOfUser);
//     // 4. the user should redeem more than their collateral.
//     dsce.redeemCollateral(address(weth), amountRedeemed);
//     collateralAmountOfUser = dsce.getCollateralAmountOfUser(user, address(weth));
//     console.log(collateralAmountOfUser);
//     // 4a. alternatively the user should try to redeem wbtc when he has weth.
//     // if we redeem, we always redeem in the collateral(either weth or wbtc) so no need for USD conversions.

// assert(amountRedeemed <= amountCollateral); // with the hardcoded values here this should always fail.
// }
