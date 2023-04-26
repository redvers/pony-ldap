use "debug"

primitive BERSize
  fun encode(x: U32): Array[U8] val =>
    recover val Array[U8]
      let t: Array[U8] trn = Array[U8](5)
        t.>push(0x84)
      ifdef bigendian then
        t.>push_u32(x)
      else
        t.>push_u32(x.bswap())
      end
      consume t
    end

	fun decode(inc: Array[U8] val): U32 ? =>
		if ((inc(0)? and 0b10000000) == 0) then
			return inc(0)?.u32()
		end
		let bitwidth: USize = (inc(0)? and 0b0_1111111).usize()

		if (bitwidth  > 4) then error end
		if (bitwidth == 0) then error end

		var retval: U32 = 0

		ifdef bigendian then
			for f in inc.slice(1, bitwidth + 1).values() do
				retval = retval << 8
				retval = retval + f.u32()
			end
		else
			for f in inc.slice(1, bitwidth + 1).values() do
				retval = retval << 8
				retval = retval + f.u32()
			end
    end
		retval
