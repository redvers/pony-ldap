primitive BERTypeOctetString
  fun encode(x: (Array[U8] val | String val)): Array[U8] val =>
    let len: U32 = x.size().u32()
    recover val Array[U8]
      let t: Array[U8] trn = Array[U8](len.usize() + 6)
      t.push(0x004)
      t.copy_from(BERSize.encode(len), 0, 1, 5)
      match x
      | let arr: Array[U8] val => t.copy_from(arr, 0, 6, len.usize())
      | let str: String val    => t.copy_from(str.array(), 0, 6, len.usize())
      end
      consume t
    end

	fun decode(inc: Array[U8] val): (Array[U8] val, Array[U8] val) ? =>
		(var len: U32, var data: Array[U8] val) = BERSize.decode(inc.trim(1))?
		(data.trim(0, len.usize()), data.trim(len.usize()))
