module ABI
module Helpers


  SIGHASH_RX = /\A
                (0x)?
                (?<sighash>[0-9a-f]{8})
                \z/ix

  def support?( selectors, sig )
    if sig.is_a?( Interface )
      iface = sig
      iface.selectors.each do |sighash|
          unless selectors.include?( sighash )
            puts "  sighash >#{sighash}< not found in interface"
            return false
          end
      end
      true
    else
      sighash =  if m=SIGHASH_RX.match( sig )
                  m[:sighash].downcase  ## assume it's sighash (hexstring)
                 else
                  ## for convenience allow (white)spaces; auto-strip - why? why not?
                  sig = sig.gsub( /[ \r\t\n]/, '' )
                  keccak256( sig )[0,4].hexdigest
                 end

      selectors.include?( sighash ) ? true : false
    end
  end

########################
#  encoding / decoding helpers

def lpad(x, symbol, l)
  return x if x.size >= l
  symbol * (l - x.size) + x
end

def rpad(x, symbol, l)
  return x if x.size >= l
  x + symbol * (l - x.size)
end

def zpad(x, l)
  lpad( x, BYTE_ZERO, l )
end

def zpad_int(n, l=32)
  zpad( encode_int(n), l )
end

def zpad_hex(s, l=32)
  zpad( decode_hex(s), l )
end



def big_endian_to_int(s)
  s = s.sub( /\A(\x00)+/, '' )   ## keep "performance" shortcut - why? why not?
  ### todo/check - allow nil - why? why not?
  ##  raise DeserializationError, "Invalid serialization (not minimal length)" if !@size && serial.size > 0 && serial[0] == BYTE_ZERO
  s = s || BYTE_ZERO
  s.unpack("H*").first.to_i(16)
end


def int_to_big_endian(n)
       if n == 0
         BYTE_EMPTY
       else
         hex = n.to_s(16)
         hex = "0#{hex}"   if hex.size.odd?

         [hex].pack("H*")    ## note Util.hex_to_bin() "inline" shortcut
       end
end


def encode_int(n)
  raise ArgumentError, "Integer invalid or out of range: #{n}" unless n.is_a?(Integer) && n >= 0 && n <= UINT_MAX
  int_to_big_endian( n )
end


def encode_hex(b)
  raise TypeError, "Value must be an instance of String" unless b.instance_of?(String)
  b.unpack("H*").first
end

def decode_hex(str)
  raise TypeError, "Value must be an instance of string" unless str.instance_of?(String)
  raise TypeError, 'Non-hexadecimal digit found' unless str =~ /\A[0-9a-fA-F]*\z/
  [str].pack("H*")
end

def ceil32(x)
  x % 32 == 0 ? x : (x + 32 - x%32)
end
end  # module Helpers


module Utils
  extend Helpers
  ## e.g. Utils.supports?( selectors, sig ) etc.
end

end  # module ABI