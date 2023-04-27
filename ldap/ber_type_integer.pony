use "debug"
use "format"

primitive BERTypeInteger
  fun encode(x: I64): Array[U8] val ? =>
    if (false) then error end
    if (x == 0) then return [ 0x02 ; 0x01 ; 0x00 ] end

    var mask: U8 = 0b00000000
    if (x < 0) then
      mask = 0b11111111
    end

    let ax: Array[U8] trn = recover trn Array[U8].init(0, 8) end
    var bytewidth: USize = 0
    ifdef littleendian then
      ax.update_u64(0, x.u64().bswap())?
    else
      ax.update_u64(0, x.u64())?
    end
    while (bytewidth < 8) do
      if ((ax(bytewidth)? == mask)) then
        bytewidth = bytewidth + 1
        continue
      end
      if ((mask == 0) and ((ax(bytewidth)? and 0b10000000) == 0b10000000)) then
        bytewidth = bytewidth - 1
        break
      end
      break
    end

    let aax: Array[U8] trn = recover trn Array[U8] end
    aax.push(0x02)
    aax.push(8 - bytewidth.u8())
    aax.append((consume ax).trim(bytewidth))
    consume aax

  fun display(s: Array[U8] val) =>
    let t: String trn = recover trn String end
    for f in s.values() do
      t.append(Format.int[U8](f where fmt = FormatHexBare, prec = 2) + " ")
    end
    Debug.out(consume t)


//    recover val Array[U8]
//      let t: Array[U8] trn = Array[U8](len.usize() + 6)
//      t.push(0x004)
//      t.copy_from(BERSize.encode(len), 0, 1, 5)
//      match x
//      | let arr: Array[U8] val => t.copy_from(arr, 0, 6, len.usize())
//      | let str: String val    => t.copy_from(str.array(), 0, 6, len.usize())
//      end
//      consume t
//    end
//
//	fun decode(inc: Array[U8] val): (Array[U8] val, Array[U8] val) ? =>
//		(var len: U32, var data: Array[U8] val) = BERSize.decode(inc.trim(1))?
//		(data.trim(0, len.usize()), data.trim(len.usize()))
