primitive BERClassUniveral    fun apply(x: U8): U8 => x and 0b00_0_00000
primitive BERClassApplication fun apply(x: U8): U8 => x and 0b01_0_00000
primitive BERClassContext     fun apply(x: U8): U8 => x and 0b10_0_00000
primitive BERClassPrivate     fun apply(x: U8): U8 => x and 0b11_0_00000

primitive BERPrimitive        fun apply(x: U8): U8 => x and 0b00_0_00000
primitive BERConstructed      fun apply(x: U8): U8 => x and 0b00_1_00000

//primitive BERTypeInteger      fun apply(x: U8): U8 => x and 0b00_0_00010
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



