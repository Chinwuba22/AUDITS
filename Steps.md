## My Audits Process

**Scooping:** 

1. Clone and checkout the repo.
2. Bring in the tools you want to use (Foundry in my case).
3. Install necesary depencies.
4. Compile/build to check that all files compiles as intended.
5. Simple test and coverage to confirm they have done adequate test and that they work.
6. Also use coverage glutters to see the part of the code that was not tested. [How?](https://x.com/nisedo_/status/1703803338326704217?s=46)
7. Use Mark Files extension to highlight all files in scope. [How?](https://x.com/0x3b33/status/1822891695236681974?s=46)

**Read the docs**

This is to understand the protocols related activities and get insights to the code about to be audited.

**Read the code**

This stage is usally not intensive. It's to have an understanding of each function and contracts and the entire layout. 
Solidity metrics is also used at this stage to get a better visual layout of the entire code.

**Tooling**
1. Slither (```slither .```)
2. Aderyn (```aderyn .```)

**Determine the Invariant in case of a private audit**

**Write a stateless & stateful test(open and closed) if not written yet or read the test if its available in case of a private audit**

**Go through the docs again**

**Manual Review**
1. Review slither and Aderyn finding
2. Careful review the audit scope files, but this time spend more time with intention to find quality bugs.
3. Checking solodit for findings with related protocols.

**Write an audit report**


