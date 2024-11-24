// SPDX-License-Identifier: MIT

// Invariants or properties of the system that should always hold

// Our invariants
// 1. The total supply of DSC should be less than the total value of collateral
// 2. Getter view functions  should never revert <- evergreen invariant

pragma solidity 0.8.19;

import { Test, console } from "forge-std/Test.sol";
import { StdInvariant } from "forge-std/StdInvariant.sol";
import { DeployDSC } from "../../script/DeployDSC.s.sol";
import { DSCEngine } from "../../src/DSCEngine.sol";
import { DecentralizedStableCoin } from "../../src/DecentralizedStableCoin.sol";
import { HelperConfig } from "../../script/HelperConfig.s.sol";
import { ERC20Mock } from "../mocks/ERC20Mock.sol";
import { Handler } from "./Handler.t.sol";

contract InvariantsTest is StdInvariant, Test {
    DeployDSC deployer;
    DSCEngine dsce;
    DecentralizedStableCoin dsc;
    HelperConfig config;
    address weth;
    address wbtc;
    Handler handler;

    function setUp() public {
        deployer = new DeployDSC();
        (dsc, dsce, config) = deployer.run();
        (,, weth, wbtc,) = config.activeNetworkConfig();
        //targetContract(address(dsce));
        handler = new Handler(dsce, dsc);
        targetContract(address(handler));
        // Hey, don't call redeemCollateral unless there is collateral to redeem
    }

    function invariant_protocolMustHaveMoreValueThanTotalSupply() public view {
        // get the value of all the collateral in the protocol
        // compare it to all the debt (dsc)
        uint256 totalSupply = dsc.totalSupply();
        console.log("total supply: ", totalSupply);
        uint256 totalWethDeposited = ERC20Mock(weth).balanceOf(address(dsce));
        uint256 totalWbtcDeposited = ERC20Mock(wbtc).balanceOf(address(dsce));

        uint256 wethValue = dsce.getUsdValue(weth, totalWethDeposited);
        console.log("weth value: ", wethValue);
        uint256 wbtcValue = dsce.getUsdValue(wbtc, totalWbtcDeposited);
        console.log("wbtc value: ", wbtcValue);

        console.log("Times mint called: ", handler.timesMintIsCalled());

        assert(wethValue + wbtcValue >= totalSupply);
    }

    // function invariant_gettersShouldNotRevert() public view {
    //     dsce.getAccountCollateralValue();
    //     dsce.getAccountInformation();
    //     dsce.getCollateralBalanceOfUser();
    //     dsce.getCollateralDeposited();
    //     dsce.getCollateralTokens();
    //     dsce.getHealthFactor();
    //     dsce.getMintedDsc();
    //     dsce.getTokenAmountFromUsd();
    //     dsce.getUsdValue();
    // }
}
