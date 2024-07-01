## DESCRIPTION OF BUG

The issue here lies in the fact that `FlashLoanReceiver.sol` gives `NaiveReceiverLenderPool.sol` approvals by passing it in it's constructor and there is no check in `NaiveReceiverLenderPool.sol::flashloan` on who calls the function making it possible for anyone to call the function. So an attacker can simple call the `NaiveReceiverLenderPool.sol::flashloan` multiple times pass as the `IERC3156FlashBorrower receiver` any contract which has given `NaiveReceiverLenderPool.sol` allowance. Check the `TestHackFlashLoan.sol` file for POC.
