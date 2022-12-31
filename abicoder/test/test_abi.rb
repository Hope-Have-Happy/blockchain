##
#  to run use
#     ruby -I ./lib -I ./test test/test_abi.rb


require 'helper'


###
#  adapted from
#    https://github.com/cryptape/ruby-ethereum-abi/blob/master/test/abi_test.rb

def encode_primitive_type( type, arg )
  ABI.encoder.encode_primitive_type( type, arg )
end

def encode_bool( arg )       ABI.encoder.encode_bool( arg ); end
def encode_uint( arg, sub )  ABI.encoder.encode_uint( arg, sub ); end
def encode_int( arg, sub )   ABI.encoder.encode_int( arg, sub ); end
def encode_bytes( arg, sub ) ABI.encoder.encode_bytes( arg, sub ); end
def encode_address( arg )    ABI.encoder.encode_address( arg ); end


## note: different encode_int also defined int ABI::Utils!!!!





class TestAbi < MiniTest::Test

  Type  = ABI::Type
  ValueOutOfBounds = ABI::ValueOutOfBounds



  def decode_primitive_type( type, data )
    ABI.decoder.decode_primitive_type( type, data )
  end


  BYTE_ZERO = "\x00".b


  def test_use_abi_class_methods
    types = ['int256']
    args  = [1]
    assert_equal ABI.encode(types, args),
                 ABI::Encoder.new.encode(types, args)
  end

  def test_abi_encode_var_sized_array
    bytes = BYTE_ZERO * 32 * 3
     types = ['address[]']
     args = [[BYTE_ZERO * 20] * 3]
    assert_equal "#{ABI::Utils.zpad_int(32)}#{ABI::Utils.zpad_int(3)}#{bytes}",
                 ABI.encode(types, args)
  end

  def test_abi_encode_fixed_sized_array
    types  = ['uint16[2]']
    args   = [[5,6]]
    assert_equal "#{ABI::Utils.zpad_int(5)}#{ABI::Utils.zpad_int(6)}",
                  ABI.encode( types, args)
  end

  def test_abi_encode_signed_int
    args = [1]
    assert_equal args,  ABI.decode(['int8'], ABI.encode(['int8'], args))

    args = [-1]
    assert_equal args, ABI.decode(['int8'], ABI.encode(['int8'], args))
  end




  def test_abi_encode_primitive_type
    type = Type.parse( 'bool' )
    assert_equal ABI::Utils.zpad_int(1), encode_primitive_type(type, true)
    assert_equal ABI::Utils.zpad_int(0), encode_primitive_type(type, false)

    assert_equal ABI::Utils.zpad_int(1), encode_bool( true )
    assert_equal ABI::Utils.zpad_int(0), encode_bool( false )


    type = Type.parse( 'uint8' )
    assert_equal ABI::Utils.zpad_int(255), encode_primitive_type(type, 255)
    assert_raises(ValueOutOfBounds) { encode_primitive_type(type, 256) }

    assert_equal ABI::Utils.zpad_int(255), encode_uint( 255, '8' )
    assert_raises(ValueOutOfBounds) { encode_uint( 256, '8' ) }



   ### todo/fix:
   ##    check for encoding e.g. BINARY/ASCII_8BIT from encode_primitive_type
   ##      should really be always  BINARY/ASCII_8BIT  - why? why not?
    type = Type.parse( 'int8' )
    assert_equal ABI::Utils.zpad("\x80", 32).b, encode_primitive_type(type, -128)
    assert_equal ABI::Utils.zpad("\x7f", 32).b, encode_primitive_type(type, 127)
    assert_raises(ValueOutOfBounds) { encode_primitive_type(type, -129) }
    assert_raises(ValueOutOfBounds) { encode_primitive_type(type, 128) }

    assert_equal ABI::Utils.zpad("\x80", 32).b, encode_int(-128, '8')
    assert_equal ABI::Utils.zpad("\x7f", 32).b, encode_int( 127, '8')
    assert_raises(ValueOutOfBounds) { encode_int( -129, '8') }
    assert_raises(ValueOutOfBounds) { encode_int( 128, '8') }



    type = Type.parse( 'bytes' )
    assert_equal "#{ABI::Utils.zpad_int(3)}\x01\x02\x03#{"\x00"*29}",
                  encode_primitive_type(type, "\x01\x02\x03")
    assert_equal "#{ABI::Utils.zpad_int(3)}\x01\x02\x03#{"\x00"*29}",
                  encode_bytes( "\x01\x02\x03", '' )


    type = Type.parse( 'bytes8' )
    assert_equal "\x01\x02\x03#{"\x00"*29}",
                 encode_primitive_type(type, "\x01\x02\x03" )
    assert_equal "\x01\x02\x03#{"\x00"*29}",
                 encode_bytes( "\x01\x02\x03", '8' )


    type = Type.parse( 'address' )
    assert_equal ABI::Utils.zpad("\xff"*20, 32), encode_primitive_type(type, "\xff"*20)
    assert_equal ABI::Utils.zpad("\xff"*20, 32).b, encode_primitive_type(type, "ff"*20)
    assert_equal ABI::Utils.zpad("\xff"*20, 32).b, encode_primitive_type(type, "0x"+"ff"*20)

    assert_equal ABI::Utils.zpad("\xff"*20, 32), encode_address( "\xff"*20 )
    assert_equal ABI::Utils.zpad("\xff"*20, 32).b, encode_address( "ff"*20 )
    assert_equal ABI::Utils.zpad("\xff"*20, 32).b, encode_address( "0x"+"ff"*20 )
  end



  def test_abi_decode_primitive_type
    type = Type.parse( 'address' )
    assert_equal 'ff'*20,
                   decode_primitive_type(type,
                   encode_primitive_type(type, "0x"+"ff"*20))

    type = Type.parse( 'bytes' )
    assert_equal "\x01\x02\x03",
                    decode_primitive_type(type,
                    encode_primitive_type(type, "\x01\x02\x03"))

    type = Type.parse( 'bytes8' )
    assert_equal ("\x01\x02\x03"+"\x00"*5),
                     decode_primitive_type(type,
                     encode_primitive_type(type, "\x01\x02\x03"))

    type = Type.parse( 'uint8' )
    assert_equal 0, decode_primitive_type(type,
                    encode_primitive_type(type, 0))
    assert_equal 255, decode_primitive_type(type,
                      encode_primitive_type(type, 255))

    type = Type.parse( 'int8' )
    assert_equal -128, decode_primitive_type(type,
                       encode_primitive_type(type, -128))
    assert_equal 127, decode_primitive_type(type,
                      encode_primitive_type(type, 127))

    type = Type.parse( 'bool' )
    assert_equal true, decode_primitive_type(type,
                       encode_primitive_type(type, true))
    assert_equal false, decode_primitive_type(type,
                        encode_primitive_type(type, false))
  end


end   ## class TestAbi
