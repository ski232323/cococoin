// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.27;

import {ERC1363} from "@openzeppelin/contracts/token/ERC20/extensions/ERC1363.sol";
import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {ERC20Burnable} from "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import {ERC20FlashMint} from "@openzeppelin/contracts/token/ERC20/extensions/ERC20FlashMint.sol";
import {ERC20Pausable} from "@openzeppelin/contracts/token/ERC20/extensions/ERC20Pausable.sol";
import {ERC20Permit} from "@openzeppelin/contracts/token/ERC20/extensions/ERC20Permit.sol";
import {ERC20Votes} from "@openzeppelin/contracts/token/ERC20/extensions/ERC20Votes.sol";
import {Nonces} from "@openzeppelin/contracts/utils/Nonces.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

contract CocoCoin is ERC20, ERC20Burnable, ERC20Pausable, Ownable, ERC1363, ERC20Permit, ERC20Votes, ERC20FlashMint {
    // Mapping pour stocker les adresses gelées
    mapping(address => bool) public frozenAccounts;

    // Événements
    event Frozen(address indexed target);
    event Unfrozen(address indexed target);

    constructor(address recipient, address initialOwner)
        ERC20("CocoCoin", "CCN")
        Ownable(initialOwner)
        ERC20Permit("CocoCoin")
    {
        _mint(recipient, 10 * 10 ** decimals());
    }

    // Fonctions pour pauser/dépauser
    function pause() public onlyOwner {
        _pause();
    }

    function unpause() public onlyOwner {
        _unpause();
    }

    // Fonction pour minter
    function mint(address to, uint256 amount) public onlyOwner {
        _mint(to, amount);
    }

    // Geler une adresse
    function freeze(address target) public onlyOwner {
        frozenAccounts[target] = true;
        emit Frozen(target);
    }

    // Dégeler une adresse
    function unfreeze(address target) public onlyOwner {
        frozenAccounts[target] = false;
        emit Unfrozen(target);
    }

    // Override _update pour bloquer transfert si gelé
    function _update(address from, address to, uint256 value)
        internal
        override(ERC20, ERC20Pausable, ERC20Votes)
    {
        require(!frozenAccounts[from], "CocoCoin: sender address is frozen");
        require(!frozenAccounts[to], "CocoCoin: recipient address is frozen");
        super._update(from, to, value);
    }

    // The following functions are overrides required by Solidity.
    function nonces(address owner)
        public
        view
        override(ERC20Permit, Nonces)
        returns (uint256)
    {
        return super.nonces(owner);
    }
}
