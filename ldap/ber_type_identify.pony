type BERApplication is (BERProtoBindRequest | BERProtoBindResponse | BERProtoUnbindRequest| BERProtoSearchRequest | BERProtoSearchResultEntry | BERProtoSearchResultDone | BERProtoModifyRequest| BERProtoModifyResponse | BERProtoAddRequest | BERProtoAddResponse | BERProtoDeleteRequest | BERProtoDeleteResponse | BERProtoModifyDNRequest | BERProtoModifyDNResponse | BERProtoCompareRequest | BERProtoCompareResponse | BERProtoAbandonRequest | BERProtoSearchResultReference | BERProtoExtendedRequest | BERProtoExtendedResponse | BERProtoIntermediateResponse)

type BERUniversal is ( BERTypeBoolean | BERTypeInteger | BERTypeOctetString | BERTypeNull | BERTypeEnumerated | BERTypeSequence | BERTypeSet)

type BERType is (BERApplication | BERUniversal)

primitive BERTypeIdentify
  fun identify(p: Array[U8] val): BERType ? =>
    match p(0)?
    | 0x60	=> BERProtoBindRequest
		| 0x61	=> BERProtoBindResponse
		| 0x42	=> BERProtoUnbindRequest
		| 0x63	=> BERProtoSearchRequest
		| 0x64	=> BERProtoSearchResultEntry
		| 0x65	=> BERProtoSearchResultDone
		| 0x66	=> BERProtoModifyRequest
		| 0x67	=> BERProtoModifyResponse
		| 0x68	=> BERProtoAddRequest
		| 0x69	=> BERProtoAddResponse
		| 0x4a	=> BERProtoDeleteRequest
		| 0x6b	=> BERProtoDeleteResponse
		| 0x6c	=> BERProtoModifyDNRequest
		| 0x6d	=> BERProtoModifyDNResponse
		| 0x6e	=> BERProtoCompareRequest
		| 0x6f	=> BERProtoCompareResponse
		| 0x50	=> BERProtoAbandonRequest
		| 0x73	=> BERProtoSearchResultReference
		| 0x77	=> BERProtoExtendedRequest
		| 0x78	=> BERProtoExtendedResponse
		| 0x79	=> BERProtoIntermediateResponse

		| 0b00_0_00001  => BERTypeBoolean
		| 0b00_0_00010	=> BERTypeInteger
		| 0b00_0_00100	=> BERTypeOctetString
		| 0b00_0_00101	=> BERTypeNull
		| 0b00_0_01010	=> BERTypeEnumerated
		| 0b00_1_10000	=> BERTypeSequence
		| 0b00_1_10001	=> BERTypeSet
		else
			error
		end



