###
#  to run use
#     ruby -I ./lib sandbox/test_abi.rb

require 'abicoder'


class String
   ## add bin_to_hex helper method
   ##   note: String#hex already in use (is an alias for String#to_i(16) !!)
   def hexdigest() self.unpack('H*').first; end
end

def hex( hex )  # convert hex(adecimal) string  to binary string
  if ['0x', '0X'].include?( hex[0,2] )   ## cut-of leading 0x or 0X if present
    [hex[2..-1]].pack('H*')
  else
    [hex].pack('H*')
  end
end


####
# try ABI.encode

##  Encoding simple types
pp ABI.encode( [ 'uint256', 'string' ],
               [ 1234, 'Hello World' ]).hexdigest
#=> "00000000000000000000000000000000000000000000000000000000000004d2"+
#   "0000000000000000000000000000000000000000000000000000000000000040"+
#   "000000000000000000000000000000000000000000000000000000000000000b"+
#   "48656c6c6f20576f726c64000000000000000000000000000000000000000000"

## Encoding with arrays types
pp ABI.encode([ 'uint256[]', 'string' ],
              [ [1234, 5678] , 'Hello World' ]).hexdigest
#=> "0000000000000000000000000000000000000000000000000000000000000040"+
#   "00000000000000000000000000000000000000000000000000000000000000a0"+
#   "0000000000000000000000000000000000000000000000000000000000000002"+
#   "00000000000000000000000000000000000000000000000000000000000004d2"+
#   "000000000000000000000000000000000000000000000000000000000000162e"+
#   "000000000000000000000000000000000000000000000000000000000000000b"+
#   "48656c6c6f20576f726c64000000000000000000000000000000000000000000"


=begin
## todo/fix:
##   check if encoding tuple works (is implemented ???)

## Encoding complex structs (also known as tuples)
pp ABI.encode( [ 'uint256', '(uint256,string)' ],
                 [ 1234,
                  [ 5678, 'Hello World' ]
                 ] ).hexdigest
## '0x00000000000000000000000000000000000000000000000000000000000004d20000000000000000000000000000000000000000000000000000000000000040000000000000000000000000000000000000000000000000000000000000162e0000000000000000000000000000000000000000000000000000000000000040000000000000000000000000000000000000000000000000000000000000000b48656c6c6f20576f726c64000000000000000000000000000000000000000000'
=end


### try ABI.decode

##  Decoding simple types
data = hex'00000000000000000000000000000000000000000000000000000000000004d2'+
          '0000000000000000000000000000000000000000000000000000000000000040'+
          '000000000000000000000000000000000000000000000000000000000000000b'+
          '48656c6c6f20576f726c64000000000000000000000000000000000000000000'
pp ABI.decode([ 'uint256', 'string' ], data)
#=>  [1234, "Hello World"]


##  Decoding with arrays types
data = hex'0000000000000000000000000000000000000000000000000000000000000040'+
          '00000000000000000000000000000000000000000000000000000000000000a0'+
          '0000000000000000000000000000000000000000000000000000000000000002'+
          '00000000000000000000000000000000000000000000000000000000000004d2'+
          '000000000000000000000000000000000000000000000000000000000000162e'+
          '000000000000000000000000000000000000000000000000000000000000000b'+
          '48656c6c6f20576f726c64000000000000000000000000000000000000000000'
pp ABI.decode([ 'uint256[]', 'string' ], data )
#=>  [[1234, 5678], "Hello World"]


## Decoding complex structs
data = hex'00000000000000000000000000000000000000000000000000000000000004d2'+
          '0000000000000000000000000000000000000000000000000000000000000040'+
          '000000000000000000000000000000000000000000000000000000000000162e'+
          '0000000000000000000000000000000000000000000000000000000000000040'+
          '000000000000000000000000000000000000000000000000000000000000000b'+
          '48656c6c6f20576f726c64000000000000000000000000000000000000000000'
pp ABI.decode([ 'uint256', '(uint256,string)'], data)
#=> [1234, [5678, "Hello World"]]


puts "bye"