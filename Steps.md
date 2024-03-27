## My Audits Process

**Scooping:** 
1. Clone and checkout the repo.
2. Bring in the tools you want to use (Foundry in my case).
3. Install necesary depencies.
4. Compile/build to check that all files compile as intended.
5. Simple test and coverage to confirm they have done adequate test and that they work.

**Read the docs**

This is to understand the protocols related activities and get insights to the code about to be audited.

**Read the code**

This stage is usally not intensive. It's to have an understanding of each function and contracts and the entire layout. Also Using solidity metrics at this stage to get a better visual layout of the entire code.

**Tooling**
1. Slither (```slither .```)
2. Aderyn (```aderyn .```)

**Determine the Invariant**

**Write a stateless & stateful test(open and closed)**

**Manual Review**
1. Review slither and Aderyn finding
2. Careful review the audit dcope files, but this time spend more time.
3. Checkink solodit for related functions.

**Write an audit report**


