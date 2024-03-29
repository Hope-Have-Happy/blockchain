###
#  to run use
#     ruby -I ./lib -I ./test test/test_base58.rb


require 'helper'


class TestBase58 < MiniTest::Test

HEX_TESTS = [
   ["00000000000000000000",                 "1111111111"],
   ["00000000000000000000123456789abcdef0", "111111111143c9JGph3DZ"],
]


def test_hex
   HEX_TESTS.each do |item|
      assert_equal item[1],  Crypto.base58( hex: item[0] )
      bin = Bytes.hex_to_bin( item[0] )
      assert_equal item[1],  Crypto.base58( bin )
    end
end


def test_bitcoin_addr
   addr_exp = '1PMycacnJaSqwwJqjawXBErnLsZ7RkXUAs'

   pkh = 'f54a5851e9372b87810a8e60cdd2e7cfd80b6e31'

   ## all-in-one
   assert_equal addr_exp, Crypto.base58check( hex: '00' + pkh )
   bin = Bytes.hex_to_bin('00' + pkh)
   assert_equal addr_exp, Crypto.base58check( bin )

   assert_equal addr_exp, Crypto::Metal.base58check( "\x00" + [pkh].pack('H*') )
end

end # class TestBase58
