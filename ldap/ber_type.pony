primitive BERClassUniveral    fun apply(x: U8): U8 => x and 0b00_0_00000
primitive BERClassApplication fun apply(x: U8): U8 => x and 0b01_0_00000
primitive BERClassContext     fun apply(x: U8): U8 => x and 0b10_0_00000
primitive BERClassPrivate     fun apply(x: U8): U8 => x and 0b11_0_00000

primitive BERPrimitive        fun apply(x: U8): U8 => x and 0b00_0_00000
primitive BERConstructed      fun apply(x: U8): U8 => x and 0b00_1_00000

primitive BERTypeBoolean      fun apply(x: Bool): Array[U8] val =>
    if (x == true) then
      [0b00_0_00001 ; 0x01 ; 0xff]
    else
      [0b00_0_00001 ; 0x01 ; 0x00]
    end

primitive BERTypeInteger      fun apply(x: U8): U8 => x and 0b00_0_00010
primitive BERTypeEnumerated   fun apply(x: U8): U8 => x and 0b00_0_01010
primitive BERTypeSequence     fun apply(x: U8): U8 => x and 0b00_1_10000
primitive BERTypeSet          fun apply(x: U8): U8 => x and 0b00_1_10001


primitive BERProtoBindRequest	          fun apply(): U8 => 0x60
primitive BERProtoBindResponse          fun apply(): U8 => 0x61
primitive BERProtoUnbindRequest         fun apply(): Array[U8] val => [ 0x42 ; 0x00 ]
primitive BERProtoSearchRequest         fun apply(): U8 => 0x63
primitive BERProtoSearchResultEntry     fun apply(): U8 => 0x64
primitive BERProtoSearchResultDone      fun apply(): U8 => 0x65
primitive BERProtoModifyRequest         fun apply(): U8 => 0x66
primitive BERProtoModifyResponse        fun apply(): U8 => 0x67
primitive BERProtoAddRequest            fun apply(): U8 => 0x68
primitive BERProtoAddResponse           fun apply(): U8 => 0x69
primitive BERProtoDeleteRequest         fun apply(): U8 => 0x4a
primitive BERProtoDeleteResponse        fun apply(): U8 => 0x6b
primitive BERProtoModifyDNRequest       fun apply(): U8 => 0x6c
primitive BERProtoModifyDNResponse      fun apply(): U8 => 0x6d
primitive BERProtoCompareRequest        fun apply(): U8 => 0x6e
primitive BERProtoCompareResponse       fun apply(): U8 => 0x6f
primitive BERProtoAbandonRequest        fun apply(): U8 => 0x50
primitive BERProtoSearchResultReference fun apply(): U8 => 0x73
primitive BERProtoExtendedRequest       fun apply(): U8 => 0x77
primitive BERProtoExtendedResponse      fun apply(): U8 => 0x78
primitive BERProtoIntermediateResponse  fun apply(): U8 => 0x79


primitive BERTypeNull
  fun encode(): Array[U8] val => [0x05 ; 0x00]

primitive BERTypeOctetString
  fun encode(x: (Array[U8] val | String val)): Array[U8] val =>
    let len: U32 = x.size().u32()
    recover val Array[U8]
      let t: Array[U8] trn = Array[U8](len.usize() + 5)
      t.copy_from(BERSize.encode(len), 0, 0, 5)
      match x
      | let arr: Array[U8] val => t.copy_from(arr, 0, 5, len.usize())
      | let str: String val    => t.copy_from(str.array(), 0, 5, len.usize())
      end
      consume t
    end

