How-To create and send money writing API calls in bitcoind using the commandline
====================

In this example, we show how we can use bitcoind to create addresses to which we'll send money using the commandline. Our goal is to be able to understand how bitcoind works under the hood. We also want to understand the bitcoin API command set so we can continue to build more complex scripts using bitcoind. 

**Step 1: Download and install a copy of bitcoind on your server.** You may download a [copy here](http://bitcoin.org/en/download). If you wish to move really quickly, you may clone a copy of the current bitcoin development tree for testing using the following commands.

```
 git clone git@github.com:bitcoin/bitcoin.git
 cd bitcoin
 cd src
 ./bitcoind & 
```

Then tail the bitcoind log file (Mac OSX file system): 
```
tail -f ~/Library/Application\ Support/Bitcoin/debug.log
```

You will need to allow bitcoind several hours for the 12GB blockchain to download onto your computer so go make some tea.


**Step 2: create two bitcoin addresses using the bitcoind getnewaddress command and list the addresses in your wallet**
```
./bitcoind createnewaddress
./bitcoind createnewaddress
./bitcoind ./bitcoind getaddressesbyaccount ""
[
    "14PEzhUMw2BE9FQE1qaJZD4rmSVD4wGRSj",
    "18hdQ2b2a48Ap5y7ThvrRraaNXmuSn1tB"
]
```

**Step 3: Send a small amount of money to the first adress you created.** In this example, we created a bitcoin address [14PEzhUMw2BE9FQE1qaJZD4rmSVD4wGRSj](https://blockchain.info/address/14PEzhUMw2BE9FQE1qaJZD4rmSVD4wGRSj) and we sent $10.00 to that address, from our Coinbase account. Bitcoin addresses receive outputs from prior transactions. Therefore, if we want to send money, we will need to send from the address that received the small deposit of 10mBTC (0.10 BTC). To verify that your bitoind server wallet received the 10mBTC you will need to tell bitcoind to retrieve a list of transactions.
```
./bitcoind listtransactions
[
    {
        "account" : "",
        "address" : "14PEzhUMw2BE9FQE1qaJZD4rmSVD4wGRSj",
        "category" : "receive",
        "amount" : 0.01000000,
        "confirmations" : 14,
        "blockhash" : "000000000000000181d761392d663d13dd1b447bfda90d52aa2154c22f8f1891",
        "blockindex" : 85,
        "blocktime" : 1390160192,
        "txid" : "75cfdd8cb0bb99bf3eb0f4160f78a2fb27e6bd500ba90e54a9d3d86115fce2ad",
        "time" : 1390160172,
        "timereceived" : 1390160172
    }
```
In this example, we only had one transaction above. We will want to save the "txid" to move to the next step.


**Step 4: Get the transaction components of the last transaction that allowed address 14PEzhUMw2BE9FQE1qaJZD4rmSVD4wGRSj to receive the 10mBTC in bitcoins.** To receive the transaction details, we need to decode the raw txid from the appropriate transaction hash.
```
# Get the Transaction hash:
./bitcoind getrawtransaction 75cfdd8cb0bb99bf3eb0f4160f78a2fb27e6bd500ba90e54a9d3d86115fce2ad
```
```
# Which should return the following output:
0100000002709d44963689679d5e0c8a6ba6860830351b253465833ca04ca6e54c0035b239000000008b483045022019648d4105dfc96ce3867291428973433970bdc3b0f64fabf5a77ffd6211ab0b022100f6384a7bcec30c257b6ffb82375b18fda4d0962e0611082c80a1b85b4b26dda901410403a8a3fe0ff5be6ce9ca17d50aaceadf0620255e92a6d235409b5aa5189ae09734539123c00699577b34ff61db2e718e3b7f9fe535a20ce15190b0536d2f8145ffffffff599ee2e4e4a84dc7c20c2111f463f5ef83a566f93051dc9f771212ac24077e02010000008b48304502201d73801dc1de21a97be3092bc813fa52c76296589279d01f2917b207597ae1bc02210099e6ad6bbe3fc8cec6fe289044109264f53cb5394dde5ac192b1050e0e6659ce014104730264b8b1432f75dc31779c945d3241e80eb0b6b8e9c7519960a3893b541c644841c1bfef3b255a08b4fd0a019b504817f240fb49f0fd8ddbbcba5f11ad8767ffffffff0240420f00000000001976a914251d35f531d020cb69ab51519fa938e677f03a2188ac8d5b1500000000001976a914e5ffd53998e1b05139b3fd737a15f51ad535cb7288ac00000000
```
**Step 5: Convert this output into the JSON representation of the full transaction**

```
./bitcoind decoderawtransaction 0100000002709d44963689679d5e0c8a6ba6860830351b253465833ca04ca6e54c0035b239000000008b483045022019648d4105dfc96ce3867291428973433970bdc3b0f64fabf5a77ffd6211ab0b022100f6384a7bcec30c257b6ffb82375b18fda4d0962e0611082c80a1b85b4b26dda901410403a8a3fe0ff5be6ce9ca17d50aaceadf0620255e92a6d235409b5aa5189ae09734539123c00699577b34ff61db2e718e3b7f9fe535a20ce15190b0536d2f8145ffffffff599ee2e4e4a84dc7c20c2111f463f5ef83a566f93051dc9f771212ac24077e02010000008b48304502201d73801dc1de21a97be3092bc813fa52c76296589279d01f2917b207597ae1bc02210099e6ad6bbe3fc8cec6fe289044109264f53cb5394dde5ac192b1050e0e6659ce014104730264b8b1432f75dc31779c945d3241e80eb0b6b8e9c7519960a3893b541c644841c1bfef3b255a08b4fd0a019b504817f240fb49f0fd8ddbbcba5f11ad8767ffffffff0240420f00000000001976a914251d35f531d020cb69ab51519fa938e677f03a2188ac8d5b1500000000001976a914e5ffd53998e1b05139b3fd737a15f51ad535cb7288ac00000000
```

This returns the JSON details of the transaction that allowed the address to receive 10mBTC. Notice the value "ScriptPubKey" which contains the bitcoin commands that will allow funds to be released to the Transaction Input that can be matched with the RIPEMD 160 hash of the hash key. This is the encumbrance that Andreas mentions in his presentation on Multisig and bitcoin transactions [recorded on January 13, 2014](http://www.youtube.com/watch?v=K-ccC9YZ8UI): 
```
{
    "txid" : "75cfdd8cb0bb99bf3eb0f4160f78a2fb27e6bd500ba90e54a9d3d86115fce2ad",
    "version" : 1,
    "locktime" : 0,
    "vin" : [
        {
            "txid" : "39b235004ce5a64ca03c836534251b35300886a66b8a0c5e9d67893696449d70",
            "vout" : 0,
            "scriptSig" : {
                "asm" : "3045022019648d4105dfc96ce3867291428973433970bdc3b0f64fabf5a77ffd6211ab0b022100f6384a7bcec30c257b6ffb82375b18fda4d0962e0611082c80a1b85b4b26dda901 0403a8a3fe0ff5be6ce9ca17d50aaceadf0620255e92a6d235409b5aa5189ae09734539123c00699577b34ff61db2e718e3b7f9fe535a20ce15190b0536d2f8145",
                "hex" : "483045022019648d4105dfc96ce3867291428973433970bdc3b0f64fabf5a77ffd6211ab0b022100f6384a7bcec30c257b6ffb82375b18fda4d0962e0611082c80a1b85b4b26dda901410403a8a3fe0ff5be6ce9ca17d50aaceadf0620255e92a6d235409b5aa5189ae09734539123c00699577b34ff61db2e718e3b7f9fe535a20ce15190b0536d2f8145"
            },
            "sequence" : 4294967295
        },
        {
            "txid" : "027e0724ac1212779fdc5130f966a583eff563f411210cc2c74da8e4e4e29e59",
            "vout" : 1,
            "scriptSig" : {
                "asm" : "304502201d73801dc1de21a97be3092bc813fa52c76296589279d01f2917b207597ae1bc02210099e6ad6bbe3fc8cec6fe289044109264f53cb5394dde5ac192b1050e0e6659ce01 04730264b8b1432f75dc31779c945d3241e80eb0b6b8e9c7519960a3893b541c644841c1bfef3b255a08b4fd0a019b504817f240fb49f0fd8ddbbcba5f11ad8767",
                "hex" : "48304502201d73801dc1de21a97be3092bc813fa52c76296589279d01f2917b207597ae1bc02210099e6ad6bbe3fc8cec6fe289044109264f53cb5394dde5ac192b1050e0e6659ce014104730264b8b1432f75dc31779c945d3241e80eb0b6b8e9c7519960a3893b541c644841c1bfef3b255a08b4fd0a019b504817f240fb49f0fd8ddbbcba5f11ad8767"
            },
            "sequence" : 4294967295
        }
    ],
    "vout" : [
        {
            "value" : 0.01000000,
            "n" : 0,
            "scriptPubKey" : {
                "asm" : "OP_DUP OP_HASH160 251d35f531d020cb69ab51519fa938e677f03a21 OP_EQUALVERIFY OP_CHECKSIG",
                "hex" : "76a914251d35f531d020cb69ab51519fa938e677f03a2188ac",
                "reqSigs" : 1,
                "type" : "pubkeyhash",
                "addresses" : [
                    "14PEzhUMw2BE9FQE1qaJZD4rmSVD4wGRSj"
                ]
            }
        },
        {
            "value" : 0.01399693,
            "n" : 1,
            "scriptPubKey" : {
                "asm" : "OP_DUP OP_HASH160 e5ffd53998e1b05139b3fd737a15f51ad535cb72 OP_EQUALVERIFY OP_CHECKSIG",
                "hex" : "76a914e5ffd53998e1b05139b3fd737a15f51ad535cb7288ac",
                "reqSigs" : 1,
                "type" : "pubkeyhash",
                "addresses" : [
                    "1My8DWfJsVScPLDdJ2sqBf7X4xiNwMMxGf"
                ]
            }
        }
    ]
}
```

**Step 6: Create a new raw transaction that takes the folloing items:**
* **txid:** The first transaction id (Tx0) of the last transaction output to the bitcoin address 14PEzhUMw2BE9FQE1qaJZD4rmSVD4wGRSj
* **vout:** The index of the value output of the last transaction putput to the bitcoin address 14PEzhUMw2BE9FQE1qaJZD4rmSVD4wGRSj
* **2nd Bitcoin address:** This is the target bitcoin address to whom we want to send new funds or the 2nd address in our wallet: 18hdQ2b2a48Ap5y7ThvrRraaNXmuSn1tB
* **A bitcoin amount to send:** How much we want to send to the 2nd address. Here, we're going to send 9.9mBTC or 0.0099 BTC.  The remaining 0.0001 BTC will be sent as miner's fees.

```
./bitcoind createrawtransaction '[{"txid" : "75cfdd8cb0bb99bf3eb0f4160f78a2fb27e6bd500ba90e54a9d3d86115fce2ad", "vout" : 0}]' '{"18hdQ2b2a48Ap5y7ThvrRraaNXmuSn1tB": 0.0099}'
```

Will then create a transaction hash:
```
0100000001ade2fc1561d8d3a9540ea90b50bde627fba2780f16f4b03ebf99bbb08cddcf750000000000ffffffff01301b0f00000000001976a9140174d36d9361dcc497478798544e94a14097a97488ac00000000
```

**Step 7: Let's add an extra step and decode the transaction hash for the new transaction created so that we can see the components of the new transaction which should include the new ScriptPubKey for allowing funds to be sent to the new address.**

```
./bitcoind decoderawtransaction 0100000001ade2fc1561d8d3a9540ea90b50bde627fba2780f16f4b03ebf99bbb08cddcf750000000000ffffffff01301b0f00000000001976a9140174d36d9361dcc497478798544e94a14097a97488ac00000000
```
```
# The resulting JSON details of the transaction decode command.
{
    "txid" : "eaea046faaf63bfb45d4ca6871e539e76b1d2d64c3b70905c1055187c0d799e4",
    "version" : 1,
    "locktime" : 0,
    "vin" : [
        {
            "txid" : "75cfdd8cb0bb99bf3eb0f4160f78a2fb27e6bd500ba90e54a9d3d86115fce2ad",
            "vout" : 0,
            "scriptSig" : {
                "asm" : "",
                "hex" : ""
            },
            "sequence" : 4294967295
        }
    ],
    "vout" : [
        {
            "value" : 0.00990000,
            "n" : 0,
            "scriptPubKey" : {
                "asm" : "OP_DUP OP_HASH160 0174d36d9361dcc497478798544e94a14097a974 OP_EQUALVERIFY OP_CHECKSIG",
                "hex" : "76a9140174d36d9361dcc497478798544e94a14097a97488ac",
                "reqSigs" : 1,
                "type" : "pubkeyhash",
                "addresses" : [
                    "18hdQ2b2a48Ap5y7ThvrRraaNXmuSn1tB"
                ]
            }
        }
    ]
}
```
**Step 8: Sign the raw transaction.** We are running a local version of bitcoind which hosts our wallet and our privatekey. Thus, we can sign this new transaction with one command that thakes the transaction hash the txid, the vou8,t and the ScriptPubKey hash or the txid from the Coinbase wallet transaction we first decoded in Step 5.
```
./bitcoind signrawtransaction 0100000001ade2fc1561d8d3a9540ea90b50bde627fba2780f16f4b03ebf99bbb08cddcf750000000000ffffffff01301b0f00000000001976a9140174d36d9361dcc497478798544e94a14097a97488ac00000000 '[{"txid" : "75cfdd8cb0bb99bf3eb0f4160f78a2fb27e6bd500ba90e54a9d3d86115fce2ad", "vout" : 0, "scriptPubKey" : "76a914251d35f531d020cb69ab51519fa938e677f03a2188ac"}]'
{
    "hex" : "0100000001ade2fc1561d8d3a9540ea90b50bde627fba2780f16f4b03ebf99bbb08cddcf75000000006a473044022051ed66aeee7d48631e410b974c257fddac052cdda4603680831afb261a3ba49202201fb745a58e76ac1da2edfc099755038d407cb4b9016164dd32ef43cf26d0e6c5012103863c4605e63c8b7b5816a11080467849c2722bfc8572a9b642954b788359ae6bffffffff01301b0f00000000001976a9140174d36d9361dcc497478798544e94a14097a97488ac00000000",
    "complete" : true
}
```			

**Step 9: Now, send the rawtransaction to bitcoind to make the first confirmation that the new output should receive the 9mBTC amount.**
```
./bitcoind sendrawtransaction 0100000001ade2fc1561d8d3a9540ea90b50bde627fba2780f16f4b03ebf99bbb08cddcf75000000006a473044022051ed66aeee7d48631e410b974c257fddac052cdda4603680831afb261a3ba49202201fb745a58e76ac1da2edfc099755038d407cb4b9016164dd32ef43cf26d0e6c5012103863c4605e63c8b7b5816a11080467849c2722bfc8572a9b642954b788359ae6bffffffff01301b0f00000000001976a9140174d36d9361dcc497478798544e94a14097a97488ac00000000
```
```
# Output from bitcoind will be hash of the transaction
fa525bf9c8aca03ad68dec3053da761a202b9ef5ab422faa4d7eb3515bd9acdf
```

**Step 10: Checkfor the transaction in your bitcoind as confirmed and propogated to the bitcoin network via other nodes.** Below, 25 confirmations were received after 1 hour of this transaction being sent, but we only needed to wait 10 minutes for the first confirmation. Each node in the network verifies this transaction commands that we just completed for the "create" and "sign" steps above.
```
./bitcoind listtransactions "" 1
[
    {
        "account" : "",
        "address" : "18hdQ2b2a48Ap5y7ThvrRraaNXmuSn1tB",
        "category" : "send",
        "amount" : -0.00990000,
        "fee" : -0.00010000,
        "confirmations" : 25,
        "blockhash" : "0000000000000001c84248016305e35e729e41a270a2e285ea0e5e2d168125fe",
        "blockindex" : 125,
        "blocktime" : 1390169919,
        "txid" : "fa525bf9c8aca03ad68dec3053da761a202b9ef5ab422faa4d7eb3515bd9acdf",
        "time" : 1390169296,
        "timereceived" : 1390169296
    }
]
```
