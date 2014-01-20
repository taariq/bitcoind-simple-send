#!/usr/local/bin/ruby

require 'json'

# source transactions with indices: [{"txid":txid,"vout":n},...] 
src = JSON.parse ARGV[0]

# destination address
dest = ARGV[1]

# total amount
amount = 0.0

# for each source ouput, sum value and collect pubkey
src.each_with_index do |out, i|
  tx = JSON.parse %x( bitcoind getrawtransaction #{out["txid"]} 1 )
  txout = tx["vout"][out["vout"]]
  amount += txout["value"]
  src[i]["scriptPubKey"] = txout["scriptPubKey"]["hex"]
end

# set some coin aside for the transaction fee
fee = 0.0001
amount -= fee

# create unsigned transaction
unsigned_tx = %x( bitcoind createrawtransaction '#{src.to_json}' '{"#{dest}":#{amount}}' ).chop

# sign it
signed_tx = JSON.parse %x( bitcoind signrawtransaction '#{unsigned_tx}' '#{src.to_json}' )

# check that signature succeeded
if signed_tx["complete"] == false
  puts "error: transaction not signed"
  exit 1
end

# send transaction
new_tx = %x( bitcoind sendrawtransaction '#{signed_tx["hex"]}' )
puts "tx: #{new_tx}"

