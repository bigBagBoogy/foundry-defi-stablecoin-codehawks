# BBB where were we?

Writing a new invariant: invariant_userCanNeverRedeemMoreThanTheirCollateral
Writing a new getter @ line:307
//vm.deal(user, amountCollateral); // do we need this? probably not

Test idea: Can we deposit 1000USD worth of ETH and then redeem 1000USD of BTC?

# end BBB

[FAIL. Reason: Arithmetic over/underflow]
[Sequence]
sender=0x7e4a4154d260f6d4a97c105d883667319dd6a613 addr=[test/fuzz/Handler.t.sol:Handler]0x2a9e8fa175f45b235efddd97d2727741ef4eee63 calldata=depositCollateral(uint256,uint256), args=[22684029450969151516589027285 **\*\***\*\***\*\***\*\***\*\***\*\***\*\*** etc etc

TO AI: This contract is written in version 0.8.19. And: Solidity 0.8 checks overflow/underflow by default 8. In other words, if you are using >= 0.8 , there might not need to import and use the SafeMath library anymore. So come there has been a "[FAIL. Reason: Arithmetic over/underflow]"?

AI: You are correct that starting from Solidity version 0.8.0, arithmetic overflow and underflow are checked by default, and the `SafeMath` library is no longer required for arithmetic operations on `uint` and `int` types. Solidity 0.8.0 introduced new arithmetic overflow and underflow protection mechanisms to improve the safety of smart contracts.

However, despite these built-in checks, there are still scenarios where arithmetic overflow and underflow can occur even in Solidity 0.8.0 and later versions. Here are some possibilities:

1. **External Calls**: If the contract interacts with other contracts or libraries, especially those written in older Solidity versions, they may not have the same overflow/underflow checks. The failure could be due to incorrect interactions with external contracts.

2. **Custom Arithmetic Operations**: Although Solidity checks for overflow/underflow in basic arithmetic operations, custom arithmetic operations using large numbers might still be susceptible to overflow or underflow.

3. **Unchecked Math in Libraries**: If the contract imports and uses external libraries (not SafeMath) that perform arithmetic operations, those libraries might not have the same level of overflow/underflow protection.

4. **Casting**: If there are explicit type conversions (casting) between `uint` and `int` or between different integer types, it could lead to unexpected results.

5. **Assembly and Low-Level Operations**: Smart contracts can use assembly or low-level operations that may bypass some of the built-in overflow/underflow checks.

To find the exact cause of the failure, the contract's code and its interactions with other contracts or libraries should be carefully reviewed. It's also essential to consider any external factors like blockchain state changes, inputs from users, oracles, and chain data.

When encountering such issues, it's recommended to use extensive unit testing, including corner

cases and boundary inputs, to ensure the contract functions as expected and to catch any edge cases where arithmetic overflow/underflow might still occur. Additionally, auditing the contract code by a security expert can help identify potential issues and vulnerabilities.

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
