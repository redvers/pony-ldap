use "debug"
use "format"

primitive BERTypeNull
  fun encode(): Array[U8] val => [ 0x05 ; 0x00 ]
	fun decode(inc: Array[U8] val): Array[U8] val ? =>
		(var len: U32, var data: Array[U8] val) = BERSize.decode(inc.trim(1))?
    if (len != 0) then display(inc); error end
		data.trim(len.usize())

  fun display(s: Array[U8] val) =>
    let t: String trn = recover trn String end
    for f in s.values() do
      t.append(Format.int[U8](f where fmt = FormatHexBare, prec = 2) + " ")
    end
    Debug.out(consume t)


