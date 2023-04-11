aptos move run \
  --function-id default::coins::register \
  --type-args 0xd0d068848da0d8b1eec5755c048142c8efecf8a2ac9e319d6f502358535f2590::coins::AVAX \
  --profile user

aptos move run \
  --function-id default::coins::mint_coin \
  --args address:0xe3eaddfcc4d7436d26fef92ee39685ef176e3513dc736d116129ce055c07afac \
  --args u64:200000000000 \
  --type-args 0xd0d068848da0d8b1eec5755c048142c8efecf8a2ac9e319d6f502358535f2590::coins::AVAX
