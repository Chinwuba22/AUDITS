## DESCRIPTION OF BUG

The issue here lies in the fact that `UnstoppableVault.sol::flashloan` requires that `uint256 balanceBefore` is always equal `UnstoppableVault.sol::totalAssets()`. So in the possibility that this is manipulated, for example, if a user sends in extra tokens that requirement will be broken and it will result to a DOS. Check the `TestUnstoppableVault.sol` for POC.