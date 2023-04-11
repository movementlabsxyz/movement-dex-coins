module movement_dex::coins {
    use std::signer;
    use std::string::utf8;

    use aptos_framework::coin::{Self, MintCapability, BurnCapability};

    /// Represents test AVAX coin.
    struct AVAX {}

    /// Represents test USDC coin.
    struct USDC {}

    /// Represents test BTC coin.
    struct BTC {}

    /// Represents test ETH coin.
    struct ETH {}

    /// Storing mint/burn capabilities for `USDT` and `BTC` coins under user account.
    struct Caps<phantom CoinType> has key {
        mint: MintCapability<CoinType>,
        burn: BurnCapability<CoinType>,
    }

    /// Initializes `BTC` and `USDT` coins.
    public entry fun register_coins(token_admin: &signer) {
        init_coin<AVAX>(token_admin, b"Avalanche", b"AVAX", 8);
        init_coin<USDC>(token_admin, b"USD Coin", b"USDC", 8);
        init_coin<BTC>(token_admin, b"Bitcoin", b"BTC", 8);
        init_coin<ETH>(token_admin, b"Ethereum", b"ETH", 8);
    }

    public fun init_coin<CoinType>(
        token_admin: &signer,
        name: vector<u8>,
        symbol: vector<u8>,
        decimals: u8,
    ) {
        let (burn, freeze, mint) =
            coin::initialize<CoinType>(token_admin, utf8(name), utf8(symbol), decimals, true);

        coin::destroy_freeze_cap(freeze);

        move_to(token_admin, Caps<CoinType> { mint, burn });
    }

    /// Mints new coin `CoinType` on account `acc_addr`.
    public entry fun mint_coin<CoinType>(token_admin: &signer, acc_addr: address, amount: u64) acquires Caps {
        let token_admin_addr = signer::address_of(token_admin);
        let caps = borrow_global<Caps<CoinType>>(token_admin_addr);
        let coins = coin::mint<CoinType>(amount, &caps.mint);
        coin::deposit(acc_addr, coins);
    }

    public entry fun faucet<CoinType>(user: &signer, amount: u64) acquires Caps {
        let caps = borrow_global<Caps<CoinType>>(@movement_dex);
        let user_addr = signer::address_of(user);
        if(!coin::is_account_registered<CoinType>(user_addr)) {
            coin::register<CoinType>(user);
        };
        let coins = coin::mint<CoinType>(amount, &caps.mint);
        coin::deposit(user_addr, coins);
    }

    public entry fun register<CoinType>(user: &signer) {
        coin::register<CoinType>(user);
    }
}
