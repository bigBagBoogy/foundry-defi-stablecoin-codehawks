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

contract Invariants is StdInvariant, Test {
    DeployDSC deployer;
    DSCEngine dsce;
    DecentralizedStableCoin dsc;
    HelperConfig config;
    address weth;
    address wbtc;
    Handler handler;

    function setUp() external {
        deployer = new DeployDSC();
        (dsc, dsce, config) = deployer.run();
        (,, weth, wbtc,) = config.activeNetworkConfig();
        // targetContract(address(dsce));
        handler = new Handler(dsce, dsc);
        targetContract(address(handler));
    } 


    // bigBagBoogy: So I think this would be the most basic thing a noob would try to exploit.
    function invariant_userCanNeverRedeemMoreThanTheirCollateral() public view {
        // 1. We should first create a user.
        vm.startPrank(user);  // 1 user must do deposit  2 user must then do redeem deposit
        // 2. We should give him balance     using vm.deal?
        ERC20Mock(weth).approve(address(dsce), amountCollateral); //ChatGPT3.5 ! does this tranfer amountCollateral to user, or not yet?
        vm.deal(user, amountCollateral); // do we need this?
        (totalDscMinted, collateralValueInUsd) = dsce.getAccountInformation(user);
        console.log(collateralValueInUsd[user]); // will this print the users
        // 3. The user should deposit collateral.
                dsce.depositCollateral(address(weth), amountCollateral); //ChatGPT3.5 !  Who calls this function?

        // 4. the user should redeem more than their collateral.
        // 4a. alternatively the user should try to redeem wbtc when he has weth.
        // if we redeem, we always redeem in the collateral(either weth or wbtc) so no need for USD conversions.
        
        uint256 amountCollateral;
        uint256 amountRedeemed;

        assert(amountRedeemed <= amountCollateral); // or should we reverse this? does it matter?
    }
    function invariant_userCanNeverRedeemMoreThanTheirCollateral() public view {
    // Create a user address (you can use a helper function to do this)
    address user = address(0x...);

    // Assign balance to the user (you can use a helper function to do this)
    // For example: dsc.mint(user, 1000);

    // The user should deposit collateral (you can use the handler function to do this)
    dsce.depositCollateral(address(weth), 1);

    // Get the user's collateral balance
    uint256 amountCollateral = dsce.getCollateralBalanceOfUser(user, address(weth));

    // Try to redeem DSC tokens more than the collateral value (you can use the handler function to do this)
    // For example: dsce.redeemDsc(1000);

    // Get the user's DSC balance after redemption
    uint256 amountDsc = dsc.balanceOf(user);

    assert(amountDsc <= amountCollateral);
}

}
