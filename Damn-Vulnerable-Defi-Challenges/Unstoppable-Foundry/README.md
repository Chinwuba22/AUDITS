## DESCRIPTION OF BUG

The issue here lies in the fact that `UnstoppableVault.sol::flashloan` requires that `uint256 balanceBefore` is always equal `UnstoppableVault.sol::totalAssets()`. So if a user sends in extra tokens it will make it impoosible to enter the function. Check `TestUnstoppableVault.sol` for POC.