// SPDX-License-Identifier: MIT

// Have our invariant aka properties

// What are our invariants?

// 1. The total supply of DSC should be less than the total value of collateral
// 2. Getter view functions should never revert <- evergreen invariant

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

contract Invariants is StdInvariant, Test {
    DeployDSC deployer;
    DSCEngine dsce;
    DecentralizedStableCoin dsc;
    HelperConfig config;
    address weth;
    address wbtc;
    Handler handler;
    address public user = address(1);
    uint256 amountCollateral = 1 ether; //1e18 weth
    uint256 amountRedeemed = 2 ether; //2e18 weth

    function setUp() external {
        deployer = new DeployDSC();
        (dsc, dsce, config) = deployer.run();
        (,, weth, wbtc,) = config.activeNetworkConfig();
        // targetContract(address(dsce));
        handler = new Handler(dsce, dsc);
        targetContract(address(handler));
    }

    // bigBagBoogy: So I think this would be the most basic thing a noob would try to exploit.
    function invariant_userCanNeverRedeemMoreThanTheirCollateral() public {
        // 1. We should first create a user.
        vm.startPrank(user); // 1 user must do deposit  2 user must then do redeem deposit
        // 2. We should give him balance
        ERC20Mock(weth).mint(user, amountCollateral);
        ERC20Mock(weth).approve(address(dsce), amountCollateral);
        // 3. The user should deposit collateral.
        dsce.depositCollateral(address(weth), amountCollateral); //ChatGPT3.5 !  Who calls this function in the way this is written now? Answer: DSCEngine does this because it has been approved to do so on behalf of the user by the line: "ERC20Mock(weth).approve(address(dsce), amountCollateral);"
        uint256 collateralAmountOfUser = dsce.getCollateralAmountOfUser(user, address(weth));
        console.log(collateralAmountOfUser);
        // 4. the user should redeem more than their collateral.
        dsce.redeemCollateral(address(weth), amountRedeemed);
        collateralAmountOfUser = dsce.getCollateralAmountOfUser(user, address(weth));
        console.log(collateralAmountOfUser);
        // 4a. alternatively the user should try to redeem wbtc when he has weth.
        // if we redeem, we always redeem in the collateral(either weth or wbtc) so no need for USD conversions.

        assert(amountRedeemed <= amountCollateral); // or should we reverse this? does it matter?
    }
}
