#!/bin/bash
#url='wss://shiden.api.onfinality.io/public-ws'
url='wss://rococo-contracts-rpc.polkadot.io'
#url='wss://ws.test.azero.dev'
contract_addresses=$(cargo run -- contract info --all --url $url)

IFS=$'\n' # Set the Internal Field Separator to newline to iterate through lines
for address in $contract_addresses; do
	output=$(cargo run -- contract info --url $url --contract $address 2>&1)
	echo $output
        unknown=$(echo $output | grep "Unknown")
	echo $unknown
	if [ -z $unknown ]; then
		echo "Recognized"
	else
		hash=$(echo $output |grep -oE 'Code Hash 0x[0-9a-fA-F]+' | awk '{print $3}')
		cargo run -- contract info --url $url --contract $address --binary > ./test/$hash.wasm
		wasm2wat ./test/$hash.wasm > ./test/$hash.wat
		echo "Not recognized"
	fi	
done
